# Sparrowdo::VSTS::YAML:Solution

Sparrowdo module to generate VSTS yaml steps to build solution files.

    $ cat sparrowfile

    module_run "VSTS::YAML::Solution", %(
      build-dir => "cicd/build",
      vs-version  => '15.0', # visual  studio version, default value
      display-name => "Build app.sln", # optional
      solution => "app.sln", # path to solution file, default is "**\*.sln"
      platform => "x86",
      configuration => "debug",
      restore-solution => "app.sln", # path to NugetRestore solution file
      skip-nuget-install => True, # don't install nuget cli
      test-assemblies => True, # run tests, default value is False
      publish-symbols => False, # publish symbols, this is default value
    );

    $ sparrowdo --local_mode --no_sudo

# Parameters

## vs-version

Visual studio version

## solution

Path to solution file

## platform
  
Build platform

## configuration

Build configuration

## restore-solution

Path to solution file for `nuget restore` command

## skip-nuget-restore

Don't run `nuget restore` command

## skip-nuget-install

Don't install nuget

## test-assemblies

Run tests

## publish-symbols


Publish symbols


# Author

Alexey Melezhik

