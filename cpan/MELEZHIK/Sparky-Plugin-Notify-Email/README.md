# SYNOPSIS

Sparky plugin to send email notifications upon completed builds.

# INSTALL

    $ zef install Sparky::Plugin::Notify::Email


# USAGE

    $ cat sparky.yaml
    # send me a notifications on failed builds
    plugins:
     - Sparky::Plugin::Notify::Email:
        run_skope: fail
        parameters:
          to: melezhik@mail.me
          
# Author

Alexey Melezhik

    
