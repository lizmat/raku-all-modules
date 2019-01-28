# Azure Update Cert

Create SSL certificate  and bind domain for Azure web application:

1. Create web SSL certificate for certificate taken from key vault SSL certificate ( `kv-id`, `kv-secret-name` )

2. Create domain (`domain`) for app service (`app-service-name`) and certificate ( `thumbprint` ). Thumbprint should be the thumbprint 
of the certificate created by first step.

# Prerequisites

* Az cli

# Usage

    $ nano sparrowfile
    
    module_run "Azure::Web::Cert", %(
        domain => "app.domain.foo",
        thumbprint => "ABC010101H0A....",
        az-res-group => "my-az-grp",
        kv-id => "my-kv-storage",
        kv-secret-name => "production-cert",
        app-service => "app"
    )
    
    $ sparrowdo --no_sudo --local_mode

# Parameters

## az-res-group

Azure resource group

## thumbprint

SSL certificate thumbprint

## domain

Domain name

## kv-id

Key vault identification

## kv-secret-name

Key vault secret name

## app-service

Azure application service name


# Modes

##  Default

This mode is applied by default. ARM templates are generated, validated and executed.

You can choose options, read next two sections.

## Dry run mode

In this mode ARM templates are generated, but not executed.

Set config<mode> to `dry-run`:

    %(

      mode => 'dry-run',
      # Other params
    )

## Validate mode

In this mode ARM templates are generated, validated but not executed.

Set config<mode> to `validate`:

    %(

      mode => 'validate',
      # Other params
    )

# Skip certificate creation stage


    $ cat config.pl  

    %(

      skip-cert-crt => True
      # Other params
    )

# Check ssl cert

    (

      check-ssl => True
      # Other params
    )

# Author

Alexey Melezhik
