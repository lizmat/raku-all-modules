use v6;
use Config::TOML::Parser::Exceptions;
unit class Config::TOML::Parser::Actions;

# TOML document
has %.toml;

# TOML arraytable tracker, records arraytables seen
has Bool %.aoh_seen;

# TOML table tracker, records tables seen
has Bool %.hoh_seen;

# TOML key tracker, records keypair keys seen
has Bool %.keys_seen;

# DateTime offset for when the local offset is omitted in TOML dates,
# see: https://github.com/toml-lang/toml#datetime
# if not passed as a parameter during instantiation, use host machine's
# local offset
has Int $.date_local_offset = $*TZ;

# string grammar-actions {{{

# --- string basic grammar-actions {{{

method string_basic_char:common ($/)
{
    make ~$/;
}

method string_basic_char:tab ($/)
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

method string_basic_char:escape_sequence ($/)
{
    make $<escape>.made;
}

method string_basic_text($/)
{
    make @<string_basic_char>».made.join;
}

method string_basic($/)
{
    make $<string_basic_text> ?? $<string_basic_text>.made !! "";
}

method string_basic_multiline_char:common ($/)
{
    make ~$/;
}

method string_basic_multiline_char:tab ($/)
{
    make ~$/;
}

method string_basic_multiline_char:newline ($/)
{
    make ~$/;
}

method string_basic_multiline_char:escape_sequence ($/)
{
    if $<escape>
    {
        make $<escape>.made;
    }
    elsif $<ws_remover>
    {
        make "";
    }
}

method string_basic_multiline_text($/)
{
    make @<string_basic_multiline_char>».made.join;
}

method string_basic_multiline($/)
{
    make $<string_basic_multiline_text>
        ?? $<string_basic_multiline_text>.made
        !! "";
}

# --- end string basic grammar-actions }}}
# --- string literal grammar-actions {{{

method string_literal_char:common ($/)
{
    make ~$/;
}

method string_literal_char:backslash ($/)
{
    make '\\';
}

method string_literal_text($/)
{
    make @<string_literal_char>».made.join;
}

method string_literal($/)
{
    make $<string_literal_text> ?? $<string_literal_text>.made !! "";
}

method string_literal_multiline_char:common ($/)
{
    make ~$/;
}

method string_literal_multiline_char:backslash ($/)
{
    make '\\';
}

method string_literal_multiline_text($/)
{
    make @<string_literal_multiline_char>».made.join;
}

method string_literal_multiline($/)
{
    make $<string_literal_multiline_text>
        ?? $<string_literal_multiline_text>.made
        !! "";
}

# --- end string literal grammar-actions }}}

method string:basic ($/)
{
    make $<string_basic>.made;
}

method string:basic_multi ($/)
{
    make $<string_basic_multiline>.made;
}

method string:literal ($/)
{
    make $<string_literal>.made;
}

