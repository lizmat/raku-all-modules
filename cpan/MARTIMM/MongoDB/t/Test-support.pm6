use v6;

#-------------------------------------------------------------------------------
unit package MongoDB:auth<github:MARTIMM>;

use BSON::Document;
use MongoDB;
use MongoDB::Collection;
use MongoDB::Server::Control;
use MongoDB::Client;

use Config::TOML;

#-------------------------------------------------------------------------------
class Test-support {

  has MongoDB::Server::Control $.server-control;

  # Environment variable SERVERKEYS holds a list of server keys. This is set by
  # xt/wrapper.pl6

  has Str $!sandbox;

  #-----------------------------------------------------------------------------
  submethod BUILD ( ) {

    $!sandbox = "$*CWD/t/Sandbox";

    # initialize Control object with config
    $!server-control .= new(
      :locations([$!sandbox,]),
      :config-name<config.toml>
    ) if $!sandbox.IO ~~ :d and "$!sandbox/config.toml".IO ~~ :r;
  }

  #-----------------------------------------------------------------------------
  # Get a connection.
  method get-connection ( Str:D :$server-key! --> MongoDB::Client ) {

    my Int $port-number = $!server-control.get-port-number($server-key);
    MongoDB::Client.new(:uri("mongodb://localhost:$port-number"))
  }

  #-----------------------------------------------------------------------------
  # Search and show content of documents
  method show-documents (
    MongoDB::Collection $collection,
    BSON::Document $criteria,
    BSON::Document $projection = BSON::Document.new()
  ) {

    say '-' x 80;

    my MongoDB::Cursor $cursor = $collection.find( $criteria, $projection);
    while $cursor.fetch -> BSON::Document $document {
      say $document.perl;
    }
  }

  #-----------------------------------------------------------------------------
  multi method serverkeys ( Str $serverkeys is copy ) {

    %*ENV<SERVERKEYS> = $serverkeys // 's1';
  }

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  multi method serverkeys ( --> List ) {

    my $l = ();
    $l = %*ENV<SERVERKEYS>.split(',').List
      if %*ENV<SERVERKEYS>:exists and ?%*ENV<SERVERKEYS>;

    $l ?? $l !! ('s1',)
  }

  #-----------------------------------------------------------------------------
  method create-clients ( --> Hash ) {

    my Hash $h = {};
    for @(self.serverkeys) -> $skey {
      $h{$skey} = self.get-connection(:server-key($skey));
    }

    # if %*ENV<SERVERKEYS> is not set then take default server s1
    $h ?? $h !! %( s1 => self.get-connection(:server-key<s1>) )
  }

  #-----------------------------------------------------------------------------
  method server-version ( DatabaseType $db --> Str ) {

    my BSON::Document $doc = $db.run-command: (
      serverStatus => 1,
      repl => 0, metrics => 0, locks => 0, asserts => 0,
      backgroundFlushing => 0, connections => 0, cursors => 0,
      extra_info => 0, globalLock => 0, indexCounters => 0, network => 0,
      opcounters => 0, opcountersRepl => 0, recordStats => 0
    );

    $doc<version>
  }

  #-----------------------------------------------------------------------------
  # Remove everything setup in directory Sandbox
  method cleanup-sandbox ( ) {

    # Make recursable sub
    my $cleanup-dir = sub ( Str $dir-entry ) {
      for dir($dir-entry) -> $entry {
        if $entry ~~ :d {
          $cleanup-dir(~$entry);
          rmdir ~$entry;
        }

        else {
          unlink ~$entry;
        }
      }
    }

    # Run the sub with top directory 'Sandbox'.
    $cleanup-dir('Sandbox');

    rmdir "Sandbox";
  }
}
