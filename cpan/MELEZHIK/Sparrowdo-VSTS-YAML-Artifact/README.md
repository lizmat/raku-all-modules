# Sparrowdo::VSTS::YAML:Artifact

Sparrowdo module to generate VSTS yaml steps to publish artifacts.

    $ cat sparrowfile

    module_run "VSTS::YAML::Artifact", %(
      build-dir => ".build",
      artifact-name => "drop",
      path => "foo/bar",
      publish-location => "Container" # default value
    );

    $ sparrowdo --local_mode --no_sudo

# Author

Alexey Melezhik

