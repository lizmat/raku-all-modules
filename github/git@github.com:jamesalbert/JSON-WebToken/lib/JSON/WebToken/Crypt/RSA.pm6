unit package JSON::WebToken::Crypt::RSA;


our $ALGORITHM2SIGNING_METHOD_MAP = {
=begin unsupported
    RS256  => 'use_sha256_hash',
    RS384  => 'use_sha384_hash',
    RS512  => 'use_sha512_hash',
    RSA1_5 => 'use_pkcs1_padding',
=end unsupported
};

sub sign is export {
    my ($algorithm, $message, $key) = @_;
=begin p5implementation

    my $private_key = Crypt::OpenSSL::RSA->new_private_key($key);
    my $method = $ALGORITHM2SIGNING_METHOD_MAP->{$algorithm};
    $private_key->$method;
    return $private_key->sign($message);
=end p5implementation
}

sub verify is export {
    my ($algorithm, $message, $key, $signature) = @_;
=begin p5implementation
    my $public_key = Crypt::OpenSSL::RSA->new_public_key($key);
    my $method = $ALGORITHM2SIGNING_METHOD_MAP->{$algorithm};
    $public_key->$method;
    return $public_key->verify($message, $signature) ? 1 : 0;
=end p5implementation
}

=finish
