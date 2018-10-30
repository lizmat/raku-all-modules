=begin pod
=head1 Math::Sequences

C<Math::Sequences> is a module with integer and floating point sequences and some helper modules

=head1 Synopsis

    use Math::Sequences::Integer;  # You have to include one ... 
    use Math::Sequences::Real;     # ... or the other

    say factorial(33);    # from  Math::Sequences::Integer;
    say sigma( 8 );
    say FatPi;

    say ℝ.gist();         # from  Math::Sequences::Real;
    say ℝ.from(pi)[0]

=end pod

unit module Math::Sequences is export;

fail "This here only for documentation purposes\nTry use Math::Sequences::\{Integer|Real}";

