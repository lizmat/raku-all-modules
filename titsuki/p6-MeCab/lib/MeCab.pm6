use v6;
use NativeCall;

my constant $library = %?RESOURCES<libraries/mecab>.Str;

class MeCab::Path is repr('CStruct') { ... }
class MeCab::Node is repr('CStruct') is export {
    enum Stat is export (
        :MECAB_NOR_NODE(0),
        :MECAB_UNK_NODE(1),
        :MECAB_BOS_NODE(2),
        :MECAB_EOS_NODE(3),
        :MECAB_EON_NODE(4)
    );

    my sub mecab_node_t_surface_get(MeCab::Node) returns Str is native($library) { * };
    has MeCab::Node $.prev;
    has MeCab::Node $.next;
    has MeCab::Node $.enext;
    has MeCab::Node $.bnext;
    has MeCab::Path $.rpath;
    has MeCab::Path $.lpath;
    has Pointer[int8] $!surface;
    has Str $.feature;
    has uint32 $.id;
    has uint16 $.length;
    has uint16 $.rlength;
    has uint16 $.rcAttr;
    has uint16 $.lcAttr;
    has uint16 $.posid;
    has uint8 $!char_type;
    has uint8 $!stat;
    has uint8 $!isbest;
    has num32 $.alpha;
    has num32 $.beta;
    has num32 $.prob;
    has int16 $.wcost;
    has int64 $.cost;

    method surface {
        mecab_node_t_surface_get(self);
    }

    method stat {
        Stat($!stat)
    }

    method isbest returns Bool {
        Bool($!isbest)
    }

    method char-type {
        $!char_type;
    }
}

class MeCab::Path is export {
    has MeCab::Node $.rnode;
    has MeCab::Path $.rnext;
    has MeCab::Node $.lnode;
    has MeCab::Path $.lnext;
    has int32 $.cost;
    has num32 $.prob;
}

=begin pod

=head1 NAME

MeCab - A Perl 6 bindings for libmecab ( http://taku910.github.io/mecab/ )

=head1 SYNOPSIS

=head2 EXAMPLE 1

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

=head2 EXAMPLE 2

       use MeCab;
       use MeCab::Lattice;
       use MeCab::Tagger;
       use MeCab::Model;
       
       my MeCab::Model $model .= new;
       my MeCab::Tagger $tagger = $model.create-tagger;
       my MeCab::Lattice $lattice = $model.create-lattice;
       $lattice.add-request-type(MECAB_NBEST);
       $lattice.sentence("今日も");

       if $tagger.parse($lattice) {
          say $lattice.nbest-tostr(2);
       }

       # OUTPUT«
       # 今日    名詞,副詞可能,*,*,*,*,今日,キョウ,キョー
       # も      助詞,係助詞,*,*,*,*,も,モ,モ
       # EOS
       # 今日    名詞,副詞可能,*,*,*,*,今日,コンニチ,コンニチ
       # も      助詞,係助詞,*,*,*,*,も,モ,モ
       # EOS
       # »

=head1 DESCRIPTION

MeCab is a Perl 6 bindings for libmecab ( http://taku910.github.io/mecab/ ).

=head1 NOTICE

=head2 COMPATIBILITY

MeCab currently doesn't support Windows. It supports Linux/Unix or Mac OS X.

=head2 BUILDING MeCab

MeCab depends on the following:

=item1 wget
=item1 mecab-0.996
=item1 mecab-ipadic-2.7.0-20070801

Once the build starts, it automatically downloads C<mecab-0.996> and C<mecab-ipadic-2.7.0-20070801> with C<wget> and installs these stuffs under the C<$HOME/.p6mecab> directory, where C<$HOME> is your home directory.

=head1 AUTHOR

titsuki <titsuki@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 titsuki

libmecab ( http://taku910.github.io/mecab/ ) by Taku Kudo is licensed under the GPL, LGPL or BSD Licenses.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
