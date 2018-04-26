use DateTime::Parse;
use Cro::Uri;
use JSON::Pointer;
use JSON::Pointer::Relative;

class X::OpenAPI::Schema::Validate::BadSchema is Exception {
    has $.path;
    has $.reason;
    method message() {
        "Schema invalid at $!path: $!reason"
    }
}
class X::OpenAPI::Schema::Validate::Failed is Exception {
    has $.path;
    has $.reason;
    method message() {
        "Validation failed for $!path: $!reason"
    }
}

my subset StrictPositiveInt of Int where * > 0;

class OpenAPI::Schema::Validate {
    has %.formats;
    has %.add-formats;
    my grammar ECMA262Regex {...}
    my %DEFAULT-FORMAT =
        date-time => { CATCH {default {False}}; DateTime::Parse.new($_, :rule('rfc3339-date')) },
        date => { CATCH {default {False}}; DateTime::Parse.new($_, :rule('date5')) },
        time => { CATCH {default {False}}; DateTime::Parse.new($_, :rule('time2')) },
        email => { True },
        idn-email => { True },
        hostname => { True },
        idn-hostname => { True },
        ipv4 => { Cro::Uri::GenericParser.parse($_, :rule('IPv4address')) },
        ipv6 => { Cro::Uri::GenericParser.parse($_, :rule('IPv6address')) },
        uri => { CATCH {default {False}}; Cro::Uri.parse($_) },
        uri-reference => { Cro::Uri::GenericParser.parse($_, :rule<relative-ref>) },
        iri => { True },
        iri-reference => { True },
        uri-template => { Cro::Uri::URI-Template.parse($_) },
        json-pointer => { CATCH {default {False}}; JSONPointer.parse($_) },
        relative-json-pointer => { JSONPointerRelative.parse($_) },
        regex => { so ECMA262Regex.parse($_) },
        int32 => { -2147483648 <= $_ <= 2147483647 },
        int64 => { -9223372036854775808 <= $_ <= 9223372036854775807 },
        binary => { $_ ~~ Blob };

    # We'll turn a schema into a tree of Check objects that enforce the
    # various bits of validation.
    my role Check {
        # Path is used for error reporting.
        has $.path;

        # Does the checking; throws if there's a problem.
        method check($value --> Nil) { ... }
    }

    # Check implement the various properties. Per the RFC draft:
    #   Validation keywords typically operate independent of each other,
    #   without affecting each other.
    # Thus we implement them in that way for now, though it does lead to
    # some duplicate type checks.

    my class AllCheck does Check {
        has $.native = True;
        has @.checks;
        method check($value --> Nil) {
            for @!checks.kv -> $i, $c {
                $c.check($value);
                CATCH {
                    when X::OpenAPI::Schema::Validate::Failed {
                        my $path = $!native ?? .path !! "{.path}/{$i + 1}";
                        die X::OpenAPI::Schema::Validate::Failed.new:
                            :$path, reason => .reason;
                    }
                }
            }
        }
    }

    my class OrCheck does Check {
        has @.checks;
        method check($value --> Nil) {
            for @!checks.kv -> $i, $c {
                $c.check($value);
                return;
                CATCH {
                    when X::OpenAPI::Schema::Validate::Failed {}
                }
            }
            die X::OpenAPI::Schema::Validate::Failed.new:
                :$!path, :reason('Does not satisfy any check');
        }
    }

    my class OneCheck does Check {
        has @.checks;
        method check($value --> Nil) {
            my $check = False;
            for @!checks.kv -> $i, $c {
                $c.check($value);
                if $check {
                    return fail X::OpenAPI::Schema::Validate::Failed.new:
                        :$!path, :reason('Value passed more than one check');
                } else {
                    $check = True;
                }
                CATCH {
                    when X::OpenAPI::Schema::Validate::Failed {}
                }
            }
        }
    }

    my class NotCheck does Check {
        has Check $.check;
        method check($value --> Nil) {
            $!check.check($value);
            CATCH {
                when X::OpenAPI::Schema::Validate::Failed {
                    return;
                }
            }
            fail X::OpenAPI::Schema::Validate::Failed.new:
                :$!path, :reason('Value passed check check');
        }
    }

