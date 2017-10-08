use v6.c;
unit class Geo::Hash:ver<0.0.1>;

use NativeCall;
use Geo::Hash::Coord;

my constant $library = %?RESOURCES<libraries/geohash>.Str;

my sub geohash_encode(num64, num64, int32) returns Str is native($library) { * }
my sub geohash_decode(Str) returns Geo::Hash::Coord is native($library) { * }
my sub geohash_neighbors(Str) returns CArray[Str] is native($library) { * }

sub geo-encode(Num $lat, Num $lng, Int $precision --> Str) is export(:MANDATORY) {
    geohash_encode($lat, $lng, $precision)
}

sub geo-decode(Str $hash --> Geo::Hash::Coord) is export(:MANDATORY) {
    geohash_decode($hash)
}

sub geo-neighbors(Str $hash --> List) is export(:MANDATORY) {
    my @array;
    my CArray[Str] $tmp = geohash_neighbors($hash);
    @array[$_] = $tmp[$_] for ^8;
    @array
}

=begin pod

=head1 NAME

Geo::Hash - A Perl 6 bindings for libgeohash

=head1 SYNOPSIS

  use Geo::Hash;
  
  my $hash = geo-encode(42.60498046875e0, -5.60302734375e0, 5);
  say $hash; # OUTPUT: «ezs42»
  my Geo::Hash::Coord $coord = geo-decode($hash);
  say $coord.latitude; # OUTPUT: «42.60498046875e0»
  say geo-neighbors($hash); # OUTPUT: «[ezs48 ezs49 ezs43 ezs41 ezs40 ezefp ezefr ezefx]»

=head1 DESCRIPTION

Geo::Hash is a Perl 6 bindings for libgeohash.

=head2 SUBS

=head3 geo-encode

Defined as:

  sub geo-encode(Num $lat, Num $lng, Int $precision --> Str) is export(:MANDATORY)

Encodes given C<$lat> and C<$lng> pair with precision of C<$precision> and creates a hash value.

=head3 geo-decode

Defined as:

  sub geo-decode(Str $hash --> Geo::Hash::Coord) is export(:MANDATORY)

Decodes given C<$hash> and creates a C<Geo::Hash::Coord> object.

=head3 geo-neighbors

Defined as:

  sub geo-neighbors(Str $hash --> List) is export(:MANDATORY)

Returns the 8-neighboring positions, where each position is represented as hash code.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 titsuki

libgeohash ( https://github.com/simplegeo/libgeohash ) by Derek Smith is licensed under the BSD-3-Clause License.

This library is free software; you can redistribute it and/or modify it under the BSD-3-Clause License.
                               
=end pod
