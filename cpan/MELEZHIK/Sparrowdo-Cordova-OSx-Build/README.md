# Sparrowdo::Cordova::OSx::Build

Sparrowdo module to build cordova project for OSx.

# USAGE

    $ zef install Sparrowdo::Cordova::OSx::Build

    $ sparrowdo --local_mode --no_sudo --cwd=/path/to/cordova/project \
    --module_run=Cordova::OSx::Build@team-id=AABBCCDDEE,keychain-password=pAsSword

# Parameters

## team-id

Your apple team ID.

## keychain-password

Password to unlock keychain access. Optional.

## skip-pod-setup

Skip `pod setup` command:

    skip-pod-setup=1

## manual-signing

If set creates manual signed build with given provisioning profile:

    sparrowdo --local_mode --no_sudo --module_run=Cordova::OSx::Build@team-id=AABBCCDDEE,\
    profile=afdc3c04-ba2d-4817-1a97-62d810e4c5ac,\
    manual-signing=OK

## profile

Sets provisioning profile, see `manual-signing` parameter.

## platform-rm

Run `cordova platform rm ios` before every build, to ensure we run in 100% clean state. Be aware
that this increases build time. The options is desabled by default.


# Per branche/env configurations

Modules supports source branches configuration int two flavors:

## Data configuration

The method copies "branch specific" files to `src/assets/jsons/` directory.

The data files should be located at `src/env/$target/$source_code_branch/.*json` where:

- `$source_code_branch` is SCM branch name
- `$target` is `ios`

Example:

    # target = ios
    # $source_code_branch = production

    cp -r src/env/ios/production/*.json src/assets/jsons/

## Command configuration

The method executed "branch specific" windows commands.

Command files should be located at `src/env/$target/$source_code_branch/` where:

- `$source_code_branch` is SCM branch name
- `$target` is `ios`

The commands are executed in order defined by their files names ( alphabetic order )

Example:

    # $source_code_branch = production

    ls -1 src/env/ios/production/

    00-command.sh # executed  first
    01-command.sh # executed  second
    02-command.sh # excecuted third, so on

You can use Perl scripts as well:

    00-command.sh # windows batch script
    01-command.pl # Perl script
    02-command.pl # Perl script

You may define `default` branch to execute command for any branch not matching listed branches:

    src/env/$target/default/


# Author

Alexey Melezhik

