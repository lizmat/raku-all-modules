use v6.c;

module Bits:ver<0.0.2>:auth<cpan:ELIZABETH> {
    use nqp;

    my constant $nibble2pos = nqp::list(
      nqp::list_i(),          #  0
      nqp::list_i(0),         #  1
      nqp::list_i(1),         #  2
      nqp::list_i(0,1),       #  3
      nqp::list_i(2),         #  4
      nqp::list_i(0,2),       #  5
      nqp::list_i(1,2),       #  6
      nqp::list_i(0,1,2),     #  7
      nqp::list_i(3),         #  8
      nqp::list_i(0,3),       #  9
      nqp::list_i(1,3),       # 10
      nqp::list_i(0,1,3),     # 11
      nqp::list_i(2,3),       # 12
      nqp::list_i(0,2,3),     # 13
      nqp::list_i(1,2,3),     # 14
      nqp::list_i(0,1,2,3)    # 15
    );

    my class IterateBits does Iterator {
        has Int $!bitmap;   # the bitmap we're looking at
        has int $!offset;   # the current offset towards nibbles
        has     $!list;     # list of positions for current nibble

        method !SET-SELF(\bitmap) {
            my $bitmap := nqp::decont(bitmap);
            nqp::if(
              $bitmap && nqp::isne_I($bitmap,-1),
              nqp::stmts(
                ($!bitmap := nqp::if(
                  nqp::islt_I($bitmap,0),
                  nqp::mul_I(-2,nqp::add_I($bitmap,1,Int),Int),
                  $bitmap
                )),
                ($!offset = -4),
                ($!list  := nqp::atpos($nibble2pos,0)),
                self
              ),
              Rakudo::Iterator.Empty
            )
        }
        method new(\bitmap) { nqp::create(self)!SET-SELF(bitmap) }

        method pull-one() {
            nqp::if(
              nqp::elems($!list),
              nqp::add_i($!offset,nqp::shift_i($!list)),   # value ready
              nqp::if(                                     # value NOT ready
                $!bitmap,
                nqp::stmts(                                 # not done yet
                  nqp::while(
                    $!bitmap && nqp::isfalse(
                      my int $index = nqp::bitand_I($!bitmap,15,Int)
                    ),
                    nqp::stmts(                              # next nibble
                      ($!offset  = $!offset + 4),
                      ($!bitmap := nqp::bitshiftr_I($!bitmap,4,Int))
                    )
                  ),
                  nqp::if(                                  # done searching
                    $!bitmap,
                    nqp::stmts(                              # found nibble
                      (my int $pos = nqp::add_i(              # convert index
                        ($!offset = nqp::add_i($!offset,4)),  # to position by
                        nqp::shift_i(                         # fetching value
                          ($!list := nqp::clone(              # from the right
                            nqp::atpos($nibble2pos,$index)    # list
                          ))
                        )
                      )),
                      ($!bitmap := nqp::bitshiftr_I($!bitmap,4,Int)),
                      $pos
                    ),
                    IterationEnd                              # done now
                  )
                ),
                IterationEnd                                 # already done
              )
            )
        }
    }

    sub bit(Int:D \bitmap, UInt:D \offset --> Bool:D) is export {
        nqp::hllbool(bitmap +& (1 +< offset))
    }

    sub bits(Int:D \bitmap --> Seq:D) is export {
        Seq.new( IterateBits.new(bitmap))
    }

    # nibble -> number of bits conversion
    my constant $nibble2bits = nqp::list_i(0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4);

    sub bitcnt(Int:D \bitmap --> Int:D) is export {
        my $bitmap := nqp::decont(bitmap);
        nqp::if(
          $bitmap && nqp::isne_I($bitmap,-1),
          nqp::stmts(                                 # has significant bits
            ($bitmap := nqp::if(
              nqp::isle_I($bitmap,0),
              nqp::mul_I(-2,nqp::add_I($bitmap,1,Int),Int),
              $bitmap
            )),
            (my int $bits = 0),
            nqp::while(
              $bitmap,
              nqp::stmts(
                ($bits = $bits + nqp::atpos_i(
                  $nibble2bits,
                  nqp::bitand_I($bitmap,0x0f,Int)
                )),
                ($bitmap := nqp::bitshiftr_I($bitmap,4,Int)),
              )
            ),
            $bits
          ),
          0                                           # no significant bits
        )
    }
}

=begin pod

=head1 NAME

Bits - provide bit related functions

=head1 SYNOPSIS

  use Bits;  # exports "bit", "bits", "bitcnt"

  say bit(8, 3);    # 1000 -> True
  say bit(7, 3);    # 0111 -> False

  say bits(8);      # 1000 -> (3,).Seq
  say bits(7);      # 0111 -> (0,1,2).Seq

  say bitcnt(8);    # 1000 -> 1
  say bitcnt(7);    # 0111 -> 3

=head1 DESCRIPTION

This module exports a number of function to handle bits in unsigned integer
values.

=head1 SUBROUTINES

=head2 bit

  sub bit(Int:D value, UInt:D bit --> Bool:D)

Takes a integer value and a bit number and returns whether that bit is set.

=head2 bits

  sub bits(Int:D value --> Seq:D)

Takes a integer value and returns a C<Seq>uence of the bit numbers that are
significant in the value.  For negative values, these are the bits that are 0.

=head2 bitcnt

  sub bitcnt(Int:D value --> Int:D)

Takes a integer value and returns the number of significant bits that are set
in the value.  For negative values, this is the number of bits that are 0.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Bits .  Comments and Pull
Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
