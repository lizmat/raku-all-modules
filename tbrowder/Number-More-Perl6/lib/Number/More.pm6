unit module Number::More:auth<github:tbrowder>;

# file:  ALL-SUBS.md
# title: Subroutines Exported by the `:ALL` Tag

# export a debug var for users
our $DEBUG is export(:DEBUG) = False;
BEGIN {
    if %*ENV<NUMBER_MORE_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}

# export a var for users to set length behavior
our $LENGTH-HANDLING is export(:DEBUG) = 'ignore'; # other options: 'warn', 'fail'
my token length-action { ^ :i warn|fail $ }

# define tokens for common regexes (no prefixes are allowed)
my token binary is export(:token-binary)            { ^ <[01]>+ $ }
my token octal is export(:token-octal)              { ^ <[0..7]>+ $ }
my token decimal is export(:token-decimal)          { ^ \d+ $ }              # actually an int
my token hexadecimal is export(:token-hecadecimal)  { :i ^ <[a..f\d]>+ $ }   # multiple chars

# for general base functions 2..62
my token all-bases is export(:token-all-bases)      { ^ <[2..9]> | <[1..5]><[0..9]> | 6 <[0..2]> $ }

# base 2 is binary
my token base2 is export(:token-base2)              { ^ <[01]>+ $ }
my token base3 is export(:token-base3)              { ^ <[012]>+ $ }
my token base4 is export(:token-base4)              { ^ <[0..3]>+ $ }
my token base5 is export(:token-base5)              { ^ <[0..4]>+ $ }
my token base6 is export(:token-base6)              { ^ <[0..5]>+ $ }
my token base7 is export(:token-base7)              { ^ <[0..6]>+ $ }
# base 8 is octal
my token base8 is export(:token-base8)              { ^ <[0..7]>+ $ }
my token base9 is export(:token-base9)              { ^ <[0..8]>+ $ }
# base 10 is decimal
my token base10 is export(:token-base10)            { ^ \d+ $ }              # actually an int
my token base11 is export(:token-base11)            { :i ^ <[a\d]>+ $ }      # multiple chars
my token base12 is export(:token-base12)            { :i ^ <[ab\d]>+ $ }     # multiple chars
my token base13 is export(:token-base13)            { :i ^ <[abc\d]>+ $ }    # multiple chars
my token base14 is export(:token-base14)            { :i ^ <[a..d\d]>+ $ }   # multiple chars
my token base15 is export(:token-base15)            { :i ^ <[a..e\d]>+ $ }   # multiple chars
# base 16 is hexadecimal
my token base16 is export(:token-base16)            { :i ^ <[a..f\d]>+ $ }   # multiple chars
my token base17 is export(:token-base17)            { :i ^ <[a..g\d]>+ $ }   # multiple chars
my token base18 is export(:token-base18)            { :i ^ <[a..h\d]>+ $ }   # multiple chars
my token base19 is export(:token-base19)            { :i ^ <[a..i\d]>+ $ }   # multiple chars

my token base20 is export(:token-base20)            { :i ^ <[a..j\d]>+ $ }   # multiple chars
my token base21 is export(:token-base21)            { :i ^ <[a..k\d]>+ $ }   # multiple chars
my token base22 is export(:token-base22)            { :i ^ <[a..l\d]>+ $ }   # multiple chars
my token base23 is export(:token-base23)            { :i ^ <[a..m\d]>+ $ }   # multiple chars
my token base24 is export(:token-base24)            { :i ^ <[a..n\d]>+ $ }   # multiple chars
my token base25 is export(:token-base25)            { :i ^ <[a..o\d]>+ $ }   # multiple chars
my token base26 is export(:token-base26)            { :i ^ <[a..p\d]>+ $ }   # multiple chars
my token base27 is export(:token-base27)            { :i ^ <[a..q\d]>+ $ }   # multiple chars
my token base28 is export(:token-base28)            { :i ^ <[a..r\d]>+ $ }   # multiple chars
my token base29 is export(:token-base29)            { :i ^ <[a..s\d]>+ $ }   # multiple chars

