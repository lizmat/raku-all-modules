use v6;
unit class Hashids;

# An alphabet is a str at least 16 chars long, has no spaces and only has
# unique characters
subset Alphabet of Str where !.comb.repeated and .chars >= 16;
subset Salt of Str where .chars > 0;

constant $RATIO-SEPARATORS = 3.5;
constant $RATIO-GUARDS = 12;

constant $DEFAULT_ALPHABET = ('a'…'z', 'A'…'Z', '1'…'9', '0').join;
constant $DEFAULT_SEPARATORS = <cfhistuCFHISTU>;

has Salt $.salt;
has Alphabet $.alphabet;
has Int $.min-hash-length where * >= 0;
has Str $.separators where !.comb.repeated;
has Str $.guards;

method new(Salt $salt, Alphabet :$alphabet? = $DEFAULT_ALPHABET,
           Int :$min-hash-length? = 0, Str :$separators? = $DEFAULT_SEPARATORS) {
    my Str $s =''; 
    for $separators.comb -> $c {
        $s ~= $c if $alphabet.index($c).defined;
    }
    my $a = remove-str($alphabet, $s);

    my $len-separators = $s.chars;
    my $len-alphabet = $a.chars;

    if $len-alphabet + $len-separators < 16 {
        die "Alphabet must contain at least 16 unique characters";
    }

    $s = consistent-shuffle($s, $salt);

    my $min-separators = ceiling($len-alphabet / $RATIO-SEPARATORS);
    if !$s || $len-separators < $min-separators {
        $min-separators++ if $min-separators == 1;
        if $min-separators > $len-separators {
            my $split-at = $min-separators - $len-separators;
            $s = $a.comb[0…^$split-at].join;
            $a = $a.comb[$split-at…*].join;
            $len-alphabet = $a.chars;
        }
    }

    $a = consistent-shuffle($a, $salt);
    my $num-guards = ceiling($len-alphabet / $RATIO-GUARDS);
    my Str $guards;
    if $a.chars < 3 {
        $guards = $s.comb[0..^$num-guards].join;
        $s = $s.comb[$num-guards..*].join;
    } else {
        $guards = $a.comb[0..^$num-guards].join;
        $a = $a.comb[$num-guards..*].join;
    }
    return self.bless(:$salt, :alphabet($a), :$min-hash-length, :separators($s), :$guards);
}

our sub remove-str(Str $alphabet, Str $separators) {
    my $a = "";
    for $alphabet.comb -> $c {
        $a ~= $c unless $separators.index($c).defined;
    }
    return $a;
}

method encode(*@numbers where .all() >= 0) returns Str {
        my $alphabet = $.alphabet;
        my $len-alphabet = $alphabet.chars;
        my $len-separators = self.separators.chars;
        my $values-hash =  [+]  @numbers.pairs.map: { .value % (.key + 100) };
        my $lottery = self.alphabet.comb[$values-hash % self.alphabet.chars];
        my $encoded = $lottery;
        for @numbers.kv -> $index, $number {
            my $alphabet-salt = play-lottery($lottery, $.salt, $alphabet);
            $alphabet = consistent-shuffle($alphabet, $alphabet-salt);
            my $last = hash($number, $alphabet);
            $encoded ~= $last;
            my $new-index = ($number % ($last[0].ord + $index)) % $len-separators;
            $encoded ~= $.separators.comb[$new-index];
        }
        $encoded = $encoded.comb[0..*-2].join;

        return $encoded if $encoded.chars >= $.min-hash-length;
        return self!ensure-length($encoded, $alphabet, $values-hash);
        die <This shouldn't happen>;
}

our sub play-lottery($lottery, $salt, $alphabet) {
    return ($lottery ~ $salt ~ $alphabet).comb[0..^$alphabet.chars].join
}

method decode(Str $id) {
    my $a = $.alphabet;
    my @parts =  _split($id, $.guards);
    my $hashid = (1 < @parts.elems < 4)  ?? @parts[1] !! @parts[0];
    my $lottery = $hashid.comb[0];
    $hashid = $hashid.comb[1..*].join;
    my @hash_parts = _split($hashid, $.separators);
    say @hash_parts;
    my @result;
    for @hash_parts -> $part {
        say "-> $part";
        my $alphabet-salt = play-lottery($lottery, $.salt, $a);
        $a = consistent-shuffle($a, $alphabet-salt);
        @result.append: unhash($part, $a);
    }
    return @result;
}

