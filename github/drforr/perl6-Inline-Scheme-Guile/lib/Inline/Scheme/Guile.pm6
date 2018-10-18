use NativeCall;

=begin pod

=head1 Inline::Scheme::Guile

C<Inline::Scheme::Guile> is a Perl 6 binding to GNU Guile Scheme.

=head1 Synopsis

    use Inline::Scheme::Guile;

    my $g = Inline::Scheme::Guile.new;
    say "Scheme says 3 + 4 is " ~ $g.run('(+ 3 4)');

    say "Scheme says 3 + 4 is " ~ $g.call( '+', 3, 4 );

=head1 Documentation

You obviously need to have Guile Scheme (L<https://www.gnu.org/software/guile/manual/guile.html>)
installed in order for this module to work. At some point an L<Alien::> package
may be created to help this process. I'd prefer to have a proper repository
but that would be even more yak shaving.

You can pass any Scheme code you like to the running Guile compiler, and it
will respond with the return value(s) from the result of executing that
expression. For a full list of object types, it's probably best to look at the
test suite, but here's a brief summary of the important types:

  =item nil

  Unsurprisingly, maps to the Nil object in Perl 6.

  =item #f

  Maps to False in Perl 6.

  =item #t

  Maps to True

  =item Integers

  Those that fit into int32 map onto a regular Int in Perl 6.
  More research is needed for wider types as of this writing.

  =item Rationals

  Map onto a Perl 6 rational, with a denominator and numerator part.

  =item Complex numbers

  Map onto a Perl 6 complex value, with a real and imaginary part.

  =item Strings

  Map to the Str type.

  =item Symbols ('foo)

  Map onto the (somewhat unwieldy) L<Inline::Scheme::Guile::Symbol> type.
  These have simply a C<:name('foo')> attribute.

  'foo expands to the macro (quote foo) inside vectors, lists and pairs.
  So don't expect to find the L<::Symbol> inside these constructs.

  =item Keywords (#:foo)

  Map onto the (somewhat unwieldy) L<Inline::Scheme::Guile::Keyword> type.
  These have simply a C<:name('foo')> attribute.

  Keywords don't have an equivalent quoted form, so they will appear verbatim
  in lists, vectors and such.

  =item List ('(1 2 3))

  Map onto an array reference. See below about multiple-value returns to see
  why this was chosen.

  =item Vector (#(1 2 3))

  Map onto the (somewhat unwieldy) L<Inline::Scheme::Guile::Vector> type.
  These have a C<:values(1,2,3)> attribute storing the values in the vector.

Scheme functions can return a single value, or more than one value. This is not
the same as a Scheme function returning a list of values. For instance:

C<$g.run('3')> returns just the value C<3>.

C<$g.run('(+ 3 4)')> returns just the value C<7>.

C<$g.run( q{'(3 4)} )> returns a list B<reference> C<[3, 4]>.

C<$g.run( q{(values 3 4)} )> returns two values, C<(3, 4)>.

Multiple-value return is the main reason why lists are array references, rather
than lists in and of themselves. Also, sometimes (most of the time (no, really))
lists are nested, and the inner layer would have to be a list reference anyway,
so for consistency's sake all lists are considered references.

=end pod

constant LIST_START       = -260;
constant LIST_END         = -259;

constant BITVECTOR_START  = -258;
constant BITVECTOR_END    = -257;

constant VECTOR_START     = -256;
constant VECTOR_END       = -255;
                         
constant UNKNOWN_TYPE     = -2;
constant VOID             = -1;
constant ZERO             = 0;
constant TYPE_NIL         = 1;
constant TYPE_BOOL        = 2;
constant TYPE_INTEGER     = 3;
constant TYPE_STRING      = 4;
constant TYPE_DOUBLE      = 5;
constant TYPE_RATIONAL    = 6;
constant TYPE_COMPLEX     = 7;
constant TYPE_SYMBOL      = 8;
constant TYPE_KEYWORD     = 9;

class Inline::Scheme::Guile::Symbol { has Str $.name }
class Inline::Scheme::Guile::Keyword { has Str $.name }
class Inline::Scheme::Guile::Vector { has @.value }
class Inline::Scheme::Guile::BitVector { has @.value }

class Inline::Scheme::Guile::AltDouble is repr('CStruct')
	{
	has num64 $.real_part;
	has num64 $.imag_part;
	}

class Inline::Scheme::Guile::AltRational is repr('CStruct')
	{
	has num64 $.numerator_part;
	has num64 $.denominator_part;
	}

class Inline::Scheme::Guile::AltType is repr('CUnion')
	{
	has long $.int_content;
	has num64 $.double_content;
	has Str $.string_content;
	HAS Inline::Scheme::Guile::AltDouble $.complex_content;
	HAS Inline::Scheme::Guile::AltRational $.rational_content;
	}

class Inline::Scheme::Guile::ConsCell is repr('CStruct')
	{
	has int32 $.type;
	HAS Inline::Scheme::Guile::AltType $.content;
	HAS Pointer $.next;
	HAS Pointer $.previous;
	}

class Inline::Scheme::Guile
	{
	sub native(Sub $sub)
		{
		my Str $path = %?RESOURCES<libraries/guile-helper>.Str;
		die "unable to find libguile-helper library"
			unless $path;
		trait_mod:<is>($sub, :native($path));
		}

	sub _dump( Str $expression ) { ... }
		native(&_dump);

	method _dump( Str $expression )
		{
		say "Asserting '$expression'";
		_dump( $expression );
		}

	sub run( Str $expression,
		 &marshal_guile (Pointer[Inline::Scheme::Guile::ConsCell]) )
		   { ... }
		native(&run);

	method push_something( @stack, $content )
		{
		if @stack[*-1] ~~ Inline::Scheme::Guile::Vector or
		   @stack[*-1] ~~ Inline::Scheme::Guile::BitVector
			{
			@stack[*-1].value.push( $content );
			}
		else
			{
			@stack[*-1].push( $content );
			}
		}

	method push_cell( @stack, $cell )
		{
		my $deref_content = $cell.deref.content;
		given $cell.deref.type
			{
			when VOID { }
			when TYPE_NIL
				{
				self.push_something( @stack, Nil );
				}
			when TYPE_BOOL
				{
				my $content =
					$deref_content.int_content
						?? True !! False;
				self.push_something( @stack, $content );
				}
			when TYPE_INTEGER
				{
				my $content =
					$deref_content.int_content;
				self.push_something( @stack, $content );
				}
			when TYPE_STRING
				{
				my $content =
					 $deref_content.string_content;
				self.push_something( @stack, $content );
				}
			when TYPE_RATIONAL
				{
				my $content =
					$deref_content.rational_content.numerator_part /
					$deref_content.rational_content.denominator_part;
				self.push_something( @stack, $content );
				}
			when TYPE_COMPLEX
				{
				my $content =
					$deref_content.complex_content.real_part + $deref_content.complex_content.imag_part * i;
				self.push_something( @stack, $content );
				}
			when TYPE_SYMBOL
				{
				my $content =
					Inline::Scheme::Guile::Symbol.new(
						:name( $deref_content.string_content ) );
				self.push_something( @stack, $content );
				}
			when TYPE_KEYWORD
				{
				my $content =
					Inline::Scheme::Guile::Keyword.new(
						:name( $deref_content.string_content ) );
				self.push_something( @stack, $content );
				}

			when LIST_START
				{
				my $v = [ ];
				self.push_something( @stack, $v );
				@stack.push( $v );
				}
			when LIST_END
				{
				@stack.pop;
				}

			when BITVECTOR_START
				{
				my $v = Inline::Scheme::Guile::BitVector.new(
						:values() );
				self.push_something( @stack, $v );
				@stack.push( $v );
				}
			when BITVECTOR_END
				{
				@stack.pop;
				}

			when VECTOR_START
				{
				my $v = Inline::Scheme::Guile::Vector.new(
						:values() );
				self.push_something( @stack, $v );
				@stack.push( $v );
				}
			when VECTOR_END
				{
				@stack.pop;
				}
			}
		}

	method run( Str $expression )
		{
		CATCH
			{
			warn "Must not die inside C callback";
			warn $_;
			}
		my @stuff;
		my @stack;
		@stack.push( @stuff );
		my $ref = sub ( Pointer[Inline::Scheme::Guile::ConsCell] $cell )
			{
			self.push_cell( @stack, $cell );
			}
		run( $expression, $ref );
		return @stuff;
		}

	method to-list( $operator, @args )
		{
		my @name = map
			{
			if $_ ~~ Array
				{ '(' ~ self.to-list( @( $_ ) ) ~ ')' }
			elsif $_ ~~ Inline::Scheme::Guile::Symbol
				{ qq{'$_.name} }
			elsif $_ ~~ Inline::Scheme::Guile::Keyword
				{ qq{#:$_.name} }
			elsif $_ ~~ Numeric { $_ }
			elsif $_ ~~ Str { qq{"$_"} }
			elsif $_ ~~ Bool { $_ ?? q{#t} !! q{#f} }
			elsif $_ ~~ Nil { q{#nil} }
			else
				{
die "Unmapped type\n";
				}
			}, @args;
		return '(' ~ "$operator " ~ @name.join( ' ' ) ~ ')';
		}

	method call( Str $operator, *@args )
		{
		my $str = self.to-list( $operator, @args );
		self.run( $str );
		}
	}