my token base30 is export(:token-base30)            { :i ^ <[a..t\d]>+ $ }   # multiple chars
my token base31 is export(:token-base31)            { :i ^ <[a..u\d]>+ $ }   # multiple chars
my token base32 is export(:token-base32)            { :i ^ <[a..v\d]>+ $ }   # multiple chars
my token base33 is export(:token-base33)            { :i ^ <[a..w\d]>+ $ }   # multiple chars
my token base34 is export(:token-base34)            { :i ^ <[a..x\d]>+ $ }   # multiple chars
my token base35 is export(:token-base35)            { :i ^ <[a..y\d]>+ $ }   # multiple chars
my token base36 is export(:token-base36)            { :i ^ <[a..z\d]>+ $ }   # multiple chars

# char sets for higher bases are case sensitive
my token base37 is export(:token-base37)            { ^ <[A..Za\d]>+ $ }     # case-sensitive, multiple chars
my token base38 is export(:token-base38)            { ^ <[A..Zab\d]>+ $ }    # case-sensitive, multiple chars
my token base39 is export(:token-base39)            { ^ <[A..Zabc\d]>+ $ }   # case-sensitive, multiple chars

my token base40 is export(:token-base40)            { ^ <[A..Za..d\d]>+ $ }  # case-sensitive, multiple chars
my token base41 is export(:token-base41)            { ^ <[A..Za..e\d]>+ $ }  # case-sensitive, multiple chars
my token base42 is export(:token-base42)            { ^ <[A..Za..f\d]>+ $ }  # case-sensitive, multiple chars
my token base43 is export(:token-base43)            { ^ <[A..Za..g\d]>+ $ }  # case-sensitive, multiple chars
my token base44 is export(:token-base44)            { ^ <[A..Za..h\d]>+ $ }  # case-sensitive, multiple chars
my token base45 is export(:token-base45)            { ^ <[A..Za..i\d]>+ $ }  # case-sensitive, multiple chars
my token base46 is export(:token-base46)            { ^ <[A..Za..j\d]>+ $ }  # case-sensitive, multiple chars
my token base47 is export(:token-base47)            { ^ <[A..Za..k\d]>+ $ }  # case-sensitive, multiple chars
my token base48 is export(:token-base48)            { ^ <[A..Za..l\d]>+ $ }  # case-sensitive, multiple chars
my token base49 is export(:token-base49)            { ^ <[A..Za..m\d]>+ $ }  # case-sensitive, multiple chars

my token base50 is export(:token-base50)            { ^ <[A..Za..n\d]>+ $ }  # case-sensitive, multiple chars
my token base51 is export(:token-base51)            { ^ <[A..Za..o\d]>+ $ }  # case-sensitive, multiple chars
my token base52 is export(:token-base52)            { ^ <[A..Za..p\d]>+ $ }  # case-sensitive, multiple chars
my token base53 is export(:token-base53)            { ^ <[A..Za..q\d]>+ $ }  # case-sensitive, multiple chars
my token base54 is export(:token-base54)            { ^ <[A..Za..r\d]>+ $ }  # case-sensitive, multiple chars
my token base55 is export(:token-base55)            { ^ <[A..Za..s\d]>+ $ }  # case-sensitive, multiple chars
my token base56 is export(:token-base56)            { ^ <[A..Za..t\d]>+ $ }  # case-sensitive, multiple chars
my token base57 is export(:token-base57)            { ^ <[A..Za..u\d]>+ $ }  # case-sensitive, multiple chars
my token base58 is export(:token-base58)            { ^ <[A..Za..v\d]>+ $ }  # case-sensitive, multiple chars
my token base59 is export(:token-base59)            { ^ <[A..Za..w\d]>+ $ }  # case-sensitive, multiple chars

my token base60 is export(:token-base60)            { ^ <[A..Za..x\d]>+ $ }  # case-sensitive, multiple chars
my token base61 is export(:token-base61)            { ^ <[A..Za..y\d]>+ $ }  # case-sensitive, multiple chars
my token base62 is export(:token-base62)            { ^ <[A..Za..z\d]>+ $ }  # case-sensitive, multiple chars