    my class StringCheck does Check {
        has $.is-blob;
        method check($value --> Nil) {
            if $!is-blob {
                unless $value ~~ Blob && $value.defined {
                    die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not a binary string');
                }
            } else {
                unless $value ~~ Str && $value.defined {
                    die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not a string');
                }
            }
        }
    }

    my class NumberCheck does Check {
        method check($value --> Nil) {
            unless $value ~~ Real && $value.defined {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not a number');
            }
        }
    }

    my class IntegerCheck does Check {
        method check($value --> Nil) {
            unless $value ~~ Int && $value.defined {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not an integer');
            }
        }
    }

    my class BooleanCheck does Check {
        method check($value --> Nil) {
            unless $value ~~ Bool && $value.defined {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not a boolean');
            }
        }
    }

    my class ArrayCheck does Check {
        method check($value --> Nil) {
            unless $value ~~ Positional && $value.defined {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not an array');
            }
        }
    }

    my class ObjectCheck does Check {
        method check($value --> Nil) {
            unless $value ~~ Associative && $value.defined {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason('Not an object');
            }
        }
    }

    my class MultipleOfCheck does Check {
        has UInt $.multi;
        method check($value --> Nil) {
            if $value ~~ Real {
                unless $value %% $!multi {
                    die X::OpenAPI::Schema::Validate::Failed.new:
                        :$!path, :reason("Number is not multiple of $!multi");
                }
            }
        }
    }

    my class MinLengthCheck does Check {
        has Int $.min;
        method check($value --> Nil) {
            if $value ~~ Str && $value.defined && $value.codes < $!min {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("String less than $!min codepoints");
            }
        }
    }

    my class MaxLengthCheck does Check {
        has Int $.max;
        method check($value --> Nil) {
            if $value ~~ Str && $value.defined && $value.codes > $!max {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("String more than $!max codepoints");
            }
        }
    }

    my class PatternCheck does Check {
        has Str $.pattern;
        has Regex $!rx;
        submethod TWEAK() {
            use MONKEY-SEE-NO-EVAL;
            $!rx = EVAL 'rx:P5/' ~ $!pattern ~ '/';
        }
        method check($value --> Nil) {
            if $value ~~ Str && $value !~~ $!rx {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("String does not match /$!pattern/");
            }
        }
    }

    my class MaximumCheck does Check {
        has Int $.max;
        has Bool $.exclusive;
        method check($value --> Nil) {
            if $value ~~ Real && (!$!exclusive && $value > $!max || $!exclusive && $value >= $!max) {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Number is more than $!max");
            }
        }
    }

    my class MinimumCheck does Check {
        has Int $.min;
        has Bool $.exclusive;
        method check($value --> Nil) {
            if $value ~~ Real && (!$!exclusive && $value < $!min || $!exclusive && $value <= $!min) {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Number is less than $!min");
            }
        }
    }

    my class MinItemsCheck does Check {
        has Int $.min;
        method check($value --> Nil) {
            if $value ~~ Positional && $value.elems < $!min {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Array has less than $!min elements");
            }
        }
    }

    my class MaxItemsCheck does Check {
        has Int $.max;
        method check($value --> Nil) {
            if $value ~~ Positional && $value.elems > $!max {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Array has less than $!max elements");
            }
        }
    }

    my class UniqueItemsCheck does Check {
        method check($value --> Nil) {
            if $value ~~ Positional && $value.elems != $value.unique(with => &[eqv]).elems {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Array has duplicated values");
            }
        }
    }

    my class ItemsCheck does Check {
        has Check $.items-check;
        method check($value --> Nil) {
            if $value ~~ Positional {
                $value.map({ $!items-check.check($_) });
            }
        }
    }

    my class MinPropertiesCheck does Check {
        has Int $.min;
        method check($value --> Nil) {
            if $value ~~ Associative && $value.values < $!min {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Object has less than $!min properties");
            }
        }
    }

    my class MaxPropertiesCheck does Check {
        has Int $.max;
        method check($value --> Nil) {
            if $value ~~ Associative && $value.values > $!max {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Object has more than $!max properties");
            }
        }
    }

    my class RequiredCheck does Check {
        has Str @.prop;
        method check($value --> Nil) {
            if $value ~~ Associative && not [&&] $value{@!prop}.map(*.defined) {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Object does not have required property");
            }
        }
    }

