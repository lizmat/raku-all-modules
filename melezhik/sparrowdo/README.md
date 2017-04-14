# Sparrowdo

Configuration management tool based on [sparrow](https://sparrowhub.org) plugins system.

# Build status

[![Build Status](https://travis-ci.org/melezhik/sparrowdo.svg)](https://travis-ci.org/melezhik/sparrowdo)

# Usage


There are 3 essential things in Sparrowdo:

* [Core DSL](#core-dsl)

* [Plugins DSL](#plugins-dsl)

* [Modules](#sparrowdo-modules)


## Core DSL

Core DSL is probably easiest way to start using Sparrowdo right away. It offers some
high level functions to accomplish most common configuration tasks, like
create directories or users, populate files from templates or start services.

    $ cat sparrowfile

    user 'zookeeper';

    group 'birds';

    directory '/var/data/avifauna/greetings/', %( owner => 'zookeeper' );

    file-create '/var/data/avifauna/greetings/sparrow.txt', %( 
        owner => 'zookeeper',
        group => 'birds', 
        mode  => '0644', 
        content => 'I am little but I am smart'
    );

    service-start 'nginx';

    package-install ('nano', 'ncdu', 'mc' );

Read [core-dsl](/core-dsl.md) doc to get acquainted with core-dsl functions available at the current sparrowdo version.

# Plugins DSL

Under the hood core dsl ends up in "calling"(*) a [sparrow plugins](https://github.com/melezhik/sparrow#sparrow-plugins) with parameters.

(\*) Not that accurate. Technically speaking core-dsl functions just *generate* a JSONs to **serialize** a sparrow plugins with
binded parameters ( so called [sparrow tasks](https://github.com/melezhik/sparrow#tasks) ) and then generated JSON gets copied (with the help of scp command ) to the target host, where it is finally executed by sparrow client.

Thus, if you want a direct access to sparrow plugins API you may use a plugin DSL.
  
Examples above could be rewritten with low level API: 

    $ cat sparrowfile

    task-run  %(
      task        => 'create zookeeper user',
      plugin      => 'user',
      parameters  => %( 
        action => 'create' , 
        name => 'zookeeper'
      )
    );

    task-run  %(
      task        => 'create birds group',
      plugin      => 'group',
      parameters  => %( 
        action => 'create' , 
        name => 'birds'
      )
    );

    # a following code will use a short form of task-run $task_desc, $plugin_name, %parameters

    task-run 'create greetings directory', 'directory', %( 
      action  => 'create' , 
      path    => '/var/data/avifauna/greetings',
      owner   => 'zookeeper'
    );


    task-run 'create sparrow greeting file', 'file', %(
      action      => 'create',
      target      => '/var/data/avifauna/greetings/sparrow.txt',
      owner       => 'zookeeper',
      group       => 'birds' 
      mode        => '0644',
      content     => 'I am little but I am smart'
    );

    task-run 'start nginx web server', 'service',  %(
      action      => 'start',
      service     => 'nginx'
    );

    task-run 'install some handy packages', 'package-generic', %( list  => 'nano ncdu mc' );

Reasons you may prefer a plugins DSL:

* not every sparrow plugin has a *related* core-dsl function ( see below )
* a core-dsl methods are just a wrappers to generated a proper JSON data to "represent" sparrow plugin with parameters,
however such a mapping could be limited in comparison with *original* plugin API, for example you might not have access to some plugin input parameters and so on. Thus, if you want to hack into plugin details, you'd probably want
a low level plugins API.
* anyway in most cases a core-dsl API should be enough for most common configuration management tasks.

# Core DSL vs Plugins DSL
    
Core DSL is kinda high level adapter bringing some "syntax sugar" to make your code terse.
As well as adding Perl6 type/function checking as core-dsl functions are plain Perl6 functions.

From other hand core-dsl is limited. **Not every sparrow plugin** has a related core-dsl method.

So it's up to you use core dsl or low level sparrow plugin API. Once I found some sparrow plugin
very common and highly useful I add a proper core-dsl method for it. In case you need 
core-dsl wrappers for new plugins - let me know!

[Here](/core-dsl.md) is the list of core-dsl function available at the current Sparrowdo version.

# Running sparrowdo scenario

Now having ready sparrowfile you can run your scenario against some remote hosts:

    $ sparrowdo --host=192.168.0.1

# Schema

Here is visual presentation of sparrowdo system design

![sparrowdo system design](https://sparrowdo.files.wordpress.com/2017/01/sparrowdo-system.png)

## Master host

Master host is the dedicated server where you push sparrow tasks execution on remote hosts.

Sparrowdo client should be installed at master host:

    $ panda install Sparrowdo

Sparrowdo acts over ssh installing sparrow [plugins](https://metacpan.org/pod/Sparrow#Plugins-API), applying configurations and running them as sparrow [tasks](https://metacpan.org/pod/Sparrow#Tasks-API).

A list of available sparrow plugins could be found here - [https://sparrowhub.org/search](https://sparrowhub.org/search).
Only [public](https://metacpan.org/pod/Sparrow#Public-plugins) sparrow plugins are supported for the current version of sparrowdo.


## Remote hosts

Remote hosts are configured by running sparrow client on them and executing sparrow tasks.

A Sparrow CPAN module, version >= 0.2.33 should be installed on remote hosts:

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

## Running private plugins

You should use `set_spl(%hash)` function to set up private plugin index file:


    $ cat sparrowfile

    set_spl %(
        package-generic-dev => 'https://github.com/melezhik/package-generic.git',
        df-check-dev => 'https://github.com/melezhik/df-check.git'
    );
    
    task-run 'install my packages', 'package-generic-dev', %( list => 'cpanminus git-core' );

    task-run 'check my disk', 'df-check-dev';
    
# Sparrowdo client command line parameters

## --help

Prints brief usage info.

## --sparrowfile

Alternative location of sparrowfile. If `--sparrowfile` is not set a file named `sparrowfile` at CWD is looked.

    $ sparrowdo --sparrowfile=~/sparrowfiles/sparrowfile.pl6

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

## --sparrow\_root

Sets alternative location for sparrow root directory. Default value is `/opt/sparrow`;

Optional parameter.

## --no\_sudo

If set to true - do not initiate ssh command under `sudo`, just as is. Default value is false - use `sudo`.
Optional parameter.

## --check_syntax

If set to true - only compile scenarios and don't run anything on target host. Optional parameter.

## --no\_index\_update

If set to true - do not run `sparrow index update` command at the beginning`. This could be useful if you
are not going to update sparrow index to save time.

Optional parameter.

## --no\_color

If set to true - disable color output when executing in sparrowdo scenarios. 

Optional parameter.

## --module\_run

Runs a sparrowdo module instead of executing tasks from sparrowfile. For example:

    $ sparrowdo --host=127.0.0.1 --module_run=Nginx

You can use task_run notation to pass parameter to modules:

    --module_run=module-name@p1=v1,p2=v2\;plg@p1=v1,p2=v2 ...

Where `module-name` - module name. `p1, p2 ...` - module parameters (separated by `,`) 

For example:

    $ sparrowdo --host=127.0.0.1 --module_run=Cpanm::GitHub@user=leejo,project=CGI.pm,branch=master

## --task\_run

Runs a sparrow plugin instead of executing tasks from sparrowfile. 

For example:

    $ sparrowdo --host=127.0.0.1 --task_run=df-check

You can run multiple tasks (plugins) with parameters as well:

    --task_run=plg-name@p1=v1,p2=v2,... --task-run=plg-name@p1=v1,p2=v2,...

Where `plg-name` - plugin name. `p1, p2 ...` - plugins parameters (separated by `,`) 

For example:

    $ sparrowdo --host=127.0.0.1 \
    --task_run=user@name=foo \
    --task_run=bash@command='id &&  pwd && uptime && ls -l && ps uax|grep nginx|grep -v grep',user=foo \
    --task_run=df-check@threshold=54

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

* They implemented in terms of sparrowdo tasks ( relying on sparrowdo API ) rather then with sparrow tasks. 

An example of sparrowdo module:

    use v6;
    
    unit module Sparrowdo::Nginx;
    
    use Sparrowdo;

    our sub tasks (%args) {

      task-run 'install nginx', 'package-generic', %( list => 'nginx' );

      task-run 'enable nginx', 'service', %(
        service => 'nginx', 
        action => 'enable'
      );

      task-run task => 'start nginx', 'service', %( 
        service => 'nginx', 
        action => 'start' 
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

`module_run($module_name)` function loads  module Sparrowdo::$module_name at runtime and calls 
function `tasks` defined at module global context.


## Helper functions

Module developers could rely on some helper function, when creating their modules.

* `target_os()`

This function returns OS name for the target server.

For example:

    if target_os() ~~ m/centos/ {
      task-run 'install epel-release', 'package-generic', %( list => 'epel-release' );
    }
    

A list of OS names provided by `target_os()` function:

    centos5
    centos6
    centos7
    ubuntu
    debian
    minoca
    archlinux
    fedora

* `input_params($param)`

Input\_params function returns command line parameter one provides running sparrowdo client. 

For example:


    task-run  %('install Moose', 'cpan-package', %( 
      list => 'Moose',
      http_proxy => input_params('HttpProxy'), 
      https_proxy => input_params('HttpsProxy'), 
    );

This is the list of arguments valid for input\_params function:

    Host 
    HttpProxy 
    HttpsProxy
    SparrowRoot 
    SshPort 
    SshUser 
    SshPrivateKey 
    Verbose
    NoSudo
    NoColor
    NoIndexUpdate

See also [sparrowdo client command line parameters](#sparrowdo-client-command-line-parameters) section.

# Scenarios configuration

There is no "magic" way to load configuration into sparrowdo scenarios. You are free to
choose any Perl6 modules to deal with configuration data. But if `config.pl6` file exists
at the current working directory it will be loaded via `EVALFILE` at the _beginning_ of
scenario. For example:


    $ cat config.pl6

    {
      user         => 'foo',
      install-base => '/opt/foo/bar'
    };

Later on in scenario you may access config data via `config` function:

    $ cat sparrowfile

    my $user         = config<user>;
    my $install-base = config<install-base>;
    
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

