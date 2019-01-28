use v6;

unit module Sparrowdo::VSTS::YAML::Update::Azure::SSL:ver<0.0.1>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::File;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {


  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";
  directory "$build-dir/files";

  file "$build-dir/files/inject-thumbprint.pl", %( content => slurp %?RESOURCES<inject-thumbprint.pl>.Str );

  directory "$build-dir/files/{%args<cert-name>}";

  template-create "$build-dir/files/{%args<cert-name>}/create-cert.json", %(
    source => ( slurp %?RESOURCES<create-cert.json> ),
    variables => %( 
      keyvault_name => %args<keyvault-name>, # the name of keyvault holding certificates
      cert_name => %args<cert-name>, # certificate name in keyvault
      resource_group => %args<resource-group>, # azure resource group
    )
  );

  template-create "$build-dir/files/{%args<cert-name>}/update-cert.json", %(
    source => ( slurp %?RESOURCES<update-cert.json> ),
    variables => %( 
      domain => %args<domain>, # web application domain name
      app_service => %args<app-service>, # azure app service name ( a.k web application )
    )
  );

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      base_dir => "$build-dir/files",
      subscription => %args<subscription>, # Azure subscription,
      keyvault_name => %args<keyvault-name>, # the name of keyvault holding certificates
      cert_name => %args<cert-name>, # certificate name in keyvault
      domain => %args<domain>, # web application domain name
      app_service => %args<app-service>, # azure app service name ( a.k web application )
      resource_group => %args<resource-group> , # azure resource group
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml";

}


