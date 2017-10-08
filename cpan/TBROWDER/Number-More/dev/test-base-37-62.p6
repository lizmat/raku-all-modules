#!/usr/bin/env perl6

use lib <../lib>;

use Number::More :ALL;

# a test set of numbers and bases
my $nums    = 100; # nums to choose
my $ndigits = 5;   # num digits per number

my @b = 2..62; # set of allowable bases
my @p = @b; # need an array to pick from since @b is used in a loop
for 1..$nums -> $i {
    # pick digits at random
    my @d = pick $ndigits, @dec2digit;
    my $num-i = join '', @d;
    say "== number $i: $num-i";

    # pick each valid base
    for @b -> UInt $base-i {
       next if $num-i !~~ @base[$base-i];
       # pick an output base
       my $base-o = @p.pick.UInt;
       while $base-o == $base-i {
           $base-o = @p.pick.UInt;
       }

       # now we should have two separate bases of set @b
       if ($base-i < 37) && ($base-o < 37) {
           # skip for now
           next;
       }

       say "  base-i: $base-i; base-o: $base-o";

       my $res;
       if ($base-i < 37) && ($base-o < 37) {
           # skip for now
           next;
	   $res = rebase($num-i, $base-i, $base-o);
       }
       elsif $base-i == 10 {
	   $res = _from-dec-to-b37-b62($num-i, $base-o);
       }
       elsif $base-o == 10 {
	   $res = _to-dec-from-b37-b62($num-i, $base-i);
       }
       else {
	   # need decimal intermediary
	   my $dec = _to-dec-from-b37-b62($num-i, $base-i);
           say "dec = $dec";
	   $res = _from-dec-to-b37-b62($dec, $base-o);
       }
       say "  input: $num-i (base: $base-i); output: $res (base: $base-o)" if $res;
    }
}

sub _to-dec-from-b37-b62($num,
			 #UInt $bi where { 36 < $bi < 63 }
			 UInt $bi
			 --> Cool
			) is export(:_to-dec-from-b37-b62) {

    # see simple algorithm for base to dec:
    #`{

Let's say you have a number

  10121 in base 3

and you want to know what it is in base 10.  Well, in base three the
place values [from the highest] are

   4   3  2  1  0 <= digit place (position)
  81, 27, 9, 3, 1 <= value: digit x base ** place

so we have 1 x 81 + 0 x 27 + 1 x 9 + 2 x 3 + 1 x 1

  81 + 0 + 9 + 6 + 1 = 97

that is how it works.  You just take the number, figure out the place
values, and then add them together to get the answer.  Now, let's do
one the other way.

45 in base ten (that is the normal one.) Let's convert it to base
five.

Well, in base five the place values will be 125, 25, 5, 1

We won't have any 125's but we will have one 25. Then we will have 20
left.  That is four 5's, so in base five our number will be 140.

Hope that makes sense.  If you don't see a formula, try to work out a
bunch more examples and they should get easier.

-Doctor Ethan,  The Math Forum

    }

    # reverse the digits of the input number
    my @num'r = $num.comb.reverse;
    my $place = $num.chars;

    my $dec = 0;
    for @num'r -> $digit {
	--$place; # first place is num chars - 1
	# need to convert the digit to dec first
	my $digit-val = %digit2dec{$digit};
	my $val = $digit-val * $bi ** $place;
	$dec += $val;
    }
    return $dec;
} # _to-dec-from-b37-b62

sub _from-dec-to-b37-b62(UInt $x'dec ,
			 #UInt $base-o where { 36 < $base-o < 63 }
			 UInt $base-o
		         --> Str) is export(:_from-dec-to-b37-b62) {
    # see Wolfram's solution (article Base)

    # need ln_b x = ln x / ln b
    my $log_b'x = log $x'dec / log $base-o; # note p6 routine 'log' is math function 'ln' if no optional base arg

    # get place index of first digit
    my $n = floor $log_b'x;

    # now the algorithm
    # we need @r below to be a fixed array of size $n + 2
    my @r[$n + 2];
    my @a[$n + 1];

    @r[$n] = $x'dec;

    # work through the $x'dec.chars places (????)
    # for now just handle integers (later, real, i.e., digits after a fraction point)
    for $n...0 -> $i { # <= Wolfram text is misleading here
	my $b'i  = $base-o ** $i;
	@a[$i]   = floor (@r[$i] / $b'i);

        say "  i = $i; a = '@a[$i]'; r = '@r[$i]'";

        # calc r for next iteration
	@r[$i-1] = @r[$i] - @a[$i] * $b'i if $i > 0;
    }

    #=begin pod
    # @a contains the index of the digits of the number in the new base
    my $x'b = '';
    # digits are in the reversed order
    for @a.reverse -> $di {
        my $digit = @dec2digit[$di];
        $x'b ~= $digit;
    }
    # trim leading zeroes
    $x'b ~~ s/^ 0+ /0/;
    $x'b ~~ s:i/^ 0 (<[0..9a..z]>) /$0/;

    return $x'b;
    #=end pod
} # _from-dec-to-b37-b62

sub rebase-b37-b62($x, $bi, $bo) {
    # error checks (see sub rebase)
    # is x valid member of base bi?
    # are bi and bo valid bases?
    # are bi or bo > 36?
    my $err = 0;

}
