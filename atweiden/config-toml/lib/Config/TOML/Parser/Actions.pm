use v6;
use Config::TOML::Parser::Exceptions;
unit class Config::TOML::Parser::Actions;

# TOML document
has %.toml;

# TOML arraytable tracker, records arraytables seen
has Bool %.aoh-seen;

# TOML table tracker, records tables seen
has Bool %.hoh-seen;

# TOML key tracker, records keypair keys seen
has Bool %.keys-seen;

# DateTime offset for when the local offset is omitted in TOML dates,
# see: https://github.com/toml-lang/toml#datetime
# if not passed as a parameter during instantiation, use host machine's
# local offset
has Int $.date-local-offset = $*TZ;

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
    make chr :16(@<hex>.join);
}

method escape:sym<U>($/)
{
    make chr :16(@<hex>.join);
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
    my Int $multiplier = $<plus-or-minus> ~~ '+' ?? 1 !! -1;
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
    my Rat $second = Rat($<time-second>.made);
    my Bool $subseconds = False;

    if $<time-secfrac>
    {
        $second += Rat($<time-secfrac>.made);
        $subseconds = True;
    }

    make %(
        :hour(Int($<time-hour>.made)),
        :minute(Int($<time-minute>.made)),
        :$second,
        :$subseconds
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
        :subseconds(Bool($<partial-time>.made<subseconds>)),
        :timezone(Int($<time-offset>.made))
    );
}

