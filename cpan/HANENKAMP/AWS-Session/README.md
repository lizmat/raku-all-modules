NAME
====

AWS::Session - Common data useful for accessing and configuring AWS APIs

SYNOPSIS
========

    use AWS::Session;
    use AWS::Credentials;

    my $session      = AWS::Session.new(
        profile => 'my-profile',
    );

    # Read configuration from the current environment
    my $profile      = $session.profile;
    my $region       = $session.region;

    # Fetch credentials from the current environment
    my $credentials = load-credentials($session);
    my $access-key  = $credentials.access-key;
    my $secret-key  = $credentials.secret-key;
    my $token       = $credentials.token;

    # Read the AWS configuration file
    my %config       = $session.get-configuration;
    my %profile-conf = $session.get-profile-configuration('default');
    my %current-conf = $session.get-current-configuration;

    # Read the AWS credentials file
    my %cred         = $session.get-credentials;
    my %profile-cred = $session.get-profile-credentials('default');
    my %current-cred = $session.get-current-credentials;

DESCRIPTION
===========

AWS clients share some common configuration data. This provides modules for
loading that data.

Hardcoded credentials are a terrible idea when using AWS. These modules also
help to make it easy to pull credentials from the current environment.

The recommended way to get credentials is to use the `load-credentials()`
subroutine. This takes or automatically constructs an
[AWS::Session](AWS::Session) object that represents the state of configuration
in the local environment and uses that and other aspects of the local
environment to locate the credentials that should be used by this service.

    # Use a newly constructed session
    {
        my $credentials = load-credentials();
    }

    # OR if you already have a session object
    {
        use AWS::Session;
        my $session = AWS::Session.new(:profile<production>);
        my $credentials = load-credentials($session);
    }

See the POD for details, but all of this is highly configurable.
