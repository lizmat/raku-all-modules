use v6;

use YAMLish;

unit module Magento::Config;

our sub init(
    Str      :$host,
    Str      :$store,
    Str      :$access_token,
    IO::Path :$config_file = $*HOME.child('.6mag').child('config.yml')
) {

    my %config     = :$host, :$store, :$access_token;
    my $config_out = (S:g /'~'/$*HOME/ given $config_file).IO;

    # Ensure config dir exists
    mkdir $config_out.parent;

    # Write config file
    my Str $config_yaml = S:g /'...'// given save-yaml %config;
    return spurt $config_out, $config_yaml;

}

our sub from-file(
    IO::Path :$config_file = $*HOME.child('.6mag').child('config.yml')
) {
    load-yaml slurp (S:g /'~'/$*HOME/ given $config_file).IO.path;
}