    my grammar ECMA262Regex {
        token TOP {
            <disjunction>
        }
        token disjunction {
            <alternative>* % '|'
        }
        token alternative {
            <term>*
        }
        token term {
            <!before $>
            [
            | <assertion>
            | <atom> <quantifier>?
            ]
        }
        token assertion {
            | '^'
            | '$'
            | '\\' <[bB]>
            | '(?=' <disjunction> ')'
            | '(?!' <disjunction> ')'
        }
        token quantifier {
            <quantifier-prefix> '?'?
        }
        token quantifier-prefix {
            | '+'
            | '*'
            | '?'
            | '{' <decimal-digits> [ ',' <decimal-digits>? ]? '}'
        }
        token atom {
            | <pattern-character>
            | '.'
            | '\\' <atom-escape>
            | <character-class>
            | '(' <disjunction> ')'
            | '(?:' <disjunction> ')'
        }
        token pattern-character {
            <-[^$\\.*+?()[\]{}|]>
        }
        token atom-escape {
            | <decimal-digits>
            | <character-escape>
            | <character-class-escape>
        }
        token character-escape {
            | <control-escape>
            | 'c' <control-letter>
            | <hex-escape-sequence>
            | <unicode-escape-sequence>
            | <identity-escape>
        }
        token control-escape {
            <[fnrtv]>
        }
        token control-letter {
            <[A..Za..z]>
        }
        token hex-escape-sequence {
            'x' <[0..9A..Fa..f]>**2
        }
        token unicode-escape-sequence {
            'u' <[0..9A..Fa..f]>**4
        }
        token identity-escape {
            <-ident-[\c[ZWJ]\c[ZWNJ]]>
        }
        token decimal-digits {
            <[0..9]>+
        }
        token character-class-escape {
            <[dDsSwW]>
        }
        token character-class {
            '[' '^'? <class-ranges> ']'
        }
        token class-ranges {
            <non-empty-class-ranges>?
        }
        token non-empty-class-ranges {
            | <class-atom> '-' <class-atom> <class-ranges>
            | <class-atom-no-dash> <non-empty-class-ranges-no-dash>?
            | <class-atom>
        }
        token non-empty-class-ranges-no-dash {
            | <class-atom-no-dash> '-' <class-atom> <class-ranges>
            | <class-atom-no-dash> <non-empty-class-ranges-no-dash>
            | <class-atom>
        }
        token class-atom {
            | '-'
            | <class-atom-no-dash>
        }
        token class-atom-no-dash {
            | <-[\\\]-]>
            | \\ <class-escape>
        }
        token class-escape {
            | <decimal-digits>
            | 'b'
            | <character-escape>
            | <character-class-escape>
        }
    }

    my class NullOrCheck does Check {
        has Check $.check;
        method check($value --> Nil) {
            return unless $value.defined;
            $!check.check($value);
        }
    }

    my class PropertiesCheck does Check {
        has Check %.props;
        has $.add;
        method check($value --> Nil) {
            if $value ~~ Associative && $value.defined {
                if $!add === True {
                    for (%!props.keys (&) $value.keys).keys -> $key {
                        %!props{$key}.check($value{$key});
                    }
                } elsif $!add === False {
                    if (set $value.keys) ⊈ (set %!props.keys) {
                        die X::OpenAPI::Schema::Validate::Failed.new:
                            path => $!path ~ '/properties',
                            :reason("Object has properties that are not covered by properties property: $((set $value.keys) (-) (set %!props.keys)).keys.join(', ')");
                    } else {
                        $value.keys.map({ %!props{$_}.check($value{$_}) });
                    }
                } else {
                    for (%!props.keys (&) $value.keys).keys -> $key {
                        %!props{$key}.check($value{$key});
                    }
                    if $!add.elems != 0 {
                        for ($value.keys (-) %!props.keys).keys -> $key {
                            $!add.check($value{$key});
                        }
                    }
                }
            }
        }
    }

    my class EnumCheck does Check {
        has $.enum;
        method check($value --> Nil) {
            unless $value.defined && $value (elem) $!enum {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Value is outside of enumeration set by enum property");
            }
        }
    }

    my class ReadOnlyCheck does Check {
        method check($value --> Nil) {
            unless $*OSV-READ {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("readOnly check is failed");
            }
        }
    }

    my class WriteOnlyCheck does Check {
        method check($value --> Nil) {
            unless $*OSV-WRITE {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("writeOnly check is failed");
            }
        }
    }

    my class FormatCheck does Check {
        has $.checker;
        has $.format-name;
        method check($value --> Nil) {
            unless $value ~~ $!checker {
                die X::OpenAPI::Schema::Validate::Failed.new:
                    :$!path, :reason("Value $value does not match against $!format-name format");
            }
        }
    }

    has Check $!check;

    submethod BUILD(:%schema!, :%formats = %DEFAULT-FORMAT, :%add-formats = {} --> Nil) {
        $!check = check-for('root', %schema, :%formats, :%add-formats);
    }

    sub check-for($path, %schema, :%formats, :%add-formats) {
        my @checks;

        with %schema<type> {
            when Str {
                when 'string' {
                    my $is-blob = %schema<format> ?? %schema<format> eq 'binary' !! False;
                    push @checks, StringCheck.new(:$path, :$is-blob);
                }
                when 'number' {
                    push @checks, NumberCheck.new(:$path);
                }
                when 'integer' {
                    push @checks, IntegerCheck.new(:$path);
                }
                when 'boolean' {
                    push @checks, BooleanCheck.new(:$path);
                }
                when 'array' {
                    with %schema<items> {
                        push @checks, ArrayCheck.new(:$path);
                    } else {
                        die X::OpenAPI::Schema::Validate::BadSchema.new:
                            :$path, :reason("Property items must be specified for array type");
                    }
                }
                when 'object' {
                    push @checks, ObjectCheck.new(:$path);
                }
                default {
                    die X::OpenAPI::Schema::Validate::BadSchema.new:
                        :$path, :reason("Unrecognized type '$_'");
                }
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The type property must be a string");
            }
        }

        with %schema<multipleOf> {
            when StrictPositiveInt {
                push @checks, MultipleOfCheck.new(:$path, multi => $_);
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The multipleOf property must be a non-negative integer");
            }
        }

        with %schema<maximum> {
            when Int {
                push @checks, MaximumCheck.new(:$path, max => $_,
                    exclusive => %schema<exclusiveMaximum> // False);
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The maximum property must be an integer");
            }
        }

        with %schema<exclusiveMaximum> {
            when $_ !~~ Bool {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                     :$path, :reason("The exclusiveMaximum property must be a boolean");
            }
        }

        with %schema<minimum> {
            when Int {
                push @checks, MinimumCheck.new(:$path, min => $_,
                    exclusive => %schema<exclusiveMinimum> // False);
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                     :$path, :reason("The minimum property must be an integer");
            }
        }

        with %schema<exclusiveMinimum> {
            when $_ !~~ Bool {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                     :$path, :reason("The exclusiveMinimum property must be a boolean");
            }
        }

        with %schema<minLength> {
            when UInt {
                push @checks, MinLengthCheck.new(:$path, :min($_));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The minLength property must be a non-negative integer");
            }
        }

        with %schema<maxLength> {
            when UInt {
                push @checks, MaxLengthCheck.new(:$path, :max($_));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The maxLength property must be a non-negative integer");
            }
        }

        with %schema<pattern> {
            when Str {
                if ECMA262Regex.parse($_) {
                    push @checks, PatternCheck.new(:$path, :pattern($_));
                }
                else {
                    die X::OpenAPI::Schema::Validate::BadSchema.new:
                        :$path, :reason("The pattern property must be an ECMA 262 regex");
                }
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The pattern property must be a string");
            }
        }

        with %schema<minItems> {
            when UInt {
                push @checks, MinItemsCheck.new(:$path, :min($_));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The minItems property must be a non-negative integer");
            }
        }

        with %schema<maxItems> {
            when UInt {
                push @checks, MaxItemsCheck.new(:$path, :max($_));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The maxItems property must be a non-negative integer");
            }
        }

        with %schema<uniqueItems> {
            when $_ === True {
                push @checks, UniqueItemsCheck.new(:$path);
            }
            when  $_ === False {}
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The uniqueItems property must be a boolean");
            }
        }

        with %schema<items> {
            when Associative {
                my $items-check = check-for($path ~ '/items', %$_, :%formats, :%add-formats);
                push @checks, ItemsCheck.new(:$path, :$items-check);
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The items property must be an object");
            }
        }

        with %schema<minProperties> {
            when UInt {
                push @checks, MinPropertiesCheck.new(:$path, :min($_));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The minProperties property must be a non-negative integer");
            }
        }

        with %schema<maxProperties> {
            when UInt {
                push @checks, MaxPropertiesCheck.new(:$path, :max($_));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The maxProperties property must be a non-negative integer");
            }
        }

        with %schema<required> {
            when Positional {
                if ([&&] .map(* ~~ Str)) && .elems == .unique.elems {
                    push @checks, RequiredCheck.new(:$path, prop => @$_);
                } else {
                    proceed;
                }
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The required property must be a Positional of unique Str");
            }
        }

        with %schema<properties> {
            when Associative {
                my %props = .map({ .key => check-for($path ~ "/properties/{.key}", %(.value), :%formats, :%add-formats) });
                with %schema<additionalProperties> {
                    when $_ === True|False {
                        push @checks, PropertiesCheck.new(:$path, :%props, add => $_);
                    }
                    when Associative {
                        my $add = check-for($path ~ "/additionalProperties", $_, :%formats, :%add-formats);
                        push @checks, PropertiesCheck.new(:$path, :%props, :$add);
                    }
                    default {
                        die X::OpenAPI::Schema::Validate::BadSchema.new:
                            :$path, :reason("The additionalProperties property must be a boolean or an object");
                    }
                }
                push @checks, PropertiesCheck.new(:$path, :%props, add => {});
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The properties property must be an object");
            }
        }

        with %schema<enum> {
            when Positional {
                push @checks, EnumCheck.new(:$path, enum => $_);
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The enum property must be an array");
            }
        }

        with %schema<allOf> {
            when Positional {
                push @checks, AllCheck.new(:path("$path/allOf"),
                                           native => False,
                                           checks => .map({ check-for($path ~ '/allOf', $_, :%formats, :%add-formats); }));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The allOf property must be an array");
            }
        }

        with %schema<anyOf> {
            when Positional {
                push @checks, OrCheck.new(:path("$path/anyOf"),
                                          checks => .map({ check-for($path ~ '/anyOf', $_, :%formats, :%add-formats); }));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The anyOf property must be an array");
            }
        }

        with %schema<oneOf> {
            when Positional {
                push @checks, OneCheck.new(:path("$path/oneOf"),
                                           checks => .map({ check-for($path ~ '/oneOf', $_, :%formats, :%add-formats); }));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The oneOf property must be an array");
            }
        }

        with %schema<not> {
            when Associative {
                push @checks, NotCheck.new(:path("$path/not"),
                                           check => check-for($path ~ '/not', $_, :%formats, :%add-formats));
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The not property must be an object");
            }
        }

        with %schema<readOnly> {
            push @checks, ReadOnlyCheck.new(:$path) if $_;
        }

        with %schema<writeOnly> {
            push @checks, WriteOnlyCheck.new(:$path) if $_;
        }

        with %schema<format> {
            with %formats{$_} {
                push @checks, FormatCheck.new(:$path, checker => $_, format-name => %schema<format>)
            }
            with %add-formats{$_} {
                push @checks, FormatCheck.new(:$path, checker => $_, format-name => %schema<format>)
            }
        }

        if %schema<readOnly> === True && %schema<writeOnly> === True {
            die X::OpenAPI::Schema::Validate::BadSchema.new:
                :$path, :reason("readOnly and writeOnly properties cannot be both True");
        }

        my $check = @checks == 1 ?? @checks[0] !! AllCheck.new(:@checks);
        with %schema<nullable> {
            when $_ === True {
                return NullOrCheck.new(:$check);
            }
            when $_ === False {
                return $check;
            }
            default {
                die X::OpenAPI::Schema::Validate::BadSchema.new:
                    :$path, :reason("The nullable property must be boolean");
            }
        } else { return $check; }
    }

    method validate($value, :read($*OSV-READ) = False, :write($*OSV-WRITE) = False --> True) {
        $!check.check($value);
        CATCH {
            when X::OpenAPI::Schema::Validate::Failed {
                fail $_;
            }
        }
    }
}
