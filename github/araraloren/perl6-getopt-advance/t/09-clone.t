
use Test;
use Getopt::Advance;

plan 7;

my OptionSet $optset .= new;

$optset.push("h|help=b");
$optset.insert-main(sub main($, @) {
    ok $optset.has("v"), "clone ok";
    nok $optset.has("z"), "clone ok";
});

my $another = $optset.clone();

$optset.push("v|version=b");
$optset.append("a=s;b=b;c=f", :radio);
$another.push("z|zsd=h");

getopt([], $optset);

ok  $optset.get('h'), "clone ok";
nok $optset === $another, "object not equal";
nok $another.has('v'), "clone ok";
nok $another.get("a"), "clone ok";
nok $optset.get("z"), "clone ok";
