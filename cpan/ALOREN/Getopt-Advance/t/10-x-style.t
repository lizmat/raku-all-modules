

use Test;
use Getopt::Advance;

plan 4;

my OptionSet $optset .= new;

$optset.push("help|=b");
$optset.push("version|=b", "print program version.");
$optset.push("count|=i");
$optset.push("?=b");

getopt(
    ["-count", "42", "-?", '-help', '-version'],
    $optset,
    :x-style
);

ok $optset<help>, "x-style set help";
ok $optset<version>, "x-style set version";
ok $optset<count>, "x-style set ?";
is $optset<count>, 42;
