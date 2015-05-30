#!/usr/bin/perl6

use v6;

use Test;

use Path::Router;

my $r = Path::Router.new;
isa_ok($r, 'Path::Router');

class Math::Simple::Add { }
class Math::Simple::Sub { }
class Math::Simple::Mul { }
class Math::Simple::Div { }

$r.add-route('/math/simple/add', { target => Math::Simple::Add.new });
$r.add-route('/math/simple/sub', { target => Math::Simple::Sub.new });
$r.add-route('/math/simple/mul', { target => Math::Simple::Mul.new });
$r.add-route('/math/simple/div', { target => Math::Simple::Div.new });

isa_ok($r.match('math/simple/add').target, 'Math::Simple::Add');
isa_ok($r.match('math/simple/sub').target, 'Math::Simple::Sub');
isa_ok($r.match('math/simple/mul').target, 'Math::Simple::Mul');
isa_ok($r.match('math/simple/div').target, 'Math::Simple::Div');

done;
