#!perl6

use v6;

use Test;
use HTTP::Headers;

# Apps may choose to extend with their own headers, here with some sort-of
# default values in place.
class MyApp::CustomHeaders is HTTP::Headers {
    enum MyAppHeader < X-Foo X-Bar >;

    method build-header($name, *@values) {
        if $name ~~ MyAppHeader {
            HTTP::Header::Custom.new(:name($name.Str), :42values);
        }
        else {
            nextsame;
        }
    }

    multi method header(MyAppHeader $name) is rw {
        self.header-proxy($name);
    }

    method X-Foo is rw { self.header(MyAppHeader::X-Foo) }
    method X-Bar is rw { self.header(MyAppHeader::X-Bar) }
}

my $h = MyApp::CustomHeaders.new;
is($h.X-Foo.value, 42);
is($h.X-Bar.value, 42);
is($h.as-string(:eol('; ')), "X-Bar: 42; X-Foo: 42; ");

done;
