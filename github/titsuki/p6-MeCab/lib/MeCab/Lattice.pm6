use v6;
use NativeCall;
use experimental :pack;

unit class MeCab::Lattice is repr('CPointer');

use MeCab;

my constant $library = %?RESOURCES<libraries/mecab>.Str;

enum RequestType is export (
  :MECAB_ONE_BEST(1),
  :MECAB_NBEST(2),
  :MECAB_PARTIAL(4),
  :MECAB_MARGINAL_PROB(8),
  :MECAB_ALTERNATIVE(16),
  :MECAB_ALL_MORPHS(32),
  :MECAB_ALLOCATE_SENTENCE(64)
);

enum BoundaryConstraintType is export (
  :MECAB_ANY_BOUNDARY(0),
  :MECAB_TOKEN_BOUNDARY(1),
  :MECAB_INSIDE_TOKEN(2)
);

my sub mecab_lattice_destroy(MeCab::Lattice) is native($library) { * }
my sub mecab_lattice_new() returns MeCab::Lattice is native($library) { * }
my sub mecab_lattice_clear(MeCab::Lattice) is native($library) { * }
my sub mecab_lattice_is_available(MeCab::Lattice) returns int32 is native($library) { * }
my sub mecab_lattice_get_bos_node(MeCab::Lattice) returns MeCab::Node is native($library) { * }
my sub mecab_lattice_get_eos_node(MeCab::Lattice) returns MeCab::Node is native($library) { * }
my sub mecab_lattice_get_begin_nodes(MeCab::Lattice, size_t) returns MeCab::Node is native($library) { * }
my sub mecab_lattice_get_end_nodes(MeCab::Lattice, size_t) returns MeCab::Node is native($library) { * }
my sub mecab_lattice_get_sentence(MeCab::Lattice) returns Str is native($library) { * }
my sub mecab_lattice_set_sentence(MeCab::Lattice, Str) is native($library) { * }
my sub mecab_lattice_set_sentence2(MeCab::Lattice, Str, size_t) is native($library) { * }
my sub mecab_lattice_get_size(MeCab::Lattice) returns size_t is native($library) { * }
my sub mecab_lattice_get_z(MeCab::Lattice) returns num64 is native($library) { * }
my sub mecab_lattice_set_z(MeCab::Lattice, num64) returns num64 is native($library) { * }
my sub mecab_lattice_get_theta(MeCab::Lattice) returns num64 is native($library) { * }
my sub mecab_lattice_set_theta(MeCab::Lattice, num64) is native($library) { * }
my sub mecab_lattice_next(MeCab::Lattice) returns int32 is native($library) { * }
my sub mecab_lattice_get_request_type(MeCab::Lattice) returns int32 is native($library) { * }
my sub mecab_lattice_has_request_type(MeCab::Lattice, int32) returns int32 is native($library) { * }
my sub mecab_lattice_set_request_type(MeCab::Lattice, int32) is native($library) { * }
my sub mecab_lattice_add_request_type(MeCab::Lattice, int32) is native($library) { * }
my sub mecab_lattice_remove_request_type(MeCab::Lattice, int32) is native($library) { * }
my sub mecab_lattice_new_node(MeCab::Lattice) returns MeCab::Node is native($library) { * }
my sub mecab_lattice_tostr(MeCab::Lattice) returns Str is native($library) { * }
my sub mecab_lattice_tostr2(MeCab::Lattice, CArray[int8] is rw, size_t) returns Str is native($library) { * }
my sub mecab_lattice_nbest_tostr(MeCab::Lattice, size_t) returns Str is native($library) { * }
my sub mecab_lattice_nbest_tostr2(MeCab::Lattice, size_t, CArray[int8] is rw, size_t) returns Str is native($library) { * }
my sub mecab_lattice_has_constraint(MeCab::Lattice) returns int32 is native($library) { * }
my sub mecab_lattice_get_boundary_constraint(MeCab::Lattice, size_t) returns int32 is native($library) { * }
my sub mecab_lattice_get_feature_constraint(MeCab::Lattice, size_t) returns Str is native($library) { * }
my sub mecab_lattice_set_boundary_constraint(MeCab::Lattice, size_t, int32) is native($library) { * }
my sub mecab_lattice_set_feature_constraint(MeCab::Lattice, size_t, size_t, Pointer[Str]) is native($library) { * }
my sub mecab_lattice_set_result(MeCab::Lattice, Str) is native($library) { * }
my sub mecab_lattice_strerror(MeCab::Lattice) returns Str is native($library) { * }

method new {
    mecab_lattice_new();
}

method clear {
    mecab_lattice_clear(self)
}

method is-available returns Bool {
    Bool(mecab_lattice_is_available(self))
}

method bos-node {
    mecab_lattice_get_bos_node(self)
}

method eos-node {
    mecab_lattice_get_eos_node(self)
}

method begin-nodes(Int $size) {
    mecab_lattice_get_begin_nodes(self, $size)
}

method end-nodes(Int $size) {
    mecab_lattice_get_end_nodes(self, $size)
}

multi method sentence {
    mecab_lattice_get_sentence(self)
}

multi method sentence(Str $text) {
    mecab_lattice_set_sentence(self, $text)
}

method size {
    mecab_lattice_get_size(self)
}

multi method z {
    mecab_lattice_get_z(self)
}

multi method z(Num $z) {
    mecab_lattice_set_z(self, $z)
}

multi method theta {
    mecab_lattice_get_theta(self)
}

multi method theta(Num $theta) {
    mecab_lattice_set_theta(self, $theta)
}

method next returns Bool {
    Bool(mecab_lattice_next(self))
}

multi method request-type returns RequestType {
    RequestType(mecab_lattice_get_request_type(self))
}

