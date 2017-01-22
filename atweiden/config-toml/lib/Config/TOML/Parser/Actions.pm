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

method string-basic-char:common ($/)
{
    make ~$/;
}

method string-basic-char:tab ($/)
{
    make ~$/;
}

method escape:sym<b>($/)
{
    make "\b";
}

method escape:sym<t>($/)
{
    make "\t";
}

method escape:sym<n>($/)
{
    make "\n";
}

method escape:sym<f>($/)
{
    make "\f";
}

method escape:sym<r>($/)
{
    make "\r";
}

method escape:sym<quote>($/)
{
    make "\"";
}

method escape:sym<backslash>($/)
{
    make '\\';
}

method escape:sym<u>($/)
{
    make chr(:16(@<hex>.join));
}

method escape:sym<U>($/)
{
    make chr(:16(@<hex>.join));
}

method string-basic-char:escape-sequence ($/)
{
    make $<escape>.made;
}

method string-basic-text($/)
{
    make @<string-basic-char>».made.join;
}

method string-basic($/)
{
    make $<string-basic-text> ?? $<string-basic-text>.made !! "";
}

method string-basic-multiline-char:common ($/)
{
    make ~$/;
}

method string-basic-multiline-char:tab ($/)
{
    make ~$/;
}

method string-basic-multiline-char:newline ($/)
{
    make ~$/;
}

method string-basic-multiline-char:escape-sequence ($/)
{
    if $<escape>
    {
        make $<escape>.made;
    }
    elsif $<ws-remover>
    {
        make "";
    }
}

method string-basic-multiline-text($/)
{
    make @<string-basic-multiline-char>».made.join;
}

method string-basic-multiline($/)
{
    make $<string-basic-multiline-text>
        ?? $<string-basic-multiline-text>.made
        !! "";
}

# --- end string basic grammar-actions }}}
# --- string literal grammar-actions {{{

method string-literal-char:common ($/)
{
    make ~$/;
}

method string-literal-char:backslash ($/)
{
    make '\\';
}

method string-literal-text($/)
{
    make @<string-literal-char>».made.join;
}

method string-literal($/)
{
    make $<string-literal-text> ?? $<string-literal-text>.made !! "";
}

method string-literal-multiline-char:common ($/)
{
    make ~$/;
}

method string-literal-multiline-char:backslash ($/)
{
    make '\\';
}

method string-literal-multiline-text($/)
{
    make @<string-literal-multiline-char>».made.join;
}

method string-literal-multiline($/)
{
    make $<string-literal-multiline-text>
        ?? $<string-literal-multiline-text>.made
        !! "";
}

# --- end string literal grammar-actions }}}

method string:basic ($/)
{
    make $<string-basic>.made;
}

method string:basic-multi ($/)
{
    make $<string-basic-multiline>.made;
}

method string:literal ($/)
{
    make $<string-literal>.made;
}

method string:literal-multi ($/)
{
    make $<string-literal-multiline>.made;
}

# end string grammar-actions }}}
# number grammar-actions {{{

method integer($/)
{
    make Int(+$/);
}

method float($/)
{
    make +$/;
}

method plus-or-minus:sym<+>($/)
{
    make ~$/;
}

method plus-or-minus:sym<->($/)
{
    make ~$/;
}

method number($/)
{
    if $<integer>
    {
        make $<integer>.made;
    }
    elsif $<float>
    {
        make $<float>.made;
    }
}

# end number grammar-actions }}}
# boolean grammar-actions {{{

method boolean:sym<true>($/)
{
    make True;
}

method boolean:sym<false>($/)
{
    make False;
}

# end boolean grammar-actions }}}
# datetime grammar-actions {{{

method date-fullyear($/)
{
    make Int(+$/);
}

method date-month($/)
{
    make Int(+$/);
}

method date-mday($/)
{
    make Int(+$/);
}

method time-hour($/)
{
    make Int(+$/);
}

method time-minute($/)
{
    make Int(+$/);
}

