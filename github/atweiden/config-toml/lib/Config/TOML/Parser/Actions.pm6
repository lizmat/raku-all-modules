use v6;
use Crane;
use X::Config::TOML;
unit class Config::TOML::Parser::Actions;

# TOML document
has %!toml;

# TOML arraytable tracker, records arraytables seen
has Bool:D %!aoh-seen{Array:D};

# TOML table tracker, records tables seen
has Bool:D %!hoh-seen{Array:D};

# TOML key tracker, records keypair keys seen
has Bool:D %!keys-seen{Array:D};

# DateTime offset for when the local offset is omitted in TOML dates,
# see: https://github.com/toml-lang/toml#datetime
# if not passed as a parameter during instantiation, use host machine's
# local offset
has Int:D $.date-local-offset = $*TZ;

# string grammar-actions {{{

# --- string basic grammar-actions {{{

method string-basic-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-basic-char:tab ($/ --> Nil)
{
    make(~$/);
}

method escape:sym<b>($/ --> Nil)
{
    make("\b");
}

method escape:sym<t>($/ --> Nil)
{
    make("\t");
}

method escape:sym<n>($/ --> Nil)
{
    make("\n");
}

method escape:sym<f>($/ --> Nil)
{
    make("\f");
}

method escape:sym<r>($/ --> Nil)
{
    make("\r");
}

method escape:sym<quote>($/ --> Nil)
{
    make("\"");
}

method escape:sym<backslash>($/ --> Nil)
{
    make('\\');
}

method escape:sym<u>($/ --> Nil)
{
    make(chr(:16(@<hex>.join)));
}

method escape:sym<U>($/ --> Nil)
{
    make(chr(:16(@<hex>.join)));
}

method string-basic-char:escape-sequence ($/ --> Nil)
{
    make($<escape>.made);
}

method string-basic-text($/ --> Nil)
{
    make(@<string-basic-char>.hyper.map({ .made }).join);
}

multi method string-basic($/ where $<string-basic-text>.so --> Nil)
{
    make($<string-basic-text>.made);
}

multi method string-basic($/ --> Nil)
{
    make('');
}

method string-basic-multiline-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-basic-multiline-char:tab ($/ --> Nil)
{
    make(~$/);
}

method string-basic-multiline-char:newline ($/ --> Nil)
{
    make(~$/);
}

multi method string-basic-multiline-char:escape-sequence (
    $/ where $<escape>.so
    --> Nil
)
{
    make($<escape>.made);
}

multi method string-basic-multiline-char:escape-sequence (
    $/ where $<ws-remover>.so
    --> Nil
)
{
    make('');
}

method string-basic-multiline-text($/ --> Nil)
{
    make(@<string-basic-multiline-char>.hyper.map({ .made }).join);
}

multi method string-basic-multiline(
    $/ where $<string-basic-multiline-text>.so
    --> Nil
)
{
    make($<string-basic-multiline-text>.made);
}

multi method string-basic-multiline($/ --> Nil)
{
    make('');
}

# --- end string basic grammar-actions }}}
# --- string literal grammar-actions {{{

method string-literal-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-literal-char:backslash ($/ --> Nil)
{
    make('\\');
}

method string-literal-text($/ --> Nil)
{
    make(@<string-literal-char>.hyper.map({ .made }).join);
}

multi method string-literal($/ where $<string-literal-text>.so --> Nil)
{
    make($<string-literal-text>.made);
}

multi method string-literal($/ --> Nil)
{
    make('');
}

method string-literal-multiline-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-literal-multiline-char:backslash ($/ --> Nil)
{
    make('\\');
}

method string-literal-multiline-text($/ --> Nil)
{
    make(@<string-literal-multiline-char>.hyper.map({ .made }).join);
}

multi method string-literal-multiline(
    $/ where $<string-literal-multiline-text>.so
    --> Nil
)
{
    make($<string-literal-multiline-text>.made);
}

multi method string-literal-multiline($/ --> Nil)
{
    make('');
}

# --- end string literal grammar-actions }}}

