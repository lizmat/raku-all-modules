#!/usr/bin/env perl6
# use Grammar::Tracer;
use lib 'lib';
use OO::Plugin;

grammar MyPOD {
    token TOP {
        [
            <pod>
            || <dummy>
        ]+
    }

    token dummy {
        [ <!before <.pod-begin>> . && . ]+
    }

    token pod-begin {
        ^^ '=begin' \h
    }

    token pod-start ( $pod-kw is rw ) {
        <pod-begin> \h* $<pod-kw>=\w+ { $pod-kw = ~$/<pod-kw> } \h* $$
    }

    token pod-end ( $pod-kw ) {
        ^^ '=end' \h+ $pod-kw \h* $$
    }

    token pod {
        :my $pod-kw;
        <pod-start( $pod-kw )>
        [
            || <pod-link>
            || <pod-text>
        ]+
        <pod-end( $pod-kw )>
    }

    token pod-text {
        .+? <?before 'L<' || [^^ '=end']>
    }

    proto token pod-link {*}
    multi token pod-link:sym<mod-url> {
        'L' '<' <link-text> '|' <link-url> '>'
    }
    multi token pod-link:sym<mod-only> {
        'L' '<' <link-module> '>'
    }

    token link-text {
        <-[\|\>]>+
    }

    token link-module {
        [ <.alnum>+ ] ** 1..* % '::'
    }

    token link-url {
        $<link-prefix>=[ 'https://github.com/' .+? '/blob/v' ] <version> $<link-suffix>=[ '/' [<!before '>'> . && .]+ ]
    }

    token version {
        [\d+] ** 3 % '.'
    }
}

class MyPOD-Actions {
    has Bool $.replaced is rw = False;
    has $!ver = OO::Plugin.^ver;
    has $!ver-str = ~OO::Plugin.^ver;

    method version ($m) {
        $.replaced ||= Version.new( $m ) ≠ $!ver;
        $m.make( $!ver-str );
    }

    method pod-link:sym<mod-only> ( $m ) {
        my $link-mod = $m<link-module>.made;
        my $link-path = $link-mod.subst('::', '/', :g);
        $m.make(
            'L<' ~ $m<link-module>.made
                ~ '|https://github.com/vrurg/Perl6-OO-Plugin/blob/v'
                ~ $!ver-str ~ '/docs/md/'
                ~ $link-path ~ '.md'
                ~ '>'
        );
        $.replaced = True;
    }

    # method link-url ($m) {
    #     $m.make( $m<link-prefix> ~ $m<version> ~ $m<link-suffix> )
    # }

    method FALLBACK ($name, $m) {
        $m.make(
            $m.chunks.map( { given .value { .?made // ~$_ } } ).join
        );
    }
}

sub MAIN ( Str:D $pod-file, Str :o($output)? is copy, Bool :r($replace)=False ) {
    my Bool $backup = False;
    my $src = $pod-file.IO.slurp;
    my $actions = MyPOD-Actions.new;
    my $res = MyPOD.parse( $src, :$actions );

    die "Failed to parse the source" unless $res;

    if $actions.replaced {
        if !$output and $replace {
            $backup = True;
            $output = $pod-file;
        }

        if $backup {
            my $idx = 0;
            my $bak-file = $pod-file ~ ".bk";
            while $bak-file.IO.e {
                $bak-file = $pod-file ~ (++$idx).fmt(".%02d.bk");
            }
            $pod-file.IO.rename( $bak-file );
        }

        if $output {
            $output.IO.spurt( $res.made );
        }
        else {
            say $res.made;
        }
    }
}
