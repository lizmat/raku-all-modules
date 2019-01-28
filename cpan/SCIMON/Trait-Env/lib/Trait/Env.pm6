use v6.c;
#no precompilation;

my %EXPORT;

module Trait::Env:ver<0.5.1>:auth<cpan:SCIMON> {

    use Trait::Env::Attribute;
    use Trait::Env::Variable;

    %EXPORT<&trait_mod:<is>> = &trait_mod:<is>;
}

sub EXPORT { %EXPORT }

=begin pod

=head1 NAME

Trait::Env - Trait to set an attribute from an environment variable.

=head1 SYNOPSIS

  use Trait::Env;
  class Test {
      # Sets from %*ENV{HOME}. Undef if the var doesn't exist
      has $.home is env;

      # Sets from %*ENV{TMPDIR}. Defaults to '/tmp'
      has $.tmpdir is env is default "/tmp";

      # Sets from %*ENV{EXTRA_DIR}. Defaults to '/tmp'
      has $.extra-dir is env( :default</tmp> );

      # Set from %*ENV{WORKDIR}. Dies if not set.
      has $.workdir is env(:required);

      # Set from %*ENV{READ_DIRS.+} ordered lexically
      has @.read-dirs is env;

      # Set from %*ENV{PATH} split on ':'
      # has @.path is env(:sep<:>);
      # Or default to the $*DISTRO.path-sep value
      has @.path is env;      
      
      # Set from %*ENV{NAME_MAP} data split on ';' pairs split on ':'
      # EG a:b;c:d => { "a" => "b", "c" => "d" }
      has %.name-map is env( :sep<;>, :kvsep<:> );

      # Get all pairs where the key ends with '_POST'
      has %.post-map is env( :post_match<_POST> );

      # Get all pairs where the Key starts with 'PRE_'
      has %.pre-map is env( :pre_match<PRE_> );

      # Get all pairs where the Key starts with 'PRE_' and ends with '_POST'
      has %.both-map is env( :pre_match<PRE_>, :post_match<_POST> );
  }

  # Sets from %*ENV{HOME}. Undef if the var doesn't exist
  has $home is env;

  # Sets from %*ENV{PATH}. Uses default path seperator
  has @path is env;

=head1 DESCRIPTION

Trait::Env is exports the new trait C<is env>.

Currently it's only working on Class / Role Attributes but I plan to expand it to variables as well in the future. 

Note the the variable name will be uppercased and any dashes changed to underscores before matching against the environment.
This functionality may be modifiable in the future.

For Booleans the standard Empty String == C<False> other String == C<True> works but the string "True" and "False" (any capitalization) will also map to True and False respectively.

If a required attribute is not set the code will raise a C<X::Trait::Env::Required::Not::Set> Exception.

Defaults can be set using the standard C<is default> trait or the C<:default> key. Note that for Positional attributes only the C<:default> key works.

Positional attributes will use the attribute name (after coercing) as the prefix to scan %*ENV for.
Any keys starting with that prefix will be ordered by the key name lexically and their values put into the attribute.

Alternatively you can use the C<:sep> key to specify a seperator, in which case the single value will be read based on the name and the list then created by spliting on this seperator.

If there is a single matching environment variable and no C<:sep> key is set then the system will fall back to splitting on the C<$*DISTRO.path-sep> value as a seperator.
                                                                     
Hashes can be single value with a C<:sep> key to specify the seperator between pairs and a C<:kvsep> to specifiy the seperator in each pair between key and value.

Hashes can also be defined by giving a C<:post_match> or C<:pre_match> arguments (or both).
Any Environment variable starting with C<:pre_match> is defined or ending with C<:post-match> if defined will be included.

Scalars, Positionals and Associative attributes can all be typed.

Variables can also be defined with C<is env> following the same rules.		     

Attribute or Variable only C<is env> traits can be loaded individually with C<Trait::Env::Attribute> and C<Trait::Env::Variable>.

=head2 Note

Currently there is a known issue with the Attribute code which means it can't be precompiled.
The Variable code does work precompiled and if speed is important you may want to use just C<Trait::Env::Varaible>. 

=head1 AUTHOR

Simon Proctor <simon.proctor@gmail.com>

Thanks to Jonathan Worthington and Elizabeth Mattijsen for giving me the framework to build this on. Any mistakes are mine. 

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