method string:basic ($/ --> Nil)
{
    make($<string-basic>.made);
}

method string:basic-multi ($/ --> Nil)
{
    make($<string-basic-multiline>.made);
}

method string:literal ($/ --> Nil)
{
    make($<string-literal>.made);
}

method string:literal-multi ($/ --> Nil)
{
    make($<string-literal-multiline>.made);
}

# end string grammar-actions }}}
# number grammar-actions {{{

method integer($/ --> Nil)
{
    make(Int(+$/));
}

method float($/ --> Nil)
{
    make(+$/);
}

method plus-or-minus:sym<+>($/ --> Nil)
{
    make(~$/);
}

method plus-or-minus:sym<->($/ --> Nil)
{
    make(~$/);
}

multi method number($/ where $<integer>.so --> Nil)
{
    make($<integer>.made);
}

multi method number($/ where $<float>.so --> Nil)
{
    make($<float>.made);
}

# end number grammar-actions }}}
# boolean grammar-actions {{{

method boolean:sym<true>($/ --> Nil)
{
    make(True);
}

method boolean:sym<false>($/ --> Nil)
{
    make(False);
}

# end boolean grammar-actions }}}
# datetime grammar-actions {{{

method date-fullyear($/ --> Nil)
{
    make(Int(+$/));
}

method date-month($/ --> Nil)
{
    make(Int(+$/));
}

method date-mday($/ --> Nil)
{
    make(Int(+$/));
}

method time-hour($/ --> Nil)
{
    make(Int(+$/));
}

method time-minute($/ --> Nil)
{
    make(Int(+$/));
}

method time-second($/ --> Nil)
{
    make(Rat(+$/));
}

method time-secfrac($/ --> Nil)
{
    make(Rat(+$/));
}

method time-numoffset($/ --> Nil)
{
    my Int:D $multiplier = $<plus-or-minus>.made eq '+' ?? 1 !! -1;
    make(
        Int((($multiplier * $<time-hour>.made * 60) + $<time-minute>.made) * 60)
    );
}

multi method time-offset($/ where $<time-numoffset>.so --> Nil)
{
    make(Int($<time-numoffset>.made));
}

multi method time-offset($/ --> Nil)
{
    make(0);
}

method partial-time($/ --> Nil)
{
    my Rat:D $second = Rat($<time-second>.made);
    $second += Rat($<time-secfrac>.made) if $<time-secfrac>;
    make(
        %(
            :hour(Int($<time-hour>.made)),
            :minute(Int($<time-minute>.made)),
            :$second
        )
    );
}

method full-date($/ --> Nil)
{
    make(
        %(
            :year(Int($<date-fullyear>.made)),
            :month(Int($<date-month>.made)),
            :day(Int($<date-mday>.made))
        )
    );
}

method full-time($/ --> Nil)
{
    make(
        %(
            :hour(Int($<partial-time>.made<hour>)),
            :minute(Int($<partial-time>.made<minute>)),
            :second(Rat($<partial-time>.made<second>)),
            :timezone(Int($<time-offset>.made))
        )
    );
}

method date-time-omit-local-offset($/ --> Nil)
{
    make(
        %(
            :year(Int($<full-date>.made<year>)),
            :month(Int($<full-date>.made<month>)),
            :day(Int($<full-date>.made<day>)),
            :hour(Int($<partial-time>.made<hour>)),
            :minute(Int($<partial-time>.made<minute>)),
            :second(Rat($<partial-time>.made<second>)),
            :timezone($.date-local-offset)
        )
    );
}

method date-time($/ --> Nil)
{
    make(
        %(
            :year(Int($<full-date>.made<year>)),
            :month(Int($<full-date>.made<month>)),
            :day(Int($<full-date>.made<day>)),
            :hour(Int($<full-time>.made<hour>)),
            :minute(Int($<full-time>.made<minute>)),
            :second(Rat($<full-time>.made<second>)),
            :timezone(Int($<full-time>.made<timezone>))
        )
    );
}

method date:full-date ($/ --> Nil)
{
    make(Date.new(|$<full-date>.made));
}

