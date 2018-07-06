#!perl6

use v6;
use lib 'lib';

use Test;
use URI::Encode;

my @tests = (
    {
        in => "drücken",
        out => "dr%C3%BCcken",
    },
    {
        in  => "Grüner Weg",
        out => "Gr%C3%BCner%20Weg",
    },
    {
        in => "šöäŸœñê€£¥‡ÑÒÓÔÕÖ×ØÙÚàáâãäåæçÿ",
        out => "%C5%A1%C3%B6%C3%A4%C5%B8%C5%93%C3%B1%C3%AA%E2%82%AC%C2%A3%C2%A5%E2%80%A1%C3%91%C3%92%C3%93%C3%94%C3%95%C3%96%C3%97%C3%98%C3%99%C3%9A%C3%A0%C3%A1%C3%A2%C3%A3%C3%A4%C3%A5%C3%A6%C3%A7%C3%BF",
    },

);

for @tests -> $test {
    is uri_encode($test<in>), $test<out>, "uri_encode correctly deals with '{ $test<in> }'";
    is uri_encode_component($test<in>), $test<out>, "uri_encode_component correctly deals with '{ $test<in> }'";
    is uri_decode($test<out>), $test<in>, "uri_decode correctly deals with '{ $test<in> }'";
    is uri_decode_component($test<out>), $test<in>, "uri_decode_component correctly deals with '{ $test<in> }'";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
