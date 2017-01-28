use v6;

unit module Sparrowdo::Core::DSL::Ssh;

#use Sparrowdo;
use Sparrowdo::Core::DSL::Bash;
use Sparrowdo::Core::DSL::Directory;
use Sparrowdo::Core::DSL::File;

sub ssh ( $command, %args? ) is export { 

  my %ssh-command;

  directory '/opt/sparrow/.cache/';

  file '/opt/sparrow/.cache/ssh-command', %( content => $command ~ "\nexit" );
  
  if %args<ssh-key>:exists {
    file '/opt/sparrow/.cache/ssh-key', %( 
      content => ( slurp %args<ssh-key> ),
      mode => '0600'
    );
  }

  my $ssh-host-term = %args<host>;

  $ssh-host-term = %args<user> ~ '@' ~ $ssh-host-term if %args<user>:exists;

  my $ssh-run-cmd  =  'ssh -o ConnectionAttempts=1  -o ConnectTimeout=5';

  $ssh-run-cmd ~= ' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -tt';

  $ssh-run-cmd ~= ' -q' ;

  $ssh-run-cmd ~= ' -i /opt/sparrow/.cache/ssh-key' if %args<ssh-key>:exists;

  $ssh-run-cmd ~= " $ssh-host-term " ~ ' < /opt/sparrow/.cache/ssh-command ';

  bash $ssh-run-cmd, %(
   description => $ssh-run-cmd
  );

  file-delete '/opt/sparrow/.cache/ssh-key' if %args<ssh-key>:exists;

}
