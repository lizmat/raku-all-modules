use v6;

use Path::Router;
use Linenoise;

class Path::Router::Shell {
    has Path::Router $.router;

    method shell {
        while (my $line = linenoise "> ").defined {
            return if $line ~~ / q | Q /;
            my $match = $!router.match($line);
            if ($match) {
                my %map = %($match.mapping);
                my $target = $match.target;

                say "Map:    ", %map.perl;
                say "Target: ", $target.perl;
                say "Round-trip URI is : " ~ $!router.uri-for(|%map);
            }
            else {
                say "No match for $line";
            }

            linenoiseHistoryAdd($line) if $line ~~ /\S/;
        }
    }
}

=begin pod

=TITLE Path::Router::Shell

=SUBTITLE An interactive shell for testing router configurations

=begin SYNOPSIS

    #!/usr/bin/perl6

    use v6;

    use My::App::Router;
    use Path::Router::Shell;

    my $router = My::App::Router.new;
    Path::Router::Shell.new(:$router).shell;

=end SYNOPSIS

=begin DESCRIPTION

This is a tool for helping test the routing in your applications, so
you simply write a small script like showing in the SYNOPSIS and then
you can use it to test new routes or debug routing issues, etc etc etc.

=end DESCRIPTION

=head1 ATTRIBUTES

=head2 router

    has $.router

This is the router that is being tested.

=head1 METHODS

=head2 method shell

    method shell()

This starts the shell. It will only return when "q" or "Q" are the only
characters on a line. It uses L<Linenoise> to handle reading lines, history,
etc.

=begin AUTHOR

Andrew Sterling Hanenkamp E<lt>hanenkamp@cpan.orgE<gt>

Based very closely on the original Perl 5 version by
Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=end AUTHOR

=for COPYRIGHT
Copyright 2015 Andrew Sterling Hanenkamp.

=for LICENSE
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
