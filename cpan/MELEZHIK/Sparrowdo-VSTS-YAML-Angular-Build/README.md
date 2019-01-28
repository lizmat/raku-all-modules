# Sparrowdo::VSTS::YAML:Solution

Sparrowdo module to generate VSTS yaml steps to build angular project.

    $ cat sparrowfile

    module_run "VSTS::YAML::Angular::Build", %(
      build-dir => "cicd/build"
    );


    $ sparrowdo --local_mode --no_sudo


# Build configuration

The module uses "per branch" build configuration. User should `define commands` to `describe build logic`

The Command files should be located at `src/env/$source_code_branch/` where:

- `$source_code_branch` is SCM branch name

The commands are executed in order defined by their files names ( alphabetic order )

Example:

    # $source_code_branch = production

    ls -1 src/env/production/

    00-command.cmd # executed  first
    01-command.cmd # executed  second
    02-command.cmd # executed third, so on

You can use Powershell or Perl scripts as well:

    00-command.cmd # windows batch script
    01-command.pl  # Perl script
    02-command.ps1 # Powershell script

You may define `default` branch to execute command for any branch not matching listed branches:

    src/env/default/


The example of command:

    # cat src/env/dev/00-build.cmd

    npm run -- ng build --configuration=dev

# Dependencies 

Perl

# Author

Alexey Melezhik

