use v6;
use CSS::Aural::Spec::Grammar;
use CSS::Grammar::CSS21;
use CSS::Aural::Spec::Interface;

grammar CSS::Aural::BadGrammar
    is CSS::Aural::Spec::Grammar 
    is CSS::Grammar::CSS21
    does CSS::Aural::Spec::Interface {
        # this grammar doesn't provide interface methods - should fail at compilation, e.g.:
        # "Method 'generic-voice' must be implemented by CSS::Aural::BadGrammar because it is required by a role"
}
