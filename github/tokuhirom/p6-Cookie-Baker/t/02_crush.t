use strict;
use Test;
use Cookie::Baker;

my $longkey = 'x' x 1024;

my @tests = (
    [ 'Foo=Bar; Bar=Baz; XXX=Foo%20Bar; YYY=0; YYY=3', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar', YYY => '0' }],
    [ 'Foo=Bar; Bar=Baz; XXX=Foo%20Bar; YYY=0; YYY=3;', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar', YYY => '0' }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY=0; YYY=3;', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar', YYY => '0' }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY=0; YYY=3;   ', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar', YYY => '0' }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar' }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY;', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar' }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY; ', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar' }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY=', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar', YYY=>"" }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY=;', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar', YYY=>"" }],
    [ 'Foo=Bar; Bar=Baz;  XXX=Foo%20Bar   ; YYY=; ', { Foo => 'Bar', Bar => 'Baz', XXX => 'Foo Bar',YYY=>"" }],
    [ "Foo=Bar; $longkey=Bar", { Foo => 'Bar', $longkey => 'Bar'}],
    [ "Foo=Bar; $longkey=Bar; Bar=Baz", { Foo => 'Bar', $longkey => 'Bar', 'Bar'=>'Baz'}], 
    [ '', {} ],
);

for @tests {
    my ($cookie, $parsed) = @$_;
    is-deeply( crush-cookie($cookie), $parsed );
}

done-testing;

