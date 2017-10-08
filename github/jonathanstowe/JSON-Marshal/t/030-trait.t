#!perl6
use v6.c;
use Test;

use JSON::Marshal;
use JSON::Fast;

subtest {
    class VersionClassCode {
        has Version $.version is marshalled-by(-> Version $v { $v.Str });
    }

    my VersionClassCode $obj = VersionClassCode.new(version => Version.new("0.0.1"));

    my $json;


    lives-ok { $json = marshal($obj) }, "marshall with attribute trait (code)";

    my $parsed;
    lives-ok { $parsed = from-json($json) }, "parse the resulting JSON";

    ok $parsed.defined, "got something back";
    is $parsed<version>, "0.0.1", "and has the right value";
}, "marshalled-by trait with Code";
subtest {
    class VersionClassMethod {
        has Version $.version is marshalled-by('Str');
    }

    my VersionClassMethod $obj = VersionClassMethod.new(version => Version.new("0.0.1"));

    my $json;
    lives-ok { $json = marshal($obj) }, "marshall with attrbute trait (method name)";

    my $parsed;

    lives-ok { $parsed = from-json($json) }, "got sensible JSON back";

    ok $parsed.defined, "got something back";
    is $parsed<version>, "0.0.1", "and has the right value";
}, "marshalled-by trait with Method name";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
