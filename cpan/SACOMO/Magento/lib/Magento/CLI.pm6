#!/usr/bin/env perl6

use v6;

use Magento::Config;

unit module Magento::CLI;

sub USAGE is export {
  say q:to/END/;
      Usage:
        6mag init         - Generate Integration token based config
        6mag print-config - Print Integration token config
        6mag version      - Print 6mag version and exit

      Optional arguments:

        --config=         - Specify a custom config file location
                            Default is `~/.6mag/config.yml`
  
        e.g. 6mag --config=path/to/config.yml init
  END
}

multi sub MAIN(
    'init',
    Str :$config
) is export {
    my $host         = prompt "Please enter the Magento host URL (e.g. http://localhost): ";
    my $store        = prompt "Please enter the store identifier (e.g. default): ";
    my $access_token = prompt "Please enter Integration Access Token (System > Integrations): ";
    my $config_file  = $config ?? IO::Path.new($config) !! $*HOME.child('.6mag').child('config.yml');
    my $config_out   = Magento::Config::init :$host, :$store, :$access_token, :$config_file;
    say "Config file written to {$config_out.IO.path}";
}

multi sub MAIN(
    'print-config',
    Str :$config
) {
    my $config_file  = $config ?? IO::Path.new($config) !! $*HOME.child('.6mag').child('config.yml');
    my %config = Magento::Config::from-file :$config_file;
    say qq:to/EOF/;

    Magento config:
    
    Host: {%config<host>}
    Store: {%config<store>}
    Access token: {%config<access_token>}
    EOF
}

multi sub MAIN(
    'version'
) {
    use Magento;
    say "Magento version {Magento.^ver}";
}
