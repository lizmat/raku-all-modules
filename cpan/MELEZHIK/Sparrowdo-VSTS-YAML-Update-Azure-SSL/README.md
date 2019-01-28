# Sparrowdo::VSTS::YAML::Update::Azure::SSL

Sparrowdo module to generate VSTS yaml build definitions to update Azure ssl certs.

    $ cat sparrowfile

    module_run "VSTS::YAML::Update::Azure::SSL", %(
      build-dir => ".build",
      subscription => "Dev01", # Azure subscription,
      keyvault-name => "app-01-02", # the name of keyvault holding certificates 
      cert-name => "app-dev", # certificate name in keyvault 
      domain => "foo.bar", # web application domain name
      app-service => "foo-bar", # azure app service name ( a.k web application )
      resource-group => "rg0102" , # azure resource group
    );

    $ sparrowdo --local_mode --no_sudo

# Agent capabilities

This is the list of required tool should be installed on VSTS agent:

* Perl
* Az cli

# Author

Alexey Melezhik

