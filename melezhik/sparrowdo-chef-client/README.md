# SYNOPSIS

Run chef client on remote host using Sparrowdo.

# Travis build status

[![Build Status](https://travis-ci.org/melezhik/sparrowdo-chef-client.svg)](https://travis-ci.org/melezhik/sparrowdo-chef-client)


# INSTALL

    $ panda install Sparrowdo::Chef::Client


# USAGE

    $ cat sparrowfile

    module_run 'Chef::Client', %(
      run-list => [
        "recipe[foo::bar]",
        "role[baz]"
      ],
      log-level => 'info'
    );
    

# Parameters

## run-list

Should be a chef run list. Default value is empty Array.

## log-level

Sets log level for chef client run. Default level is `info`. Optional.
  
## attributes

Sets chef node attributes. From the Perl6 point of view it's just a Hash of parameters. 

For example:

    attributes => {
      foo => 'bar',
      bar => {
        baz => [ 1, 2, 3 ]
      }
    }


Optional. Default value is empty Hash.

# Author

[Alexey Melezhik](melezhik@gmail.com)
