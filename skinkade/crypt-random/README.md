# Crypt::Random
[![Build Status](https://travis-ci.org/skinkade/crypt-random.svg?branch=master)](https://travis-ci.org/skinkade/crypt-random) [![Build status](https://ci.appveyor.com/api/projects/status/9w39bpjclskckwep?svg=true)](https://ci.appveyor.com/project/skinkade/crypt-random)

Random numbers and bytes mimicking `arc4random()`.


## Synopsis
```
use Crypt::Random;

# Random 32-bit Int
my Int $foo = crypt_random();

# Random 32-bit Int between 0 and $upper_bound (exclusive)
my Int $bar = crypt_random_uniform($upper_bound);

# Buf of $len random bytes
my Buf $baz = crypt_random_buf($len);
```

### Arbitrary Precision
`crypt_random()` and `crypt_random_uniform()` operate with arbitrary precision,
defaulting to 32 bits. For example, we can use 128-bit Ints:
```
> crypt_random();
2995622573
> crypt_random((128/8).Int);
329575757216165039775477155555355515616
> crypt_random_uniform(329575757216165039775477155555355515616);
3948459150
> crypt_random_uniform(329575757216165039775477155555355515616, (128/8).Int);
41874606600151197604385879164147854165
```

## Extra
Additional useful functions built upon the above primitives.
```
> use Crypt::Random::Extra

> my Str $uuid = crypt_random_UUIDv4()
ad7c433e-cf9f-4393-9403-cc59197191bd

> my Int $prime = crypt_random_prime()
2147037551
> my Int $prime2048 = crypt_random_prime((2048/8).Int)
96793777171756505978796079334994845848042781756...

> my @sample = crypt_random_sample([1..100], 20)
[10 55 88 71 58 41 1 84 5 94 29 68 44 47 13 67 85 65 54 86]
```

## Entropy Sources
Random bytes are drawn from `/dev/urandom` on Unix-like systems, and `RtlGenRandom()`
on Windows.

## Copyright & License
Copyright 2016 Shawn Kinkade.

This module may be used under the terms of the Artistic License 2.0.
