# mktxn

Double-entry accounting ledger packager


## Synopsis

**cmdline**

```sh
cat >> TXNBUILD <<'EOF'
pkgname = 'sample'
pkgver = '1.0.0'
pkgrel = 1
source = 'sample.txn'
EOF
mktxn
```

**perl6**

```perl6
use TXN;
my Str $pkgname = 'sample';
my Version $pkgver .= new('1.0.0');
my UInt $pkgrel = 1;
my Str $pkgdesc = 'Sample transactions';
my Str $source = 'sample.txn';
my %pkg = mktxn(:$pkgname, :$pkgver, :$pkgrel, :$pkgdesc, :$source);
```


## Description

Serializes double-entry accounting ledgers to JSON package format.

### Release Mode

In release mode, mktxn produces a tarball comprised of two JSON files:

#### .TXNINFO

Inspired by Arch Linux `.PKGINFO` files, `.TXNINFO` files contain
accounting ledger metadata useful in simple queries.

```json
{
  "pkgname" : "with-includes",
  "pkgver" : "0.0.1",
  "pkgrel" : 1,
  "pkgdesc" : "Sample transactions with include directives",
  "compiler" : "mktxn v0.1.0 2018-04-21T14:14:33.931470Z",
  "entities-seen" : [
    "FooCorp",
    "Personal",
    "WigwamLLC"
  ],
  "count" : 112
}
```

#### txn.json

txn.json contains the output of serializing the accounting ledger to JSON.

```json
[
  {
    "id" : {
      "xxhash" : 1468523538,
      "text" : "2014-01-01 \"I started the year with $1000 in Bankwest cheque account\"\n  Assets:Personal:Bankwest:Cheque      $1000.00 USD\n  Equity:Personal                      $1000.00 USD",
      "number" : [
        3
      ]
    },
    "header" : {
      "important" : 0,
      "description" : "I started the year with $1000 in Bankwest cheque account",
      "date" : "2014-01-01"
    },
    "posting" : [
      {
        "drcr" : "DEBIT",
        "id" : {
          "xxhash" : 4134277096,
          "text" : "Assets:Personal:Bankwest:Cheque      $1000.00 USD",
          "entry-id" : {
            "xxhash" : 1468523538,
            "text" : "2014-01-01 \"I started the year with $1000 in Bankwest cheque account\"\n  Assets:Personal:Bankwest:Cheque      $1000.00 USD\n  Equity:Personal                      $1000.00 USD",
            "number" : [
              3
            ]
          },
          "number" : 0
        },
        "decinc" : "INC",
        "amount" : {
          "asset-code" : "USD",
          "asset-quantity" : 1000,
          "asset-symbol" : "$"
        },
        "account" : {
          "entity" : "Personal",
          "path" : [
            "Bankwest",
            "Cheque"
          ],
          "silo" : "ASSETS"
        }
      },
      {
        "drcr" : "CREDIT",
        "id" : {
          "xxhash" : 344831063,
          "text" : "Equity:Personal                      $1000.00 USD",
          "entry-id" : {
            "xxhash" : 1468523538,
            "text" : "2014-01-01 \"I started the year with $1000 in Bankwest cheque account\"\n  Assets:Personal:Bankwest:Cheque      $1000.00 USD\n  Equity:Personal                      $1000.00 USD",
            "number" : [
              3
            ]
          },
          "number" : 1
        },
        "decinc" : "INC",
        "amount" : {
          "asset-code" : "USD",
          "asset-quantity" : 1000,
          "asset-symbol" : "$"
        },
        "account" : {
          "entity" : "Personal",
          "silo" : "EQUITY"
        }
      }
    ]
  }
]
```

`.TXNINFO` and `txn.json` are compressed and saved as filename
`$pkgname-$pkgver-$pkgrel.txn.pkg.tar.xz` in the current working
directory.


## Installation

### Dependencies

- Rakudo Perl6
- [Config::TOML](https://github.com/atweiden/config-toml)
- [File::Presence](https://github.com/atweiden/file-presence)
- [TXN::Parser](https://github.com/atweiden/txn-parser)
- [TXN::Remarshal](https://github.com/atweiden/txn-remarshal)

### Test Dependencies

- [Peru](https://github.com/buildinspace/peru)

To run the tests:

```
$ git clone https://github.com/atweiden/mktxn && cd mktxn
$ peru --file=.peru.yml --sync-dir="$PWD" sync
$ PERL6LIB=lib prove -r -e perl6
```


## Licensing

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.

<!-- vim: set filetype=markdown foldmethod=marker foldlevel=0 nowrap: -->
