unit class IO::Glob;

use v6;

=NAME IO::Glob - Glob matching for paths & strings and listing files

=begin SYNOPSIS

    use IO::Glob;

    # Use a glob to match a string or path
    if "some-string" ~~ glob("some-*") { say "match string!" }
    if "some/path.txt".IO ~~ glob("some/*.txt") { say "match path!" }

    # Use a glob as a test in built-in IO::Path.dir()
    for "/var/log".IO.dir(test => glob("*.err")) -> $err-log { ... }

    # Or better, do it directly from here
    for glob("*.err").dir("/var/log") -> $err-log { ... }

    # Globs are objects, which you can save, reuse, and pass around
    my $file-match = glob("*.txt);
    my @files := dir("$*HOME/docs", :test($file-match));

=end SYNOPSIS

=begin DESCRIPTION

Traditionally, globs provide a handy shorthand for identifying the files you're
interested in based upon their path. This class provides that shorthand using a
BSD-style glob grammar that is familiar to Perl devs. However, it is more
powerful than it's predecessor in Perl 5's File::Glob.

=item # Globs are built as IO::Glob objects which encapsulate the pattern and let you pass them around for whatever use you want to put them too.

=item # By using L<#method dir>, you can put globs to their traditional use, listing all the files in a directory.

=item # It also works well as a smart-match. It will match against strings or anything that stringifies and against L<IO::Path>s too. This allows it to be used with the built-in L<IO::Path#method dir> too.

=item # You can use custom grammars for your smart match. This is still somewhat experimental, but if you need a different glob style that is provided, you can roll your own with a small amount of effort or extend on of the existing ones. This class ships with three grammars: Simple, BSD, and SQL.

=end DESCRIPTION

class Globber {
    role Term { }
    class Match does Term { has $.smart-match is rw }
    class Expansion does Term { has @.alternatives }

    has @.terms where { .elems > 0 && all($_) ~~ Term };
    has @!matchers;

    method !compile-terms-ind($base, @terms is copy) {
        my $term = @terms.shift;

        my @roots;
        if $term ~~ Match {
            my $match = $term.smart-match;
            @roots = rx/$base$match/;
        }
        elsif $term ~~ Expansion {
           my @alts = $term.alternatives;
           @roots = @alts.map({ rx/$base$^alt/ });
       }
       else {
           die "unknown match term: $term";
       }

       if @terms { @roots.map({ self!compile-terms-ind($^base, @terms).Slip }) }
       else { @roots.Slip }
    }
    method !compile-terms() {
        return if @!matchers;
        @!matchers = self!compile-terms-ind(rx/<?>/, @.terms).map(-> $rx {rx/^$rx$/});
    }

    multi method ACCEPTS(Str:U $) returns Bool:D { False }
    multi method ACCEPTS(Str:D $candidate) returns Bool:D {
        self!compile-terms;
        $candidate ~~ any(@!matchers);
    }
}

# Unlike File::Glob in Perl 5, we don't make a bunch of options to turn off each
# kind of feature. Instead, we give them the option to pick a grammar. They are
# free to subclass a grammar as simple or complicated as they like and we give
# them the obvious grammars to begin with.
grammar Base {
    token TOP {
        <term>+
        { make $<term>».made }
    }

    token term {
        || <match>
           { make Globber::Match.new(:smart-match($<match>.made)) }
        || <expansion>
           { make Globber::Expansion.new(:alternatives($<expansion>.made)) }
        || <escape>
           { make Globber::Match.new(:smart-match($<escape>.made)) }
        || <char>
           { make Globber::Match.new(:smart-match($<char>.made)) }
    }

    proto token match {*}
    proto token expansion { * }
    proto token escape { * }
    token char { $<char> = . { make $<char>.Str } }
}

grammar SQL is Base {
    method whatever-match { '%' }

    token match:sym<%> { <sym> { make rx/.*?/ } }
    token match:sym<_> { <sym> { make rx/./ } }
}

grammar Simple is Base {
    method whatever-match { '*' }

    token match:sym<*> {
        <!after "\\"> <sym>
        { make rx/.*?/ }
    }
    token match:sym<?> {
        <!after "\\"> <sym>
        { make rx/./ }
    }

    token escape { "\\" <escape-sym> { make $<escape-sym>.Str } }

    proto token escape-sym { * }
    token escape-sym:sym<*> { <sym> }
    token escape-sym:sym<?> { <sym> }
}

grammar BSD is Simple {
    token TOP { <term>+ }

    token match:character-class {
        <!after "\\"> '['
            $<not>   = [ "!"? ]
            $<class> = [ <-[ \] ]>+ ]
        ']'

        {
            my @class = $<class>.Str.comb;
            make $<not> ?? rx{@class} !! rx{<!before @class> .}
        }
    }

    token expansion:alternatives {
        <!after "\\"> '{'
            <list=.comma-list>
        '}'

        { make my @list= ([~] $<list>).split(',') }
    }

    token comma-list {
        [ <-[ , \} ]>+ ]+ % ','
    }

    token expansion:home-dir {
        <!after "\\"> '~' $<user> = [ <-[/]>+ ]?

        { make $<user> ?? [ 'NYI' ]<> !! [ $*HOME ]<> }
    }

    token escape-sym:sym<[> { <sym> }
    token escape-sym:sym<]> { <sym> }
    token escape-sym:sym<{> { <sym> }
    token escape-sym:sym<}> { <sym> }
    token escape-sym:sym<~> { <sym> }
}

