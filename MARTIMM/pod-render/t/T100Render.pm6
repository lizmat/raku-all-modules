#!/usr/bin/env perl6

use v6.c;

#===============================================================================
=begin pod

=TITLE T100Render::A

=SUBTITLE Testing the POD document rendering process

=begin code
  unit package T100Render;
  class A { ... }
=end code

=head1 Synopsis

=end pod
#===============================================================================
unit package T100Render;

#-------------------------------------------------------------------------------
class A {

  #=============================================================================
  =begin pod

  =head1 Methods
  =head2 return-ah

  Defined as

    method return-ah ( --> Str )
  
  Method which returns a string I<aahhh>.

  =end pod
  #=============================================================================

  method return-ah ( --> Str ) {
    'aahhh';
  }
}
