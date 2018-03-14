use v6;

use Test;
use AWS::Session;

use lib 't/lib';
use Test::AWS::Session;

plan 16;

my $session = AWS::Session.new(
    session-configuration => TEST-SESSION-DEFAULTS(),
    data-path => 't/aws/my-data'.IO,
);

isa-ok $session, AWS::Session;

is $session.profile, 'default';
is $session.region, 'us-west-1';
is $session.data-path, 't/aws/my-data';
is $session.config-file, 't/aws/config';
is $session.ca-bundle, Nil;
is $session.api-versions, {};
is $session.credentials-file, 't/aws/credentials';
is $session.metadata-service-timeout, 1;
is $session.metadata-service-num-attempts, 1;

is $session.get-configuration.<default><region>, 'us-west-1';
is $session.get-current-configuration.<output>, 'json';
is $session.get-profile-configuration('fun').<region>, 'us-east-2';

is $session.get-credentials.<default><aws_access_key_id>, 'AKEYDEFAULTDEFAULTDE';
is $session.get-current-credentials.<aws_secret_access_key>, 'SecretSecretSecretSecretSecretSecretSecr';
is $session.get-profile-credentials('fun').<aws_access_key_id>, 'AKEYFUNFUNFUNFUNFUNF';

done-testing;
