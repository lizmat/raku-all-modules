use v6;

unit module ULID:auth<github:zostay>:ver<0.1.0>;

class GLOBAL::X::ULID is Exception {
    has $.message;
}

# See https://www.crockford.com/wrmg/base32.html
# 32 letters, 0 .. 9, A .. Z except I, L, O, U
constant @crockford-out = grep <I L O U>.none, flat '0' .. '9', 'A' .. 'H', 'J', 'K', 'M', 'N', 'P' .. 'T', 'V' .. 'Z';

constant @bitmasking = (
     3, 0b11111000, 0, 0b00000000,
    -2, 0b00000111, 6, 0b11000000,
     1, 0b00111110, 0, 0b00000000,
    -4, 0b00000001, 4, 0b11110000,
    -1, 0b00001111, 7, 0b10000000,
     2, 0b01111100, 0, 0b00000000,
    -3, 0b00000011, 5, 0b11100000,
     0, 0b00011111, 0, 0b00000000,
).rotor(4);

constant @bitmasking-offsets = 0, 3, 6, 1, 4, 0;

my sub crockford(Blob:D $bin --> Seq:D) {
    # These exceptions should never be thrown
    die "cannot encode empty blob"
        unless $bin.elems > 0;
    die "expected blob8, but got something else"
        unless $bin.elems == $bin.bytes;

    my $total-bits = $bin.bytes * 8;
    my $pad-bits   = (5 - $total-bits % 5) % 5;

    # say "Input = $bin.perl()";
    # say "Bits = $total-bits, Padding = $pad-bits";

    my @bitmasks   = @bitmasking.rotate(@bitmasking-offsets[$pad-bits]);
    my @bytes      = @$bin;

    @bytes.unshift(0) if $pad-bits;

    my $index = 1;
    my $segment = 0;
    gather {
        loop {
            my ($mss, $msm, $lss, $lsm) = @bitmasks[ $segment++ % @bitmasking ];
            my $ubits = ((@bytes[$index - 1] +& $msm) +> $mss)
                    +| ((@bytes[$index]     +& $lsm) +> $lss);

            # printf "%s %08b <- %08b +& %08b +> %2d +| %08b +& %08b +> %2d\n",
            #     @crockford-out[ $ubits ],
            #     $ubits,
            #     @bytes[$index - 1], $msm, $mss,
            #     @bytes[$index], $lsm, $lss,
            #     ;

            take @crockford-out[ $ubits ];

            $index++ if $lss || !$mss;
            last if $index >= @bytes;
        }

        # There's one more 5-bit to grab, but it's the easy one
        take @crockford-out[ @bytes[*-1] +& 0b00011111 ];
    }
}

constant @time-bytes =
    0xFF0000000000, 40,
    0x00FF00000000, 32,
    0x0000FF000000, 24,
    0x000000FF0000, 16,
    0x00000000FF00,  8,
    0x0000000000FF,  0,
    ;

our sub ulid-now(Instant:D $now = now --> Int:D) is export(:time) {
    my ($unix-secs) = $now.to-posix;
    Int(($unix-secs + ($now - $now.floor)) * 1000);
}

our sub ulid-time(Int:D $now --> Seq:D) is export(:parts) {
    my @bytes = @time-bytes.map(-> $m, $s { $now +& $m +> $s });
    crockford(Blob.new(@bytes));
}

my sub random-number($x) { $x.rand.floor }

constant $zero = Blob.new: 0 xx 10;
my $previous-time = 0;
my $previous-random;
our sub ulid-random(
    Int:D $now,
    :&random-function = &random-number,
    Bool:D :$monotonic = False,
    --> Seq:D
) is export(:parts) {
    my $random-blob;

    if $monotonic && $now == $previous-time {
        my $nudging = True;
        $random-blob = Blob.new: @($previous-random).reverse.map({
            if $nudging {
                if $_ < 0xFF {
                    $nudging--;
                    $_ + 1;
                }
                else {
                    0x00;
                }
            }
            else {
                $_
            }
        }).reverse;

        if $random-blob eq $zero {
            die X::ULID.new(message => "monotonic ULID overflow");
        }
    }
    else {
        $random-blob = Blob.new: (^10).map({ 0x100.&random-function });
    }

    $previous-time   = $now;
    $previous-random = $random-blob;

    crockford($random-blob);
}

