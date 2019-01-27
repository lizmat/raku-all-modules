use v6;
use Test::CSS::Aural::Spec::Grammar;
use CSS::Grammar::CSS21;
use Test::CSS::Aural::Spec::Interface;

grammar Test::CSS::Aural::BadGrammar
    is Test::CSS::Aural::Spec::Grammar 
    is CSS::Grammar::CSS21
    does Test::CSS::Aural::Spec::Interface {
        # this grammar doesn't provide interface methods - should fail at compilation, e.g.:
        # "Method 'generic-voice' must be implemented by Test::CSS::Aural::BadGrammar because it is required by a role"
}
