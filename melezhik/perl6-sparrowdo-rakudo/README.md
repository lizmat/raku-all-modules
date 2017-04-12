# Sparrowdo::Rakudo

[![Build Status](https://travis-ci.org/melezhik/perl6-sparrowdo-rakudo.svg?branch=master)](https://travis-ci.org/melezhik/perl6-sparrowdo-rakudo)

## SYNOPSIS

## Via sparrowfile

```
$ cat sparrowfile

# install default version
module_run 'Rakudo'; 

# install specific version
module_run 'Rakudo', %(
  version => 'https://github.com/nxadm/rakudo-pkg/releases/download/2017.02/perl6-rakudo-moarvm-ubuntu16.04_20170200-01_i386.deb'
)
```

## Via sparrowdo command line:

```
# install default version  
$ sparrowdo --host=192.168.0.1 --module_run=Rakudo 
# install specific version
$ sparrowdo --host=192.168.0.1 --module_run=Rakudo@version=https://github.com/nxadm/rakudo-pkg/releases/download/2017.02/perl6-rakudo-moarvm-ubuntu16.04_20170200-01_i386.deb

```

# Description

This is simple installer of Rakudo Perl6.

# Platforms supported:

    CentOS
    Ubuntu


## LICENSE

All files (unless noted otherwise) can be used, modified and redistributed
under the terms of the Artistic License Version 2. Examples (in the
documentation, in tests or distributed as separate files) can be considered
public domain.

ⓒ2017 'Alexey Melezhik'