our sub ulid(
    Int:D() $now       = ulid-now,
    Bool:D :$monotonic = False,
    :&random-function  = &random-number,
    --> Str:D
) is export(:DEFAULT, :ulid) {
    [~] flat ulid-time($now), ulid-random($now, :$monotonic, :&random-function)
}

=begin pod

=head1 NAME

ULID - Universally Unique Lexicographically Sortable Identifier

=head1 SYNOPSIS

    use ULID;

    say ulid; #> 01D3HRFBR2WBZHW2HZ6CYSJ9JB

=head1 DESCRIPTION

This implements the L<ULID specification|https://github.com/ulid/spec> in Perl. Using the C<ulid> function will generate a random unique ID according to that specification. These unique IDs can be generated in sortable order and are encoded in a Base 32 encoding.

=head1 EXPORTED SUBROUTINES

=head2 sub ulid

    our sub ulid(
        Int:D() $now       = ulid-now,
        Bool:D :$monotonic = False,
        :&random-function  = &random-number,
        --> Str:D
    ) is export(:DEFAULT, :ulid)

With no arguments, this returns a string containing the ULID for the current moment.

The C<$now> argument may be set to ULID's notion of time, which is number of milliseconds since the POSIX epoch start. Because this is annoying to calculate in Perl, this module provides the L<ulid-now|#sub ulid-now> to do the conversion from L<Instant> for you.

The C<$monotonic> argument turns on monotonic ULID generation, which ensures that ULIDs generated sequentially during the same millisecond will also be issued in sorted order. The first time this is done for a given millisecond, the ULID is generated randomly as usual. The second time, however, the next ULID will be identical to the previous ULID, but increased in value by 1. This process may be repreated until the final carry bit occurs, at which point an L<X::ULID|#X::ULID> exception will be thrown.

B<CAVEAT:> As of this writing, this is implemented in Perl and has not been much optimized, so it is unlikely in the extreme that you will be able to generate 2 ULIDs during the same millisecond unless you are passing the C<$now> argument to deliberately generate multiple per second.

The C<&random-function> argument allows you to provide an alternative to the built-in random function used, which just depends on Perl's C<rand>. The function should be defined similar to the default implementation which looks something like this:

    sub (Int:D $max --> Int:D) { $max.rand.floor }

That is, given an integer, it should return an integer C<$n> such that C<< 0 <= $n  < $max >>.

=head2 sub ulid-now

    our sub ulid-now(Instant:D $now = now --> Int:D) is export(:time)

This method can be used to retrieve the number of milliseconds since the POSIX epoch. Or you may choose to pass an L<Instant> to convert to such a value.

=head2 sub ulid-time

    our sub ulid-time(Int:D $now --> Seq:D) is export(:parts)

This method will allow you to return just the time part of a ULID. The value will convert a number of milliseconds since the POSIX epoch, C<$now>, into the first 10 characters of the ULID. These are returned a sequence, so you'll have to join them yourself if you want a string.

=head2 sub ulid-random

    our sub ulid-random(
        Int:D $now,
        :&random-function = &random-number,
        Bool:D :$monotonic = False,
        --> Seq:D
    ) is export(:parts)

This method will allow you to return just the random part of a ULID. The value returned will be 16 characters long in a sequence.

This must be passed the C<$now> to use to generate the sequence, which will be stord in case C<$monotonic> is passed during a subsequent call.

See C<&random-function> and C<$monotonic> as described for L<ulid|#sub ulid> for details on how they work.

=head1 DIAGNOSTICS

=head2 X::ULID

This exception will be thrown if a ULID cannot be generated for some reason by L<ulid|#sub ulid>. Currently, the only case where this will be true is when monotonic ULIDs are generated for a given millisecond and the module runs out of ULIDs that can be generated monotonically.

In that case, the message will be "monotonic ULID overflow". Enjoy.

=end pod
