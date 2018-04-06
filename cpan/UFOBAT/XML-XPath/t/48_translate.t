use v6.c;

use Test;
use XML::XPath;

plan 4;

my $x = XML::XPath.new(xml => '<foo/>');
is $x.find('translate("1,234.56", ",", "")'),      1234.56;
is $x.find('translate("bar", "abc", "ABC")'),      "BAr";
is $x.find('translate("--aaa--", "abc-", "ABC")'), "AAA";

# If a character occurs more than once in the second argument string, then the first occurrence determines the replacement character.
# https://rt.perl.org/Public/Bug/Display.html?id=130762
skip 'skipping one test because of  https://rt.perl.org/Public/Bug/Display.html?id=130762', 1;
#is $x.find('translate("--aaa--", "abca-", "ABCX")'), "AAA";

done-testing();
