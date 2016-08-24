# TXN

Double-entry bookkeeping transaction journal parser and serializer (mktxn)


## Synopsis

**cmdline**

```bash
$ mktxn \
    --pkgname="txnjrnl" \
    --pkgver="1.0.0" \
    --pkgrel=1 \
    --pkgdesc="My transactions" \
    sample.txn

$ mktxn -m=json serialize path/to/transaction/journal
```

**perl6**

Parse transactions from string:

```perl6
use TXN;

my $txn = Q:to/EOF/;
2014-01-01 "I started the year with $1000 in Bankwest"
  Assets:Personal:Bankwest:Cheque    $1000 USD
  Equity:Personal                    $1000 USD
EOF
my @txn = from-txn($txn);
my $json = from-txn($txn, :json);
```

Parse transactions from file:

```perl6
use TXN;

my $file = 'sample.txn';
my @txn = from-txn(:$file);
my $json = from-txn(:$file, :json);
```


## Description

Serializes double-entry transaction journals to JSON or Perlish object
representation.

### Release Mode

In release mode, mktxn produces a tarball comprised of two JSON files:

#### .TXNINFO

Inspired by Arch Linux `.PKGINFO` files, `.TXNINFO` files contain
transaction journal metadata useful in simple queries.

```json
{
   "count" : 112,
   "pkgrel" : 1,
   "entities-seen" : [
      "FooCorp",
      "Personal",
      "WigwamLLC"
   ],
   "pkgver" : "1.0.0",
   "pkgname" : "with-includes",
   "pkgdesc" : "txn with include directives",
   "compiler" : "mktxn v0.0.2 2016-05-10T10:22:44.054586-07:00"
}
```

#### txn.json

txn.json contains the output of serializing the transaction journal
to JSON.

```json
[
  {
    "id": {
      "text": "2013-01-01 \"I started the year with $1000 in Bankwest cheque account\"\n  Assets:Personal:Bankwest:Cheque    $1000.00 USD\n  Equity:Personal                    $1000.00 USD\n",
      "xxhash": 1373719837,
      "number": [
        0
      ]
    },
    "header": {
      "important": 0,
      "tags": [],
      "description": "I started the year with $1000 in Bankwest cheque account",
      "date": "2013-01-01T00:00:00Z"
    },
    "postings": [
      {
        "id": {
          "text": "Assets:Personal:Bankwest:Cheque    $1000.00 USD",
          "xxhash": 352942826,
          "entry-id": {
            "text": "2013-01-01 \"I started the year with $1000 in Bankwest cheque account\"\n  Assets:Personal:Bankwest:Cheque    $1000.00 USD\n  Equity:Personal                    $1000.00 USD\n",
            "xxhash": 1373719837,
            "number": [
              0
            ]
          },
          "number": 0
        },
        "decinc": "INC",
        "amount": {
          "asset-code": "USD",
          "exchange-rate": {},
          "asset-symbol": "$",
          "asset-quantity": 1000,
          "plus-or-minus": ""
        },
        "account": {
          "subaccount": [
            "Bankwest",
            "Cheque"
          ],
          "entity": "Personal",
          "silo": "ASSETS"
        }
      },
      {
        "id": {
          "text": "Equity:Personal                    $1000.00 USD",
          "xxhash": 95742535,
          "entry-id": {
            "text": "2013-01-01 \"I started the year with $1000 in Bankwest cheque account\"\n  Assets:Personal:Bankwest:Cheque    $1000.00 USD\n  Equity:Personal                    $1000.00 USD\n",
            "xxhash": 1373719837,
            "number": [
              0
            ]
          },
          "number": 1
        },
        "decinc": "INC",
        "amount": {
          "asset-code": "USD",
          "exchange-rate": {},
          "asset-symbol": "$",
          "asset-quantity": 1000,
          "plus-or-minus": ""
        },
        "account": {
          "entity": "Personal",
          "silo": "EQUITY"
        }
      }
    ]
  }
]
```

`.TXNINFO` and `txn.json` are compressed and saved as filename
`$pkgname-$pkgver-$pkgrel.txn.tar.xz` in the current working directory.


## Installation

### Dependencies

- Rakudo Perl6
- [Config::TOML](https://github.com/atweiden/config-toml)
- [File::Presence](https://github.com/atweiden/file-presence)
- [TXN::Parser](https://github.com/atweiden/txn-parser)

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
