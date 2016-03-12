TXN
===

Double-entry bookkeeping transaction journal parser and serializer (mktxn)


Synopsis
--------

cmdline:

```bash
$ mktxn \
    --name="txnjrnl" \
    --version="1.0.0" \
    --release=1 \
    --description="My transactions" \
    sample.txn

$ mktxn -m=json serialize path/to/transaction/journal
```

perl6:

```perl6
use TXN;

# parse transactions from string
my $txn = Q:to/EOF/;
2014-01-01 "I started the year with $1000 in Bankwest"
  Assets:Personal:Bankwest:Cheque    $1000 USD
  Equity:Personal                    $1000 USD
EOF
my @txn = from-txn($txn);
my $json = from-txn($txn, :json);

# parse transactions from file
my $file = 'sample.txn';
my @txn = from-txn(:$file);
my $json = from-txn(:$file, :json);
```


Description
-----------

Parses transaction journals with syntax inspired
by [@mafm](https://github.com/mafm)'s work in
[@ledger.py](https://github.com/mafm/ledger.py), e.g.:

```
2013-01-15 I paid my electricity bill.
  Expenses:Electricity        $280.42
  Assets:Bankwest:Cheque     -$280.42
```

Serializes to JSON or Perlish object representation.

#### Release Mode

In release mode, mktxn produces a tarball comprised of two JSON files:

**.TXNINFO**

Inspired by Arch .PKGINFO files, .TXNINFO files contain transaction
journal metadata useful in simple queries.

```json
{
  "compiler": "mktxn 0.0.1 2015-10-12T20:48:23Z",
  "name": "mysamplejrnl",
  "version": "0.1.9",
  "release": "1",
  "owner": "",
  "description": "",
  "config": {
    "profile-name": "first"
  },
  "count": 7,
  "count-involving-aux-assets": 2,
  "count-involving-aux-assets-xe-missing": 1,
  "entities-seen": ["Entity", "Names", "Go", "Here"]
}
```

**txn.json**

txn.json contains the output of serializing the transaction journal
to JSON.

```json
[
  {
    "drift": 0,
    "entity": "VarName",
    "entry-id": {
      "number": 0,
      "xxhash": 5555555,
      "text": "capture entry"
    },
    "mod-holdings": {
      "AssetCode": {
        "entity": "VarName",
        "asset-code": "AssetCode",
        "asset-flow": "AssetFlow",
        "costing": "Costing",
        "date": "DateTime",
        "price": 5.55,
        "acquisition-price-asset-code": "AssetCode",
        "quantity": 5.5555555
      }
    },
    "mod-wallet": [
      {
        "silo": "SILO",
        "entity": "VarName",
        "subwallet": [ "VarName" ],
        "asset-code": "AssetCode",
        "decinc": "DecInc",
        "quantity": 5.5555555,
        "xe-asset-code": "",
        "xe-asset-quantity": "",
        "entry-id": {
          "number": 0,
          "xxhash": 5555555,
          "text": "capture entry"
        },
        "posting-id": {
          "entry-id": {
            "number": 0,
            "xxhash": 5555555,
            "text": "capture entry"
          },
          "number": 0,
          "xxhash": 55555557,
          "text": "capture posting"
        }
      }
    ]
  }
]
```

.TXNINFO and txn.json are compressed and saved as filename
`$pkgname-$pkgver-$pkgrel.txn.tar.xz` in the current working directory.


Installation
------------

#### Dependencies

- Rakudo Perl6
- [Config::TOML](https://github.com/atweiden/config-toml)
- [Digest::xxHash](https://github.com/atweiden/digest-xxhash)
- [JSON::Tiny](https://github.com/moritz/json)


Licensing
---------

This is free and unencumbered public domain software. For more
information, see http://unlicense.org/ or the accompanying UNLICENSE file.
