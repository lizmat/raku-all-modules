use v6;

unit module Sparrowdo::RemoteFile;

use Sparrowdo;

our sub tasks (%args) {

  task_run  %(
    task => 'install curl',
    plugin => 'package-generic',
    parameters => %( list => 'curl' )
  );

  task_run %(
    task        => "create directory for downloads",
    plugin      => "directory",
    parameters  => %( path =>  %args<location>.IO.dirname )
  );

  my $cmd = "set -e"  ~ "\n";
 
  $cmd ~= 'if test -f ' ~ %args<location> ~ ' ; then ' ~ "\n";
  $cmd ~= 'echo file ' ~  %args<location> ~ ' exists, skip download' ~ "\n";
  $cmd ~= 'else' ~ "\n";

  $cmd ~= 'curl '  ~ %args<url> ~ ' -w \'%{url_effective} ==> <%{http_code}> \'' 
  ~ ' -L -s -k -f -o ' ~ %args<location>; 

  $cmd ~= ' -u' ~ %args<user> if %args<user>.defined;

  if %args<headers> {

    # -H "X-First-Name: Joe"
    for %args<headers> -> $h {
      $cmd ~= ' -H "' ~ $h ~ '"';
    }
  }


  $cmd ~= ':' ~ %args<password> if %args<password>.defined;

  $cmd ~= "\n" ~ 'fi' ~ "\n";

  $cmd ~= 'ls -lh ' ~ %args<location>;

  task_run %(
    task    => "download remote file",
    plugin  => "bash",
    parameters => %( command => $cmd, debug => 0 );
  );

}

