# Digest::FNV

Fowler–Noll–Vo hash function in pure perl6.

## Exports

### `fnv0`

If you want to use this, you must import with the `:DEPRECATED` flag.

### `fnv1`

Performs the FNV1 hash.

### `fnv1a`

The alternate FNV1 hash (XOR, then multiply)

## Signatures

All of the exports have the signature of `($data, :bits(32|64|128|256|512|1024))`

The tests only use 32|64, use the others at your own peril.

## Usage

```
use Digest::FNV;

my $x = fnv1a('some str');
# $x = 651763969055412538
```
