use v6.c;

my %export;  # there must be a better way to do this, but this will work for now
module P5built-ins:ver<0.0.2> {
    use P5caller;
    use P5chomp;
    use P5chop;
    use P5chr;
    use P5each;
    use P5fc;
    use P5hex;
    use P5index;
    use P5lc;
    use P5lcfirst;
    use P5length;
    use P5oct;
    use P5ord;
    use P5pack;
    use P5quotemeta;
    use P5ref;
    use P5rindex;
    use P5substr;
    use P5tie;
    use P5times;
    use P5uc;
    use P5ucfirst;

    BEGIN %export{'&' ~ .name} := $_
      for &caller, &chomp, &chop, &chr, &each, &fc, &hex, &index, &lc, &lcfirst,
          &length, &oct, &ord, &pack, &quotemeta, &ref, &rindex, &substr, &tie,
          &tied, &times, &uc, &ucfirst, &unpack, &untie;
}

multi sub EXPORT() { %export }
multi sub EXPORT(*@args) {
    my $imports := Map.new( |(%export{ @args.map: '&' ~ * }:p) );
    if $imports != @args {
        die "P5built-ins doesn't know how to export: "
          ~ @args.grep( { !$imports{$_} } ).join(', ')
    }
    $imports
}

=begin pod

=head1 NAME

P5built-ins - Implement Perl 5's built-in functions

=head1 SYNOPSIS

  use P5functions;   # import all P5 built-in functions supported

  use P5functions <tie untie>;  # only import specific ones

  tie my @a, Foo;

=head1 DESCRIPTION

This module provides an easy way to import a growing number of built-in functions
of Perl 5 in Perl 6.  Currently supported at:

  caller chomp chop chr each hex index lcfirst length oct ord pack quotemeta
  ref rindex substr tie tied times ucfirst unpack untie

=head1 PORTING CAVEATS

Please look at the porting caveats of the underlying modules that actually
provide the functionality:

  module      | built-in functions
  ------------+-------------------
  P5caller    | caller
  P5each      | each
  P5length    | length
  P5pack      | pack unpack
  P5ref       | ref
  P5tie       | tie, tied, untie
  P5times     | times

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5built-ins . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