method time-second($/)
{
    make Rat(+$/);
}

method time-secfrac($/)
{
    make Rat(+$/);
}

method time-numoffset($/)
{
    my Int:D $multiplier = $<plus-or-minus>.made eq '+' ?? 1 !! -1;
    make Int(
        (
            ($multiplier * $<time-hour>.made * 60) + $<time-minute>.made
        )
        * 60
    );
}

method time-offset($/)
{
    make $<time-numoffset> ?? Int($<time-numoffset>.made) !! 0;
}

method partial-time($/)
{
    my Rat:D $second = Rat($<time-second>.made);
    $second += Rat($<time-secfrac>.made) if $<time-secfrac>;
    make %(
        :hour(Int($<time-hour>.made)),
        :minute(Int($<time-minute>.made)),
        :$second
    );
}

method full-date($/)
{
    make %(
        :year(Int($<date-fullyear>.made)),
        :month(Int($<date-month>.made)),
        :day(Int($<date-mday>.made))
    );
}

method full-time($/)
{
    make %(
        :hour(Int($<partial-time>.made<hour>)),
        :minute(Int($<partial-time>.made<minute>)),
        :second(Rat($<partial-time>.made<second>)),
        :timezone(Int($<time-offset>.made))
    );
}

method date-time-omit-local-offset($/)
{
    make %(
        :year(Int($<full-date>.made<year>)),
        :month(Int($<full-date>.made<month>)),
        :day(Int($<full-date>.made<day>)),
        :hour(Int($<partial-time>.made<hour>)),
        :minute(Int($<partial-time>.made<minute>)),
        :second(Rat($<partial-time>.made<second>)),
        :timezone($.date-local-offset)
    );
}

method date-time($/)
{
    make %(
        :year(Int($<full-date>.made<year>)),
        :month(Int($<full-date>.made<month>)),
        :day(Int($<full-date>.made<day>)),
        :hour(Int($<full-time>.made<hour>)),
        :minute(Int($<full-time>.made<minute>)),
        :second(Rat($<full-time>.made<second>)),
        :timezone(Int($<full-time>.made<timezone>))
    );
}

method date:full-date ($/)
{
    make Date.new(|$<full-date>.made);
}

method date:date-time-omit-local-offset ($/)
{
    make DateTime.new(|$<date-time-omit-local-offset>.made);
}

method date:date-time ($/)
{
    make DateTime.new(|$<date-time>.made);
}

# end datetime grammar-actions }}}
# array grammar-actions {{{

method array-elements:strings ($/)
{
    make @<string>».made;
}

method array-elements:integers ($/)
{
    make @<integer>».made;
}

method array-elements:floats ($/)
{
    make @<float>».made;
}

method array-elements:booleans ($/)
{
    make @<boolean>».made;
}

method array-elements:dates ($/)
{
    make @<date>».made;
}

method array-elements:arrays ($/)
{
    make @<array>».made;
}

method array-elements:table-inlines ($/)
{
    make @<table-inline>».made;
}

method array($/)
{
    make $<array-elements> ?? $<array-elements>.made !! [];
}

# end array grammar-actions }}}
# table grammar-actions {{{

method keypair-key:bare ($/)
{
    make ~$/;
}

method keypair-key-string:basic ($/)
{
    make $<string-basic>.made;
}

method keypair-key-string:literal ($/)
{
    make $<string-literal>.made;
}

method keypair-key:quoted ($/)
{
    make $<keypair-key-string>.made;
}

method keypair-value:string ($/)
{
    make $<string>.made;
}

method keypair-value:number ($/)
{
    make $<number>.made;
}

method keypair-value:boolean ($/)
{
    make $<boolean>.made;
}

method keypair-value:date ($/)
{
    make $<date>.made;
}

method keypair-value:array ($/)
{
    make $<array>.made;
}

method keypair-value:table-inline ($/)
{
    make $<table-inline>.made;
}

method keypair($/)
{
    make Str($<keypair-key>.made) => $<keypair-value>.made;
}