our @base is export(:base) = [
'0',
'1',
&base2, &base3, &base4, &base5, &base6, &base7, &base8, &base9,
&base10, &base11, &base12, &base13, &base14, &base15, &base16, &base17, &base18, &base19,
&base20, &base21, &base22, &base23, &base24, &base25, &base26, &base27, &base28, &base29,
&base30, &base31, &base32, &base33, &base34, &base35, &base36,

&base37, &base38, &base39,
&base40, &base41, &base42, &base43, &base44, &base45, &base46,
&base47, &base48, &base49, &base50, &base51, &base52, &base53,
&base54, &base55, &base56, &base57, &base58, &base59, &base60,
&base61, &base62
];

# standard digit set for bases 2 through 62 (char 0 through 61)
# the array of digits is indexed by their decimal value
our @dec2digit is export(:dec2digit) = <
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    a b c d e f g h i j k l m n o p q r s t u v w x y z
    >;

# standard digit set for bases 2 through 62 (char 0 through 61)
# the hash is comprised of digit keys and their decimal value
our %digit2dec is export(:digit2dec) = [
    0 =>  0, 1 =>  1, 2 =>  2, 3 =>  3, 4 =>  4, 5 =>  5, 6 =>  6, 7 =>  7, 8 =>  8, 9 =>  9,
    A => 10, B => 11, C => 12, D => 13, E => 14, F => 15, G => 16, H => 17, I => 18, J => 19,
    K => 20, L => 21, M => 22, N => 23, O => 24, P => 25, Q => 26, R => 27, S => 28, T => 29,
    U => 30, V => 31, W => 32, X => 33, Y => 34, Z => 35, a => 36, b => 37, c => 38, d => 39,
    e => 40, f => 41, g => 42, h => 43, i => 44, j => 45, k => 46, l => 47, m => 48, n => 49,
    o => 50, p => 51, q => 52, r => 53, s => 54, t => 55, u => 56, v => 57, w => 58, x => 59,
    y => 60, z => 61
];

my token base { ^ 2|8|10|16 $ }

# this is an internal sub
sub pad-number($num is rw,
               UInt $base where &all-bases,
               UInt $len = 0,
               Bool :$prefix = False,
	       Bool :$suffix = False,
               Bool :$LC = False,
	      ) {

    # this also checks for length error, upper-lower casing, and handling
    if $base > 10 && $base < 37 {
        if $LC {
	    # special feature for case-insensitive bases
            $num .= lc;
        }
    }

    my $nc  = $num.chars;
    my $nct = ($prefix && !$suffix) ?? $nc + 2 !! $nc;
    if $LENGTH-HANDLING ~~ &length-action && $nct > $len {
        my $msg = "Desired length ($len) of number '$num' is less than required by it";
        $msg ~= " and its prefix" if $prefix;
        $msg ~= " ($nct).";

        if $LENGTH-HANDLING ~~ /$ :i warn $/ {
            note "WARNING: $msg";
        }
        else {
            die "FATAL: $msg";
        }
    }

    if $len > $nct {
        # padding required
        # first pad with zeroes
        # the following test should always be true!!
        die "debug FATAL: unexpected \$len ($len) NOT greater than \$nc ($nc)" if $len <= $nc;
        # create the zero padding
        my $zpad = 0 x ($len - $nct);
        $num = $zpad ~ $num;
    }

    if $suffix {
	$num ~= "_base-$base";
    }
    elsif $prefix {
        when $base eq '2'  { $num = '0b' ~ $num }
        when $base eq '8'  { $num = '0o' ~ $num }
        when $base eq '16' { $num = '0x' ~ $num }
    }
} # pad-number

#------------------------------------------------------------------------------
# Subroutine: hex2dec
# Purpose : Convert a non-negative hexadecimal number (string) to a decimal number.
# Params  : Hexadecimal number (string), desired length (optional), suffix (optional).
# Returns : Decimal number (or string).
sub hex2dec(Str:D $hex where &hexadecimal,
            UInt $len = 0,
            Bool :$suffix = False,
            --> Cool) is export(:hex2dec) {
    # need bases of incoming and outgoing number
    constant $base-i = 16;
    constant $base-o = 10;

    my $dec = parse-base $hex, $base-i;
    pad-number $dec, $base-o, $len, :$suffix;
    return $dec;
} # hex2dec

