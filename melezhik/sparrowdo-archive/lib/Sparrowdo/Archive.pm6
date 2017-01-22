use v6;

unit module Sparrowdo::Archive;

use Sparrowdo;

our sub tasks (%args) {

  task_run  %(
    task => 'install archive programs',
    plugin => 'package-generic',
    parameters => %( list => 'tar gzip unzip' )
  );

  my $ext = %args<source>.IO.extension;
  my $command;

  if $ext eq 'gz' {
    $command = %args<verbose> ??  
      'tar --verbose -xzf ' ~ %args<source> ~ ' -C ' ~ %args<target> !!
      'tar -xzf ' ~ %args<source> ~ ' -C ' ~ %args<target>;
  } elsif $ext eq 'tar' {
    $command = 'tar -xf ' ~ %args<source> ~ ' -C ' ~ %args<target>;
  } elsif $ext eq 'zip'  {
    $command = %args<verbose> ?? 
      'unzip -v -o -u ' ~ %args<source> ~ ' -d ' ~ %args<target> !!
      'unzip -o -u ' ~ %args<source> ~ ' -d ' ~ %args<target>;
  } elsif $ext eq 'gem'  {
    $command = %args<verbose> ?? 
      'gem unpack ' ~ %args<source> ~ ' -V --target ' ~ %args<target> !!
      'gem unpack ' ~ %args<source> ~ ' --target ' ~ %args<target>;
  }else {
    die 'unknown file extension ' ~   %args<source>.IO.extension
  }


  task_run %(
    task    => "extract files from archive",
    plugin  => "bash",
    parameters => %(
      user    => %args<user>,
      command => $command,
      debug   => 0,
    )
  );

}

