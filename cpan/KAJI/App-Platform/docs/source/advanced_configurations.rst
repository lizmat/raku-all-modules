Advanced Configurations
=======================

Feature Set
-----------

* Auto configuring DNS server
* Auto configuring HTTP proxy server
* Generation and usage of SSL RSA keys
* Generation and usage of SSH authentication keys
* Start/stop projects with project specific configuration
* Support for basic containers and more cumbersome systemd containers
* Creating/mounting/overriding files inside project container

Example Environment Setup
-------------------------

When you have tightly coupled projects you may want configure those "single" projects to somekind of shared environment, and then platform tool's environment support kicks in. Steps are:

1. You have already configured your projects with ```project.yml``` file

#. Create your environment file e.g ```my-environment.yml``` file::

    # First project. No changes to project configuration just start the project.
    project-butterfly: true

    # Second project. Make changes to project default configuration
    project-snail:
      files:
        /var/www/app/config:
          volume: true
          readonly: true
          content: |
          <?php
            $hello = "こんにちは!";

#. Start platform services if not yet started::

    $ platform create

#. Start your environment::

    $ platform run my-environment.yml 

#. Open projects in a browser:

   http://project-butterfly.local
   http://project-snail.local

Custom Domain Names
-------------------

By default platform creates domain (dns) name from folder name, but you can specify additional domain names with environment variables.

`<your-project>/project.yml`::

   environment:
      - VIRTUAL_HOST=*.foo.bar.localhost,foo.bar.localhost

Running Projects Under Own Domain Name
--------------------------------------

It's possible to run projects under given domain address. You have to configure domain names by your own to point your server so that its foundable from your network or internet. For example you can use AWS Lightsail instances for development.

1. Configure platform to use your domain name. Use text editor or just execute:

   $ echo 'domain: <yourdomainname>' >> ~/.platform/config.yml

You can also define domain from the command line per command basis:

   $ platform --domain=<yourdomainname> <command> ..

#. Launch platform services

   $ platform [--domain=<yourdomainname>] create

#. Launch environment

   $ platform [--domain=<yourdomainname] run your-environment.yml

#. Check your configuration with `platform info`. You should see something like this:

   Platform
    status:    running
    ssl-certs: available
    ssh-keys:  available
    domain:    <yourdomainname>
    network:   acme
    data-path: /home/user/.platform


