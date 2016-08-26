# SYNOPSIS

Extract various archives using tar/unzip programs.

Archive formats supported:

    +-----------+---------------------------+
    | extension | internal archive program  |
    +-----------+---------------------------+
    | *.zip     | unzip                     |
    | *.tar     | tar                       |
    | *.tar.gz  | tar                       |
    +-----------+---------------------------+

# INSTALL

    $ panda install Sparrowdo::Archive

# USAGE

    $ cat sparrow file

    module_run 'Archive', %(
      source  => '/tmp/nginx/nginx-1.11.3.tar.gz',
      target  => '/home/app-user/apps/nginx',
      user    => 'app-user',
      verbose => 1,
    );
    

# Parameters

## source

A local file path to archived file. Obligatory. No default.

## target

A local file path where to store extracted archive data. No default value. Obligatory.
  
## user

A user which run a archive program and thus to which user extracted files will belong to. 
Optional. No default value.

## verbose

Try to run archive extractor program in verbose mode. Default value is `0` ( no verbose ). Optional.

# Author

[Alexey Melezhik](melezhik@gmail.com)
