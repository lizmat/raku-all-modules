
use Test;
use Getopt::Advance;

plan 3;

my OptionSet $optset .= new;

$optset.push("h|help=b");
$optset.push("v|version=b", "print program version.");
$optset.push("?=b");

getopt(
    ["hv", "?"],
    $optset,
    :bsd-style
);

ok $optset<h>, "bsd-style set help";
ok $optset<v>, "bsd-style set version";
ok $optset<?>, "bsd-style set ?";
