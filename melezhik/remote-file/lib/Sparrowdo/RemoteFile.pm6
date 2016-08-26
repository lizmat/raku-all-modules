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

  task_run %(
    task    => "download remote file",
    plugin  => "bash",
    parameters => %(
      command => 'curl '  ~ %args<url> ~ ' -w \'%{url_effective} ==> <%{http_code}> \'' 
      ~ ' -L -s -k -f -o ' ~ %args<location> ~ ' && echo && ls -lh ' ~ %args<location> ,
      debug => 0,
    )
  );

}

