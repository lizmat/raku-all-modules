use v6;

unit module Sparrowdo::Core::DSL::Git;

use Sparrowdo;

use Sparrowdo::Core::DSL::Bash;


multi sub git-scm ( $source, %args? ) is export {

  my $cd-cmd = %args<to> ?? "cd " ~ %args<to> ~ ' && pwd ' !! 'pwd';

  bash qq:to/HERE/, %( description => "fetch from git source: $source" );
    set -e;
    $cd-cmd
    if test -d .git; then
      git pull
    else
      git clone $source . 
    fi
  HERE

}


