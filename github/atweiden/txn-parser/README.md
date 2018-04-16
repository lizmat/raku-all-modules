# TXN::Parser

Double-entry accounting ledger parser


## Synopsis

```perl6
use TXN::Parser;
use TXN::Parser::ParseTree;

# parse ledger from string
my $txn = Q:to/EOF/;
2014-01-01 "I started the year with $1000 in Bankwest"
  Assets:Personal:Bankwest:Cheque    $1000 USD
  Equity:Personal                    $1000 USD
EOF
my Entry @entry = TXN::Parser.parse($txn).made;

# parse ledger from file
my $file = 'sample.txn';
my Entry @entry = TXN::Parser.parsefile($file).made;
```


## Installation

### Dependencies

- Rakudo Perl6
- [Digest::xxHash](https://github.com/atweiden/digest-xxhash)

### Test Dependencies

- [Peru](https://github.com/buildinspace/peru)

To run the tests:

```
$ git clone https://github.com/atweiden/txn-parser && cd txn-parser
$ peru --file=.peru.yml --sync-dir="$PWD" sync
$ PERL6LIB=lib prove -r -e perl6
```


Licensing
---------

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
