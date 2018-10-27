use v6;
use Test;

plan 7;

use JSON::JWT;

# jwt.io HS256
my $test = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ';
dies-ok { JSON::JWT.decode($test, :alg('none')) }, 'none alg fails';
dies-ok { JSON::JWT.decode($test, :alg('RS256')) }, 'RS256 alg fails';
dies-ok { JSON::JWT.decode($test, :alg('HS256'), :secret('asdf')) }, 'bad secret fails';
my $decoded;
lives-ok { $decoded = JSON::JWT.decode($test, :alg('HS256'), :secret('secret')) }, 'correct decode succeeds';

is $decoded<sub>, '1234567890', 'Got correct data';

# jwt.io RS256
my $rsatest = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.EkN-DOsnsuRjRO6BxXemmJDm3HbxrbRzXglbN2S4sOkopdU4IsDxTI8jO19W_A4K8ZPJijNLis4EZsHeY559a4DFOd50_OqgHGuERTqYZyuhtF39yxJPAjUESwxk2J5k_4zM3O-vtd1Ghyo4IbqKKSy6J9mTniYJPenn5-HIirE';
my $rsadecoded;
my $pem = slurp 't/pub.pem';
lives-ok { $rsadecoded = JSON::JWT.decode($rsatest, :alg('RS256'), :$pem) }, 'correct decode succeeds';

is $rsadecoded<sub>, '1234567890', 'Got correct data';
