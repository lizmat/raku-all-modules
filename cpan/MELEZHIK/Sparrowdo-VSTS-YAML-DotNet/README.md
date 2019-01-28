# Sparrowdo::VSTS::YAML:DotNet

Sparrowdo module to generate VSTS yaml steps to build dotnet application.

    $ cat sparrowfile

    module_run "VSTS::YAML::DotNet", %(
      build-dir => "cicd/build",
      project   => "app.csproj", # The path to the csproj file(s) to use. You can use wildcards;
      configuration => "debug",  # Build configuration, default value
      display-name => "Build app.csproj", # optional  
    );

    $ sparrowdo --local_mode --no_sudo

# Parameters

## project

The path to the csproj file(s) to use. You can use wildcards

## configuration

Build configuration

# See also

- Sparrowdo::VSTS::YAML::Solution

- Sparrowdo::VSTS::YAML::MsBuild

# Author

Alexey Melezhik

