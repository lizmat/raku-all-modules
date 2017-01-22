#!/usr/bin perl6

use v6;
use Test;
use Getopt::Kinoko;
use Getopt::Kinoko::OptionSet;
use Getopt::Kinoko::Argument;
use Getopt::Kinoko::NonOption;

plan 3 + 3 + 1 * 2 + 2 * 2;

my $old-opts = OptionSet.new();
my $new-opts;

$old-opts.insert-normal("h|help=b");
$new-opts = $old-opts.deep-clone();
$new-opts.push-option("n|new=s");

$old-opts.insert-front(-> $arg {
    ok $arg.value eq "test", "compatible with the old version";
});
$new-opts.insert-front(-> $arg, $opts {
    ok $arg.value eq "test", "get first NOA ok";
    ok $opts.has-option("new"), "pass OptionSet to callback ok";
});
$old-opts.insert-all(-> @noa {
        ok [@noa>>.value] eqv ["test", "old"], "compatible with the old version";
});
$new-opts.insert-all(-> @noa, $opts {
        ok [@noa>>.value] eqv ["test", "new"], "get all NOA ok";
        ok $opts.has-option("new"), "pass OptionSet to callback ok";
});
$old-opts.insert-each(-> $arg {
        ok $arg eq "test" || "old", "compatible with the old version";
});
$new-opts.insert-each(-> $arg, $opts {
        ok $arg eq "test" || "old", "get each NOA ok";
        ok $opts.has-option("new"), "pass OptionSet to callback ok";
});

getopt($old-opts, ["test", "--help", "old"]);
getopt($new-opts, ["test", "--help", "new"]);

done-testing();
