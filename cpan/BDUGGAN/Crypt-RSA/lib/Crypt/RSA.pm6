#| Perl 6 implementation of RSA public key algorithm.
unit class Crypt::RSA;
use Crypt::RSA::Key;

has Crypt::RSA::Key $.public-key;
has Crypt::RSA::Key $.private-key;

has &.random-prime-generator = sub (UInt $digits = 110) {
  repeat { $_ = (10**$digits .. (10**($digits+1))).pick } until .is-prime;
  return $_;
}

has &.random-range-picker = sub (Range $range) returns UInt {
    return $range.pick
}

method !random-prime(*@args) returns UInt {
    return &.random-prime-generator()(|@args);
}

#| Generate a public and private key.  Args will be passed to the random-prime-generator.
method generate-keys(*@args) {
    my $q = self!random-prime(|@args);
    my $p = self!random-prime(|@args);
    my $pq = $p * $q;
    my $phi = ($p-1) * ($q-1);
    my $k;
    repeat {
      $k = &.random-range-picker()(1..$pq);
    } until $k gcd $phi == 1;

    my $inverse = expmod($k, -1, $phi);
    $!public-key = Crypt::RSA::Key.new(exponent => $k , modulus => $pq );
    $!private-key = Crypt::RSA::Key.new(exponent => $inverse, modulus => $pq );
    return ($!public-key, $!private-key);
}

#| Encrypt a message with the public key
method encrypt(UInt $message) {
  return expmod($message,$!public-key.exponent,$!public-key.modulus)
}

#| Decrypt a message with the private key.
method decrypt(UInt $message) {
  return expmod($message,$!private-key.exponent,$!private-key.modulus)
}

#| Generate a signature for a message with the private key.
method generate-signature(UInt $message) {
  return expmod($message,$!private-key.exponent,$!private-key.modulus)
}

#| Verify a signature against the public key.
method verify-signature(UInt $message, UInt $signature) {
  return expmod($signature,$!public-key.exponent,$!public-key.modulus)==$message;
}

