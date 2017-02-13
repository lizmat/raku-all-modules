use v6;

unit module Sparrowdo::Core::DSL::Ssh;

use Sparrowdo;
use Sparrowdo::Core::DSL::Bash;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::File;

multi sub ssh ( $command, %args? ) is export { 

  directory '/opt/sparrow/.cache/';

  if %args<ssh-key>:exists {
    file '/opt/sparrow/.cache/ssh-key', %( 
      content => ( slurp %args<ssh-key> ),
      mode => '0600'
    );
  }

  my $ssh-host-term = %args<user>:exists ?? %args<user> ~ '@' ~ %args<host> !! %args<host>;


  my $ssh-run-cmd  =  'ssh -o ConnectionAttempts=1  -o ConnectTimeout=10';

  $ssh-run-cmd ~= ' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -tt';

  $ssh-run-cmd ~= ' -q' ;

  $ssh-run-cmd ~= ' -i /opt/sparrow/.cache/ssh-key' if %args<ssh-key>:exists;

  $ssh-run-cmd ~= " $ssh-host-term '$command'";

  my $bash-cmd;

  if %args<create>:exists {
    $bash-cmd = "if ! test -f %args<create> ; then set -x; $ssh-run-cmd ; else echo skip due to %args<create> exists; fi"    
  } else {
    $bash-cmd = "set -x; $ssh-run-cmd"
  }

  bash $bash-cmd, %(
    description => %args<description> ||  "remote command on $ssh-host-term",
    debug       => %args<debug>:exists ?? 1 !! 0,
  );

  file-delete '/opt/sparrow/.cache/ssh-key' if %args<ssh-key>:exists;

  file %args<create> if %args<create>:exists;

}

multi sub ssh ( %args ) is export { 
  ssh %args<command>, %args;
}

sub scp ( %args ) is export { 

  directory '/opt/sparrow/.cache/';

  if %args<ssh-key>:exists {
    file '/opt/sparrow/.cache/ssh-key', %( 
      content => ( slurp %args<ssh-key> ),
      mode => '0600'
    );
  }

  my $ssh-host-term = %args<user>:exists ?? %args<user> ~ '@' ~ %args<host> !! %args<host>;

  my $scp-run-cmd  =  'scp -o ConnectionAttempts=1  -o ConnectTimeout=10';

  $scp-run-cmd ~= ' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no';

  $scp-run-cmd ~= ' -q' ;

  $scp-run-cmd ~= ' -i /opt/sparrow/.cache/ssh-key' if %args<ssh-key>:exists;

  $scp-run-cmd ~= %args<pull> ??  " $ssh-host-term %args<data>" !! " %args<data> $ssh-host-term";

  my $bash-cmd;

  if %args<create>:exists {
    $bash-cmd = "if ! test -f %args<create> ; then set -x; $scp-run-cmd ; else echo skip due to %args<create> exists; fi"    
  } else {
    $bash-cmd = "set -x; $scp-run-cmd"
  }

  bash $bash-cmd, %(
    description => $scp-run-cmd,
    debug       => %args<debug>:exists ?? 1 !! 0,
  );

  file-delete '/opt/sparrow/.cache/ssh-key' if %args<ssh-key>:exists;

  file %args<create> if %args<create>:exists;

}