method table-inline-keypairs($/)
{
    # verify inline table does not contain duplicate keys
    #
    # this is necessary to do early since keys are subsequently in this
    # method being assigned in a hash and are at risk of being overwritten
    # by duplicate keys
    {
        my Str:D @keys-seen = |@<keypair>».made».keys.flat;
        unless @keys-seen.elems == @keys-seen.unique.elems
        {
            die X::Config::TOML::InlineTable::DuplicateKeys.new(
                :@keys-seen,
                :subject('inline table'),
                :text(~$/)
            );
        }
    }

    my %h;
    @<keypair>».made.map({ %h{.keys[0]} = .values[0] });
    make %h;
}

method table-inline($/)
{
    # did inline table contain keypairs?
    if $<table-inline-keypairs>
    {
        make $<table-inline-keypairs>.made;
    }
    else
    {
        # empty inline table
        make {};
    }
}

# end table grammar-actions }}}
# document grammar-actions {{{

method keypair-line($/)
{
    make $<keypair>.made;
}

# this segment represents keypairs not belonging to any table
method segment:keypair-line ($/)
{
    my @path = $<keypair-line>.made.keys[0];
    my $value = $<keypair-line>.made.values[0];

    if seen(%!keys-seen, :@path)
    {
        die X::Config::TOML::KeypairLine::DuplicateKeys.new(
            :keypair-line-text(~$/),
            :@path
        );
    }

    Crane.exists(%!toml, :@path)
        ?? die
            X::Config::TOML::KeypairLine::DuplicateKeys.new(
                :keypair-line-text(~$/),
                :@path
            )
        !! Crane.set(%!toml, :@path, :$value);

    %!keys-seen{$@path}++;
}

method table-header-text($/)
{
    make @<keypair-key>».made;
}

method hoh-header($/)
{
    make $<table-header-text>.made;
}

method table:hoh ($/)
{
    my @base-path = pwd(%!toml, :steps($<hoh-header>.made));
    my Str:D $hoh-text = ~$/;

    if seen(%!keys-seen, :path(@base-path))
    {
        die X::Config::TOML::HOH::Seen::Key.new(
            :$hoh-text,
            :path(@base-path)
        );
    }
    if %!aoh-seen.grep({.keys[0] eqv $@base-path}).elems > 0
    {
        die X::Config::TOML::HOH::Seen::AOH.new(
            :hoh-header-text(~$<hoh-header>),
            :$hoh-text
        );
    }
    if %!hoh-seen.grep({.keys[0] eqv $@base-path}).elems > 0
    {
        die X::Config::TOML::HOH::Seen.new(
            :hoh-header-text(~$<hoh-header>),
            :$hoh-text
        );
    }

    my @keypairs = @<keypair-line>».made.flat;
    {
        CATCH
        {
            when X::AdHoc
            {
                my rule exception-associative-indexing
                {
                    Type (\w+) does not support associative indexing
                }
                if .payload ~~ &exception-associative-indexing
                {
                    die X::Config::TOML::HOH::Seen::Key.new(
                        :$hoh-text,
                        :path(@base-path)
                    );
                }
            }
        }

        # does table contain keypairs?
        if @keypairs
        {
            # verify keypairs do not contain duplicate keys
            {
                my Str:D @keys-seen = |@keypairs».keys.flat;
                unless @keys-seen.elems == @keys-seen.unique.elems
                {
                    die X::Config::TOML::HOH::DuplicateKeys.new(
                        :@keys-seen,
                        :subject('table'),
                        :text($hoh-text)
                    );
                }
            }

            for @keypairs -> %keypair
            {
                my @path = |@base-path, %keypair.keys[0];
                my $value = %keypair.values[0];
                Crane.exists(%!toml, :@path)
                    ?? die
                        X::Config::TOML::HOH::Seen::Key.new(
                            :$hoh-text,
                            :@path
                        )
                    !! Crane.set(%!toml, :@path, :$value);
                %!keys-seen{$@path}++;
            }
        }
        else
        {
            Crane.exists(%!toml, :path(@base-path))
                ?? die
                    X::Config::TOML::HOH::Seen::Key.new(
                        :$hoh-text,
                        :path(@base-path)
                    )
                !! Crane.set(%!toml, :path(@base-path), :value({}));
        }
    }

    %!hoh-seen{$@base-path}++;
}

