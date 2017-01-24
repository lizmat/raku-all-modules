# SYNOPSIS

Sparrowdo core-dsl functions spec.

* [User accounts](#user-accounts)
* [User groups](#user-groups)
* [Packages](#packages)
  * [System packages](#system-packages)
  * [CPAN packages](#cpan-packages)
* [Services](#services)
* [Directories](#directories)
* [Files](#files)
* [Templates](#templates)
* [Bash commands](#bash)

## User accounts

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| user-create | create user | `user-create($name)`| [user](https://sparrowhub.org/info/user) | 
| user-delete | delete user | `user-delete($name)`| [user](https://sparrowhub.org/info/user) |
| user        | create/delete user | `user($name,[%args])`| [user](https://sparrowhub.org/info/user) |

Examples:


    user-create 'alexey'; # create user `alexey'
    user-delete 'alexey'; # delete user `alexey'
    user 'alexey'; # short form of user create
    user 'alexey', %(action => 'create'); # hash parameters form of user create
    user 'alexey', %(action => 'delete'); # hash parameters form of user delete

## User groups

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| group-create | create group | `group-create($name)`| [group](https://sparrowhub.org/info/group) | 
| group-delete | delete group | `group-delete($name)`| [group](https://sparrowhub.org/info/group) |
| group        | create/delete group | `group($name,[%args])`| [group](https://sparrowhub.org/info/group) |

Examples:


    group-create 'sparrows'; # create group `sparrows'
    group-delete 'sparrows'; # delete group `sparrows'
    group 'sparrows'; # short form of group create
    group 'sparrows', %(action => 'create'); # hash parameters form of group create
    group 'sparrows', %(action => 'delete'); # hash parameters form of group delete

## Packages

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| package-install | install software package | `package-install(@list|$list)`| [package-generic](https://sparrowhub.org/info/package-generic) | 
| cpan-package-install | install CPAN package | `cpan-package-install(@list|$list,%opts)`| [cpan-package](https://sparrowhub.org/info/cpan-package) | 
| cpan-package         | alias for cpan-install function | * | *  |

Examples:

### System packages

    # pass list as Array
    package-install ('nano', 'tree', 'mc');

    # pass list as String, 
    # packages are space separated items 
    package-install 'nano tree mc';
    package-install 'nano';

### CPAN packages

    # install 3 cpan modules, system wide paths
    cpan-package-install ('CGI', 'Config::Tiny', 'HTTP::Tiny');
    
    # short form of above
    cpan-package ('CGI', 'Config::Tiny', 'HTTP::Tiny');
    
    # install 3 cpan modules, users install
    cpan-package-install 'CGI Config::Tiny HTTP::Tiny', %(
        user =>'foo',
        install-base => '/home/foo/',
    );
    
    # the same as above but passing cpan modules list as Array
    cpan-package-install ('CGI', 'Config::Tiny', 'HTTP::Path'), %(
        user =>'foo',
        install-base => '/home/foo/',
    );
      
## Services

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| service-start | start service | `service-start($name)`| [service](https://sparrowhub.org/info/service) | 
| service-restart | restart service | `service-restart($name)`| [service](https://sparrowhub.org/info/service) | 
| service-stop | stop service | `service-stop($name)`| [service](https://sparrowhub.org/info/service) | 
| service-enable | enable service | `service-enable($name)`| [service](https://sparrowhub.org/info/service) | 
| service-disable | disable service | `service-disable($name)`| [service](https://sparrowhub.org/info/service) | 
| service       | start/stop/restart/enable/disable service | `service($name, %args)`| [service](https://sparrowhub.org/info/service) |

Examples:

    service-enable 'nginx';
    
    service-start 'nginx';
    
    service-stop 'nginx';
    
    service-restart 'nginx';
    
    service 'nginx', %( action => 'stop' );
    
    service 'nginx', %( action => 'disable' );
    
    service-disable 'nginx';
    

## Directories

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| directory-create | create directory | `directory-create($path,%args)`| [directory](https://sparrowhub.org/info/directory) | 
| directory-delete | delete directory | `directory-delete($path)`| [directory](https://sparrowhub.org/info/directory) |
| directory        | create/delete directory | `directory($path,[%args])`| [directory](https://sparrowhub.org/info/directory) |

Examples:

    directory '/tmp/baz';

    directory-create '/tmp/baz';

    directory-create '/tmp/foo/bar', %(
      recursive => 1 ,
      owner => 'foo',
      mode => '755'
    );
    
    directory '/tmp/foo/bar/bar/123', %(
      action => 'create',
      recursive => 1 ,
      owner => 'foo',
      mode => '755'
    );
    
    
    directory-delete '/tmp/foo/bar';

## Files

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| file-create | create file | `file-create($path,%args)`| [file](https://sparrowhub.org/info/file) | 
| file-delete | delete file | `file-delete($path)`| [file](https://sparrowhub.org/info/file) |
| file        | create/delete file | `file($path,[%args])`| [file](https://sparrowhub.org/info/file) |

Examples:

    # just create (touch) an empty file
    file-create '/var/data/animals.txt';

    # shortcut for file-create
    file '/var/data/animals.txt';

    # copy file from source
    file '/var/data/animals.txt', %( source => '/var/data/backup/animals.txt' );

    # sets file attributes
    file '/var/data/animals.txt', %(
      owner => 'zookeeper',
      group => 'animals' ,
      mode => '644',
      content => 'I am read fox!'
    );

    # sets file content explicitly
    file '/var/data/animals.txt', %(
      action  => 'create',
      owner   => 'zookeeper',
      group   => 'animals' ,
      mode    => '644',
      content => 'I am read fox!'
    );
    
    file-delete '/var/data/animals.txt';

    # the same as above
    file '/var/data/animals.txt', %( action => 'delete' );

## Templates

Templates are files gets populated from templates sources in [Template-Toolkit](http://template-toolkit.org/) format.

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| template-create | create template | `template-create($path,%args)`| [templater](https://sparrowhub.org/info/templater) | 
| template        | alias for template-create | * | * |

Examples:

    $ cat examples/templates/animals.tmpl

    Hello, my name is [% name %]!
    I speak [% language %]

    template-create '/var/data/animals.txt', %(
      source => ( slurp 'examples/templates/animals.tmpl' ),
      owner => 'zookeeper',
      group => 'animals' ,
      mode => '644',
      variables => %(
        name => 'red fox',
        language => 'English'
      ),
    );
    
    
## Bash

This function executes bash code.

| function | description | usage | sparrow plugin |
| -------- | ----------- | ----- | -------------- |
| bash | execute bash, default user | `bash($command)`| [bash](https://sparrowhub.org/info/bash) | 
| bash | execute bash, for user | `bash($command,$user)`| [bash](https://sparrowhub.org/info/bash) |
| bash | execute bash, generic form | `bash($command,%args)`| [bash](https://sparrowhub.org/info/bash) |

Examples:

    # execute bash for default user 
    bash(q:to/HERE/);
      set -e;
      touch /tmp/sparrow123.txt
      echo one
      echo two
      echo three
    HERE
    
    # one-liner
    bash('echo hello world');
    

    # execute command for `foo' user    
    bash('pwd', 'foo');
    

    # pass parameters as Hash, many options here:

    # check STDOUT from executed command
    bash 'pwd', %(
      user => 'foo',
      expect_stdout => '/home/foo'
    );

    # enable debug mode ( set -x ):
    bash 'very-long-command', %( debug => 1 );
    
    # or passing environment variables:
    bash 'echo $FOO; echo $BAR', %(
      envvars => %(
        FOO => 'the-foo',
        BAR => 'the-bar',
      )
    )

    # sets description for bash command 
    # ( will be printed at sparrowdo report instead of dummy "execute bash command" )
    bash "ls -l", %( 
      description => "use this description for bash command" 
    );    
