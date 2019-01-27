use v6;
unit module Test::Amazon::DynamoDB;

use Amazon::DynamoDB;
use AWS::Credentials;
use AWS::Session;

my constant $resolver = AWS::Credentials::Provider::FromEnv.new(
    :access-key<TEST_AWS_DDB_ACCESS_KEY_ID>,
    :secret-key<TEST_AWS_DDB_SECRET_ACCESS_KEY>,
    :token<TEST_AWS_DDB_SECURITY_TOKEN TEST_AWS_DDB_SESSION_TOKEN>,
    :expiry-time<TEST_AWS_DDB_CREDENTIAL_EXPIRATION>,
);

sub test-session() is export {
    AWS::Session.new(
        config-file      => 't/aws/config'.IO,
        credentials-file => 't/aws/credentials'.IO,
        region           => 'us-east-1',
    );
}

sub test-credentials() is export {
    AWS::Credentials.new(
        access-key => 'AKISUCHABADIDEATOHAV',
        secret-key => 'PJaLYouReallyOughtNotToDoThisOrPainComes',
    );
}

sub new-dynamodb-actions(
    :$ua is copy,
    :$scheme is copy,
    :$hostname is copy,
    :$port is copy,
    :$session is copy,
    :$credentials is copy,
) is export {
    $scheme      //= test-env<scheme>;
    $hostname    //= test-env<hostname>;
    $port        //= test-env<port>;

    $session     //= test-session();
    $credentials //= test-credentials();

    Amazon::DynamoDB.new(
        :$scheme, :$hostname, :$port,
        :$session,
        :$credentials,
        |(:$ua with $ua),
    );
}

sub test-env is export {
    $ //= %(
        scheme       => %*ENV<TEST_AWS_DDB_SCHEME> // 'http',
        hostname     => %*ENV<TEST_AWS_DDB_HOSTNAME>,
        port         => %*ENV<TEST_AWS_DDB_PORT>.defined ?? %*ENV<TEST_AWS_DDB_PORT>.Int !! Int,
        table-prefix => %*ENV<TEST_AWS_DDB_TABLE_PREFIX>,
    )
}

sub test-env-is-ok is export {
    constant $required = all(< hostname table-prefix >);
    test-env.{ $required }.defined;
}

sub test-env-skip-message is export {
    q<Missing required environment, at least TEST_AWS_DDB_HOSTNAME and TEST_AWS_DDB_TABLE_PREFIX must be set.>;
}

sub test-prefix is export {
    my $test-name = $*PROGRAM-NAME.IO.basename.subst(/.t$/, '');
    $test-name ~ $*PID
}

sub tn(Str $name) is export {
    my $test-tn = join '_', test-prefix(), $name;
    with test-env.<table-prefix> -> $table-prefix {
        join '_', $table-prefix, $test-tn
    }
    else {
        $test-tn
    }
}

sub test-data($name) is export {
    EVALFILE("t/corpus/$name.p6");
}
