use v6.c;

my %export;
module P5built-ins:ver<0.0.12>:auth<cpan:ELIZABETH> {
    use P5caller;
    use P5chdir;
    use P5chomp;
    use P5chr;
    use P5each;
    use P5fc;
    use P5fileno;
    use P5hex;
    use P5index;
    use P5lc;
    use P5lcfirst;
    use P5length;
    use P5localtime;
    use P5opendir;
    use P5pack;
    use P5push;
    use P5quotemeta;
    use P5readlink;
    use P5ref;
    use P5reverse;
    use P5seek;
    use P5shift;
    use P5sleep;
    use P5study;
    use P5substr;
    use P5tie;
    use P5times;
    use P5-X;

    # there must be a better way to do this, but this will work for now
    %export = MY::.keys.grep( *.starts-with('&') ).map: { $_ => ::($_) };
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

  use P5built-ins;   # import all P5 built-in functions supported

  use P5built-ins <tie untie>;  # only import specific ones

  tie my @a, Foo;

=head1 DESCRIPTION

This module provides an easy way to import a growing number of built-in
functions of Perl 5 in Perl 6.  Currently supported at:

  caller chdir chomp chop chr closedir each fc fileno gmtime hex index lc
  lcfirst length localtime oct opendir ord pack pop push quotemeta readdir
  readlink ref rewinddir rindex seek seekdir shift sleep study substr
  telldir tie tied times uc ucfirst unpack unshift untie
  
The following file test operators are also available:

  -r -w -x -e -f -d -s -z -l

=head1 PORTING CAVEATS

Please look at the porting caveats of the underlying modules that actually
provide the functionality:

  module      | built-in functions
  ------------+-------------------
  P5caller    | caller
  P5chdir     | chdir
  P5each      | each
  P5fileno    | fileno
  P5length    | length
  P5localtime | localtime gmtime
  P5opendir   | opendir readdir telldir seekdir rewinddir closedir
  P5pack      | pack unpack
  P5readlink  | readlink
  P5ref       | ref
  P5reverse   | reverse
  P5study     | study
  P5tie       | tie, tied, untie
  P5times     | times
  P5-X        | -r -w -x -e -f -d -s -z -l

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5built-ins . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
