use v6;

unit module Sparrowdo::VSTS::YAML::MsBuild:ver<0.0.2>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {

  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";
  directory "$build-dir/files";

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      project => %args<project>,
      platform => %args<platform>,
      configuration => %args<configuration>,
      display_name => %args<display-name> || "MsBuild %args<project>"
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml"

}


