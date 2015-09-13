#!perl6

use v6;
use lib 'lib';
use Test;

use Audio::Libshout;

my $obj = Audio::Libshout.new();

my @tests = { name => "host", default => "localhost", value => chomp qx{"hostname"} }, 
            { name => "port", default => 8000, value => 8080 }, 
            { name => "user", default => "source", value => $*USER.Str }, 
            { name => "password", value => 'hackme' }, 
            { name => "protocol", default => Audio::Libshout::HTTP, value => Audio::Libshout::ICY }, 
            { name => "format", default => Audio::Libshout::Ogg, value => Audio::Libshout::MP3 }, 
            { name => "mount", value => '/stream' }, 
            { name => "dumpfile", value => 'test.mp3' }, 
            { name => "agent", value => 'foo/1.2.4', default => "libshout/{ $obj.libshout-version }" }, 
            { name => "public" , value => True, default => False }, 
            { name => "name", value => "Test Show" }, 
            { name => "url", value => "http://example.com" }, 
            { name => "genre", value => "techno" }, 
            { name => "description", value => "Test Show Description" }; 

my %params;
for @tests -> $test {
    ok($obj.can($test<name>), "Audio::Libshout object can { $test<name> }");
    if $test<default>:exists {
        is $obj."$test<name>"(), $test<default>, "and got the correct default value";
    }

    if $test<value>:exists {
        lives-ok { $obj."$test<name>"() = $test<value> }, "set $test<name>";
        is $obj."$test<name>"(), $test<value>, "and got the correct value back";
        %params{$test<name>} = $test<value>;
    }
}
 
lives-ok { $obj = Audio::Libshout.new(|%params) }, "new object with parameters";

for @tests -> $test {

    if $test<value>:exists {
        is $obj."$test<name>"(), $test<value>, "and got the correct value back";
    }
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
