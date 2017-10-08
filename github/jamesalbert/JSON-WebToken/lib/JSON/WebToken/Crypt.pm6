unit package JSON::WebToken::Crypt;

sub sign is export {
    my ($class, $algorithm, $message, $key) = @_;
    die 'sign method must be implements!';
}

sub verify is export {
    my ($class, $algorithm, $message, $key, $signature) = @_;
    die 'verify method must be implements!'
}

=finish
