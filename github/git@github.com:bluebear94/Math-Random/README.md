## Math::Random

Random numbers à la `java.util.Random`.

### Background

I was bothered by Perl 6's primitive random number handling (only `rand` and
`srand`, with no mechanism to have multiple generators in parallel), so,
instead of bugging some random people about it, I decided to write a module!

### Synopsis

    use Math::Random::JavaStyle; # uses same mechanics as
                                 # java.util.Random
    my $j = Math::Random::JavaStyle.new;
    $j.setSeed(9001);
    say $j.nextInt;
    say $j.nextLong;
    say $j.nextDouble;
    say $j.nextInt(100);
    say $j.nextLong(100_000_000_000);
    say $j.nextDouble(100);
    say $j.nxt(256); # generate a random 256-bit integer
    say $j.nextGaussian;
    use Math::Random::MT;
    my $m64 = Math::Random::MT.mt19937_64;
    # ...

### Usage

The `Math::Random` role requires two methods to be implemented:

    method setSeed(Int $seed) { ... }
    method nxt(Int $bits) returns Int { ... }

Unlike in Java's equivalent, `nxt` is required to accept as large of an input
as possible.

#### setSeed(Int $seed)

Sets the random seed.

#### nextInt

Returns a random unsigned 32-bit integer.

#### nextInt(Int $max)

Returns a random nonnegative integer less than `$max`.

The upper bound must not exceed `2**32`.

#### nextLong

Returns a random unsigned 64-bit integer.

#### nextLong(Int $max)

Returns a random nonnegative integer less than `$max`.

The upper bound must not exceed `2**64`.

#### nextBoolean

Returns `True` or `False`.

#### nextDouble

Returns a random `Num` in the range [0.0, 1.0).

#### nextDouble(Num $max)

Returns a random `Num` in the range [0.0, `$max`).

#### nextGaussian

Returns a random value according to the normal distribution.

#### nxt(Int $bits)

Returns a random integer with `$bits` bits.

### Acknowledgements

Oracle's documentation on `java.util.Random`, as well as Wikipedia's article
on the Mersenne Twister generator.

### Todo

* Provide constructors that also set the seed.
* Ensure thread safety, or create a thread-safe wrapper
* Provide higher-level methods
* Tests? They won't be easy to pull off, so if anyone wants to PR...
