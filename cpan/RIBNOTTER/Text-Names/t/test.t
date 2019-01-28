use v6;
use Test;
use Test::META;
use lib 'lib';
use Text::Names;


#this code is under MIT license

#this code does not do complete testing. For example, if get-full() returned "123 123" sometimes, the tests would pass but the code would be wrong still.

plan 10;
meta-ok();
ok(get-full().split(" ").elems === 2);
ok(get-male().split(" ").elems === 1);
ok(get-female().split(" ").elems === 1);
#In theory this could fail rarely, but it is a low enough rate that it shouldn't matter to much 
ok(not get-first() eq get-first() eq get-first() eq get-first() eq get-first());
ok(not get-full() eq get-full() eq get-full() eq get-full() eq get-full());
ok(not get-full("female") eq get-full("female") eq get-full("female") eq get-full("female") eq get-full("female"));
ok(not get-full(female) eq get-full(female) eq get-full(female) eq get-full(female) eq get-full(female));
ok(not get-full(male) eq get-full(male) eq get-full(male) eq get-full(male) eq get-full(male));
ok(not get-full("male") eq get-full("male") eq get-full("male") eq get-full("male") eq get-full("male"));
