#!/usr/bin/env perl6

sub show_vars($scope) {
  my @vars = $scope.keys;
  say "vars: {@vars}";
}

sub foo {
  my $x = 5;
  # say "Lexical keys: {LEXICAL::.keys}";
  # say "Lexical keys: {LEXICAL::.keys.perl}";
  # say "Lexical keys: {~LEXICAL::.keys}";

  say "\n\n------------- [List variables] ---------------";
  my @my_vars = LEXICAL::.keys;
  my @parent_vars = CALLER::.keys;
  say "my     vars: {@my_vars}";
  say "caller vars: {@parent_vars}";

  say "\n\n------------- [Eval Variable] ---------------";
  say 'Local          $x=' ~ $x;
  say 'EVAL           $x=' ~ EVAL('$x');
  say 'EVAL LEXICAL:: $x=' ~ EVAL('$x', context => LEXICAL::);
  say 'EVAL CALLER::  $x=' ~ EVAL('$x', context => CALLER::);

  say "\n\n------------- [EVAL var file/line] ---------------";
  say 'Local        $?FILE/$?LINE:' ~ $?FILE ~ ":" ~ $?LINE;
  say 'EVAL         $?FILE/$?LINE:' ~ EVAL('$?FILE ~ ":" ~ $?LINE');
  say 'EVAL LEXICAL $?FILE/$?LINE:' ~ EVAL('$?FILE ~ ":" ~ $?LINE', context => LEXICAL::);
  say 'EVAL CALLER  $?FILE/$?LINE:' ~ EVAL('$?FILE ~ ":" ~ $?LINE', context => CALLER::);

  say "\n\n------------- [EVAL callframe file/line] ---------------";
  say 'Local        callframe file/line:' ~ callframe().file ~ ":" ~ callframe().line;
  say 'EVAL         callframe file/line:' ~ EVAL('callframe().file ~ ":" ~ callframe().line');
  say 'EVAL LEXICAL callframe file/line:' ~ EVAL('callframe().file ~ ":" ~ callframe().line', context => LEXICAL::);
  say 'EVAL CALLER  callframe file/line:' ~ EVAL('callframe().file ~ ":" ~ callframe().line', context => CALLER::);

  say "\n\n------------- [EVAL callframe(1) file/line] ---------------";
  say 'Local        callframe(1) file/line:' ~ callframe(1).file ~ ":" ~ callframe(1).line;
  say 'EVAL         callframe(1) file/line:' ~ EVAL('callframe(1).file ~ ":" ~ callframe(1).line');
  say 'EVAL LEXICAL callframe(1) file/line:' ~ EVAL('callframe(1).file ~ ":" ~ callframe(1).line', context => LEXICAL::);
  say 'EVAL CALLER  callframe(1) file/line:' ~ EVAL('callframe(1).file ~ ":" ~ callframe(1).line', context => CALLER::);

  say "\n\n------------- [EVAL callframe(2) file/line] ---------------";
  say 'Local        callframe(2) file/line:' ~ callframe(2).file ~ ":" ~ callframe(2).line;
  say 'EVAL         callframe(2) file/line:' ~ EVAL('callframe(2).file ~ ":" ~ callframe(2).line');
  say 'EVAL LEXICAL callframe(2) file/line:' ~ EVAL('callframe(2).file ~ ":" ~ callframe(2).line', context => LEXICAL::);
  say 'EVAL CALLER  callframe(2) file/line:' ~ EVAL('callframe(2).file ~ ":" ~ callframe(2).line', context => CALLER::);

  say "\n\n------------- [EVAL callframe(3) file/line] ---------------";
  say 'Local        callframe(3) file/line:' ~ callframe(3).file ~ ":" ~ callframe(3).line;
  say 'EVAL         callframe(3) file/line:' ~ EVAL('callframe(3).file ~ ":" ~ callframe(3).line');
  say 'EVAL LEXICAL callframe(3) file/line:' ~ EVAL('callframe(3).file ~ ":" ~ callframe(3).line', context => LEXICAL::);
  say 'EVAL CALLER  callframe(3) file/line:' ~ EVAL('callframe(3).file ~ ":" ~ callframe(3).line', context => CALLER::);

  say "\n\n------------- [EVAL callframe(4) file/line] ---------------";
  say 'Local        callframe(4) file/line:' ~ callframe(4).file ~ ":" ~ callframe(4).line;
  say 'EVAL         callframe(4) file/line:' ~ EVAL('callframe(4).file ~ ":" ~ callframe(4).line');
  say 'EVAL LEXICAL callframe(4) file/line:' ~ EVAL('callframe(4).file ~ ":" ~ callframe(4).line', context => LEXICAL::);
  say 'EVAL CALLER  callframe(4) file/line:' ~ EVAL('callframe(4).file ~ ":" ~ callframe(4).line', context => CALLER::);
}

sub bar {
  my $x = 2;
  my $y = "hi";
  foo;
}

bar;

