use v6;

=begin pod

=head1 NAME

Algorithm::Trie::libdatrie - a character keyed trie using the datrie library.

=head1 SYNOPSIS

  use Algorithm::Trie::libdatrie;

  my Trie $t .= new: 'a'..'z', 'A'..'Z';
  my @words = <pool prize preview prepare produce progress>;
  for @words.kv -> $data, $word {
    $t.store( $word, $data );
  }
  $data = $t.retrieve($word);
  my $iter = $t.iterator;
  while $iter.next {
    $key = $iter.key;
    $data = $iter.value;
  }

=head1 WARNING

More documentation and maybe a few more features and tests are planned.  For
now the tests are probably the best documentation.

=head1 DESCRIPTION

Algorithm::Trie::libdatrie is an implementation of a character keyed L<trie|http://en.wikipedia.org/wiki/Trie> using the L<datrie|http://linux.thai.net/~thep/datrie/datrie.html> library.

As the author of the datrie library states:

=begin para :nested

Trie is a kind of digital search tree, an efficient indexing method with
O(1) time complexity for searching. Comparably as efficient as hashing,
trie also provides flexibility on incremental matching and key spelling
manipulation. This makes it ideal for lexical analyzers, as well as
spelling dictionaries.

This library is an implementation of double-array structure for representing
trie, as proposed by Junichi Aoe. The details of the implementation can be
found at L<http://linux.thai.net/~thep/datrie/datrie.html>

=end para

=head1 Classes and Methods

=head2 Trie

  multi method new(**@ranges) returns Trie
  multi method new(Str $file) returns Trie
  method save(Str $file) returns Bool
  method is-dirty() returns Bool
  method store(Str $key, Int $data) returns Bool
  method store-if-absent(Str $key, Int $data) returns Bool
  method retrieve(Str $key) returns Int
  method delete(Str $key) returns Bool
  method root() returns TrieState
  method iterator() returns TrieIterator
  method free()
  /* NYI
  sub enum_func(Str $key, Int $value, Pointer[void] $stash) returns Bool { * }
  method enumerate(&enum_func, Pointer[void] $stash) returns Bool
  */

=item new

  my Trie $t .= new: 'a'..'z', 'A'..'Z', '0'..'9';

The set of characters used in C<key>s has a maximum size of 255.  The
characters themselves may be any unicode character who's code will fit in a
32 bit uint.  The C<new> function will map the input ranges into C<0..254>
internally.

  my Trie $t .= new: $file;

A Trie may be loaded from a R<$file> created by the C<save> method.

=item root, iterator

These methods return objects of class C<TrieState> and C<TrieIterator> that
are positioned at the root of the Trie.

=item the rest

Should be mostly self-explanatory.  See the tests.

=head2 TrieState

A TrieState object is used to walk through the Trie character by character.
A TrieState object may also be used to create a TrieIterator in order to
iterate over the nodes beneath the TrieStat's current position.

  method clone() returns TrieState
  method rewind()
  method walk(Str $c where *.chars == 1) returns Bool
  method is-walkable(Str $c where *.chars == 1) returns Bool
  method walkable-chars() returns Array[Str]
  method is-terminal() returns Bool
  method is-single() returns Bool
  method is-leaf() returns Bool
  method value() returns Int
  method free()

=head2 TrieIterator

A TrieIterator can be created from the Trie directly via C<$trie.iterator>
or from a TrieState via C<TrieIterator.new($trie-state)>.

  method new(TrieState $state) returns TrieIterator
  method next() returns Bool
  method key() returns Str
  method value() returns Int
  method free()

=end pod

unit class Algorithm::Trie::libdatrie:ver<v0.2>:auth<github:zengargoyle>;
use NativeCall;
use LibraryMake;

sub library {
  my $so = get-vars('')<SO>;
  my $libname = "lib/libdatrie$so";
  my $lib = %?RESOURCES{$libname}.Str;
  if not $lib.defined {
    die "Unable to find library";
  }
  $lib;
}

# for freeing returned key from TrieIterator.key
sub free(CArray[uint32]) is native(Str) { * }

class AlphaMap is repr('CPointer') { }

class TrieState is export is repr('CPointer') {

  method clone() returns TrieState {
    trie_state_clone(self) || fail 'could not clone';
  }

  # XXX: not implemented, use .clone instead
  # sub copy(TriState $dst, Tristate $src) {
  #   trie_state_copy($dst,$src);
  # }

  method free() {
    trie_state_free(self);
  }

  method rewind() {
    trie_state_rewind(self);
  }

  method walk(Str $c where *.chars == 1) returns Bool {
    trie_state_walk(self, $c.ord) !== 0;
  }

  method is-walkable(Str $c where *.chars == 1) returns Bool {
    trie_state_is_walkable(self, $c.ord) !== 0;
  }

  method walkable-chars() returns Array[Str] {
    my $walkable = CArray[uint32].new;
    $walkable[256] = 0;
    trie_state_walkable_chars(self, $walkable, 256)
      || fail 'could not get walkable chars';
    my Str @w;
    loop {
      state $i = 0;
      last if $walkable[$i] == 0;
      @w.push: $walkable[$i++].chr;
    }
    @w;
  }

  # NOTE: is-terminal is MACRO (TRIE_CHAR_TERM = '\0'
  method is-terminal() returns Bool {
    trie_state_is_walkable(self, 0) !== 0;
  }

  method is-single() returns Bool {
    trie_state_is_single(self) !== 0;
  }

  # NOTE: is-leaf is MACRO
  method is-leaf() returns Bool {
    self.is-single && self.is-terminal();
  }

  method value() returns Int {
    Int( trie_state_get_data(self) );
  }

}

class TrieIterator is export is repr('CPointer') {

