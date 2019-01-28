# Sparrowdo::VSTS::YAML::Build::Assembly::Patch

Sparrowdo module to generate VSTS yaml build definition steps to patch revision part of AssemblyFileVersion.

    $ cat sparrowfile

    module_run "VSTS::YAML::Build::Assembly::Patch", %(
      build-dir => "vsts/",
    );

    $ sparrowdo --local_mode --no_sudo


# Author

Alexey Melezhik

