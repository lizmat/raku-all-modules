#!perl6

use v6;
use lib 'lib';

use Test;

use JSON::Tiny;
use URI::Template;

use URI::Encode;
my Bool $broken-encode = uri_encode("drücken") ne "dr%C3%BCcken";


my IO::Path $data-dir = $*PROGRAM.parent.child('data');

my IO::Path $spec-examples = $data-dir.child('uritemplate-test/spec-examples-by-section.json');

my $data-json = $spec-examples.open(:r).slurp-rest;

my $data = from-json($data-json);


for $data.keys.sort -> $label {
    my $level-data = $data{$label};
    my $variables = $level-data<variables>.hash;
    my $tests = $level-data<testcases>;
    todo("URI::Encode appears to be broken") if $broken-encode;
    subtest {
        for $tests.list -> $test {
            my $ut = URI::Template.new(template => $test[0]);

            my $processed;
            lives-ok { $processed = $ut.process(|$variables); }, "process";
            is $processed, any($test[1].list), "'{ $test[0] }' expands to '{ $test[1].list.join(" or ") }'";
        }

    }, $label;
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
