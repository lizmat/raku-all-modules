use v6;

unit module Sparrowdo::VSTS::YAML::Build::Assembly::Patch:ver<1.0.0>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::File;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;

our sub tasks (%args) {


  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";
  directory "$build-dir/files";

  file "$build-dir/files/AssemblyInfoPatchVersion.pl", %( content => slurp %?RESOURCES<AssemblyInfoPatchVersion.pl>.Str );

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      base_dir => "$build-dir/files"
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml";

}