multi method request-type(RequestType $type) {
    mecab_lattice_set_request_type(self, $type)
}

method has-request-type(RequestType $type) returns Bool {
    Bool(mecab_lattice_has_request_type(self, $type))
}

method add-request-type(RequestType $type) {
    mecab_lattice_add_request_type(self, $type)
}

method remove-request-type(RequestType $type) {
    mecab_lattice_remove_request_type(self, $type)
}

method create-node {
    mecab_lattice_new_node(self)
}

method tostr {
    mecab_lattice_tostr(self)
}

method nbest-tostr(Int $size) {
    mecab_lattice_nbest_tostr(self, $size)
}

method has-constraint returns Bool {
    Bool(mecab_lattice_has_constraint(self))
}

multi method boundary-constraint(Int $pos) returns BoundaryConstraintType {
    BoundaryConstraintType(mecab_lattice_get_boundary_constraint(self, $pos))
}

multi method boundary-constraint(Int $pos, BoundaryConstraintType $boundary-type) {
    mecab_lattice_set_boundary_constraint(self, $pos, $boundary-type)
}

multi method feature-constraint(Int $begin-pos, Int $end-pos, Str $feature) {
    my CArray[int8] $int8-feature .= new;
    my $i = 0;
    for $feature.encode('UTF-8').unpack("C*") {
        $int8-feature[$i++] = $_;
    }
    mecab_lattice_set_feature_constraint(self, $begin-pos, $end-pos, nativecast(Pointer[Str], $int8-feature))
}

multi method feature-constraint(Int $pos) {
    mecab_lattice_get_feature_constraint(self, $pos)
}

method set-result(Str $text) {
    mecab_lattice_set_result(self, $text)
}

method strerror {
    mecab_lattice_strerror(self)
}

submethod DESTROY {
    mecab_lattice_destroy(self)    
}

=begin pod

=head1 NAME

MeCab::Lattice - A Perl 6 MeCab::Lattice class

=head1 SYNOPSIS

       use MeCab;
       use MeCab::Lattice;
       use MeCab::Tagger;
       use MeCab::Model;
       
       my MeCab::Model $model .= new;
       my MeCab::Tagger $tagger = $model.create-tagger;
       my MeCab::Lattice $lattice = $model.create-lattice;
       $lattice.sentence("今日も");

       if $tagger.parse($lattice) {
          say $lattice.tostr;
       }

       # OUTPUT«
       # 今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
       # も      助詞,係助詞,*,*,*,*,も,モ,モ
       # EOS
       # »

=head1 DESCRIPTION

MeCab::Lattice is a Perl 6 MeCab::Lattice class.

=head2 METHODS

=head3 new

Defined as:
        
        method new() returns MeCab::Lattice

Creates a new MeCab::Lattice object.

=head3 clear

Defined as:

        method clear()

Clears the invocant MeCab::Lattice object.

=head3 is-avilable

Defined as:

        method is-available() returns Bool

Returns whether the invocant MeCab::Lattice object is available or not.

=head3 bos-node

Defined as:

        method bos-node() returns MeCab::Node

Returns the bos node.

=head3 eos-node

Defined as:

        method eos-node() returns MeCab::Node

Returns the eos node.

=head3 sentence

Defined as:

        multi method sentence() returns Str
        multi method sentence(Str $text)

Are getter/setter methods for the sentence.

=head3 size

Defined as:

        method size() returns Int

Returns the size.

=head3 z

Defined as:

        multi method z() returns Num
        multi method z(Num $z)

Are getter/setter methods for the parameter z.

=head3 theta

Defined as:

        multi method theta() returns Num
        multi method theta(Num $theta)

Are getter/setter methods for the parameter theta.

=head3 next

Defined as:

        method next() returns Bool

TBD

=head3 request-type

Defined as:

        multi method request-type() returns RequestType
        multi method request-type(RequestType $type)

Are getter/setter methods for the C<RequestType> constant.

=head3 has-request-type

Defined as:

        method has-request-type(RequestType $type) returns Bool

Returns whether the invocant MeCab::Lattice object has the given C<RequestType> constant.

=head3 add-request-type

Defined as:

        method add-request-type(RequestType $type)

Adds the given C<RequestType> constant to the invocant MeCab::Lattice object.

=head3 remove-request-type

Defined as:

        method remove-request-type(RequestType $type)

Removes the given C<RequestType> constant from the invocant MeCab::Lattice object.

=head3 create-node

Defined as:

        method create-node() returns MeCab::Node

Creates a new MeCab::Node object.

=head3 tostr

Defined as:

        method tostr() returns Str

Returns the Str representation of the invocant MeCab::Lattice object.

=head3 nbest-tostr

Defined as:

        method nbest-tostr(Int $size) returns Str

Returns the top C<$size> Str representations of the invocant MeCab::Lattice object.

=head2 CONSTANTS

=head3 RequestType

=item1 C<:MECAB_ONE_BEST(1)>
=item1 C<:MECAB_NBEST(2)>
=item1 C<:MECAB_PARTIAL(4)>
=item1 C<:MECAB_MARGINAL_PROB(8)>
=item1 C<:MECAB_ALTERNATIVE(16)>
=item1 C<:MECAB_ALL_MORPHS(32)>
=item1 C<:MECAB_ALLOCATE_SENTENCE(64)>

=head3 BoundaryConstraintType

=item1 C<:MECAB_ANY_BOUNDARY(0)>
=item1 C<:MECAB_TOKEN_BOUNDARY(1)>
=item1 C<:MECAB_INSIDE_TOKEN(2)>

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

libmecab ( http://taku910.github.io/mecab/ ) by Taku Kudo is licensed under the GPL, LGPL or BSD Licenses.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