#------------------------------------------------------------------------------
# Subroutine: hex2bin
# Purpose : Convert a non-negative hexadecimal number (string) to a binary string.
# Params  : Hexadecimal number (string), desired length (optional), prefix (optional), suffix (optional).
# Returns : Binary number (string).
sub hex2bin(Str:D $hex where &hexadecimal,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            --> Str) is export(:hex2bin) {
    # need bases of incoming and outgoing number
    constant $base-i = 16;
    constant $base-o =  2;

    # have to get decimal first
    my $dec = parse-base $hex, $base-i;
    my $bin = $dec.base: $base-o;
    pad-number $bin, $base-o, $len, :$prefix, :$suffix;
    return $bin;
} # hex2bin

#------------------------------------------------------------------------------
# Subroutine: dec2hex
# Purpose : Convert a non-negative integer to a hexadecimal number (string).
# Params  : Non-negative decimal number, desired length (optional), prefix (optional), suffix (optional), lower-case (optional).
# Returns : Hexadecimal number (string).
sub dec2hex($dec where &decimal,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            Bool :$LC = False
            --> Str) is export(:dec2hex) {
    # need base of outgoing number
    constant $base-o = 16;

    my $hex = $dec.base: $base-o;
    pad-number $hex, $base-o, $len, :$prefix, :$suffix, :$LC;
    return $hex;
} # dec2hex

#------------------------------------------------------------------------------
# Subroutine: dec2bin
# Purpose : Convert a non-negative integer to a binary number (string).
# Params  : Non-negative decimal number, desired length (optional), prefix (optional), suffix (optional).
# Returns : Binary number (string).
sub dec2bin($dec where &decimal,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            --> Str) is export(:dec2bin) {
    # need base of outgoing number
    constant $base-o = 2;

    my $bin = $dec.base: $base-o;
    pad-number $bin, $base-o, $len, :$prefix, :$suffix;
    return $bin;
} # dec2bin

#------------------------------------------------------------------------------
# Subroutine: bin2dec
# Purpose : Convert a binary number (string) to a decimal number.
# Params  : Binary number (string), desired length (optional), suffix (optional).
# Returns : Decimal number (or string).
sub bin2dec(Str:D $bin where &binary,
            UInt $len = 0,
            Bool :$suffix = False,
            --> Cool) is export(:bin2dec) {
    # need bases of incoming and outgoing numbers
    constant $base-i =  2;
    constant $base-o = 10;

    my $dec = parse-base $bin, $base-i;
    pad-number $dec, $base-o, $len, :$suffix;
    return $dec;
} # bin2dec

#------------------------------------------------------------------------------
# Subroutine: bin2hex
# Purpose : Convert a binary number (string) to a hexadecimal number (string).
# Params  : Binary number (string), desired length (optional), prefix (optional), suffix (optional), lower-case (optional).
# Returns : Hexadecimal number (string).
sub bin2hex(Str:D $bin where &binary,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            Bool :$LC = False,
            --> Str) is export(:bin2hex) {
    # need bases of incoming and outgoing number
    constant $base-i =  2;
    constant $base-o = 16;

    # need decimal intermediary
    my $dec = parse-base $bin, $base-i;
    my $hex = $dec.base: $base-o;
    pad-number $hex, $base-o, $len, :$prefix, :$suffix, :$LC;
    return $hex;
} # bin2hex

#------------------------------------------------------------------------------
# Subroutine: oct2bin
# Purpose : Convert an octal number (string) to a binary number (string).
# Params  : Octal number (string), desired length (optional), prefix (optional), suffix (optional).
# Returns : Binary number (string).
sub oct2bin($oct where &octal, UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            --> Str) is export(:oct2bin) {
    # need bases of incoming and outgoing number
    constant $base-i = 8;
    constant $base-o = 2;

    # need decimal intermediary
    my $dec = parse-base $oct, $base-i;
    my $bin = $dec.base: $base-o;
    pad-number $bin, $base-o, $len, :$prefix, :$suffix;
    return $bin;
} # oct2bin

