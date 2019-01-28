use v6;

unit module Sparrowdo::VSTS::YAML::Nuget:ver<0.0.2>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {

  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      skip_nuget_install => %args<skip-nuget-install>, 
      solution => %args<solution> || '"**\*.sln"',
      working_folder => %args<working-folder>,
      base_dir => "$build-dir/files"
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml"

}