method date:date-time-omit-local-offset ($/ --> Nil)
{
    make(DateTime.new(|$<date-time-omit-local-offset>.made));
}

method date:date-time ($/ --> Nil)
{
    make(DateTime.new(|$<date-time>.made));
}

# end datetime grammar-actions }}}
# array grammar-actions {{{

method array-elements:strings ($/ --> Nil)
{
    my @made = @<string>.hyper.map({ .made });
    make(@made);
}

method array-elements:integers ($/ --> Nil)
{
    my @made = @<integer>.hyper.map({ .made });
    make(@made);
}

method array-elements:floats ($/ --> Nil)
{
    my @made = @<float>.hyper.map({ .made });
    make(@made);
}

method array-elements:booleans ($/ --> Nil)
{
    my @made = @<boolean>.hyper.map({ .made });
    make(@made);
}

method array-elements:dates ($/ --> Nil)
{
    my @made = @<date>.hyper.map({ .made });
    make(@made);
}

method array-elements:arrays ($/ --> Nil)
{
    my @made = @<array>.hyper.map({ .made });
    make(@made);
}

method array-elements:table-inlines ($/ --> Nil)
{
    my @made = @<table-inline>.hyper.map({ .made });
    make(@made);
}

multi method array($/ where $<array-elements>.so --> Nil)
{
    make($<array-elements>.made);
}

multi method array($/ --> Nil)
{
    make([]);
}

# end array grammar-actions }}}
# table grammar-actions {{{

method keypair-key:bare ($/ --> Nil)
{
    make(~$/);
}

method keypair-key-string:basic ($/ --> Nil)
{
    make($<string-basic>.made);
}

method keypair-key-string:literal ($/ --> Nil)
{
    make($<string-literal>.made);
}

method keypair-key:quoted ($/ --> Nil)
{
    make($<keypair-key-string>.made);
}

method keypair-value:string ($/ --> Nil)
{
    make($<string>.made);
}

method keypair-value:number ($/ --> Nil)
{
    make($<number>.made);
}

method keypair-value:boolean ($/ --> Nil)
{
    make($<boolean>.made);
}

method keypair-value:date ($/ --> Nil)
{
    make($<date>.made);
}

method keypair-value:array ($/ --> Nil)
{
    make($<array>.made);
}

method keypair-value:table-inline ($/ --> Nil)
{
    make($<table-inline>.made);
}

method keypair($/ --> Nil)
{
    make(Str($<keypair-key>.made) => $<keypair-value>.made);
}

method table-inline-keypairs($/ --> Nil)
{
    my @keypair = @<keypair>.hyper.map({ .made });

    # verify inline table does not contain duplicate keys
    #
    # this is necessary to do early since keys are subsequently in this
    # method being assigned in a hash and are at risk of being overwritten
    # by duplicate keys
    verify-no-duplicate-keys(
        @keypair,
        'inline table',
        ~$/,
        X::Config::TOML::InlineTable::DuplicateKeys
    );

    my %h = @keypair.map({ .keys.first => .values.first });
    make(%h);
}

# inline table contains keypairs
multi method table-inline($/ where $<table-inline-keypairs>.so --> Nil)
{
    make($<table-inline-keypairs>.made);
}

# inline table is empty
multi method table-inline($/ --> Nil)
{
    make({});
}

# end table grammar-actions }}}
# document grammar-actions {{{

method keypair-line($/ --> Nil)
{
    make($<keypair>.made);
}

# this segment represents keypairs not belonging to any table
method segment:keypair-line ($/ --> Nil)
{
    my @path = $<keypair-line>.made.keys.first;
    my $value = $<keypair-line>.made.values.first;

    my Str:D $keypair-line-text = ~$/;
    my X::Config::TOML::KeypairLine::DuplicateKeys $exception .=
        new(:$keypair-line-text, :@path);

    !seen(%!keys-seen, :@path)
        or die($exception);
    !Crane.exists(%!toml, :@path)
        or die($exception);
    Crane.set(%!toml, :@path, :$value);

    %!keys-seen{$@path}++;
}