method aoh-header($/)
{
    make $<table-header-text>.made;
}

method table:aoh ($/)
{
    my @path = pwd(%!toml, :steps($<aoh-header>.made));
    my Str:D $aoh-header-text = ~$<aoh-header>;
    my Str:D $aoh-text = ~$/;

    if seen(%!keys-seen, :@path)
    {
        die X::Config::TOML::AOH::OverwritesKey.new(
            :$aoh-header-text,
            :$aoh-text,
            :@path
        );
    }
    if %!hoh-seen.grep({.keys[0] eqv $@path}).elems > 0
    {
        die X::Config::TOML::AOH::OverwritesHOH.new(
            :$aoh-header-text,
            :$aoh-text,
            :@path
        );
    }

    unless %!aoh-seen.grep({.keys[0] eqv $@path}).elems > 0
    {
        Crane.exists(%!toml, :@path)
            ?? die X::Config::TOML::Keypath::AOH.new(:$aoh-text, :@path)
            !! Crane.set(%!toml, :@path, :value([]));
        %!aoh-seen{$@path}++;
    }

    my %h;
    my @keypairs = @<keypair-line>».made.flat;
    if @keypairs
    {
        # verify keypair lines do not contain duplicate keys
        {
            my Str:D @keys-seen = |@keypairs».keys.flat;
            unless @keys-seen.elems == @keys-seen.unique.elems
            {
                die X::Config::TOML::AOH::DuplicateKeys.new(
                    :@keys-seen,
                    :subject('array table'),
                    :text($aoh-text)
                );
            }
        }

        @keypairs.map({ %h{.keys[0]} = .values[0] });
    }
    Crane.set(%!toml, :path(|@path, *-0), :value(%h));
}

method TOP($/)
{
    make %!toml;
}

# end document grammar-actions }}}

# helper functions {{{

# given TOML hash and keypath, print working directory including
# arraytable indices
multi sub pwd(Associative:D $container, :@steps where *.elems > 0) returns Array:D
{
    my @steps-taken;
    my $root := $container;
    $root := $root{@steps[0]};
    push @steps-taken, @steps[0], |pwd($root, :steps(@steps[1..*]));
    @steps-taken;
}

multi sub pwd(Associative:D $container, :@steps where *.elems == 0) returns Array:D
{
    my @steps-taken;
}

multi sub pwd(Positional:D $container, :@steps where *.elems > 0) returns Array:D
{
    my @steps-taken;
    my $root := $container;
    my Int:D $index = $container.end;
    $root := $root[$index];
    push @steps-taken, $index, |pwd($root, :@steps);
    @steps-taken;
}

multi sub pwd(Positional:D $container, :@steps where *.elems == 0) returns Array:D
{
    my @steps-taken;
}

multi sub pwd($container, :@steps where *.elems > 0) returns Array:D
{
    my @steps-taken;
    my $root := $container;
    $root := $root{@steps[0]};
    push @steps-taken, @steps[0], |pwd($root, :steps(@steps[1..*]));
    @steps-taken;
}

multi sub pwd($container, :@steps where *.elems == 0) returns Array:D
{
    my @steps-taken;
}

multi sub seen(Bool:D %h, :@path! where *.elems > 1) returns Bool:D
{
    %h.grep({.keys[0] eqv $@path}).elems > 0
        || seen(%h, :path(@path[0..^*-1].Array));
}

multi sub seen(Bool:D %h, :@path! where *.elems > 0) returns Bool:D
{
    %h.grep({.keys[0] eqv $@path}).elems > 0;
}

multi sub seen(Bool:D %h, :@path! where *.elems == 0) returns Bool:D
{
    False;
}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