=begin pod

=head1 SUBROUTINES

=head2 sub glob

    sub glob(Str:D $pattern, :$grammar = IO::Glob::BSD.new, :$spec = $*SPEC) returns IO::Glob:D
    sub glob(Whatever $, :$grammar = IO::Glob::BSD.new, :$spec = $*SPEC) returns IO::Glob:D

When given a string, that string will be stored in the L<#method
pattern/pattern> attribute and will be parsed according to the L<#method
grammar/grammar>.

When given L<Whatever> (C<*>) as the argument, it's the same as:

    glob('*');

which will match anything. (Note that what whatever matches may be grammar specific, so C<glob(*, :grammar(IO::Glob::SQL))> is the same as C<glob('%')>.)

The optional C<:$grammar> setting lets you select a globbing grammar to use. Two
are provided:

=item IO::Glob::Simple (which supports just C<*> and C<?>)

=item IO::Glob::BSD (supports C<*>, C<?>, C<[abc]>, C<[!abc]>, C<~>, and C<{ab,cd,efg}>)

=item IO::Glob::SQL (supports C<%> and C<_>)

If you want a grammar that does something else, you may create your own as well,
but no documentation of that process has been written yet as of this writing.

Finally, the C<:$spec> option allows you to specify the L<IO::Spec> to use when
matching paths. It uses C<$*SPEC>, by default.

=head1 METHODS

=head2 method pattern

    method pattern() returns Str:D

Returns the pattern set during construction.

=head2 method spec

    method spec() returns IO::Spec:D

Returns the spec set during construction.

=head2 method grammar

    method grammar() returns Any:D

Returns the grammar set during construction.

=end pod

has Str:D $.pattern;
has IO::Spec:D $.spec = $*SPEC;

has $.grammar = BSD.new;
has Globber $!globber;
has Globber @!globbers;

method !compile-glob() {
    $!globber = Globber.new(
        terms => $!grammar.parse($!pattern)<term>.map({.made}),
    );
}

method !compile-globs() {
    my @parts = $.pattern.split($.spec.dir-sep);
    @!globbers = @parts.map({
        Globber.new(
            terms => $!grammar.parse($^pattern)<term>.map({.made}),
        );
    });
}

=begin pod

=head2 method dir

    method dir(Cool $path = '.') returns List:D

Returns a list of files matching the glob. This will descend directories if the
pattern contains a L<IO::Spec#dir-sep> using a depth-first search. (This ought
to respect the order of alternates in expansions like C<{bc,ab}>, but that is
not supported yet at this time.)

=end pod

method dir(Cool $path = '.') returns List:D {
    self!compile-globs;

    my $current = $path.IO;
    return []<> unless $current.d;

    my @globbers = @!globbers;

    # Depth-first-search... commence!
    my @open-list = \(:path($current), :@globbers);
    my @result;
    while @open-list {
        my (:$path, :@globbers) := @open-list.shift;

        if @globbers {
            my ($globber, @remaining) = @globbers;
            @open-list.unshift: $path.dir(test => $globber)\
                .map({
                    \(:$^path, :globbers(@remaining))
                });
        }
        else {
            @result.push: $path;
        }
    }

    @result;
}

=begin pod

=head2 method ACCEPTS

    method ACCEPTS(Mu:U $) returns Bool:D
    method ACCEPTS(Str:D(Any) $candiate) returns Bool:D
    method ACCEPTS(IO::Path:D $path) returns Bool:D

This implements smart-match. Undefined values never match. Strings are matched
using the whole pattern, without reference to any directory separators in the
string. Paths, however, are matched and carefully respect directory separators.
For most circumstances, this will not make any difference. However, a case like
this will be treated very differently in each case:

    my $glob = glob("hello{x,y/}world");
    say "String" if "helloy/world" ~~ $glob;      # outputs> String
    say "Path"   if "helloy/world".IO ~~ $glob;   # outputs nothing, no match
    say "Path 2" if "helloy{x,y/}world" ~~ $glob; # outputs> Path 2

The reason is that the second and third are matched in parts as follows:

    "helloy" ~~ glob("hello{x,y") && "world" ~~ glob("}world")
    "hello{x,y" ~~ glob("hello{x,y") && "}world" ~~ glob("}world")

=end pod

multi method ACCEPTS(Mu:U $) returns Bool:D { False }
multi method ACCEPTS(Str:D(Any) $candidate) returns Bool:D {
    self!compile-glob;
    $candidate ~~ $!globber
}
multi method ACCEPTS(IO::Path:D $path) returns Bool:D {
    self!compile-globs;
    my @parts = $path.split($.spec.dir-sep);
    return False unless @parts.elems == @!globbers.elems;
    [&&] (@parts Z @!globbers).flatmap: -> ($p, $g) { $p ~~ $g };
}

multi sub glob(Str:D $pattern, :$grammar = BSD.new, :$spec = $*SPEC) returns IO::Glob:D is export {
    IO::Glob.new(:$pattern, :$grammar, :$spec);
}
multi sub glob(Whatever $, :$grammar = BSD.new, :$spec = $*SPEC) returns IO::Glob:D is export {
    IO::Glob.new(:pattern($grammar.whatever-match), :$grammar, :$spec);
}
