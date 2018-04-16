use v6;
use Crane;
use X::Config::TOML;
unit class Config::TOML::Parser::Actions;

# TOML document
has %!toml;

# TOML arraytable tracker, records arraytables seen
has Bool:D %!aoh{Array:D};

# TOML table tracker, records tables seen
has Bool:D %!hoh{Array:D};

# TOML key tracker, records keypair keys seen
has Bool:D %!key{Array:D};

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

method float($/ --> Nil)
{
    make(+$/);
}

multi method float-inf($/ where $<plus-or-minus>.so --> Nil)
{
    my Int:D $multiplier = $<plus-or-minus>.made eq '+' ?? 1 !! -1;
    make(Inf * $multiplier);
}

multi method float-inf($/ --> Nil)
{
    make(Inf);
}

method float-nan($/ --> Nil)
{
    make(NaN);
}

method integer($/ --> Nil)
{
    make(Int(+$/));
}

method integer-bin($/ --> Nil)
{
    make(Int(+$/));
}

method integer-hex($/ --> Nil)
{
    make(Int(+$/));
}

method integer-oct($/ --> Nil)
{
    make(Int(+$/));
}

method plus-or-minus:sym<+>($/ --> Nil)
{
    make(~$/);
}

method plus-or-minus:sym<->($/ --> Nil)
{
    make(~$/);
}

method number:float ($/ --> Nil)
{
    make($<float>.made);
}

method number:float-inf ($/ --> Nil)
{
    make($<float-inf>.made);
}

method number:float-nan ($/ --> Nil)
{
    make($<float-nan>.made);
}

method number:integer ($/ --> Nil)
{
    make($<integer>.made);
}

method number:integer-bin ($/ --> Nil)
{
    make($<integer-bin>.made);
}

method number:integer-hex ($/ --> Nil)
{
    make($<integer-hex>.made);
}

