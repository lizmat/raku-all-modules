use v6;
use lib 'lib';
use TXN;
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

    my @txn = from-txn($txn);
    my @txn-from-txn-parser = TXN::Parser.parse($txn).made;
    my @txn-from-mktxn =
        mktxn($txn, :pkgname<catfood>, :pkgver<1.0.0>, :pkgrel(1))<txn>.Array;

    is-deeply @txn-from-txn-parser, @txn, 'Is expected value';
    is-deeply @txn-from-txn-parser, @txn-from-mktxn, 'Is expected value';
}

# vim: ft=perl6 fdm=marker fdl=0