method string:literal_multi ($/)
{
    make $<string_literal_multiline>.made;
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

method date_fullyear($/)
{
    make Int(+$/);
}

method date_month($/)
{
    make Int(+$/);
}

method date_mday($/)
{
    make Int(+$/);
}

method time_hour($/)
{
    make Int(+$/);
}

method time_minute($/)
{
    make Int(+$/);
}

method time_second($/)
{
    make Rat(+$/);
}

method time_secfrac($/)
{
    make Rat(+$/);
}

method time_numoffset($/)
{
    my Int $multiplier = $<plus_or_minus> ~~ '+' ?? 1 !! -1;
    make Int(
        (
            ($multiplier * $<time_hour>.made * 60) + $<time_minute>.made
        )
        * 60
    );
}

method time_offset($/)
{
    make $<time_numoffset> ?? Int($<time_numoffset>.made) !! 0;
}

method partial_time($/)
{
    my Rat $second = Rat($<time_second>.made);
    my Bool $subseconds = False;

    if $<time_secfrac>
    {
        $second += Rat($<time_secfrac>.made);
        $subseconds = True;
    }

    make %(
        :hour(Int($<time_hour>.made)),
        :minute(Int($<time_minute>.made)),
        :$second,
        :$subseconds
    );
}

method full_date($/)
{
    make %(
        :year(Int($<date_fullyear>.made)),
        :month(Int($<date_month>.made)),
        :day(Int($<date_mday>.made))
    );
}

method full_time($/)
{
    make %(
        :hour(Int($<partial_time>.made<hour>)),
        :minute(Int($<partial_time>.made<minute>)),
        :second(Rat($<partial_time>.made<second>)),
        :subseconds(Bool($<partial_time>.made<subseconds>)),
        :timezone(Int($<time_offset>.made))
    );
}

method date_time_omit_local_offset($/)
{
    make DateTime.new(
        :year(Int($<full_date>.made<year>)),
        :month(Int($<full_date>.made<month>)),
        :day(Int($<full_date>.made<day>)),
        :hour(Int($<partial_time>.made<hour>)),
        :minute(Int($<partial_time>.made<minute>)),
        :second(Rat($<partial_time>.made<second>)),
        :timezone($.date_local_offset)
    );
}

method date_time($/)
{
    make DateTime.new(
        :year(Int($<full_date>.made<year>)),
        :month(Int($<full_date>.made<month>)),
        :day(Int($<full_date>.made<day>)),
        :hour(Int($<full_time>.made<hour>)),
        :minute(Int($<full_time>.made<minute>)),
        :second(Rat($<full_time>.made<second>)),
        :timezone(Int($<full_time>.made<timezone>))
    );
}

method date:full_date ($/)
{
    make DateTime.new(|$<full_date>.made, :timezone($.date_local_offset));
}

method date:date_time_omit_local_offset ($/)
{
    make $<date_time_omit_local_offset>.made;
}

method date:date_time ($/)
{
    make $<date_time>.made;
}

# end datetime grammar-actions }}}
# array grammar-actions {{{

method array_elements:strings ($/)
{
    make @<string>».made;
}

method array_elements:integers ($/)
{
    make @<integer>».made;
}

method array_elements:floats ($/)
{
    make @<float>».made;
}

method array_elements:booleans ($/)
{
    make @<boolean>».made;
}

method array_elements:dates ($/)
{
    make @<date>».made;
}

method array_elements:arrays ($/)
{
    make @<array>».made;
}

method array_elements:table_inlines ($/)
{
    make @<table_inline>».made;
}

method array($/)
{
    make $<array_elements> ?? $<array_elements>.made !! [];
}

# end array grammar-actions }}}
# table grammar-actions {{{

method keypair_key:bare ($/)
{
    make ~$/;
}

method keypair_key_string_basic($/)
{
    make $<string_basic_text>.made;
}

method keypair_key:quoted ($/)
{
    make $<keypair_key_string_basic>.made;
}

method keypair_value:string ($/)
{
    make $<string>.made;
}

method keypair_value:number ($/)
{
    make $<number>.made;
}

method keypair_value:boolean ($/)
{
    make $<boolean>.made;
}

method keypair_value:date ($/)
{
    make $<date>.made;
}

method keypair_value:array ($/)
{
    make $<array>.made;
}

method keypair($/)
{
    # if keypair value is inline table, map inline table keypairs to
    # keypair key as hash
    if $<table_inline>
    {
        my %h;
        $<table_inline>.made.map({
            %h{Str($<keypair_key>.made)}{.keys[0]} = .values[0]
        });
        make %h;
    }
    else
    {
        make Str($<keypair_key>.made) => $<keypair_value>.made;
    }
}

method table_inline_keypairs($/)
{
    # verify inline table does not contain duplicate keys
    #
    # this is necessary to do early since keys are subsequently in this
    # method being assigned in a hash and are at risk of being overwritten
    # by duplicate keys
    {
        my Str @keys_seen = |@<keypair>».made».keys.flat;
        unless @keys_seen.elems == @keys_seen.unique.elems
        {
            die X::Config::TOML::InlineTable::DuplicateKeys.new(
                :table_inline_text($/.Str),
                :@keys_seen
            );
        }
    }

    my %h;
    @<keypair>».made.map({ %h{.keys[0]} = .values[0] });
    make %h;
}

method table_inline($/)
{
    # did inline table contain keypairs?
    if $<table_inline_keypairs>
    {
        make $<table_inline_keypairs>.made;
    }
    else
    {
        # empty inline table
        make {};
    }
}

# end table grammar-actions }}}
# document grammar-actions {{{

method keypair_line($/)
{
    make $<keypair>.made;
}

# this segment represents keypairs not belonging to any table
method segment:keypair_line ($/)
{
    # update keypath
    my Str @keypath = $<keypair_line>.made.keys[0];

    # mark key as seen, verify key is not being redeclared
    if %!keys_seen{$(self!pwd(%.toml, @keypath))}++
    {
        die X::Config::TOML::KeypairLine::DuplicateKeys.new(
            :keypair_line_text($/.Str),
            :@keypath
        );
    }

    self!at_keypath(%!toml, @keypath) = $<keypair_line>.made.values[0];
}

method table_header_text($/)
{
    make @<keypair_key>».made;
}

method hoh_header($/)
{
    make $<table_header_text>.made;
}

method table:hoh ($/)
{
    my Str @base_keypath = $<hoh_header>.made;
    my Str $hoh_text = $/.Str;

    # verify table does not overwrite existing key
    if %.keys_seen{$(self!pwd(%.toml, @base_keypath))}
    {
        die X::Config::TOML::HOH::Seen::Key.new(
            :$hoh_text,
            :keypath(@base_keypath)
        );
    }

    # verify table does not overwrite existing arraytable
    if %.aoh_seen{$@base_keypath}
    {
        die X::Config::TOML::HOH::Seen::AOH.new(
            :hoh_header_text($<hoh_header>.Str),
            :$hoh_text
        );
    }

    # mark table as seen, verify table is not being redeclared
    if %!hoh_seen{$(self!pwd(%.toml, @base_keypath))}++
    {
        die X::Config::TOML::HOH::Seen.new(
            :hoh_header_text($<hoh_header>.Str),
            :$hoh_text
        );
    }

    # verify base keypath is clear
    try
    {
        self.is_keypath_clear(@base_keypath);

        CATCH
        {
            default
            {
                die X::Config::TOML::Keypath::HOH.new(
                    :$hoh_text,
                    :keypath(@base_keypath)
                );
            }
        }
    }

    # does table contain keypairs?
    if @<keypair_line>
    {
        # verify keypair lines do not contain duplicate keys
        {
            my Str @keys_seen = |@<keypair_line>».made».keys.flat;
            unless @keys_seen.elems == @keys_seen.unique.elems
            {
                die X::Config::TOML::HOH::DuplicateKeys.new(
                    :$hoh_text,
                    :@keys_seen
                );
            }
        }

        for @<keypair_line>».made -> $keypair
        {
            my Str @keypath = @base_keypath;
            push @keypath, $keypair.keys[0];

            # verify keypair key does not conflict with existing key
            try
            {
                self.is_keypath_clear(@keypath);

                CATCH
                {
                    when X::Config::TOML::BadKeypath::ArrayNotAOH
                    {
                        die X::Config::TOML::HOH::Seen::Key.new(
                            :$hoh_text,
                            :keypath(@base_keypath)
                        );
                    }
                    default
                    {
                        die X::Config::TOML::Keypath::HOH.new(
                            :$hoh_text,
                            :@keypath
                        );
                    }
                }
            }

            # assign value to keypath
            self!at_keypath(%!toml, @keypath) = $keypair.values[0];

            # mark key as seen
            %!keys_seen{$(self!pwd(%.toml, @keypath))}++;
        }
    }
    else
    {
        self!at_keypath(%!toml, @base_keypath) = {};
    }
}

method aoh_header($/)
{
    make $<table_header_text>.made;
}

method table:aoh ($/)
{
    my Str @base_keypath = $<aoh_header>.made;
    my Str $aoh_header_text = $<aoh_header>.Str;
    my Str $aoh_text = $/.Str;

    # verify arraytable does not overwrite existing key
    if %.keys_seen{$(self!pwd(%.toml, @base_keypath))}
    {
        die X::Config::TOML::AOH::OverwritesKey.new(
            :$aoh_header_text,
            :$aoh_text,
            :keypath(@base_keypath)
        );
    }

    # verify arraytable does not overwrite existing table
    if %.hoh_seen{$(self!pwd(%.toml, @base_keypath))}
    {
        die X::Config::TOML::AOH::OverwritesHOH.new(
            :$aoh_header_text,
            :$aoh_text,
            :keypath(@base_keypath)
        );
    }

    my %h;
    if @<keypair_line>
    {
        # verify keypair lines do not contain duplicate keys
        {
            my Str @keys_seen = |@<keypair_line>».made».keys.flat;
            unless @keys_seen.elems == @keys_seen.unique.elems
            {
                die X::Config::TOML::AOH::DuplicateKeys.new(
                    :$aoh_text,
                    :@keys_seen
                );
            }
        }

        @<keypair_line>».made.map({ %h{.keys[0]} = .values[0]; });
    }

    sub append_to_aoh(@keypath, %h)
    {
        push self!at_keypath(
            %!toml,
            @keypath.end > 0 ?? @keypath[0..^@keypath.end] !! []
        ){@keypath[@keypath.end]}, %h;
    }

    # is base keypath an existing array of hashes?
    if %.aoh_seen{$@base_keypath}
    {
        # push values to existing array of hashes
        append_to_aoh(@base_keypath, %h);
    }
    # new array of hashes
    else
    {
        # make sure we're not trodding over scalars or tables
        try
        {
            self.is_keypath_clear(@base_keypath, :aoh);

            CATCH
            {
                when X::Config::TOML::BadKeypath::ArrayNotAOH
                {
                    die X::Config::TOML::AOH::OverwritesKey.new(
                        :$aoh_header_text,
                        :$aoh_text,
                        :keypath(@base_keypath)
                    );
                }
                default
                {
                    die X::Config::TOML::Keypath::AOH.new(
                        :$aoh_text,
                        :keypath(@base_keypath)
                    );
                }
            }
        }

        # push values to new array of hashes
        append_to_aoh(@base_keypath, %h);

        # mark arraytable as seen
        %!aoh_seen{$@base_keypath}++;
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
method !at_keypath(%h, *@k) is rw
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
            unless %.aoh_seen{$@path}
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
multi method is_keypath_clear(Str:D @full_keypath) returns Bool:D
{
    my Bool:D $clear = False;

    # does full keypath exist?
    if self!at_keypath(%.toml, @full_keypath).defined
    {
        # is it a scalar?
        unless self!at_keypath(%.toml, @full_keypath).WHAT ~~ Hash
        {
            $clear = False;
            die X::Config::TOML::Keypath.new(:keypath(@full_keypath));
        }

        $clear = True;
    }
    else
    {
        # full keypath does not exist, and full keypath has depth of 1?
        if @full_keypath.end == 0
        {
            $clear = True;
        }
        else
        {
            # for extended keypaths, make sure we're not trodding
            # over scalars
            $clear = self._is_keypath_clear(
                @full_keypath[0..^@full_keypath.end].Array
            );
        }
    }

    $clear;
}

# special keypath check for arraytables
multi method is_keypath_clear(
    Str:D @full_keypath,
    Bool:D :$aoh! where *.so
) returns Bool:D
{
    my Bool:D $clear = False;

    # does full keypath exist?
    if self!at_keypath(%.toml, @full_keypath).defined
    {
        # we're tracking arraytables so if we got here, it's because
        # we're tasked with making a new arraytable
        # this new arraytable cannot overwrite any existing value
        $clear = False;
        die X::Config::TOML::Keypath.new(:keypath(@full_keypath));
    }
    else
    {
        # full keypath does not exist, and full keypath has depth of 1?
        if @full_keypath.end == 0
        {
            $clear = True;
        }
        else
        {
            # for extended keypaths, make sure we're not trodding
            # over scalars
            $clear = self._is_keypath_clear(
                @full_keypath[0..^@full_keypath.end].Array
            );
        }
    }

    $clear;
}

multi method _is_keypath_clear(@keypath where *.end > 0) returns Bool:D
{
    self!is_trodden(@keypath)
        ?? die X::Config::TOML::Keypath.new(:@keypath)
        !! self._is_keypath_clear(@keypath[0..^@keypath.end]);
}

multi method _is_keypath_clear(@keypath where *.end == 0) returns Bool:D
{
    self!is_trodden(@keypath)
        ?? die X::Config::TOML::Keypath.new(:@keypath)
        !! True;
}

method !is_trodden(@keypath) returns Bool:D
{
    if self!at_keypath(%.toml, @keypath).defined
    {
        unless self!at_keypath(%.toml, @keypath).WHAT ~~ Hash
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