method number:integer-oct ($/ --> Nil)
{
    make($<integer-oct>.made);
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

method time($/ --> Nil)
{
    make($<partial-time>.made);
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

method array-elements:times ($/ --> Nil)
{
    my @made = @<time>.hyper.map({ .made });
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

method keypair-key-dotted($/ --> Nil)
{
    my Str:D @made = @<keypair-key-single>.hyper.map({ .made }).flat;
    make(@made);
}

method keypair-key-single:bare ($/ --> Nil)
{
    my Str:D @made = ~$/;
    make(@made);
}

method keypair-key-single-string:basic ($/ --> Nil)
{
    make($<string-basic>.made);
}

method keypair-key-single-string:literal ($/ --> Nil)
{
    make($<string-literal>.made);
}

method keypair-key-single:quoted ($/ --> Nil)
{
    my Str:D @made = $<keypair-key-single-string>.made;
    make(@made);
}

method keypair-key:dotted ($/ --> Nil)
{
    make($<keypair-key-dotted>.made);
}

method keypair-key:single ($/ --> Nil)
{
    make($<keypair-key-single>.made);
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

method keypair-value:time ($/ --> Nil)
{
    make($<time>.made);
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
    my Str:D @keypair-key = $<keypair-key>.made;
    my $keypair-value = $<keypair-value>.made;
    make(%(:@keypair-key, :$keypair-value));
}

method table-inline-keypairs($/ --> Nil)
{
    my Hash:D @keypair = @<keypair>.hyper.map({ .made });

    # verify inline table does not contain duplicate keys
    verify-no-duplicate-keys(
        @keypair,
        'inline table',
        ~$/,
        X::Config::TOML::InlineTable::DuplicateKeys
    );

    my %h;
    @keypair.hyper.map(-> %keypair {
        my @path = %keypair<keypair-key>.flat;
        my $value = %keypair<keypair-value>;
        Crane.set(%h, :@path, :$value);
    });
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
    my @path = $<keypair-line>.made<keypair-key>.flat;
    my $value = $<keypair-line>.made<keypair-value>;

    my Str:D $keypair-line-text = ~$/;
    my X::Config::TOML::KeypairLine::DuplicateKeys $exception .=
        new(:$keypair-line-text, :@path);

    seen(%!key, :@path).not
        or die($exception);
    Crane.exists(%!toml, :@path).not
        or die($exception);
    Crane.set(%!toml, :@path, :$value);

    %!key{$@path}++;
}

method table-header-text($/ --> Nil)
{
    my Str:D @made = @<keypair-key-single>.hyper.map({ .made }).flat;
    make(@made);
}

method hoh-header($/ --> Nil)
{
    make($<table-header-text>.made);
}

method table:hoh ($/ --> Nil)
{
    my @base-path = pwd(%!toml, $<hoh-header>.made);
    my Str:D $hoh-text = ~$/;
    my Str:D $hoh-header-text = ~$<hoh-header>;
    my Hash:D @keypair = @<keypair-line>.hyper.map({ .made });

    my X::Config::TOML::HOH::Seen::Key $exception-hoh-seen-key .=
        new(:$hoh-text, :path(@base-path));
    seen(%!key, :path(@base-path)).not
        or die($exception-hoh-seen-key);

    my X::Config::TOML::HOH::Seen::AOH $exception-hoh-seen-aoh .=
        new(:$hoh-header-text, :$hoh-text, :path(@base-path));
    %!aoh.grep({ .keys.first eqv $@base-path }).not
        or die($exception-hoh-seen-aoh);

    my X::Config::TOML::HOH::Seen $exception-hoh-seen .=
        new(:$hoh-header-text, :$hoh-text, :path(@base-path));
    %!hoh.grep({ .keys.first eqv $@base-path }).not
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
    self.mktable-hoh(@base-path, $hoh-text, :@keypair);
}

multi method mktable-hoh(
    @base-path,
    $hoh-text,
    Hash:D :@keypair! where *.so
    --> Nil
)
{
    # verify keypairs do not contain duplicate keys
    verify-no-duplicate-keys(
        @keypair,
        'table',
        $hoh-text,
        X::Config::TOML::HOH::DuplicateKeys
    );

    @keypair.hyper.map(-> %keypair {
        my @path = |@base-path, |%keypair<keypair-key>;
        my $value = %keypair<keypair-value>;
        my X::Config::TOML::HOH::Seen::Key $exception-hoh-seen-key .=
            new(:$hoh-text, :@path);
        Crane.exists(%!toml, :@path).not
            or die($exception-hoh-seen-key);
        Crane.set(%!toml, :@path, :$value);
        %!key{$@path}++;
    });

    %!hoh{$@base-path}++;
}

multi method mktable-hoh(
    @path,
    $hoh-text,
    :keypair(@)
    --> Nil
)
{
    my X::Config::TOML::HOH::Seen::Key $exception-hoh-seen-key .=
        new(:$hoh-text, :@path);
    Crane.exists(%!toml, :@path).not
        or die($exception-hoh-seen-key);
    Crane.set(%!toml, :@path, :value({}));
    %!hoh{$@path}++;
}

method aoh-header($/ --> Nil)
{
    make($<table-header-text>.made);
}

method table:aoh ($/ --> Nil)
{
    my @path = pwd(%!toml, $<aoh-header>.made);
    my Str:D $aoh-header-text = ~$<aoh-header>;
    my Str:D $aoh-text = ~$/;
    my Hash:D @keypair = @<keypair-line>.hyper.map({ .made });

    my X::Config::TOML::AOH::OverwritesKey $exception-aoh-overwrites-key .=
        new(:$aoh-header-text, :$aoh-text, :@path);
    seen(%!key, :@path).not
        or die($exception-aoh-overwrites-key);

    my X::Config::TOML::AOH::OverwritesHOH $exception-aoh-overwrites-hoh .=
        new(:$aoh-header-text, :$aoh-text, :@path);
    %!hoh.grep({ .keys.first eqv $@path }).not
        or die($exception-aoh-overwrites-hoh);

    self.mktable-aoh(@path, $aoh-text, :@keypair);
}

multi method mktable-aoh(@path, $aoh-text, Hash:D :@keypair! where *.so --> Nil)
{
    # initialize empty array if array does not yet exist
    %!aoh.grep({ .keys.first eqv $@path }).so
        or self!mktable-aoh-init(@path, $aoh-text);

    # verify keypair lines do not contain duplicate keys
    verify-no-duplicate-keys(
        @keypair,
        'array table',
        $aoh-text,
        X::Config::TOML::AOH::DuplicateKeys
    );

    # create hash table with keypairs
    my %value;
    @keypair.hyper.map(-> %keypair {
        my @k = %keypair<keypair-key>.flat;
        my $v = %keypair<keypair-value>;
        Crane.set(%value, :path(@k), :value($v));
    });
    Crane.set(%!toml, :path(|@path, *-0), :%value);
}

multi method mktable-aoh(@path, $aoh-text, :keypair(@) --> Nil)
{
    # initialize empty array if array does not yet exist
    %!aoh.grep({ .keys.first eqv $@path }).so
        or self!mktable-aoh-init(@path, $aoh-text);

    # create hash table without keypairs
    Crane.set(%!toml, :path(|@path, *-0), :value({}));
}

method !mktable-aoh-init(@path, $aoh-text --> Nil)
{
    my X::Config::TOML::Keypath::AOH $exception-keypath-aoh .=
        new(:$aoh-text, :@path);
    Crane.exists(%!toml, :@path).not
        or die($exception-keypath-aoh);
    Crane.set(%!toml, :@path, :value([]));
    %!aoh{$@path}++;
}

method TOP($/ --> Nil)
{
    make(%!toml);
}

# end document grammar-actions }}}

# helper functions {{{

# --- sub is-path-clear {{{

multi sub is-path-clear(
    Array[Str:D] @k
    --> Bool:D
)
{
    my %k;
    my Bool:D $is-path-clear = is-path-clear(%k, @k);
}

multi sub is-path-clear(
    %k,
    Array[Str:D] @k
    --> Bool:D
)
{
    my Bool:D @set-true = @k.map(-> Str:D @l { set-true(%k, @l) });
    my Bool:D $is-path-clear = [&&] @set-true;
}

multi sub set-true(
    %k,
    Str:D @path where { Crane.exists(%k, :@path) }
    --> Bool:D
)
{
    my Bool:D $set-true = False;
}

multi sub set-true(
    %k,
    Str:D @path
    --> Bool:D
)
{
    my Bool:D $value = True;
    try Crane.set(%k, :@path, :$value);
    my Bool:D $set-true = Crane.exists(%k, :@path);
}

# --- end sub is-path-clear }}}
# --- sub pwd {{{

# given TOML hash and keypath, print working directory including
# arraytable indices
multi sub pwd(Associative:D $container, @ ($step, *@rest) --> Array:D)
{
    my @step-taken;
    my $root := $container;
    $root := $root{$step};
    push(@step-taken, $step, |pwd($root, @rest));
    @step-taken;
}

multi sub pwd(Associative:D $, @ --> Array:D)
{
    my @step-taken;
}

multi sub pwd(Positional:D $container, @step where *.elems > 0 --> Array:D)
{
    my @step-taken;
    my $root := $container;
    my Int:D $index = $container.end;
    $root := $root[$index];
    push(@step-taken, $index, |pwd($root, @step));
    @step-taken;
}

multi sub pwd(Positional:D $, @ --> Array:D)
{
    my @step-taken;
}

multi sub pwd($container, @ ($step, *@rest) --> Array:D)
{
    my @step-taken;
    my $root := $container;
    $root := try $root{$step};
    push(@step-taken, $step, |pwd($root, @rest));
    @step-taken;
}

multi sub pwd($, @ --> Array:D)
{
    my @step-taken;
}

# --- end sub pwd }}}
# --- sub seen {{{

multi sub seen(Bool:D %h, :@path! where *.elems > 1 --> Bool:D)
{
    my Bool:D $seen =
        %h.grep({ .keys.first eqv $@path }).so
            || seen(%h, :path(@path[0..^*-1].Array));
}

multi sub seen(Bool:D %h, :@path! where *.elems > 0 --> Bool:D)
{
    my Bool:D $seen = %h.grep({ .keys.first eqv $@path }).so;
}

multi sub seen(Bool:D %h, :@path! where *.elems == 0 --> Bool:D)
{
    my Bool:D $seen = False;
}

# --- end sub seen }}}
# --- sub verify-no-duplicate-keys {{{

sub verify-no-duplicate-keys(
    Hash:D @keypair,
    $subject,
    $text,
    Exception:U $exception-type
    --> Nil
)
{
    my Array[Str:D] @key =
        @keypair.hyper.map(-> %keypair { %keypair<keypair-key> });
    is-path-clear(@key)
        or die($exception-type.new(:$subject, :$text));
}

# --- end sub verify-no-duplicate-keys }}}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
