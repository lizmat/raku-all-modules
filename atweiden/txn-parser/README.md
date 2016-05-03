TXN::Parser
===========

Double-entry bookkeeping transaction journal parser


Synopsis
--------

```perl6
use TXN::Parser;

# parse transactions from string
my $txn = Q:to/EOF/;
2014-01-01 "I started the year with $1000 in Bankwest"
  Assets:Personal:Bankwest:Cheque    $1000 USD
  Equity:Personal                    $1000 USD
EOF
my @txn = TXN::Parser.parse($txn).made;

# parse transactions from file
my $file = 'sample.txn';
my @txn = TXN::Parser.parsefile($file).made;
```


Installation
------------

#### Dependencies

- Rakudo Perl6
- [Digest::xxHash](https://github.com/atweiden/digest-xxhash)


Licensing
---------

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
