# SYNOPSIS

Fetch remote file using http.

# INSTALL

    $ panda install Sparrowdo::RemoteFile

# USAGE

    $ cat sparrowfile

    module_run 'RemoteFile', %(
        url       => 'https://github.com/melezhik/remote-file/archive/master.zip',
        location  => '/tmp/foo/bar/master.zip'
    );
    

# Parameters

## url

Remote file url. No default value. Obligatory.

## location

A local file path where to store a downloaded file. No default value. Obligatory.

## user

Sets user name for resources with access restricted by http basic authentication. Optional,
no default value.

## password

Sets password for resources with access restricted by http basic authentication. Optional,
no default value.

# Author

[Alexey Melezhik](melezhik@gmail.com)
