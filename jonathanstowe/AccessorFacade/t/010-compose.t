#!perl6

use v6;
use lib 'lib';
use Test;

use AccessorFacade;

class Bar {
    has $.boot is rw = "foo";
    has $.star is rw = '*';
    sub get_bar(Bar:D $self) {
        $self.boot;
    }
    sub set_bar(Bar:D $self, $val) {
        $self.boot = $val;
    }

    sub my_fudge(Bar $self, Str $t) {
        $self.star ~ $t ~ $self.star;
    }

    sub my_check(Bar $self, $rc ) {
        die "with $rc";
    }

    method boom() is rw is accessor-facade(&get_bar, &set_bar) {};
    method zapp() is rw is accessor-facade(&get_bar, &set_bar, &my_fudge) {};
    method poww() is rw is accessor-facade(&get_bar, &set_bar, &my_fudge, &my_check ) { }
    method bosh() is rw is accessor-facade(&get_bar, &set_bar, Code, &my_check ) { }

    has Int $.bool is rw = 1;
    sub get_boolio(Bar $self) returns Int { $self.bool }
    sub set_boolio(Bar $self, Int $bool) { $self.bool = $bool }
    method boolio() returns Bool is rw is accessor-facade(&get_boolio, &set_boolio) { * }

    enum Burble <A B C>;
    has Int $.burb is rw = 1;
    sub get_burbio(Bar $self) returns Int { $self.burb }
    sub set_burbio(Bar $self, Int $burb) { $self.burb = $burb }
    method burbio() returns Burble is rw is accessor-facade(&get_burbio, &set_burbio) { * }
}
 
my $a;

lives-ok { $a = Bar.new }, "construct object with trait";
 
is($a.boom, $a.boot, "get works fine");
lives-ok { $a.boom = "yada" }, "exercise setter";
is($a.boom, "yada", "get returns what we set");
is($a.boot, "yada", "and the internal thing got set");
is($a.zapp, "yada", "method with fudge");
lives-ok { $a.zapp = 'banana' }, "setter with fudge";
is($a.zapp, '*banana*', "and got fudged value");
is($a.boot, '*banana*', "and the storage get changed");
throws-like { $a.poww = 'food' }, ( message => '*food*' ) , '&after got called';
throws-like { $a.bosh = 'duck' }, ( message => 'duck' ) , '&after got called (no &before)';

is($a.boolio, True, "Boolean coercion works");
lives-ok { $a.boolio = False }, "set with a boolean";
is($a.boolio, False, "Boolean coercion works");

is($a.burbio, Bar::B, "enum coercion works");
lives-ok { $a.burbio = Bar::C }, "set with an enum";
is($a.burbio, Bar::C, "enum coercion works");

done;
# vim: expandtab shiftwidth=4 ft=perl6
