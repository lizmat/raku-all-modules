use v6;
unit class MeCab::DictionaryInfo is repr('CStruct');

enum DictionaryInfoType is export (
  :MECAB_SYS_DIC(0),
  :MECAB_USR_DIC(1),
  :MECAB_UNK_DIC(2)
);

has Str $.filename;
has Str $.charset;
has uint32 $.size;
has int32 $!type;
has uint32 $.lsize;
has uint32 $.rsize;
has uint16 $.version;
has MeCab::DictionaryInfo $.next;

method type {
    DictionaryInfoType($!type);
}

=begin pod

=head1 NAME

MeCab::DictionaryInfo - A Perl 6 MeCab::DictionaryInfo class

=head1 SYNOPSIS

       use MeCab;
       use MeCab::DictionaryInfo;
       use MeCab::Tagger;

       my MeCab::Tagger $tagger .= new("-C");
       my MeCab::DictionaryInfo $dictionary-info = $tagger.dictionary-info;
       say $dictionary-info.filename;

=head1 DESCRIPTION

MeCab::DictionaryInfo is a Perl 6 MeCab::DictionaryInfo class.

=head2 METHODS

=head3 filename

Defined as:

        method filename() returns Str

Returns the filename.

=head3 charset

Defined as:

        method charset() returns Str

Returns the charset.

=head3 size

Defined as:

        method size() returns Int

Returns the size.

=head3 type

Defined as:

        method type() returns DictionaryInfoType

Returns the C<DictionaryInfoType> constant.

=head3 lsize

Defined as:

        method lsize() returns Int

Returns the lsize.

=head3 rsize

Defined as:

        method rsize() returns Int

Returns the rsize.

=head3 version

Defined as:

        method rsize() returns Int

Returns the version.

=head3 next

Defined as:

        method next() returns MeCab::DictionaryInfo

Returns the next C<MeCab::DictionaryInfo> object.

=head2 CONSTANTS

=item1 C<:MECAB_SYS_DIC(0)>
=item1 C<:MECAB_USR_DIC(1)>
=item1 C<:MECAB_UNK_DIC(2)>

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

libmecab ( http://taku910.github.io/mecab/ ) by Taku Kudo is licensed under the GPL, LGPL or BSD Licenses.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
