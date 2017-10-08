use v6;

unit module Sparrowdo::Cpanm::GitHub;

use Sparrowdo;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::Bash;
use Sparrowdo::Core::DSL::Ssh;

our sub tasks (%args) {

    use Sparrowdo;

    my $root-dir = "/tmp/sparrowdo-cpanm";

    directory-delete $root-dir;
    directory-create "$root-dir/distros";
    directory-create "$root-dir/source";
    
    my $url = 'https://github.com/' ~ %args<user> ~ '/' ~
    %args<project> ~ '/archive/' ~ %args<branch> ~ '.zip';

    module_run 'RemoteFile', %(
        url       => $url,
        location  => $root-dir ~ '/' ~ 'data.zip';
    );
    
    
    module_run 'Archive', %(
      source  => $root-dir ~ '/' ~ 'data.zip',
      target  => $root-dir ~ '/' ~ 'source',
      verbose => 0,
    );
    
    bash "cd $root-dir/source/" ~ %args<project> ~ '-' ~ %args<branch>  ~ " && cpanm .";
    
}

