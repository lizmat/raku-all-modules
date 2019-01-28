use v6;

unit module Sparrowdo::VSTS::YAML::Build:ver<0.0.7>;

use Sparrowdo;
use Sparrowdo::Core::DSL::Template;
use Sparrowdo::Core::DSL::File;
use Sparrowdo::Core::DSL::Directory;

our sub tasks (%args) {

  my $queue = %args<queue> || 'default';
  my $agent-name = %args<agent-name>;
  my $timeout = %args<timeout> || 20; # 20 minutes

  my $build-dir = %args<build-dir> || die "usage module_run '{ ::?MODULE.^name }' ,%(build-dir => dir)";

  directory-delete "$build-dir/files";
  directory-delete "$build-dir/.cache";

  directory "$build-dir/.cache";
  directory "$build-dir/files";

  my @demands = %args<demands> || [];

  @demands.push: "Agent.name -equals {%args<agent-name>}" if %args<agent-name>;

  template-create "$build-dir/build.yaml", %(
    source => ( slurp %?RESOURCES<build.yaml> ),
    variables => %( 
      queue => $queue,
      demands => @demands,
      timeout => $timeout
    )
  );

}


