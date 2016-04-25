use Digest::SHA;
use Digest::HMAC;


our $ALGORITHM2SIGNING_METHOD_MAP = {
    HS256 => &sha256
=begin unsupported
    HS384 => \&Digest::SHA::hmac_sha384,
    HS512 => \&Digest::SHA::hmac_sha512,
=end unsupported
};

class JSON::WebToken::Crypt::HMAC {
  method sign($algorithm, $message, $key) {
    my $method = $ALGORITHM2SIGNING_METHOD_MAP{$algorithm};
    return hmac-hex($message, $key, $method);
  }

  method verify($algorithm, $message, $key, $signature) {
    my $sign = self.sign($algorithm, $message, $key);
    return $sign eq $signature ?? 1 !! 0;
  }
}

=finish
