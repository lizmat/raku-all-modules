unit class AWS::Session:ver<0.3>:auth<github:zostay>;
use v6;

use Config::INI;

=begin pod

=head1 NAME

AWS::Session - Common data useful for accessing and configuring AWS APIs

=head1 SYNOPSIS

    use AWS::Session;

    my $session      = AWS::Session.new(
        profile => 'my-profile',
    );

    my $profile      = $session.profile;
    my $region       = $session.region;
    my $data-path    = $session.data-path;
    my $config-file  = $session.config-file;
    my $ca-bundle    = $session.ca-bundle;
    my %api-versions = $session.api-versions;
    my $cred-file    = $session.credentials-file;
    my $timeout      = $session.metadata-service-timeout;
    my $attempts     = $session.metadata-service-num-attempts;

    # Read the AWS configuration file
    my %config       = $session.get-configuration;
    my %profile-conf = $session.get-profile-configuration('default');
    my %current-conf = $session.get-current-configuration;

    # Read the AWS credentials file
    my %cred         = $session.get-credentials;
    my %profile-cred = $session.get-profile-credentials('default');
    my %current-cred = $session.get-current-credentials;

=head1 DESCRIPTION

AWS clients share some common configuration data. This is a configurable module for loading that data.

=head1 ATTRIBUTES

Any attributes provided will override any configuration values found on the system through the environment, configuration, or defaults.

=head2 profile

The configuration files are in INI format. These are broken up into sections. Each section is a profile. This way you can have multiple AWS configurations, each with its own settings and credentials.

=head2 region

This is the AWS region code to use.

=head2 data-path

The botocore system uses data models to figure out how to interact with AWS APIs. This is the path where additional models can be loaded.

=head2 config-file

This is the location of the AWS configuration file.

=head2 ca-bundle

This is the location of the CA bundle to use.

=head2 api-versions

This is a hash of API versions to prefer for each named API.

=head2 credentials-file

This is the location of the credentials file.

=head2 metadata-service-timeout

This is the timeout to use with the metadata service.

=head2 metadata-service-num-attempts

This is the number of attempts to make when using the metadata service.

=head2 session-configuration

This is a map of configuration variable names to L<AWS::Session::Default> objects, which define how to configure them.

=head1 HELPERS

=head2 AWS::Session::Default

This is a basic structural class. All attributes are optional.

=head3 ATTRIBUTES

=head4 config-file

This is the name of the variable to use when loading the value from the configuration file.

=head4 env-var

This is an array of names of the environment variable to use for the value.

=head4 default-value

This is the default value to fallback to.

=head4 converter

This is a function that will convert values from the configuration file or environment variable to the appropriate object.

=head1 METHODS

=head2 get-configuration

    method get-configuration($config-file?, :$reload?) returns Hash

Returns the full contents of the configuration as a hash of hashes. Normally, this method caches the configuration. Setting the C<:reload> flag will force the configuration cache to be ignored.

=head2 get-profile-configuration

    method get-profile-configuration(Str:D $profile, :$config-file?) returns Hash

Returns the named profile configuration.

=head2 get-current-configuration

    method get-current-configuration() returns Hash

Returns the configuration for the current profile.

=head2 get-credentials

    method get-credentials($credentials-file?) returns Hash

Returns the full contents of the credentials file as a hash of hashes. Unlike configuration, the contents of this file is not cached.

=head2 get-profile-credentials

    method get-profile-credentials(Str:D $profile, :$credentials-file?) returns Hash

Returns the named profile credentials.

=head2 get-current-credentials

    method get-current-credentials() returns Hash

Returns the credentials for the current profile.

=head2 get-config-variable

    method get-config-variable(
        Str $logical-name,
        Bool :$from-instance = True,
        Bool :$from-env = True,
        Bool :$from-config = True,
    )

Loads the configuration named variable from the current configuration. This is loaded from the configuration file, environment, or whatever according to the default set in C<session-configuration>. Returns C<Nil> if no such configuration is defined for the given C<$logical-name>.

The boolean flags are used to select which methods will be consulted for determining the variable value.

=item from-instance When True, the local instance variable will be checked.

=item from-env When True, the process environment variables will be searched for the value.

=item from-config When True, the shared configuration file will be consulted for the value.

The value will be pulled in the order listed above, with the first value found being the one chosen.

=end pod

class Default {
    has $.config-file is rw;
    has @.env-var is rw;
    has $.default-value is rw;
    has &.converter;
}

our sub IO-and-tilde($path) {
    $path.subst(/^ '~/' /, "$*HOME/").IO;
}

