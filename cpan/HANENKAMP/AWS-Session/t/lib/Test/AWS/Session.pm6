unit module Test::AWS::Session;
use v6;

use AWS::Session;

sub TEST-SESSION-DEFAULTS is export {
    my %configuration := AWS::Session.DEFAULTS;
    %configuration<config-file>.default-value = 't/aws/config';
    %configuration<credentials-file>.default-value = 't/aws/credentials';
    %configuration;
}
