# Sparrowdo

Simple configuration engine based on [sparrow](https://sparrowhub.org) plugin system.

# Build status

[![Build Status](https://travis-ci.org/melezhik/sparrowdo.svg)](https://travis-ci.org/melezhik/sparrowdo)

# Usage


    $ cat sparrowfile

    task_run  %(
      task => 'check disk available space',
      plugin => 'df-check',
      parameters => %( threshold => 80 )
    );
    
    task_run  %(
      task => 'install app',
      plugin => 'perl-app',
      parameters => %( 
        'app_source_url' => 'https://github.com/melezhik/web-app.git',
        'git_branch' => 'dev',
        'http_port' => 3030
      )
    );
    
    $ sparrowdo --host=192.168.0.1

# Schema

      +-----------------+
      |                 |    ssh
      |                 |------------> < host-1 > 192.168.0.1
      | <master host>   |    ssh
      | {sparrowdo}     |------------------> < host-2 > 192.168.0.2
      |                 |    ssh 
      |                 |-----------------------> < host-N > 127.0.0.1
      |                 |
      +-----------------+


      +-------------+
      |             |
      | <host>      |
      |             |
      | {sparrow}   | 
      | {curl}      |
      |             |
      +-------------+

## Master host

Master host is the dedicated server where you push sparrow tasks execution on remote hosts.

Sparrowdo client should be installed at master host:

    $ panda install Sparrowdo

Sparrowdo acts over ssh installing sparrow [plugins](https://metacpan.org/pod/Sparrow#Plugins-API), applying configurations and running them as sparrow [tasks](https://metacpan.org/pod/Sparrow#Tasks-API).

A list of available sparrow plugins could be found here - [https://sparrowhub.org/search](https://sparrowhub.org/search).
Only [public](https://metacpan.org/pod/Sparrow#Public-plugins) sparrow plugins are supported for the current version of sparrowdo.


## Remote hosts

Remote hosts are configured by running sparrow client on them and executing sparrow tasks.

A Sparrow CPAN module, version >= 0.1.22 should be installed on remote hosts:

    $ cpanm Sparrow

A minimal none Perl dependencies also should be satisfied - `curl`, so sparrow could manage it's index files and
upload plugins. Eventually I will replace it by proper Perl module to reduce none Perl dependencies, but for now
it's not a big deal:

    $ yum install curl

# SSH/User setup

An assumption made that ssh user you run `sparrowdo` with ( see --ssh_user command line parameter also ):

* ssh passwordless access to remote hosts
* sudo (passwordless?) rights on remote host

Eventually I will make user/ssh related stuff configurable so one could run sparrowdo with various ssh configurations and
users.

# Advanced usage

## Running tasks with private plugins

You should use `set_spl(%hash)` function to set up priviate plugin index file:


    $ cat sparrowfile

    set_spl %(
        package-generic-dev => 'https://github.com/melezhik/package-generic.git',
        df-check-dev => 'https://github.com/melezhik/df-check.git'
    );
    
    task_run  %(
      task => 'install my packages',
      plugin => 'package-generic-dev',
      parameters => %( list => 'cpanminus git-core' )
    );

    task_run  %(
      task => 'check my disk',
      plugin => 'df-check-dev'
    );
    

# Sparrowdo client command line parameters

## --help

Prints brief usage info.

## --http\_proxy

Sets http\_proxy environment variable on remote host.

## --https\_proxy

Sets https\_proxy environment variable on remote host.

## --ssh\_user

Sets user for ssh connection to remote host.

## --ssh\_private\_key

Selects a file from which the identity (private key) for public key authentication is read. 

Is equal to `ssh -i` parameter.

## --ssh\_port

Sets shh port for ssh connection to remote host. Default value is `22`.

## --module\_run

Runs a sparrowdo module instead of executing tasks from sparrowfile. For example:


    $ sparrowdo --host=127.0.0.1 --module_run=Nginx


## --verbose

Sets verbose mode ( low level information will be printed at console ).


# Bootstrapping 

One may use `bootstrap` mode to install Sparrow on target host first:

    $ sparrowdo --host=192.168.0.0.1 --bootstrap

Currently only CentOS platform is supported for bootstrap operation. 

# Sparrowdo modules

Sparrowdo modules are collection of sparrow tasks. They are very similar to sparrow task boxes,
with some differences though:

* They are Perl6 modules.

* They deal with sparrowdo tasks ( relying on sparrowdo API ) rather then with sparrow tasks. 

An example of sparrowdo module:

    use v6;
    
    unit module Sparrowdo::Nginx;
    
    use Sparrowdo;

    our sub tasks (%args) {

      task_run  %(
        task => 'install nginx',
        plugin => 'package-generic',
        parameters => %( list => 'nginx' )
      );

      task_run  %(
        task => 'enable nginx',
        plugin => 'service',
        parameters => %( service => 'nginx', action => 'enable' )
      );

      task_run  %(
        task => 'start nginx',
        plugin => 'service',
        parameters => %( service => 'nginx', action => 'start' )
      );
  

    }
        

Later on, in your sparrowfile you may have this:


    $ cat sparrowfile

    module_run 'Nginx';

You may pass parameters to sparrowdo module:

    module_run 'Nginx', port => 80;

In module definition one access parameters as:

    our sub tasks (%args) {

        say %args<port>;

    }


A module naming convention is:

    Sparrowdo::Foo::Bar ---> module_run Foo::Bar

`module\_run($module_name)` function loads  module Sparrowdo::$module_name at runtime and calls 
function `tasks` defined at module global context.


## Helper functions

Module developers could rely on some helper function, when creating their modules.

* `target_os()`

This function returns OS name for the target server.

For example:

    if target_os() ~~ m/centos/ {
    
      task_run  %(
        task => 'install epel-release',
        plugin => 'package-generic',
        parameters => %( list => 'epel-release' )
      );
    
    }
    

A list of OS names provided by `target_os()` function:

    centos5
    centos6
    centos7
    ubuntu
    debian

* `input_params($param)`

Input\_params function returns command line parameter one provides running sparrowdo client. 

For example:


    task_run  %(
      task => 'install great CPAN module',
      plugin => 'cpan-package',
      parameters => %( 
        list => 'Moose',
        http_proxy => input_params('HttpProxy'), 
        https_proxy => input_params('HttpsProxy'), 
      )
    );

This is the list of arguments valid for input\_params function:

    Host 
    HttpProxy 
    HttpsProxy 
    SshPort 
    SshUser 
    SshPrivateKey 
    Verbose

See also [sparrowdo client command line parameters](#sparrowdo-client-command-line-parameters) section.
    
# AUTHOR

[Aleksei Melezhik](mailto:melezhik@gmail.com)

# Home page

[https://github.com/melezhik/sparrowdo](https://github.com/melezhik/sparrowdo)

# Copyright

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

# See also

* [Sparrow](https://metacpan.org/pod/Sparrow) - Multipurpose scenarios manager.

* [SparrowHub](https://sparrowhub.org) - Central repository of sparrow plugins.

* [Outthentic](https://metacpan.org/pod/Outthentic) - Multipurpose scenarios devkit.

# Thanks

To God as the One Who inspires me to do my job!

