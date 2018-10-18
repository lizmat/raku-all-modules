# SYNOPSIS

Sparrowdo module to install Nginx web server.

# Description

This module Makes a simple Nginx install ( default virtual host binded to 80 port ).

# Install

    $ panda install Sparrowdo::Nginx


# Usage

    $ cat sparrowfile

    module_run 'Nginx';

# Parameters

## document_root

Nginx default virtual host document root. Optional. Default value is `/usr/share/nginx/html`

For example:

    module_run 'Nginx', %(
      document_root => '/var/www/data'
    );

# Platforms supported

This is where I tested this module.

* CentOS
* Ubuntu
* Debian

# Author

[Alexey Melezhik](mailto:melezhik@gmail.com)

# See also

[SparrowDo](https://github.com/melezhik/sparrowdo)

