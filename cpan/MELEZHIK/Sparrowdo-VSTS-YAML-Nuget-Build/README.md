# Sparrowdo::VSTS::YAML:Nuget

Sparrowdo module to generate VSTS yaml steps to build nuget packages.

    $ cat sparrowfile

    # Build nuget package for project "CoollLib" located in $working-folder
    module_run "VSTS::YAML::Nuget::Build", %(
      build-dir => "build",
      project-folder => "app/foo", # path to project directory
      project-file => "CoolLib.csproj", # path to project file
      configuration => "Release", # msbuild configuration, default value
      output_directory => "packages", # directory to write nuget packages, this is default value
    );

    $ sparrowdo --local_mode --no_sudo

# Author

Alexey Melezhik