our sub _split(Str $string, $splitters){
    my Str @parts;
    my Str $cur = '';
    for $string.comb -> $c {
        if $splitters.index($c).defined {
            @parts.append($cur);
            $cur = '';
        } else {
            $cur ~= $c;
        }
    }
    @parts.append: $cur;
    return @parts;
}

method !ensure-length(Str $string, Str $alphabet, Int $values-hash) returns Str {
    my $len-separators = $!separators.chars;
    my $index = ($values-hash + $string.comb[0].ord) % $len-separators;
    my $encoded = $!separators.comb[$index] ~ $string;

    if $encoded.chars < $!min-hash-length {
        $index = ($values-hash + $encoded.comb[2].ord) % $len-separators;
        $encoded += $!separators[$index];
    }

    my $split-at = $alphabet.chars / 2;
    while ($encoded.chars < $!min-hash-length) {
    }
    return $encoded;
}

our sub hash(UInt $n, Str $alphabet) returns Str {
    my $number = $n;
    my $hashed = '';
    my $alphabet-len = $alphabet.chars;
    loop {
        $hashed = $alphabet.comb[$number % $alphabet-len] ~ $hashed;
        $number = ($number div $alphabet-len).round;
        return $hashed if $number == 0;
    }
}

our sub unhash(Str $hashed, $alphabet){
    my $number = 0;
    my $len-hash = $hashed.chars;
    my $len-alphabet = $alphabet.chars;
    for $hashed.comb.kv -> $i, $c {
        my Int $pos = $alphabet.index($c);
        $number += $pos * $len-alphabet ** ($len-hash - $i - 1);
    }
    return $number;
}

our sub consistent-shuffle(Str $string, Salt $salt) returns Str {
    my Int $length-salt = $salt.chars;
    return $string if $length-salt == 0;

    my Int $index = 0;
    my Int $integer_sum = 0;
    my $str = $string;
    loop (my $i = $string.chars -1; $i >0; $i--){
        $index %= $length-salt;
        my $integer = ord $salt.comb[$index];
        $integer_sum += $integer;
        my $j = ($integer + $index + $integer_sum) % $i;
        my $tmp_char = $str.comb[$j];
        my $trailer = $j+1 < $str.chars ?? $str.comb[$j+1…*].join !! '';
        $str= $str.comb[0…^$j].join ~ $str.comb[$i] ~ $trailer;
        $str = $str.comb[0…^$i].join ~ $tmp_char ~ $str.comb[$i+1…*].join;
        $index++;
    }

    return $str;
    
}

=begin pod

=begin NAME

Hashids — generate short and reversable hashes from numbers.

=end NAME

=begin SYNOPSIS

    use Hashids;
    my $hashids = Hashids.new('this is my salt');

    # encrypt a single number
    my $hash = $hashids.encode(123);         # 'YDx'
    my $number = $hashids.decode('Ydx');     # 123

    # or a list
    $hash = $hashids.encode(1, 2, 3);        # 'eGtrS8'
    my @numbers = $hashids.decode('laHquq'); # (1, 2, 3)

=end SYNOPSIS

=begin DESCRIPTION

Hashids is designed for use in URL shortening, tracking stuff, validating
accounts or making pages private (through abstraction.) Instead of showing items
as C<1>, C<2>, or C<3>, you could show them as C<b9iLXiAa>, C<EATedTBy>, and
C<Aaco9cy5>.  Hashes depend on your salt value.

This is a port of the Hashids JavaScript library for Perl 6.

B<IMPORTANT>: This implementation follows the v1.0.0 API release of
hashids.js.
=end DESCRIPTION

=begin AUTHOR

Bahtiar `kalkin-` Gadimov <bahtiar@gadimov.de>

Follow me L<@_kalkin|https://twitter.com/_kalkin>
Or L<https://bahtiar.gadimov.de/>

=end AUTHOR

=begin COPYRIGHT

Copyright 2016 Bahtiar `kalkin-` Gadimov.
=end COPYRIGHT

=begin LICENSE
MIT License. See the LICENSE file. You
can use Hashids in open source projects and commercial products.
=end LICENSE
=end pod
