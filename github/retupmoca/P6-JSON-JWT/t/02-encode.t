use v6;
use Test;

plan 6;

use JSON::JWT;

my %data = :a(1), :b(2), :c(3);

my $encoded;
my $decoded;
lives-ok { $encoded = JSON::JWT.encode(%data,    :alg('none')) }, 'Can encode with alg none';
lives-ok { $decoded = JSON::JWT.decode($encoded, :alg('none')) }, 'correct decode succeeds';
lives-ok { $encoded = JSON::JWT.encode(%data,    :alg('HS256'), :secret('secret')) },
    'Can encode with alg HS256';
lives-ok { $decoded = JSON::JWT.decode($encoded, :alg('HS256'), :secret('secret')) },
    'correct decode succeeds';
lives-ok { $encoded = JSON::JWT.encode(%data,    :alg('RS256'), :pem(slurp('t/priv.pem'))) },
    'Can encode with alg RS256';
lives-ok { $decoded = JSON::JWT.decode($encoded, :alg('RS256'), :pem(slurp('t/pub.pem'))) },
    'correct decode succeeds';
