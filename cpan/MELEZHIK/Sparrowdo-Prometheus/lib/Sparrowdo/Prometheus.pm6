use v6;

unit module Sparrowdo::Prometheus;

use Sparrowdo;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Systemd;
use Sparrowdo::Core::DSL::Service;

our sub tasks (%args) {

  my $distro-url = 'https://github.com/prometheus/prometheus/releases/download/v1.8.0/prometheus-1.8.0.linux-amd64.tar.gz';
  
  directory '/var/data/prometheus';
  
  module_run 'RemoteFile', %(
    url       => $distro-url,
    location  => '/var/data/prometheus/prometheus.tar.gz'
  );
  
  module_run 'Archive', %(
   source  => '/var/data/prometheus/prometheus.tar.gz',
   target  => '/var/data/prometheus/',
  );
  
  systemd-service "prometheus", %(
    user => "root",
    workdir => "/var/data/prometheus/prometheus-1.8.0.linux-amd64",
    command => "/var/data/prometheus/prometheus-1.8.0.linux-amd64/prometheus"
  );
  
  service-start "prometheus";
  
}

