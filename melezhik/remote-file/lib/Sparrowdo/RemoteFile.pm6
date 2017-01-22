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

  my $cmd = 'curl '  ~ %args<url> ~ ' -w \'%{url_effective} ==> <%{http_code}> \'' 
  ~ ' -L -s -k -f -o ' ~ %args<location>; 

  $cmd ~= ' -u' ~ %args<user> if %args<user>.defined;
  $cmd ~= ':' ~ %args<password> if %args<password>.defined;

  $cmd ~= ' && echo && ls -lh ' ~ %args<location>;

  task_run %(
    task    => "download remote file",
    plugin  => "bash",
    parameters => %( command => $cmd, debug => 0 );
  );

}

