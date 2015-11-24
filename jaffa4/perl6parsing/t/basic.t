use v6;

use Rakudo::Perl6::Parsing;
use Test;

ok Rakudo::Perl6::Parsing.new() ~~ Rakudo::Perl6::Parsing,
   'contructor';

my $p = Rakudo::Perl6::Parsing.new();
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

# note $p.dumptokens().perl;
ok $p.dumptokens().chars>0,"dumptokens basic test";
ok $p.dumpranges().chars>0,"dumpranges basic test";

done-testing;
