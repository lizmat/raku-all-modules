
unit module Text::Template ;

=begin pod

=NAME
Text::Template - Expand text template with embedded Perl6 code

=SYNOPSIS
	
	use Text::Template ;

	my $t = 'author: $author, title: $title' ;
	say fill_in $t, variables => { author => 'M. Twain', title => 'Niagara'} ;

=DESCRIPTION
Given a text template, which may contain references to variables and code, and
a set of variables, I<fill_in> will render your template.

The text template can be a string or a Heredoc for multi line templates. You 
can define your template in your code or in a separate file.

I<Text::Template> is a thin layer over Perl6 string interpolation and EVAL, it
is important to understand the security implications when using it.

The way EVAL works doesn't make it possible to use local variables, you need to
pass your variables to I<fill_in>. I will try to work around that limitation
but passing variables in the call to I<fill_in>or collecting them in a hash to
pass to I<fill_in> often looks cleaner.

=INTERFACE

=item sub fill_in (Str $template, :%variables?)
Accepts a template and optional variables that you want to define for the 
current template rendering. This may generate exceptions.

=item sub fill_in(Str $template, :%variables?, :$catch_exceptions, :$no_warnings?)
Accepts a template, optional variables, $catch_exceptions flag, and an optional
$no_warnings flag.

if $catch_exceptions is set, I<fill_in> will catch the exceptions and return 
Nil. This lets you handle the calls to I<fill_in> with an error rather than an
exception.

By Default I<fill_in> will display the exception it has caught, you can change
this behavior by passing the $no_warnings flag. 

=head1 VARIABLES

=head2 Passing variables to I<fill_in>
The variables you pass through the %variables hash are local to the I<fill_in>
call. You can also pass subroutines.

	my $title = 'Niagara' ;
	my $t = 'author: $author, title: $title' ;
	say fill_in $t, variables => { author => 'M. Twain', title => $title} ;

=head1 TEMPLATE FILES

=head2 Define template in file
You can use IO.slurp to read your template from a file

	say fill_in 'file_template'.IO.slurp, variables => { location => 'in file'} ;
 
=head2 Including templates

	say fill_in q:to/TEMPLATE/, variables => { location => 'TOP' } ;
		# include text file, it will be included verbatim
		{ 'file_template'.IO.slurp }

		# include text file and render it with the current variables
		{ fill_in 'file_template'.IO.slurp, variables => %variables }

		# include text file and render it with specific variables
		{ fill_in 'file_template'.IO.slurp, variables => {location => 'in_include'} }
		TEMPLATE

I<%variables> are the variables defined in the top call to I<fill_in>.

=head1 EXCEPTIONS / ERRORS

=head2 Let I<fill_in> catch the exceptions

=head3 I<fill_in> catches exception and displays warning
	
	say fill_in( '$non_existant', :catch_exceptions, ... ) // '' ;

=head3 I<fill_in> catches exception, you display handle the error

	say fill_in( '$non_existant', :catch_exceptions, :no_warnings, ... ) 
		// "Can't fill template @$?FILE:$?LINE" ;

=head3 catch exceptions in your code
This gives you all control as you receive the exception.

	try { say fill_in '$non_existant' }
	if $! {	say  "Can't fill template; exception: $! @$?FILE:$?LINE" }

=head1  EMBEDDING Perl6 CODE
You can emmbed Perl6 code blocks, as in you can in any Perl6 string, the 
template can refer to variables, or subroutines, that are defined in the
%variables parameter.
 
	say fill_in q:to/TEMPLATE/, variables => {hash => {a => 1}, array => [4..6], private_sub => sub ( |c) {use Data::Dump::Tree ; get_dump(|c)},} ;
		\%has<a> = %hash<a>
		{ @array.map({ "array item * $_"}).join("\n") }
		
		{ private_sub([{a => [^3]}, 123]) }
		TEMPLATE

=head2 {} vs $()
{} block are scoping blocks, IE, variable declared in the block will not be
visible outside the block.

	say fill_in(q:to/TEMPLATE/, :catch_exceptions) // '' ;
		$( my $not_scoped = 1 ) ... $not_scoped
		{ my $scoped = 1 } ... $scoped ... will generate an exception
		TEMPLATE

=head1 CODE BLOCKS RETURNED VALUES
The value returned by your code blocks is integrated in the rendering og the 
template. if you want to avoid that, return an empty string as the last 
statement of your code block; in a Heredoc, it will use a line of the template
even with an empty string.

Your code block is returns a single value even if it is multiple lines long.


=head1 BUGS
Submit bugs (preferably as executable tests) and, please, make suggestions.

=AUTHOR

Nadim ibn hamouda el Khemir
https://github.com/nkh

=LICENSE

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl6 itself.

=SEE-ALSO

P5 Text::Template

=end pod

sub compile_template (Str $template, :%variables, :$debug?)
{
my $t =
	%variables.kv.map( -> $k, $v 
		{
		given $v
			{
			when Str { "my \$$k := \%variables<$k> ;" }
			when List { "my \@$k := \%variables<$k> ;" }
			when Hash { "my \%$k := \%variables<$k> ;" }
			when Range { "my \@$k := \%variables<$k> ;" }
			when Routine { "my &$k = &\%variables<$k> ;" }

			default { "my \$$k := \%variables<$k> ;" }
			}
		}).join("\n")
		~ "\nqq/{$template}/\n" ;

if $debug { say $t}

$t
}

multi sub fill_in (Str $template, :%variables?, :$debug?) is export
{
use MONKEY-SEE-NO-EVAL ;
EVAL compile_template($template, :%variables, :$debug) ;
}

multi sub fill_in (Str $template, :%variables?, :$debug?, :$catch_exceptions, :$no_warnings?) is export
{
my $filled_in = '' ;

try { $filled_in = fill_in $template, :%variables, :$debug ; }

if $! 
	{
	unless $no_warnings { $*ERR.print( "fill_in exception: $! @" ~ callframe(1).file ~ ':' ~ callframe(1).line) }
	Nil
	}
else
	{ $filled_in }
}

  
DOC INIT {use Pod::To::Text ; pod2text($=pod) ; }

