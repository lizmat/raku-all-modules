#! /usr/bin/env perl6
use v6.c;

# A WIP Tool to pull documentation out of our scoped classes and roles.
# Currently just pulls out the why and adds a heading of the symbol name.
# Appending the output to the README.md works for now.
#
# Issues: Roles, they don't like giving up a WHY

unit sub MAIN(Str :$project-dir = '.', Str :$out = 'README.md') {
    use Pod::To::Markdown;
    use Reaper::Control;

    my $symbols = %(
        'Reaper::Control' => %(
            'Listener' => [],
            'Event' => <PlayState Play Stop PlayTime Level Mixer Unhandled>,
        )
    );

    # Still yet to work out how best to pull the documentation out
    my $package-root = 'Reaper::Control';
    # say pod2markdown ('lib/' ~ $package-root.subst(/'::'/, '/') ~ '.pm6').IO.slurp;

    my $names = gather take-symbols $symbols;

    for $names.values -> $name {
        #say "Collecting documentation for $name";
        next if $name eq $package-root;
        given ::($name) -> \symbol {
            say "### ", symbol.WHAT.perl, "\n", symbol.WHY, "\n";
            # Not sure if I want to dive into NQP land yet
            #say "is: $_" for symbol.HOW.?parents(symbol);
            #say "does: $_" for symbol.HOW.?roles_to_compose(symbol);
        }
    }

}

#! Root call for symbol builder
multi sub take-symbols(Map $s) {
    for $s.kv -> $k, $v {
        take-symbols($k, $v)
    }
}

#! Collect and recurse for Associatives
multi sub take-symbols(Str $name, Associative $s) {
    take $name;
    for $s.kv -> $k, $v {
        take-symbols("$name\::$k", $v)
    }
}

#! Collect Positionals
multi sub take-symbols(Str $name, Positional $s) {
    take $name;
    for $s.values -> $v {
        take "$name\::$v"
    }
}
