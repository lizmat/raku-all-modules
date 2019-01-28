use v6;

unit module Sparrowdo::Azure::Web::Cert:ver<0.0.3>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::File;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {

    my $az-res-group = %args<az-res-group>;
    my $thumbprint  = %args<thumbprint>;
    my $domain = %args<domain>;
    my $kv-id = %args<kv-id>;
    my $kv-secret-name = %args<kv-secret-name>;
    my $app-srv = %args<app-service>;
    my $skip-cert-crt = %args<skip-cert-crt>;
    
    my $base-dir = '/home/' ~ %*ENV<USER> ~ '/.azure-web-cert/' ~ $domain;

    directory-delete $base-dir;
    directory "$base-dir/arm";
    
    template-create "$base-dir/arm/update-cert.json", %(
      source => ( slurp %?RESOURCES<update-cert.json> ),
      variables => %(
        app_service_name  => $app-srv,
        domain            => $domain,
        thumbprint        => $thumbprint
      )
    );
    
    unless $skip-cert-crt {
    
      template-create "$base-dir/arm/create-cert.json", %(
        source => ( slurp %?RESOURCES<create-cert.json> ),
        variables => %(
          keyvault_id           => $kv-id,
          keyvault_secret_name  => $kv-secret-name,
          res_group             => $az-res-group,
          thumbprint            => $thumbprint,
        )
      );
    
    }
    
    task-run "validate json files", "json-lint", %(
      path => "$base-dir/arm"
    );
    
    my $mode = %args<mode> || 'default';
    
    say "mode: $mode";
    
    if $mode eq 'validate' or $mode eq 'default' {
    
      unless $skip-cert-crt {
        bash qq:to/HERE/, %(  description => "validate az group deploy / create cert", expect_stdout => 'Succeeded' );
          set -x
          az group deployment validate  -g  $az-res-group  --template-file $base-dir/arm/create-cert.json
        HERE
      }
    
      bash qq:to/HERE/, %(  description => "validate az group deploy / update cert", expect_stdout => 'Succeeded');
        set -x
        az group deployment validate  -g  $az-res-group  --template-file $base-dir/arm/update-cert.json
      HERE
    }
    
    if $mode eq 'default' {
    
      unless $skip-cert-crt {
        bash qq:to/HERE/, %(  description => "run az group deploy / create cert", expect_stdout => 'create-cert\s+' ~ $az-res-group );
          set -x
          az group deployment create -g  $az-res-group  --template-file $base-dir/arm/create-cert.json
        HERE
      }
    
      bash qq:to/HERE/, %(  description => "run az group deploy / update cert" , expect_stdout => 'update-cert\s+' ~ $az-res-group );
        set -x
        az group deployment create -g  $az-res-group  --template-file $base-dir/arm/update-cert.json
      HERE
    
    }
    
    
    if %args<check-ssl> {
      bash "sleep 8", %(
        description => "sleep for 8 seconds to let new certs apply"
      );
      task-run  "check ssl cert for $domain", "check-ssl-cert", %(
        hosts => [ $domain  ],
        expiration_date => 3,
      )
    }
    
}

