# TXN::Remarshal

Double-entry accounting ledger file format converter


## Synopsis

**cmdline**

read TXN from stdin, write JSON to stdout:

```sh
cat sample.txn | txn-remarshal -if=txn -of=json
```

read TXN from `sample.txn`, write JSON to `sample.json`:

```sh
txn-remarshal -i=sample.txn -if=txn -of=json -o=sample.json
```

**perl6**

```perl6
use TXN::Parser::ParseTree;
use TXN::Remarshal;

my Str $txn = Q:to/EOF/;
2014-01-01 "I started the year with $1000 in Bankwest"
  Assets:Personal:Bankwest:Cheque    $1000 USD
  Equity:Personal                    $1000 USD
EOF

# convenience wrappers
my Ledger $ledger = from-txn($txn);
my Str $txn = to-txn($ledger);

# txn ↔ ledger
my Ledger $ledger = remarshal($txn, :if<txn>, :of<ledger>);
my Str $txn = remarshal($ledger, :if<ledger>, :of<txn>);

# ledger ↔ hash
my %ledger = remarshal($ledger, :if<ledger>, :of<hash>);
my Ledger $ledger = remarshal(%ledger, :if<hash>, :of<ledger>);

# hash ↔ json
my Str $json = remarshal(%ledger, :if<hash>, :of<json>);
my %ledger = remarshal($json, :if<json>, :of<hash>);
```


## Installation

### Dependencies

- Rakudo Perl6
- [File::Path::Resolve](https://github.com/atweiden/file-path-resolve)
- [File::Presence](https://github.com/atweiden/file-presence)
- [TXN::Parser](https://github.com/atweiden/txn-parser)

### Test Dependencies

- [Peru](https://github.com/buildinspace/peru)

To run the tests:

```
$ git clone https://github.com/atweiden/txn-remarshal && cd txn-remarshal
$ peru --file=.peru.yml --sync-dir="$PWD" sync
$ PERL6LIB=lib prove -r -e perl6
```


## Licensing

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
