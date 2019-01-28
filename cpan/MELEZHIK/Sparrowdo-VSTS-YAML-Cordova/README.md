# Sparrowdo::VSTS::YAML::Cordova

Sparrowdo module to generate VSTS yaml build definition steps for Cordova build.

# Platform supported

* Windows

For building Cordova for iOS/OSx see [Sparrowdo::Cordova::OSx::Build](https://github.com/melezhik/sparrowdo-cordova-osx-build) module.

# Prerequisites

* Perl5

# Usage

    $ cat sparrowfile

    module_run "VSTS::YAML::Cordova", %( 
      build-dir => "vsts/build",
      build-configuration => "debug", # build configuration, default value  
      build-arch => "x86" # build architecture, default value  
    );

    $ sparrowdo --no_sudo --local_mode


# Visual studio project creation

If only need to create VS source code, use `prepare-only` flag:


    prepare-only => True


# MSBuild/VS configuration

Use following parameter to adjust MSBuild and Visual Studio settings:

    Parameter               | Meaning                            | Default value
    ===============================================================================================================================================
    vs-inst-dir             | Visual  Studio install directory   | C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional
    ms-build-dir            | MS Build exe install directory     | C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin
    make-pri-exe-full-path  | Path to MakePri.exe tool           | C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x86\MakePri.exe
    ===============================================================================================================================================

# Per branche/env configurations

Modules supports source branches configuration int two flavors:

## Data configuration

The method copies "branch specific" files to `src/assets/jsons/` directory.

The data files should be located at `src/env/$target/$source_code_branch/.*json` where:

- `$source_code_branch` is SCM branch name
- `$target` is `uwp` or `ios`

Example:

    # target = uwp
    # $source_code_branch = production
    
    cp -r src/env/uwp/production/*.json src/assets/jsons/

## Command configuration

The method executed "branch specific" windows commands.

Command files should be located at `src/env/$target/$source_code_branch/` where:

- `$source_code_branch` is SCM branch name
- `$target` is `uwp` or `ios`

The commands are executed in order defined by their files names ( alphabetic order )

Example:

    # $source_code_branch = production
    
    ls -1 src/env/uwp/production/

    00-command.cmd # executed  first
    01-command.cmd # executed  second
    02-command.cmd # excecuted third, so on

You can use Powershell or Perl scripts as well:

    00-command.cmd # windows batch script 
    01-command.pl  # Perl script
    02-command.ps1 # Powershell script 

You may define `default` branch to execute command for any branch not matching listed branches:

    src/env/$target/default/

# VSTS Build configurations

These variables adjust build logic:

- Build.$source_code_branch.Configuration 

Set configuration for `cordova build` command.

For example:

    Build.Production.Configuration = "release" # Set release configuration for production branch 

    Build.Default.Configuration = "debug" # Set debug configuration by default

- Build.NoPatchRevision

Disable revision version patching. Helpful when you create build for windows store.


# Author

Alexey Melezhik
