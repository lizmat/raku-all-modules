use IRC::Async::Grammar;
use IRC::Async::Grammar::Actions;
unit class IRC::Async::Parser;

sub parse-irc (Str:D $input) is export {
    IRC::Async::Grammar.parse($input, actions => IRC::Async::Grammar::Actions).made // [];
}
