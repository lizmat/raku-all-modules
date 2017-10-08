use Data::Dump;
use JSON::WebToken;
use Test;

my $claims = {
  iss => 'joe',
  exp => 1300819380
};
my $secret = 'secret';

my $jwt = encode_jwt $claims, $secret; #, 'RS256';
say "encoded " ~ Dump($claims) ~ " to $jwt";
my $decoded = decode_jwt $jwt, $secret;
say "decoded to " ~ Dump($decoded);

is-deeply $decoded, $claims;
done-testing;
