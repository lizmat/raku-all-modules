# SYNOPSIS

Sparrowdo module to install CPAN modules using App::cpm - a fast CPAN module installer.

# Install

    $ panda install Sparrowdo::Cpm


# Usage

    $ cat sparrowfile

    module_run 'Cpm', %( list => 'Moose DBI CGI', verbose => 1 );

# Parameters

## list 

Should be space separated list of CPAN modules to install.

## user

Sets user to runs a cpm client. By default user is not set.

## install-base 

Sets install base. By default install-base is not set.


This is how user/install-base result in cpm install run:

    +-----------+--------------+---------------------------------------------+
    | user      | install-base | cpm run                                     |
    +-----------+--------------+---------------------------------------------+
    | not set   | not set      | cpm install -g   # global %INC install      |
    | set       | not set      | cpm install      # install into ./local     |
    | not set   | set          | cpm install -L /install/base # into base    |
    +-----------+--------------+---------------------------------------------+

## verbose

Sets cpm client verbose mode on.

# Author

[Alexey Melezhik](mailto:melezhik@gmail.com)

# See also

* [SparrowDo](https://github.com/melezhik/sparrowdo)

* [App::cpm](https://metacpan.org/pod/App::cpm)
