use v6;
use lib 'lib';
use TXN;
use TXN::Parser;
use TXN::Parser::ParseTree;
use TXN::Parser::Types;
use TXN::Remarshal;
use Test;

plan(1);

subtest('verify mktxn(...) eqv TXN::Parser.made', {
    my Str:D $file = 't/data/fy2013/fy2013.txn';
    my Entry:D @entry = from-txn(:$file);
    my Entry:D @entry-from-txn-parser = TXN::Parser.parsefile($file).made;
    my Entry:D @entry-from-mktxn = do {
        my Str:D $pkgname = 'fy2013';
        my Version $pkgver .= new('1.0.0');
        my UInt:D $pkgrel = 1;
        my Str:D $source = $file;
        mktxn(:$pkgname, :$pkgver, :$pkgrel, :$source)<entry>.flat
    };
    is-deeply(@entry-from-txn-parser, @entry, 'Is expected value');
    is-deeply(@entry-from-txn-parser, @entry-from-mktxn, 'Is expected value');
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
