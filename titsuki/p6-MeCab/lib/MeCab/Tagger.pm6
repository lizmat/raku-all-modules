use v6;
unit class MeCab::Tagger is repr('CPointer');

use NativeCall;
use MeCab;
use MeCab::Lattice;
use MeCab::DictionaryInfo;

my constant $library = %?RESOURCES<libraries/mecab>.Str;

my sub mecab_destroy(MeCab::Tagger) is native($library) { * }
my sub mecab_new2(Str) returns MeCab::Tagger is native($library) { * }
my sub mecab_version() returns Str is native($library) { * }
my sub mecab_get_theta(MeCab::Tagger) is native($library) { * }
my sub mecab_set_theta(MeCab::Tagger, num32) is native($library) { * }
my sub mecab_get_lattice_level(MeCab::Tagger) returns int32 is native($library) { * }
my sub mecab_set_lattice_level(MeCab::Tagger, int32) returns int32 is native($library) { * }
my sub mecab_parse_lattice(MeCab::Tagger, MeCab::Lattice) returns int32 is native($library) { * }
my sub mecab_sparse_tonode(MeCab::Tagger, Str) returns MeCab::Node is native($library) { * }
my sub mecab_sparse_tostr(MeCab::Tagger, Str) returns Str is native($library) { * }
my sub mecab_sparse_tostr2(MeCab::Tagger, size_t, Str, size_t) returns CArray[int8] is native($library) { * }
my sub mecab_sparse_tostr3(MeCab::Tagger, size_t, Str, size_t, CArray[int8], size_t) returns CArray[int8] is native($library) { * }
my sub mecab_dictionary_info(MeCab::Tagger) returns MeCab::DictionaryInfo is native($library) { * }
my sub mecab_strerror(MeCab::Tagger) returns Str is native($library) { * }

multi method new(Str $arg) {
    mecab_new2($arg);
}

multi method new {
    mecab_new2("-C");
}

method version {
    mecab_version();
}

multi method parse(Str $text) {
    mecab_sparse_tostr(self, $text);
}

multi method parse(MeCab::Lattice $lattice) returns Bool {
    Bool(mecab_parse_lattice(self, $lattice))
}

method parse-tonode(Str $text) {
    mecab_sparse_tonode(self, $text);
}

method dictionary-info {
    mecab_dictionary_info(self)
}

method strerror {
    mecab_strerror(self)
}

submethod DESTROY {
    mecab_destroy(self)
}

=begin pod

=head1 NAME

MeCab::Tagger - A Perl 6 MeCab::Tagger class

=head1 SYNOPSIS

       use MeCab;
       use MeCab::Tagger;
       
       my Str $text = "すもももももももものうち。";
       my $mecab-tagger = MeCab::Tagger.new('-C');
       loop ( my MeCab::Node $node = $mecab-tagger.parse-tonode($text); $node; $node = $node.next ) {
              say ($node.surface, $node.feature).join("\t");
       }
       
       # OUTPUT«
       #         BOS/EOS,*,*,*,*,*,*,*,*
       # すもも  名詞,一般,*,*,*,*,すもも,スモモ,スモモ
       # も      助詞,係助詞,*,*,*,*,も,モ,モ
       # もも    名詞,一般,*,*,*,*,もも,モモ,モモ
       # も      助詞,係助詞,*,*,*,*,も,モ,モ
       # もも    名詞,一般,*,*,*,*,もも,モモ,モモ
       # の      助詞,連体化,*,*,*,*,の,ノ,ノ
       # うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
       # 。      記号,句点,*,*,*,*,。,。,。
       #         BOS/EOS,*,*,*,*,*,*,*,*
       # »

=head1 DESCRIPTION

MeCab::Tagger is a Perl 6 MeCab::Tagger class.

=head2 METHODS

=head3 new

Defined as:

        method new(Str $arg) returns MeCab::Tagger

Creates a new MeCab::Tagger object.

=head3 version

Defined as:

        method version() returns Str

Returns the version.

=head3 parse

Defined as:

        multi method parse(Str $text) returns Str
        multi method parse(MeCab::Lattice $lattice)

Parses the given C<$text> or C<$lattice>.

=head3 parse-tonode

Defined as:

        method parse-tonode(Str $text) returns MeCab::Node

Parses the given C<$text> and returns a resulting C<MeCab::Node> object.

=head3 dictionary-info

Defined as:

        method dictionary-info() returns MeCab::DictionaryInfo

Returns the MeCab::DictionaryInfo object.

=head3 strerror

Defined as:

        method strerror() returns Str

Returns a stored error message if it has one.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

libmecab ( http://taku910.github.io/mecab/ ) by Taku Kudo is licensed under the GPL, LGPL or BSD Licenses.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
