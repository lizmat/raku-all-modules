# SYNOPSIS

Sparrowdo module to run goss scenarios.

# Travis build status

[![Build Status](https://travis-ci.org/melezhik/sparrowdo-goss.svg)](https://travis-ci.org/melezhik/sparrowdo-goss)


# INSTALL

    $ panda install Sparrowdo::Goss

# USAGE

Here are few examples.

## Install goss binary

    $ cat sparrowfile

    module_run 'Goss', %( action => 'install' ); # will install into default location - /usr/bin/goss

    module_run 'Goss', %( action => 'install', install_path => '/home/user' ); # will install into users location - /home/user/bin

## Runs goss scenarios

Pass goss ymal as is:

    $ cat sparrowfile

    module_run 'Goss', %( title => 'mysql checks',  yaml => << q:to/HERE/);
      port:
        tcp:3306:
          listening: true
          ip:
          - 127.0.0.1
      service:
        mysql:
          enabled: true
          running: true
      process:
        mysqld:
          running: true
    HERE


Use your favorite templater to populate goss yamls:

    $ cat mysql.goss.yaml

      port:
        tcp:{{port}}:
          listening: true

    $ cat sparrowfile

    use Template::Mustache;

    module_run 'Goss', %( 
      title => 'mysql tcp port check',  
      yaml => Template::Mustache.render('mysql.goss.yaml'.IO.slurp, {  port => '3306' })
    );


Sets path to goss binary:

    module_run 'Goss', %( install_path => '/home/user', yaml => '...', title => '...'  );

# Author

Alexey Melezhik

# See also

[goss](https://github.com/aelsabbahy/goss)

