# Crypt::RSA

[![Build Status](https://travis-ci.org/bduggan/p6-Crypt-RSA.svg?branch=master)](https://travis-ci.org/bduggan/p6-Crypt-RSA)

## SYNOPSIS

Pure Perl 6 implementation of RSA public key encryption.

```

my $crypt = Crypt::RSA.new;
my ($public,$private) = $crypt.generate-keys;

my $message = 123456789;
my $encrypted = $crypt.encrypt($message);
my $decrypted = $crypt.decrypt($encrypted);

my $message = 123456789;
my $signature = $crypt.generate-signature($message);
die unless $crypt.verify-signature($message,$signature);

```

## DESCRIPTION

This is a very simplistic implementation of the RSA algorithm
for public key encryption.

By default, it relies on Perl 6 built-ins for randomness,
but the constructor takes two optional arguments:
`random-prime-generator(UInt $digits)` and `random-range-picker(Range $range)`
that can be used instead.  Any arguments to `generate-keys`
(such as the number of digits or number of bits) will be passed
on to `random-prime-generator`.

## EXAMPLES


```
use Crypt::Random;
use Crypt::Random::Extra;

my $crypt = Crypt::RSA.new(
    random-prime-generator => sub {
        crypt_random_prime()
    },
    random-range-picker => sub ($range) {
        my $size = log($range, 10).Int;
        my $rand = crypt_random_uniform($range.max,$size);
        return $range[$rand];
    }
);
```

## References

- https://people.csail.mit.edu/rivest/Rsapaper.pdf
- https://www.promptworks.com/blog/public-keys-in-perl-6

