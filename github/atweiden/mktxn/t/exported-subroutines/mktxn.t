use v6;
use lib 'lib';
use TXN;
use TXN::Parser;
use TXN::Parser::Types;
use TXN::Remarshal;
use Test;

plan 1;

# verify mktxn(...) eqv TXN::Parser.made
subtest
{
    my Str $txn = q:to/EOF/;
    2016-01-01 "I bought cat food for $5"
      Expenses:Personal:Pets:Food         $5.00 USD
      Assets:Personal:Bankwest:Cheque    -$5.00 USD
    EOF

    my TXN::Parser::AST::Entry @entry = from-txn($txn);
    my TXN::Parser::AST::Entry @entry-from-txn-parser =
        TXN::Parser.parse($txn).made;
    my TXN::Parser::AST::Entry @entry-from-mktxn =
        mktxn($txn, :pkgname<catfood>, :pkgver<1.0.0>, :pkgrel(1))<entry>.Array;

    is-deeply @entry-from-txn-parser, @entry, 'Is expected value';
    is-deeply @entry-from-txn-parser, @entry-from-mktxn, 'Is expected value';
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