method table-header-text($/ --> Nil)
{
    my @made = @<keypair-key>.hyper.map({ .made });
    make(@made);
}

method hoh-header($/ --> Nil)
{
    make($<table-header-text>.made);
}

method table:hoh ($/ --> Nil)
{
    my @base-path = pwd(%!toml, :steps($<hoh-header>.made));
    my Str:D $hoh-text = ~$/;
    my Str:D $hoh-header-text = ~$<hoh-header>;
    my @keypairs = @<keypair-line>.hyper.map({ .made }).flat;

    my X::Config::TOML::HOH::Seen::Key $exception-hoh-seen-key .=
        new(:$hoh-text, :path(@base-path));
    !seen(%!keys-seen, :path(@base-path))
        or die($exception-hoh-seen-key);

    my X::Config::TOML::HOH::Seen::AOH $exception-hoh-seen-aoh .=
        new(:$hoh-header-text, :$hoh-text);
    %!aoh-seen.grep({.keys.first eqv $@base-path}).elems == 0
        or die($exception-hoh-seen-aoh);

    my X::Config::TOML::HOH::Seen $exception-hoh-seen .=
        new(:$hoh-header-text, :$hoh-text);
    %!hoh-seen.grep({.keys.first eqv $@base-path}).elems == 0
        or die($exception-hoh-seen);

    CATCH
    {
        when X::AdHoc
        {
            my rule exception-associative-indexing
            { Type (\w+) does not support associative indexing }
            .payload !~~ &exception-associative-indexing
                or die($exception-hoh-seen-key);
        }
    }
    self.mktable-hoh(@base-path, $hoh-text, :@keypairs);
}

multi method mktable-hoh(@base-path, $hoh-text, :@keypairs! where *.so --> Nil)
{
    # verify keypairs do not contain duplicate keys
    verify-no-duplicate-keys(
        @keypairs,
        'table',
        $hoh-text,
        X::Config::TOML::HOH::DuplicateKeys
    );

    @keypairs.map(-> %keypair {
        my @path = |@base-path, %keypair.keys.first;
        my $value = %keypair.values.first;
        my X::Config::TOML::HOH::Seen::Key $exception-hoh-seen-key .=
            new(:$hoh-text, :@path);
        !Crane.exists(%!toml, :@path)
            or die($exception-hoh-seen-key);
        Crane.set(%!toml, :@path, :$value);
        %!keys-seen{$@path}++;
    });

    %!hoh-seen{$@base-path}++;
}

multi method mktable-hoh(@path, $hoh-text, :@keypairs --> Nil)
{
    my X::Config::TOML::HOH::Seen::Key $exception-hoh-seen-key .=
        new(:$hoh-text, :@path);
    !Crane.exists(%!toml, :@path)
        or die($exception-hoh-seen-key);
    Crane.set(%!toml, :@path, :value({}));
    %!hoh-seen{$@path}++;
}

method aoh-header($/ --> Nil)
{
    make($<table-header-text>.made);
}

method table:aoh ($/ --> Nil)
{
    my @path = pwd(%!toml, :steps($<aoh-header>.made));
    my Str:D $aoh-header-text = ~$<aoh-header>;
    my Str:D $aoh-text = ~$/;
    my @keypairs = @<keypair-line>.hyper.map({ .made }).flat;

    my X::Config::TOML::AOH::OverwritesKey $exception-aoh-overwrites-key .=
        new(:$aoh-header-text, :$aoh-text, :@path);
    !seen(%!keys-seen, :@path)
        or die($exception-aoh-overwrites-key);

    my X::Config::TOML::AOH::OverwritesHOH $exception-aoh-overwrites-hoh .=
        new(:$aoh-header-text, :$aoh-text, :@path);
    %!hoh-seen.grep({.keys.first eqv $@path}).elems == 0
        or die($exception-aoh-overwrites-hoh);

    self.mktable-aoh(@path, $aoh-text, :@keypairs);
}