method date-time-omit-local-offset($/)
{
    make DateTime.new(
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
    make DateTime.new(
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
    make DateTime.new(|$<full-date>.made, :timezone($.date-local-offset));
}

method date:date-time-omit-local-offset ($/)
{
    make $<date-time-omit-local-offset>.made;
}

method date:date-time ($/)
{
    make $<date-time>.made;
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

method keypair($/)
{
    # if keypair value is inline table, map inline table keypairs to
    # keypair key as hash
    if $<table-inline>
    {
        my %h;
        $<table-inline>.made.map({
            %h{Str($<keypair-key>.made)}{.keys[0]} = .values[0]
        });
        make %h;
    }
    else
    {
        make Str($<keypair-key>.made) => $<keypair-value>.made;
    }
}

method table-inline-keypairs($/)
{
    # verify inline table does not contain duplicate keys
    #
    # this is necessary to do early since keys are subsequently in this
    # method being assigned in a hash and are at risk of being overwritten
    # by duplicate keys
    {
        my Str @keys-seen = |@<keypair>».made».keys.flat;
        unless @keys-seen.elems == @keys-seen.unique.elems
        {
            die X::Config::TOML::InlineTable::DuplicateKeys.new(
                :table-inline-text($/.Str),
                :@keys-seen
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
    # update keypath
    my Str @keypath = $<keypair-line>.made.keys[0];

    # mark key as seen, verify key is not being redeclared
    if %!keys-seen{$(self!pwd(%.toml, @keypath))}++
    {
        die X::Config::TOML::KeypairLine::DuplicateKeys.new(
            :keypair-line-text($/.Str),
            :@keypath
        );
    }

    self!at-keypath(%!toml, @keypath) = $<keypair-line>.made.values[0];
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
    my Str @base-keypath = $<hoh-header>.made;
    my Str $hoh-text = $/.Str;

    # verify table does not overwrite existing key
    if %.keys-seen{$(self!pwd(%.toml, @base-keypath))}
    {
        die X::Config::TOML::HOH::Seen::Key.new(
            :$hoh-text,
            :keypath(@base-keypath)
        );
    }

    # verify table does not overwrite existing arraytable
    if %.aoh-seen{$@base-keypath}
    {
        die X::Config::TOML::HOH::Seen::AOH.new(
            :hoh-header-text($<hoh-header>.Str),
            :$hoh-text
        );
    }

    # mark table as seen, verify table is not being redeclared
    if %!hoh-seen{$(self!pwd(%.toml, @base-keypath))}++
    {
        die X::Config::TOML::HOH::Seen.new(
            :hoh-header-text($<hoh-header>.Str),
            :$hoh-text
        );
    }

    # verify base keypath is clear
    try
    {
        self.is-keypath-clear(@base-keypath);

        CATCH
        {
            default
            {
                die X::Config::TOML::Keypath::HOH.new(
                    :$hoh-text,
                    :keypath(@base-keypath)
                );
            }
        }
    }

    # does table contain keypairs?
    if @<keypair-line>
    {
        # verify keypair lines do not contain duplicate keys
        {
            my Str @keys-seen = |@<keypair-line>».made».keys.flat;
            unless @keys-seen.elems == @keys-seen.unique.elems
            {
                die X::Config::TOML::HOH::DuplicateKeys.new(
                    :$hoh-text,
                    :@keys-seen
                );
            }
        }

        for @<keypair-line>».made -> $keypair
        {
            my Str @keypath = @base-keypath;
            push @keypath, $keypair.keys[0];

            # verify keypair key does not conflict with existing key
            try
            {
                self.is-keypath-clear(@keypath);

                CATCH
                {
                    when X::Config::TOML::BadKeypath::ArrayNotAOH
                    {
                        die X::Config::TOML::HOH::Seen::Key.new(
                            :$hoh-text,
                            :keypath(@base-keypath)
                        );
                    }
                    default
                    {
                        die X::Config::TOML::Keypath::HOH.new(
                            :$hoh-text,
                            :@keypath
                        );
                    }
                }
            }

            # assign value to keypath
            self!at-keypath(%!toml, @keypath) = $keypair.values[0];

            # mark key as seen
            %!keys-seen{$(self!pwd(%.toml, @keypath))}++;
        }
    }
    else
    {
        self!at-keypath(%!toml, @base-keypath) = {};
    }
}

method aoh-header($/)
{
    make $<table-header-text>.made;
}

method table:aoh ($/)
{
    my Str @base-keypath = $<aoh-header>.made;
    my Str $aoh-header-text = $<aoh-header>.Str;
    my Str $aoh-text = $/.Str;

    # verify arraytable does not overwrite existing key
    if %.keys-seen{$(self!pwd(%.toml, @base-keypath))}
    {
        die X::Config::TOML::AOH::OverwritesKey.new(
            :$aoh-header-text,
            :$aoh-text,
            :keypath(@base-keypath)
        );
    }

    # verify arraytable does not overwrite existing table
    if %.hoh-seen{$(self!pwd(%.toml, @base-keypath))}
    {
        die X::Config::TOML::AOH::OverwritesHOH.new(
            :$aoh-header-text,
            :$aoh-text,
            :keypath(@base-keypath)
        );
    }

    my %h;
    if @<keypair-line>
    {
        # verify keypair lines do not contain duplicate keys
        {
            my Str @keys-seen = |@<keypair-line>».made».keys.flat;
            unless @keys-seen.elems == @keys-seen.unique.elems
            {
                die X::Config::TOML::AOH::DuplicateKeys.new(
                    :$aoh-text,
                    :@keys-seen
                );
            }
        }

        @<keypair-line>».made.map({ %h{.keys[0]} = .values[0]; });
    }

    sub append-to-aoh(@keypath, %h)
    {
        push self!at-keypath(
            %!toml,
            @keypath.end > 0 ?? @keypath[0..^@keypath.end] !! []
        ){@keypath[@keypath.end]}, %h;
    }

    # is base keypath an existing array of hashes?
    if %.aoh-seen{$@base-keypath}
    {
        # push values to existing array of hashes
        append-to-aoh(@base-keypath, %h);
    }
    # new array of hashes
    else
    {
        # make sure we're not trodding over scalars or tables
        try
        {
            self.is-keypath-clear(@base-keypath, :aoh);

            CATCH
            {
                when X::Config::TOML::BadKeypath::ArrayNotAOH
                {
                    die X::Config::TOML::AOH::OverwritesKey.new(
                        :$aoh-header-text,
                        :$aoh-text,
                        :keypath(@base-keypath)
                    );
                }
                default
                {
                    die X::Config::TOML::Keypath::AOH.new(
                        :$aoh-text,
                        :keypath(@base-keypath)
                    );
                }
            }
        }

        # push values to new array of hashes
        append-to-aoh(@base-keypath, %h);

        # mark arraytable as seen
        %!aoh-seen{$@base-keypath}++;
    }
}

method TOP($/)
{
    make %.toml;
}

# end document grammar-actions }}}

# helper functions {{{

# given TOML hash and keypath, return scalar container of deepest path,
# with special treatment of array of hashes
method !at-keypath(%h, *@k) is rw
{
    my $h := %h;

    my @path;

    for @k -> $k
    {
        push @path, $k;

        # if keypath step is array of hashes, always traverse array
        # element of highest index
        if $h{$k} ~~ List
        {
            # verify this is aoh before traversing
            unless %.aoh-seen{$@path}
            {
                die X::Config::TOML::BadKeypath::ArrayNotAOH.new;
            }

            my Int $l = $h{$k}.end;
            $h := $h{$k}[$l];
        }
        else
        {
            $h := $h{$k};
        }
    }
    $h;
}

# verify keypath does not conflict with existing key
multi method is-keypath-clear(Str:D @full-keypath) returns Bool:D
{
    my Bool:D $clear = False;

    # does full keypath exist?
    if self!at-keypath(%.toml, @full-keypath).defined
    {
        # is it a scalar?
        unless self!at-keypath(%.toml, @full-keypath).WHAT ~~ Hash
        {
            $clear = False;
            die X::Config::TOML::Keypath.new(:keypath(@full-keypath));
        }

        $clear = True;
    }
    else
    {
        # full keypath does not exist, and full keypath has depth of 1?
        if @full-keypath.end == 0
        {
            $clear = True;
        }
        else
        {
            # for extended keypaths, make sure we're not trodding
            # over scalars
            $clear = self._is-keypath-clear(
                @full-keypath[0..^@full-keypath.end].Array
            );
        }
    }

    $clear;
}

# special keypath check for arraytables
multi method is-keypath-clear(
    Str:D @full-keypath,
    Bool:D :$aoh! where *.so
) returns Bool:D
{
    my Bool:D $clear = False;

    # does full keypath exist?
    if self!at-keypath(%.toml, @full-keypath).defined
    {
        # we're tracking arraytables so if we got here, it's because
        # we're tasked with making a new arraytable
        # this new arraytable cannot overwrite any existing value
        $clear = False;
        die X::Config::TOML::Keypath.new(:keypath(@full-keypath));
    }
    else
    {
        # full keypath does not exist, and full keypath has depth of 1?
        if @full-keypath.end == 0
        {
            $clear = True;
        }
        else
        {
            # for extended keypaths, make sure we're not trodding
            # over scalars
            $clear = self._is-keypath-clear(
                @full-keypath[0..^@full-keypath.end].Array
            );
        }
    }

    $clear;
}

multi method _is-keypath-clear(@keypath where *.end > 0) returns Bool:D
{
    self!is-trodden(@keypath)
        ?? die X::Config::TOML::Keypath.new(:@keypath)
        !! self._is-keypath-clear(@keypath[0..^@keypath.end]);
}

multi method _is-keypath-clear(@keypath where *.end == 0) returns Bool:D
{
    self!is-trodden(@keypath)
        ?? die X::Config::TOML::Keypath.new(:@keypath)
        !! True;
}

method !is-trodden(@keypath) returns Bool:D
{
    if self!at-keypath(%.toml, @keypath).defined
    {
        unless self!at-keypath(%.toml, @keypath).WHAT ~~ Hash
        {
            die X::Config::TOML::Keypath.new(:@keypath);
            True;
        }
    }
    False;
}

# given TOML hash and keypath, print working directory including
# arraytable indices
# returns either a keyname or array index at each step of the path
class Step { has $.key; has Int $.index; }
method !pwd(%h, *@k) returns Array
{
    my Step @steps;

    my $h := %h;
    for @k -> $k
    {
        # if keypath step is array of hashes, always traverse array
        # element of highest index
        if $h{$k} ~~ List
        {
            my Int $l = $h{$k}.end;
            $h := $h{$k}[$l];
            push @steps, Step.new(:key($k), :index($l));
        }
        else
        {
            $h := $h{$k};
            push @steps, Step.new(:key($k));
        }
    }

    unfold(@steps);
}

# convert list of Steps to strings
sub unfold(Step @steps) returns Array
{
    my Str @unfold;

    for @steps -> $step
    {
        # surround keypair keys with angle brackets
        push @unfold, '<' ~ $step.key ~ '>';

        # surround array indices with square brackets
        push @unfold, '[' ~ $step.index ~ ']' if defined $step.index;
    }

    @unfold;
}

# end helper functions }}}

# vim: ft=perl6 fdm=marker fdl=0
