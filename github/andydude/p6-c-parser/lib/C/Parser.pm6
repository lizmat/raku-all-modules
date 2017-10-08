use v6;
use C::Parser::Actions;
use C::Parser::Grammar;
unit class C::Parser;

method parse($line) {
    my $actions = C::Parser::Actions.new();
    my $ast = C::Parser::Grammar.parse($line, :$actions);
    return $ast ?? $ast.ast !! Nil;
}
