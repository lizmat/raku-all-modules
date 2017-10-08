# Sparrowdo::Rvm

[![Build Status](https://travis-ci.org/melezhik/perl6-sparrowdo-rvm.svg?branch=master)](https://travis-ci.org/melezhik/perl6-sparrowdo-rvm)

## SYNOPSIS

[Sparrowdo](https://github.com/melezhik/sparrowdo) module to install RVM and Ruby.

    # install default RVM and default Ruby version
    $ cat sparrowfile
    module_run 'Rvm';
    
    # install specific Ruby version
    $ cat sparrowfile
    module_run 'Rvm', %( version => '2.2.0' );

## Tested on

* CentOS
* Ubuntu
    
## LICENSE

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

ⓒ2017 'Alexey Melezhik'