multi method mktable-aoh(@path, $aoh-text, :@keypairs! where *.so --> Nil)
{
    # initialize empty array if array does not yet exist
    %!aoh-seen.grep({.keys.first eqv $@path}).elems > 0
        or self!mktable-aoh-init(@path, $aoh-text);

    # verify keypair lines do not contain duplicate keys
    verify-no-duplicate-keys(
        @keypairs,
        'array table',
        $aoh-text,
        X::Config::TOML::AOH::DuplicateKeys
    );

    # create hash table with keypairs
    my %value = @keypairs.map({ .keys.first => .values.first });
    Crane.set(%!toml, :path(|@path, *-0), :%value);
}

multi method mktable-aoh(@path, $aoh-text, :@keypairs --> Nil)
{
    # initialize empty array if array does not yet exist
    %!aoh-seen.grep({.keys.first eqv $@path}).elems > 0
        or self!mktable-aoh-init(@path, $aoh-text);

    # create hash table without keypairs
    Crane.set(%!toml, :path(|@path, *-0), :value({}));
}

method !mktable-aoh-init(@path, $aoh-text --> Nil)
{
    my X::Config::TOML::Keypath::AOH $exception-keypath-aoh .=
        new(:$aoh-text, :@path);
    !Crane.exists(%!toml, :@path)
        or die($exception-keypath-aoh);
    Crane.set(%!toml, :@path, :value([]));
    %!aoh-seen{$@path}++;
}

method TOP($/ --> Nil)
{
    make(%!toml);
}

# end document grammar-actions }}}

# helper functions {{{

# --- sub pwd {{{

# given TOML hash and keypath, print working directory including
# arraytable indices
multi sub pwd(Associative:D $container, :@steps where *.elems > 0 --> Array:D)
{
    my @steps-taken;
    my $root := $container;
    $root := $root{@steps[0]};
    push(@steps-taken, @steps[0], |pwd($root, :steps(@steps[1..*])));
    @steps-taken;
}

multi sub pwd(Associative:D $container, :@steps where *.elems == 0 --> Array:D)
{
    my @steps-taken;
}

multi sub pwd(Positional:D $container, :@steps where *.elems > 0 --> Array:D)
{
    my @steps-taken;
    my $root := $container;
    my Int:D $index = $container.end;
    $root := $root[$index];
    push(@steps-taken, $index, |pwd($root, :@steps));
    @steps-taken;
}

multi sub pwd(Positional:D $container, :@steps where *.elems == 0 --> Array:D)
{
    my @steps-taken;
}

multi sub pwd($container, :@steps where *.elems > 0 --> Array:D)
{
    my @steps-taken;
    my $root := $container;
    $root := try $root{@steps[0]};
    push(@steps-taken, @steps[0], |pwd($root, :steps(@steps[1..*])));
    @steps-taken;
}

multi sub pwd($container, :@steps where *.elems == 0 --> Array:D)
{
    my @steps-taken;
}

# --- end sub pwd }}}
# --- sub seen {{{

multi sub seen(Bool:D %h, :@path! where *.elems > 1 --> Bool:D)
{
    %h.grep({.keys.first eqv $@path}).elems > 0
        || seen(%h, :path(@path[0..^*-1].Array));
}

multi sub seen(Bool:D %h, :@path! where *.elems > 0 --> Bool:D)
{
    %h.grep({.keys.first eqv $@path}).elems > 0;
}

multi sub seen(Bool:D %h, :@path! where *.elems == 0 --> Bool:D)
{
    False;
}

# --- end sub seen }}}
# --- sub verify-no-duplicate-keys {{{

sub verify-no-duplicate-keys(
    @keypairs,
    $subject,
    $text,
    Exception:U $exception-type
    --> Nil
)
{
    my Str:D @keys-seen = |@keypairs.map({ .keys }).flat;
    my $exception = $exception-type.new(:@keys-seen, :$subject, :$text);
    @keys-seen.elems == @keys-seen.unique.elems
        or die($exception);
}

# --- end sub verify-no-duplicate-keys }}}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