#------------------------------------------------------------------------------
# Subroutine: oct2hex
# Purpose : Convert an octal number (string) to a hexadecimal number (string).
# Params  : Octal number (string), desired length (optional), prefix (optional), suffix (optional), lower-case (optional).
# Returns : Hexadecimal number (string).
sub oct2hex($oct where &octal, UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            Bool :$LC = False,
            --> Str) is export(:oct2hex) {
    # need bases of incoming and outgoing number
    constant $base-i =  8;
    constant $base-o = 16;

    # need decimal intermediary
    my $dec = parse-base $oct, $base-i;
    my $hex = $dec.base: $base-o;
    pad-number $hex, $base-o, $len, :$prefix, :$suffix, :$LC;
    return $hex;
} # oct2hex

#------------------------------------------------------------------------------
# Subroutine: oct2dec
# Purpose : Convert an octal number (string) to a decimal number.
# Params  : Octal number (string), desired length (optional), suffix (optional).
# Returns : Decimal number (or string).
sub oct2dec($oct where &octal, UInt $len = 0,
            Bool :$suffix = False,
            --> Cool) is export(:oct2dec) {
    # need bases of incoming and outgoing number
    constant $base-i =  8;
    constant $base-o = 10;

    my $dec = parse-base $oct, $base-i;
    pad-number $dec, $base-o, $len, :$suffix;
    return $dec;
} # oct2dec

#------------------------------------------------------------------------------
# Subroutine: bin2oct
# Purpose : Convert a binary number (string) to an octal number (string).
# Params  : Binary number (string), desired length (optional), prefix (optional), suffix (optional).
# Returns : Octal number (string).
sub bin2oct($bin where &binary,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            --> Str) is export(:bin2oct) {
    # need bases of incoming and outgoing number
    constant $base-i = 2;
    constant $base-o = 8;

    # need decimal intermediary
    my $dec = parse-base $bin, $base-i;
    my $oct = $dec.base: $base-o;
    pad-number $oct, $base-o, $len, :$prefix, :$suffix;
    return $oct;
} # bin2oct

#------------------------------------------------------------------------------
# Subroutine: dec2oct
# Purpose : Convert a non-negative integer to an octal number (string).
# Params  : Decimal number, desired length (optional), prefix (optional), suffix (optional).
# Returns : Octal number (string).
sub dec2oct($dec where &decimal,
            UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            --> Cool) is export(:dec2oct) {
    # need base of outgoing number
    constant $base-o =  8;

    my $oct = $dec.base: $base-o;
    pad-number $oct, $base-o, $len, :$prefix, :$suffix;
    return $oct;
} # dec2oct

#------------------------------------------------------------------------------
# Subroutine: hex2oct
# Purpose : Convert a hexadecimal number (string) to an octal number (string).
# Params  : Hexadecimal number (string), desired length (optional), prefix (optional), suffix (optional).
# Returns : Octal number (string).
sub hex2oct($hex where &hexadecimal, UInt $len = 0,
            Bool :$prefix = False,
            Bool :$suffix = False,
            --> Str) is export(:hex2oct) {
    # need bases of incoming and outgoing number
    constant $base-i = 16;
    constant $base-o =  8;

    # need decimal intermediary
    my $dec = parse-base $hex, $base-i;
    my $oct = $dec.base: $base-o;
    pad-number $oct, $base-o, $len, :$prefix, :$suffix;
    return $oct;
} # hex2oct

