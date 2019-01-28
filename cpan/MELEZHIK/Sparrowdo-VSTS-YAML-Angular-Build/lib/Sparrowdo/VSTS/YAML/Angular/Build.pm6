use v6;

unit module Sparrowdo::VSTS::YAML::Angular::Build:ver<0.0.6>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;
use Sparrowdo::Core::DSL::File;

our sub tasks (%args) {

  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory "$build-dir/.cache";
  directory "$build-dir/files";

  file "$build-dir/files/set-version.pl", %( content => slurp %?RESOURCES<set-version.pl>.Str );
  file "$build-dir/files/build.pl", %( content => slurp %?RESOURCES<build.pl>.Str );

  template-create "$build-dir/.cache/build.yaml.sample", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      base_dir => "$build-dir/files" 
    )
  );

  bash "cat $build-dir/.cache/build.yaml.sample >> $build-dir/build.yaml"

}


