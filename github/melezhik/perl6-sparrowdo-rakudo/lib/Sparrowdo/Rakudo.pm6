use v6;

unit module Sparrowdo::Rakudo;
use Sparrowdo;

our sub tasks (%args) {

    my $version = %args<version>;
    
    unless $version {

      $version = 'https://github.com/nxadm/rakudo-pkg/releases/download/2017.03_02/perl6-rakudo-moarvm-CentOS7.3.1611-20170300-02.x86_64.rpm'
        if target_os() ~~ m/centos/;

      $version = 'https://github.com/nxadm/rakudo-pkg/releases/download/2017.03_02/perl6-rakudo-moarvm-ubuntu17.04_20170300-02_i386.deb'
        if target_os() ~~ m/debian/;

      $version = 'https://github.com/nxadm/rakudo-pkg/releases/download/2017.03_02/perl6-rakudo-moarvm-ubuntu17.04_20170300-02_i386.deb'
        if target_os() ~~ m/ubuntu/;
        
    }

    task-run 'install Rakudo', 'rakudo-install', %(
      url => $version
    );
}

