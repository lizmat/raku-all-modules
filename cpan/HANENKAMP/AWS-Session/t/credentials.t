use v6;

use Test;
use AWS::Credentials;

use lib 't/lib';
use Test::AWS::Session;

plan 6;

my $session = AWS::Session.new(
    session-configuration => TEST-SESSION-DEFAULTS(),
);

{
    my $credentials = load-credentials($session);

    isa-ok $credentials, AWS::Credentials;

    is $credentials.access-key, 'AKEYDEFAULTDEFAULTDE';
    is $credentials.secret-key, 'SecretSecretSecretSecretSecretSecretSecr';
}

$session.profile = 'fun';
#dd $session.profile;

{
    my $credentials = load-credentials($session);

    isa-ok $credentials, AWS::Credentials;

    is $credentials.access-key, 'AKEYFUNFUNFUNFUNFUNF';
    is $credentials.secret-key, 'AlsoSecretSecretSecretSecretSecretSecret';
}

done-testing;
