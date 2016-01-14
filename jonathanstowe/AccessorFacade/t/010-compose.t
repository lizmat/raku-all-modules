#!perl6

use v6;
use Test;
use lib 'lib';

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
    method boom-named() is rw is accessor-facade(getter => &get_bar, setter => &set_bar) { }
    method zapp() is rw is accessor-facade(&get_bar, &set_bar, &my_fudge) {};
    method zapp-named is rw is accessor-facade(getter => &get_bar, setter => &set_bar, before => &my_fudge) { }
    method poww() is rw is accessor-facade(&get_bar, &set_bar, &my_fudge, &my_check ) { }
    method poww-named() is rw is accessor-facade(getter => &get_bar, setter => &set_bar, before => &my_fudge, after => &my_check ) { }
    method bosh() is rw is accessor-facade(&get_bar, &set_bar, Code, &my_check ) { }
    method bosh-named() is rw is accessor-facade(getter => &get_bar, setter => &set_bar, after => &my_check ) { }

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
is($a.boom-named, $a.boot, "get works finei (named)");
lives-ok { $a.boom = "yada" }, "exercise setter";
is($a.boom, "yada", "get returns what we set");
is($a.boot, "yada", "and the internal thing got set");
lives-ok { $a.boom-named = "furble" }, "setter (named) ";
is($a.boom-named, "furble", "get returns what we set (named)");
is($a.boot, "furble", "and the internal thing got set");
lives-ok { $a.boom-named = "yada" }, "reset with named";
is($a.zapp, "yada", "method with fudge");
is($a.zapp-named, "yada", "method with fudge (named)");
lives-ok { $a.zapp = 'banana' }, "setter with fudge";
is($a.zapp, '*banana*', "and got fudged value");
is($a.boot, '*banana*', "and the storage get changed");
lives-ok { $a.boom-named = "yada" }, "reset with named";
lives-ok { $a.zapp-named = 'banana' }, "setter with fudge (named)";
is($a.zapp-named, '*banana*', "and got fudged value (named)");
is($a.boot, '*banana*', "and the storage get changed (named)");
throws-like { $a.poww = 'food' }, X::AdHoc, payload => 'with *food*' , '&after got called';
throws-like { $a.poww-named = 'food' }, X::AdHoc, payload  => 'with *food*'  , 'after got called (named)';
throws-like { $a.bosh = 'duck' },X::AdHoc, payload  => 'with duck'  , '&after got called (no &before)';
throws-like { $a.bosh-named = 'duck' }, X::AdHoc, payload => 'with duck'  , 'after got called (no before) (named)';

is($a.boolio, True, "Boolean coercion works");
lives-ok { $a.boolio = False }, "set with a boolean";
is($a.boolio, False, "Boolean coercion works");

is($a.burbio, Bar::B, "enum coercion works");
lives-ok { $a.burbio = Bar::C }, "set with an enum";
is($a.burbio, Bar::C, "enum coercion works");

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
