#!/usr/bin/env perl6
use v6;
use JSON::Fast;
use Fortran::Grammar;
use Fortran::Grammar::Test;


sub MAIN (Str :$rule!, Bool :$json = False, Bool :$verbose = False) {
    # Read from STDIN
    # For some reason, plain «slurp» doesn't work. Might have to do
    # with some named or positional argument being presend, I don't know.
    my Str $input = lines($*IN).join("\n");

    # Verbose output
    say "" if $verbose;
    say "### INPUT ###" if $verbose;
    say $input if $verbose;
    say "#############" if $verbose;
    say "" if $verbose;
    say "### INPUT parsed as «$rule» ###" if $verbose;

    # Parse the input
    my $m = Fortran::Grammar::FortranBasic.parse: $input, 
        rule => $rule, actions => Fortran::Grammar::Test::TestActions.new;

    if $json { # JSON output wanted
        try {
            CATCH { default { say to-json {} } } # empty hash
            say to-json $m.made; # Print the JSON-serialized made Match
            }
        }
    else { # no JSON output wanted
        say $m; # just print the Match
        }

    # verbose output
    say "######################" if $verbose;
    say "" if $verbose;

    }