  method new(TrieState $state) returns TrieIterator {
    trie_iterator_new($state);
  }

  method next() returns Bool {
    trie_iterator_next(self) !== 0;
  }

  method key() returns Str {
    my Str $key;
    my $k = trie_iterator_get_key(self) || fail 'could not get key';
    loop { state $i = 0; last if $k[$i] == 0; $key ~= $k[$i++].chr }
    free($k);
    $key;
  }

  method value() returns Int {
    Int( trie_iterator_get_data(self) );
  }

  method free() {
    trie_iterator_free(self);
  }

}

class Trie is export is repr('CPointer') {

  multi method new(**@ranges) returns Trie {
    my AlphaMap $map = alpha_map_new();
    for @ranges -> $range {
      alpha_map_add_range($map, |$range.bounds.map(*.ord)) == 0
        or fail "could not add range: $range";
    }
    my $t = trie_new($map) || fail "could not create trie";
    alpha_map_free($map);
    return $t;
  }

  multi method new(Str $file) returns Trie {
    trie_new_from_file($file) || fail "could not load trie from '$file'"
  }
  
  method save(Str $file) returns Bool {
    trie_save(self,$file) == 0 || fail "could not save trie to '$file'";
  }

  method free() {
    trie_free(self);
  }

  method is-dirty() {
    trie_is_dirty(self);
  }

  method store(Str $key, Int $data) returns Bool {
    my $c = CArray[uint32].new($key.ords, 0);
    trie_store(self, $c, $data) !== 0;
  }

  method store-if-absent(Str $key, Int $data) returns Bool {
    my $c = CArray[uint32].new($key.ords, 0);
    trie_store_if_absent(self, $c, $data) !== 0;
  }

  method retrieve(Str $key) returns Int {
    my $c = CArray[uint32].new($key.ords, 0);
    my $ret = CArray[uint32].new(0);
    my $rc = trie_retrieve(self, $c, $ret);
    return Int($ret[0]) but ($rc ?? True !! False);
  }

  method delete(Str $key) returns Bool {
    my $c = CArray[uint32].new($key.ords, 0);
    trie_delete(self, $c) !== 0;
  }

  method root() returns TrieState {
    trie_root(self) || fail 'could not get root state';
  }

  method iterator() returns TrieIterator {
    trie_iterator_new(trie_root(self));
  }

}

#
# AlphaMap
#

sub alpha_map_new() returns AlphaMap
  is native(&library)
  { * }

sub alpha_map_add_range(AlphaMap,int32,int32) returns int32
  is native(&library)
  { * }

sub alpha_map_free(AlphaMap)
  is native(&library)
  { * }

#
# Trie
#

sub trie_new(AlphaMap) returns Trie
  is native(&library)
  { * }

sub trie_new_from_file(Str) returns Trie
  is native(&library)
  { * }

sub trie_save(Trie,Str) returns int32
  is native(&library)
  { * }

sub trie_free(Trie)
  is native(&library)
  { * }

sub trie_store(Trie,CArray[uint32],int32) returns int32
  is native(&library)
  { * }

sub trie_store_if_absent(Trie,CArray[uint32],int32) returns int32
  is native(&library)
  { * }

sub trie_delete(Trie,CArray[uint32]) returns int32
  is native(&library)
  { * }

sub trie_retrieve(Trie,CArray[uint32],CArray[uint32]) returns int32
  is native(&library)
  { * }

sub trie_root(Trie) returns TrieState
  is native(&library)
  { * }

sub trie_is_dirty(Trie) returns uint32
  is native(&library)
  { * }

# TODO: callbacks into Perl 6 make brain hurt.
# sub trie_enumerate(Trie,TrieEnumFunc,Pointer[void]) returns uint32
#   is native(&library)
#   { * }

# XXX: not implemented raw I/O via IO::Handle?
# sub trie_fwrite(Trie,FILE) returns uint32
#   is native(&library)
#   { * }
# sub trie_fread(FILE) returns Trie
#   is native(&library)
#   { * }

#
# TrieIterator
#

sub trie_iterator_new(TrieState) returns TrieIterator
  is native(&library)
  { * }

sub trie_iterator_next(TrieIterator) returns Bool
  is native(&library)
  { * }

sub trie_iterator_get_key(TrieIterator) returns CArray[uint32]
  is native(&library)
  { * }

sub trie_iterator_get_data(TrieIterator) returns uint32
  is native(&library)
  { * }

sub trie_iterator_free(TrieIterator)
  is native(&library)
  { * }

#
# TrieState
#

sub trie_state_clone(TrieState) returns TrieState
  is native(&library)
  { * }

# XXX: no copy, use clone
# sub trie_state_copy(TrieState) returns TrieState
#   is native(&library)
#   { * }

sub trie_state_free(TrieState)
  is native(&library)
  { * }

sub trie_state_rewind(TrieState)
  is native(&library)
  { * }

sub trie_state_walk(TrieState,uint32) returns uint32
  is native(&library)
  { * }

sub trie_state_is_walkable(TrieState,uint32) returns uint32
  is native(&library)
  { * }

sub trie_state_walkable_chars(TrieState,CArray[uint32],uint32) returns uint32
  is native(&library)
  { * }

sub trie_state_is_single(TrieState) returns uint32
  is native(&library)
  { * }

sub trie_state_get_data(TrieState) returns uint32
  is native(&library)
  { * }


=begin pod

=head1 SEE ALSO

The datrie library: L<http://linux.thai.net/~thep/datrie/datrie.html>

Wikipedia entry for: L<Trie|http://en.wikipedia.org/wiki/Trie>

=head1 AUTHOR

zengargoyle <zengargoyle@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 zengargoyle

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
