use v6;

unit module Sparrowdo::VSTS::YAML::Nuget::Build:ver<0.0.3>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {

  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      project_file => %args<project-file>,
      project_folder => %args<project-folder>,
      configuration => %args<configuration> || "Release",
      output_directory => %args<output-directory> || "packages",
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml"

}


