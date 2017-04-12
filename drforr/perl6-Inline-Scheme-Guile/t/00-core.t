#!/usr/bin/env perl6

use v6;
use Test;

plan 10;

use Inline::Scheme::Guile;

my $g = Inline::Scheme::Guile.new;

is-deeply [ $g.run( q{}         ) ], [ ], q{empty};
is-deeply [ $g.run( q{(values)} ) ], [ ], q{(values) -> empty};

#$g._dump('#()');
subtest sub
	{
	plan 15;

# Anything that returns 0 to Perl 6 dies.
	is-deeply [ $g.run( q{#nil}  ) ], [ Nil   ], q{#nil};
#	is-deeply [ $g.run( q{#f}    ) ], [ False ], q{#f};
	is-deeply [ $g.run( q{#t}    ) ], [ True  ], q{#t};
#	is-deeply [ $g.run( q{0}     ) ], [ 0     ], q{0};
	is-deeply [ $g.run( q{1}     ) ], [ 1     ], q{1};
	is-deeply [ $g.run( q{-1}    ) ], [ -1    ], q{-1};
	is-deeply [ $g.run( q{""}    ) ], [ ""    ], q{""};
	is-deeply [ $g.run( q{"foo"} ) ], [ "foo" ], q{"foo"};
	is-deeply [ $g.run( q{"£"}   ) ], [ "£"   ], q{"£"};

	is-deeply [ $g.run( q{-1.2} ) ],
		  [ -1.2e0 ],
		  q{-1.2 -> -1.2e0 (?)};

	is-deeply [ $g.run( q{-1/2} ) ],
		  [ -1.0e0/2.0e0  ],
		  q{-1/2 -> -1.0e0/2.0e0};

	is-deeply [ $g.run( q{-1+2i} ) ],
		  [ -1.0e0+2.0e0i  ],
		  q{-1+2i -> -1.0e0+2.0e0i};

	is-deeply [ $g.run( q{'a} ) ],
		  [ Inline::Scheme::Guile::Symbol.new( :name('a') ) ],
		  q{'a -> ::Symbol};

	is-deeply [ $g.run( q{#:a} ) ],
		  [ Inline::Scheme::Guile::Keyword.new( :name('a') ) ],
		  q{#:a -> ::Keyword};

#`( False still dies.
	is-deeply [ $g.run( q{#*000101} ) ],
                  [ Inline::Scheme::Guile::Vector.new(
		      :value( False, False, False, True, False, True ) ) ],
                  q{#*000101 -> BitVector};
)
	},
	q{Single atom};

subtest sub
	{
	plan 4;

	is-deeply [ $g.run( q{#()} ) ],
                  [ Inline::Scheme::Guile::Vector.new( :value( ) ) ],
                  q{#() -> ::Vector};

	is-deeply [ $g.run( q{#(1)} ) ],
                  [ Inline::Scheme::Guile::Vector.new( :value( 1 ) ) ],
                  q{#(1) -> ::Vector};

	is-deeply [ $g.run( q{#(1 2)} ) ],
                  [ Inline::Scheme::Guile::Vector.new( :value( 1, 2 ) ) ],
                  q{#(1 2) -> ::Vector};

	# #('a) returns as #( (quote a) ), so a list.
	#
	is-deeply [ $g.run( q{#(#nil #t 1 2.3 2/3 -1+2i "foo" #:bar)} ) ],
                  [ Inline::Scheme::Guile::Vector.new(
		      :value( Nil, True, 1, 2.3e0, 2.0e0/3.0e0,
			      -1.0e0+2.0e0i, "foo",
			      Inline::Scheme::Guile::Keyword.new( :name('bar') )
 ) ) ],
                  q{#(#nil #t 1 2.3 2/3 -1+2i "foo" #:bar) -> ::Vector};
	},
	q{Composite atom};

subtest sub
	{
	plan 2;

	is-deeply [ $g.run( q{(values 1 2)} ) ],
		  [ 1, 2 ],
		  q{(values 1 2) returns a list of values};

	is-deeply [ $g.run( q{(values 1 2 3 4 5 6 7 8 9 10)} ) ],
		  [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ],
		  q{(values 1 2 3 4 5 6 7 8 9 10) returns a list of values};
	},
	q{Two return values (not a two-element list)};

subtest sub
	{
	plan 2;

	is-deeply [ $g.run( q{#(#())} ) ],
                  [ Inline::Scheme::Guile::Vector.new( :value(
                      Inline::Scheme::Guile::Vector.new( :value( ) ) ) ) ],
                  q{#(#()) -> ::Vector(::Vector)};

	is-deeply [ $g.run( q{#(1 #(2) 3)} ) ],
                  [ Inline::Scheme::Guile::Vector.new( :value( 1,
                      Inline::Scheme::Guile::Vector.new( :value( 2 ) ), 3 ) ) ],
                  q{#(1 #(2) 3) -> ::Vector(::Vector)};
	},
	q{Nested vectors};

subtest sub
	{
	is-deeply [ $g.run( q{(values 1 #(2) 3)} ) ],
                  [ 1, Inline::Scheme::Guile::Vector.new( :value( 2 ) ), 3 ],
                  q{(values 1 #(2) 3) -> ::Vector};
	},
	q{Composite atom in a list of singletons};

subtest sub
	{
	is-deeply [ $g.run( q{'()} ) ],
		  [ $[ ] ],
		  q{'()};

	is-deeply [ $g.run( q{'(1 2 3)} ) ],
		  [ $[ 1, 2, 3 ] ],
		  q{'(1 2 3)};

	is-deeply [ $g.run( q{'(1 ( 2 ) 3)} ) ],
		  [ $[ 1, $[ 2 ], 3 ] ],
		  q{'(1 ( 2 ) 3)};
	},
	q{List};

subtest sub
	{
	plan 1;

	$g.run( q{(define (inc-it x) (+ x 1))} );

	is-deeply [ $g.run( q{(inc-it 2)} ) ], [ 3 ], q{(inc-it 2) is 3};
	},
	q{Environment persists};

is $g.call( '+', 3, 4 ), 7, q{(+ 3 4) -> 7};