#------------------------------------------------------------------------------
# Subroutine: rebase
# Purpose : Convert any number (integer or string) and base (2..62) to a number in another base (2..62).
# Params  : Number (string), desired length (optional), prefix (optional), suffix (optional), suffix (optional), lower-case (optional).
# Returns : Desired number (decimal or string) in the desired base.
sub rebase($num-i,
           $base-i where &all-bases,
           $base-o where &all-bases,
           UInt $len = 0,
           Bool :$prefix = False,
           Bool :$suffix = False,
           Bool :$LC = False
           --> Cool) is export(:baseM2baseN) {

    # make sure incoming number is in the right base
    if $num-i !~~ @base[$base-i] {
        die "FATAL: Incoming number in sub 'rebase' is not a member of base '$base-i'.";
    }

    # check for same bases
    if $base-i eq $base-o {
        die "FATAL: Both bases are the same ($base-i), no conversion necessary."
    }

    # check for known bases, eliminate any prefixes
    my ($bi, $bo);
    {
        when $base-i == 2  {
	    $bi = 'bin';
	    $num-i ~~ s:i/^0b//;
	}
        when $base-i == 8  {
	    $bi = 'oct';
	    $num-i ~~ s:i/^0o//;
	}
        when $base-i == 16 {
	    $bi = 'hex';
	    $num-i ~~ s:i/^0x//;
	}
    }
    {
        when $base-o == 2  { $bo = 'bin' }
        when $base-o == 8  { $bo = 'oct' }
        when $base-o == 16 { $bo = 'hex' }
    }

    if $bi && $bo {
        note "\nNOTE: Use function '{$bi}2{$bo}' instead for an easier interface.";
    }

    # treatment varies if in or out base is decimal
    my $num-o;
    if $base-i == 10 {
	if $base-o < 37 {
            $num-o = $num-i.base: $base-o;
	}
	else {
            $num-o = _from-dec-to-b37-b62 $num-i, $base-o;
	}
    }
    elsif $base-o == 10 {
	if $base-i < 37 {
            $num-o = parse-base $num-i, $base-i;
	}
	else {
	    $num-o = _to-dec-from-b37-b62 $num-i, $base-o;
	}
    }
    elsif ($base-i < 37) && ($base-o < 37) {
        # need decimal as intermediary
        my $dec = parse-base $num-i, $base-i;
        $num-o  = $dec.base: $base-o;
    }
    else {
        # need decimal as intermediary
	my $dec;
	if $base-i < 37 {
            $dec = parse-base $num-i, $base-i;
	}
	else {
	    $dec = _to-dec-from-b37-b62 $num-i, $base-i;
	}
	if $base-o < 37 {
            $num-o = $dec.base: $base-o;
	}
	else {
            $num-o = _from-dec-to-b37-b62 $dec, $base-o;
	}
    }

    # finally, pad the number, make upper-case and add prefix or suffix as
    # appropriate
    if $base-o == 2 || $base-o == 8 {
        pad-number $num-o, $base-o, $len, :$prefix, :$suffix;
    }
    elsif $base-o == 16 {
        pad-number $num-o, $base-o, $len, :$prefix, :$suffix, :$LC;
    }
    elsif (10 < $base-o < 37) {
	# case insensitive bases
        pad-number $num-o, $base-o, $len, :$LC, :$suffix;
    }
    elsif (1 < $base-o < 11) {
	# case N/A bases
        pad-number $num-o, $base-o, $len, :$suffix;
    }
    else {
	# case SENSITIVE bases
        pad-number $num-o, $base-o, $len, :$suffix;
    }

    return $num-o;
} # rebase


sub _to-dec-from-b37-b62($num,
			 UInt $bi where { 36 < $bi < 63 }
			 #UInt $bi
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

#`{
# begin multi-line comment

General method of converting a whole number (decimal) to an base b
(from Wolfram, see [Base] in README.md references):

the index of the leading digit needed to represent the number x in
base b is:

  n = floor (log_b x) [see computing log_b below]

then recursively compute the successive digits:

  a_i = floor r_i / b_i )

where r_n = x and

  r_(i-1) = r_i - a_i * b^i

for i = n, n -1, ..., 1, 0

to convert between logarithms in different bases, the formula:

  log_b x = ln x / ln b

# end of multi-line comment
}

sub _from-dec-to-b37-b62(UInt $x'dec ,
			 UInt $base-o where { 36 < $base-o < 63 }
			 #UInt $base-o
		         --> Str) is export(:_from-dec-to-b37-b62) {

    # see Wolfram's solution (article Base, see notes above)

    # need ln_b x = ln x / ln b

    # note p6 routine 'log' is math function 'ln' if no optional base
    # arg is entered
    my $log_b'x = log $x'dec / log $base-o;

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

        say "  i = $i; a = '@a[$i]'; r = '@r[$i]'" if $DEBUG;

        # calc r for next iteration
	@r[$i-1] = @r[$i] - @a[$i] * $b'i if $i > 0;
    }

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
} # _from-dec-to-b37-b62
