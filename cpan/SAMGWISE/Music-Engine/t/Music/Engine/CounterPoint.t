#! /usr/bin/env perl6
use v6;
use Test;

use-ok("Music::Engine::CounterPoint");
use Music::Engine::CounterPoint;

my Music::Engine::CounterPoint $gen .= new( :max-range(36) );

is $gen.defined, True, "Music::Engine::CounterPoint instantiated OK";

#
# SKIP need to fix this up
#
# $gen.update-contour-target(0, -7);
# my Seq $notes = $gen.notes( Seq((0,-7), (-1, -6), (0, -7)), 3 );
# is $notes[0], (0, -12),                            "Limited option note generation 0";
# is $notes[1], (-1, -5)|(-1, -3)|(-1, -10)|(0, -3)|(-3, -7), "Limited option note generation 1";
# is $notes[2], (0, -12)|(-5, -5),            "Limited option note generation 2";


done-testing
