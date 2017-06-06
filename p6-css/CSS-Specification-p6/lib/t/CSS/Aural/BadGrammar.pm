use v6;
use t::CSS::Aural::Spec::Grammar;
use CSS::Grammar::CSS21;
use t::CSS::Aural::Spec::Interface;

grammar t::CSS::Aural::BadGrammar
    is t::CSS::Aural::Spec::Grammar 
    is CSS::Grammar::CSS21
    does t::CSS::Aural::Spec::Interface {
        # this grammar doesn't provide interface methods - should fail at compilation, e.g.:
        # "Method 'generic-voice' must be implemented by t::CSS::Aural::BadGrammar because it is required by a role"
}
