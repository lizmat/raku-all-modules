#!/usr/bin/env perl6

use Text::Template ;
use IO::Capture::Simple ;

use Test ;
plan 17 ;

my $filled = '' ;

my $t = 'author: $author, title: $title' ;
$filled = fill_in $t, variables => { author => 'M. Twain', title => 'Niagara'} ;
is $filled, 'author: M. Twain, title: Niagara', 'variables from parameters' ;
is $filled.lines.elems, 1, '1 line' or diag $filled ;


$filled = fill_in 'file_template'.IO.slurp, variables => { location => 'in file'} ;
is $filled, "where are we? in file\n", 'file template' ;
is $filled.lines.elems, 1, '1 line' or diag $filled ;


$filled = fill_in q:to/TEMPLATE/, variables => { location => 'TOP' } ;
	# include text file, it will be included verbatim
	{ 'file_template'.IO.slurp }

	# include text file and render it with the current variables
	{ fill_in 'file_template'.IO.slurp, variables => %variables }

	# include text file and render it with specific variables
	{ fill_in 'file_template'.IO.slurp, variables => {location => 'in_include'} }
	TEMPLATE

is $filled, q:to/FILLED/, 'include' ;
# include text file, it will be included verbatim
where are we? $location


# include text file and render it with the current variables
where are we? TOP


# include text file and render it with specific variables
where are we? in_include

FILLED
is $filled.lines.elems, 11, '11 lines' or diag $filled ;

my $r = capture_stderr 
	{
	$filled = Nil ;
	lives-ok { $filled = fill_in '$non_existant', :catch_exceptions }, 'catch exception' ;
	is($filled, Any, 'nothing returned after exception') ;
	} ;

ok $r ~~ /'fill_in exception: Variable \'$non_existant\' is not declared'/, 'warnings' ;


$r = capture_stderr 
	{
	$filled = Nil ;
	lives-ok { $filled = fill_in '$non_existant', :catch_exceptions, :no_warnings }, 'catch exception, no warnings' ; 
	is($filled, Any, 'nothing returned after exception') ;
	} ;

is($r, Any, 'no warnings') ;


try { fill_in '$non_existant' }
ok($!.defined, 'try') or diag $filled ;

lives-ok
	{
	$filled = fill_in q:to/TEMPLATE/, variables => {hash => {a => 1}, array => [4..6], private_sub => sub {'in private_sub'},} ;
		\%has<a> = %hash<a>
		{ @array.map({ "array item * $_"}).join("\n") }
		
		{ private_sub }
		TEMPLATE
	}, 'perl6 code' ;

is $filled, q:to/FILLED/, 'perl6 code' ;
%has<a> = 1
array item * 4
array item * 5
array item * 6

in private_sub
FILLED

is $filled.lines.elems, 6, '6 lines' or diag $filled ;


try 
	{
	fill_in (q:to/TEMPLATE/, :catch_exceptions) ;
		$( my $not_scoped = 1 ) ... $not_scoped
		{ my $scoped = 1 } ... $scoped will generate an exception
		TEMPLATE
	}

ok($!.defined, 'P6 scope exception') or diag $filled ;



