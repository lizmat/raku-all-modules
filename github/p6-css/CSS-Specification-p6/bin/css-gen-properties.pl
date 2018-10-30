#!/usr/bin/env perl6

#= translates w3c property definitions to basic Perl 6 roles, grammars or actions.

use CSS::Specification::Build;

#| e.g. cat /examples/css21-aural.txt | css-gen-properties grammar MyCSS::Grammar > MyCSS/Grammar.pm
multi sub MAIN('grammar', Str $class-name ) {
    CSS::Specification::Build::generate('grammar', $class-name);
}

multi sub MAIN('actions', Str $class-name ) {
    CSS::Specification::Build::generate('actions', $class-name);
}

multi sub MAIN('interface', Str $class-name ) {
    CSS::Specification::Build::generate('interface', $class-name);
}