method DEFAULTS returns Hash {
    %(
        profile => Default.new(:env-var<AWS_DEFAULT_PROFILE AWS_PROFILE>, :default-value<default>),
        region => Default.new(:config-file<region>, :env-var<AWS_DEFAULT_REGION>),
        data-path => Default.new(:config-file<data-path>, :env-var<AWS_DATA_PATH>, :converter(&IO-and-tilde)),
        config-file => Default.new(:env-var<AWS_CONFIG_FILE>, :default-value<~/.aws/config>, :converter(&IO-and-tilde)),
        ca-bundle => Default.new(:config-file<ca_bundle>, :env-var<AWS_CA_BUNDLE>, :converter(&IO-and-tilde)),
        api-versions => Default.new(:config-file<api-version>, :default-value(%)),

        credentials-file => Default.new(
            :env-var<AWS_SHARED_CREDENTIALS_FILE>,
            :default-value<~/.aws/credentials>,
            :converter(&IO-and-tilde),
        ),

        metadata-service-timeout => Default.new(
            :config-file<metadata_service_timeout>,
            :env-var<AWS_METADATA_SERVICE_TIMEOUT>,
            :default-value(1),
            :converter({.Int}),
        ),

        metadata-service-num-attempts => Default.new(
            :config-file<metadata_service_num_attempts>,
            :env-var<AWS_METADATA_SERVICE_NUM_ATTEMPTS>,
            :default-value(1),
            :converter({.Int}),
        ),
    );
}

has %.session-configuration = AWS::Session.DEFAULTS;

has Str $.profile is rw;
has Str $.region is rw;
has IO::Path $.data-path is rw;
has IO::Path $.config-file is rw;
has IO::Path $.ca-bundle is rw;
has %.api-versions is rw;
has IO::Path $.credentials-file is rw;
has Int $.metadata-service-timeout is rw;
has Int $.metadata-service-num-attempts is rw;

has %!configuration-cache;
method get-configuration(::?CLASS:D: $config-file? is copy, Bool :$reload = False) {
    $config-file //= self.get-config-variable(
        'config-file',
        :!from-config
    );

    unless $reload {
        return $_ with %!configuration-cache{ $config-file };
    }

    %!configuration-cache{ $config-file } = Config::INI::parse_file(~$config-file);
}

method get-credentials(::?CLASS:D: $credentials-file? is copy) {
    $credentials-file //= self.get-config-variable('credentials-file');
    Config::INI::parse_file(~$credentials-file);
}

method get-profile-configuration(::?CLASS:D: Str:D $profile, :$config-file = $!config-file) {
    self.get-configuration($config-file).{ $profile } // %;
}

method get-profile-credentials(::?CLASS:D: Str:D $profile, :$credentials-file = $!credentials-file) {
    self.get-credentials($credentials-file).{ $profile } // %;
}

method get-current-configuration(::?CLASS:D:) {
    my $profile = self.get-config-variable('profile');
    self.get-profile-configuration($profile);
}

method get-current-credentials(::?CLASS:D:) {
    my $profile = self.get-config-variable('profile');
    self.get-profile-credentials($profile);
}

method get-instance-variable(::?CLASS:D: Str $logical-name) {
    with self.^attributes.first({ .name eq '$!' ~ $logical-name }) {
        return .get_value(self);
    }
    Nil;
}

method get-config-variable(::?CLASS:D:
    Str $logical-name,
    Bool :$from-instance = True,
    Bool :$from-env = True,
    Bool :$from-config = True,
) {
    return unless %!session-configuration{ $logical-name } :exists;

    my $default = %!session-configuration{ $logical-name };

    if $from-instance && self.get-instance-variable($logical-name) -> $value {
        return $value;
    }

    my $value;
    if $from-env {
        $value = $default.env-var.map(
            -> $env-var { %*ENV{ $env-var } }
        ).first({ .defined });
    }

    if $from-config && !$value.defined {
        my $profile = self.get-config-variable('profile', :!from-config);

        my %profile = self.get-profile-configuration($profile);

        $value = $_ with %profile{ $logical-name };
    }

    $value //= $default.default-value;

    return without $value;

    with $default.converter -> &converter {
        converter($value);
    }
    else {
        $value;
    }
}

method session-accessor(::?CLASS:D: $name) {
    my $self := self;
    Proxy.new(
        FETCH => method () { $self.get-config-variable($name) },
        STORE => method ($v) {
            $self.^attributes.first({ .name eq '$!' ~ $name }).set_value($self, $v);
        },
    )
}

method profile(::?CLASS:D:) returns Str { self.session-accessor('profile') }
method region(::?CLASS:D:) returns Str { self.session-accessor('region') }
method data-path(::?CLASS:D:) returns IO::Path { self.session-accessor('data-path') }
method config-file(::?CLASS:D:) returns IO::Path { self.session-accessor('config-file') }
method ca-bundle(::?CLASS:D:) returns IO::Path { self.session-accessor('ca-bundle') }
method api-versions(::?CLASS:D:) returns Hash { self.session-accessor('api-versions') }
method credentials-file(::?CLASS:D:) returns IO::Path { self.session-accessor('credentials-file') }
method metadata-service-timeout(::?CLASS:D:) returns Int { self.session-accessor('metadata-service-timeout') }
method metadata-service-num-attempts(::?CLASS:D:) returns Int { self.session-accessor('metadata-service-num-attempts') }
