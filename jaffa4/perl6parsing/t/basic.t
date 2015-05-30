use v6;

use Perl6::Parsing;
use Test;
plan 4;

ok Perl6::Parsing.new() ~~ Perl6::Parsing,
   'contructor';

my $p = Perl6::Parsing.new();
$p.parse("my \$p=3;
");
#say "walktree";
try
{
 $p.walktree(False,0,"root");
  ok 1,"walktree method";
 $p.tokenise();
}
try
{
$p.parse("my \$p=3;
");

}

ok $p.dumptokens().chars>0,"dumptokens basic test";
ok $p.dumpranges().chars>0,"dumpranges basic test";
