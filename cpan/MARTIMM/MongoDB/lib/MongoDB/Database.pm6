use v6;

#-------------------------------------------------------------------------------
unit package MongoDB:auth<github:MARTIMM>;

use MongoDB;
use MongoDB::Collection;
use MongoDB::Cursor;
use BSON::Document;

#-------------------------------------------------------------------------------
class Database {

  has Str $.name;
  has ClientType $.client;
  has MongoDB::Collection $!cmd-collection;

  # Batch of documents in last response
  has @!documents;

  #-----------------------------------------------------------------------------
  submethod BUILD ( ClientType:D :$client, Str:D :$name ) {

    self!set-name($name);
    $!client = $client;

    trace-message("create database $name");

    # Create a collection $cmd to be used with run-command()
    $!cmd-collection = self.collection('$cmd');
  }

  #-----------------------------------------------------------------------------
  # Select a collection. When it is new it comes into existence only
  # after inserting data
  #
  method collection ( Str:D $name --> MongoDB::Collection ) {

    return MongoDB::Collection.new( :database(self), :name($name));
  }

  #-----------------------------------------------------------------------------
  # Run command should ony be working on the admin database using the virtual
  # $cmd collection. Method is placed here because it works on a database be
  # it a special one.
  #
  # Run command using the BSON::Document.
  multi method run-command ( BSON::Document:D $command --> BSON::Document ) {

    debug-message("run command {$command.keys[0]}");
    self!execute($command);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run command using List of Pair.
  multi method run-command ( List $pairs --> BSON::Document ) {

    my BSON::Document $command .= new: $pairs;
    debug-message("run command {$command.keys[0]}");
    self!execute($command);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run command using the BSON::Document.
  multi method run-command (
    BSON::Document:D $command, Bool:D :$cursor!
    --> MongoDB::Cursor
  ) {

    debug-message("run command cursor {$command.keys[0]}");

    my MongoDB::Cursor $c;
    my BSON::Document $doc = self!execute($command);
#note "Cursor doc 1: ", $doc<cursor><firstBatch>.perl;
    if ? $doc<cursor><firstBatch> {
      $c .= new(
        :$!client, :database(self), :cursor-doc($doc<cursor>), :modern
      );
    }

    $c
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Run command using the BSON::Document.
  multi method run-command (
    List:D $pairs, Bool:D :$cursor!
    --> MongoDB::Cursor
  ) {

    my BSON::Document $command .= new: $pairs;
    debug-message("run command cursor {$command.keys[0]}");

    my MongoDB::Cursor $c;
    my BSON::Document $doc = self!execute($command);
#note "Cursor doc 2: ", $doc<cursor>.perl;
    if ? $doc<cursor> {
      $c .= new(
        :$!client, :database(self), :cursor-doc($doc<cursor>), :modern
      );
    }

    $c
  }

  #-----------------------------------------------------------------------------
  method !execute ( BSON::Document $command --> BSON::Document ) {

#    my MongoDB::Cursor $cursor = self!find(:$command);

    # Commands for the command collection ($cmd) always return one document
    # Lately, the default setting 0 for number-to-return is not accepted and
    # must be set to 1 explicitly.
    my MongoDB::Cursor $cursor = $!cmd-collection.find(
      :criteria($command), :number-to-return(1)
    );

    # Return undefined on server problems
    if not $cursor.defined {
      error-message("No cursor returned");
      return BSON::Document;
    }

    my $doc = $cursor.fetch;
    return $doc.defined ?? $doc !! BSON::Document.new;
  }

  #-----------------------------------------------------------------------------
  method !set-name ( Str $name = '' ) {

    # Check special database first. Should be empty and is set later
    if !?$name and self.^name ne 'MongoDB::AdminDB' {
      return error-message("Illegal database name: '$name'");
    }

    elsif !?$name {
      return error-message("No database name provided");
    }

    # Check the name of the database. On window systems more is prohibited
    # https://docs.mongodb.org/manual/release-notes/2.2/#rn-2-2-database-name-restriction-windows
    # https://docs.mongodb.org/manual/reference/limits/
    #
    elsif $*DISTRO.is-win {
      if $name ~~ m/^ <[\/\\\.\s\"\$\*\<\>\:\|\?]>+ $/ {
        return error-message("Illegal database name: '$name'");
      }
    }

    else {
      if $name ~~ m/^ <[\/\\\.\s\"\$]>+ $/ {
        return error-message("Illegal database name: '$name'");
      }
    }

    $!name = $name;
  }
}
