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
use TXN::Remarshal;

my Str $txn = Q:to/EOF/;
2014-01-01 "I started the year with $1000 in Bankwest"
  Assets:Personal:Bankwest:Cheque    $1000 USD
  Equity:Personal                    $1000 USD
EOF

# convenience wrappers
my TXN::Parser::AST::Entry @entry = from-txn($txn);
my Str $s = to-txn(@entry);

# txn ↔ entry
my TXN::Parser::AST::Entry @entry = remarshal($txn, :if<txn>, :of<entry>);
my Str $ledger = remarshal(@entry, :if<entry>, :of<txn>);

# entry ↔ hash
my Hash @a = remarshal(@entry, :if<entry>, :of<hash>);
my TXN::Parser::AST::Entry @e = remarshal(@a, :if<hash>, :of<entry>);

# hash ↔ json
my Str $json = remarshal(@a, :if<hash>, :of<json>);
my Hash @b = remarshal($json, :if<json>, :of<hash>);
```


## Installation

### Dependencies

- Rakudo Perl6
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
