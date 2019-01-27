use v6;
use BSON::Document;
use MongoDB;
use MongoDB::Wire;

#-------------------------------------------------------------------------------
unit package MongoDB:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
class Cursor does Iterable {

  has MongoDB::ClientType $.client;
  has Str $.full-collection-name;
  has Int $.id;

  # Batch of documents in last response
  has @!documents;

  has MongoDB::ServerType $!server;
  has Int $!number-to-return;

  # Attributes needed when a modern type of cursor is used
  has Bool $!modern = False;
  has MongoDB::DatabaseType $!database;

  #-----------------------------------------------------------------------------
  # Support for the newer BSON::Document
  multi submethod BUILD (
    MongoDB::CollectionType:D :$collection!, BSON::Document:D :$server-reply!,
    ServerType:D :$server!, Int :$number-to-return = 0
  ) {

    $!client = $collection.database.client;
    $!full-collection-name = $collection.full-collection-name;

    # Get cursor id from reply. Will be 8 * 0 bytes when there are no more
    # batches left on the server to retrieve. Documents may be present in
    # this reply.
    my Buf $cid = $server-reply<cursor-id>;
    if [+] $cid {
      $!id = self!decode-int64($cid);
      $!server = $server;
    }

    else {
      $!server = Nil;
    }

    # Get documents from the reply.
    @!documents = $server-reply<documents>.list;
    $!number-to-return = $number-to-return;

    trace-message("Cursor set for @!documents.elems() documents (type 1)");
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # This can be set with data received from a command e.g. listDatabases
  multi submethod BUILD (
    MongoDB::ClientType:D :$client!, BSON::Document:D :$cursor-doc!,
    Int :$number-to-return = 0
  ) {

    $!client = $client;
    $!full-collection-name = $cursor-doc<ns>;
    my MongoDB::Header $header .= new;

    # Get cursor id from reply. Will be 8 * 0 bytes when there are no more
    # batches left on the server to retrieve. Documents may be present in
    # this reply.3
    my Buf $cid = $header.encode-cursor-id($cursor-doc<id>);
    if [+] $cid {
      $!id = self!decode-int64($cid);
      $!server = $!client.select-server;
    }

    else {
      $!server = Nil;
    }

    # Get documents from the reply.
    @!documents = @($cursor-doc<firstBatch>);
    $!number-to-return = $number-to-return;

    trace-message("Cursor set for @!documents.elems() documents (type 2)");
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # This can be set with data received from a command e.g. listDatabases
  multi submethod BUILD (
    MongoDB::ClientType:D :$!client!, MongoDB::DatabaseType:D :$!database!,
    BSON::Document:D :$cursor-doc!, Bool:D :$modern!
  ) {

#TODO test mongodb server version
    # Whatever is set. The named attribute functions as a method selector!
    $!modern = True;

    # Get documents from the reply.
    @!documents = @($cursor-doc<firstBatch>);
    $!number-to-return = 0;
    $!full-collection-name = $cursor-doc<ns>;

    # Get cursor id from cursor document. Will be 0 when there are no more
    # batches left on the server to retrieve. Documents may be present in
    # this reply.
    if ?$cursor-doc<id> {
      $!id = $cursor-doc<id>;
      $!server = $!client.select-server;
    }

    else {
      $!server = Nil;
    }

    trace-message("Cursor: @!documents.elems() documents (modern method)");
  }

  #-----------------------------------------------------------------------------
  # Iterator to be used in for {} statements
  method iterator ( MongoDB::Cursor:D: --> Iterator:D ) {

    # Save object to be used in Iterator object
    my $cursor-object = self;
    # Create anonymous class which does the Iterator role
    class :: does Iterator {
      method pull-one ( --> Mu ) {
        my BSON::Document $doc = $cursor-object.fetch;
        return $doc.defined ?? $doc !! IterationEnd;
      }

    # Create the object for this class and return it
    }.new;
  }

  #-----------------------------------------------------------------------------
  method fetch ( --> BSON::Document ) {

    return BSON::Document unless self.defined;

    # If there are no more documents in last response batch but there is
    # still a next batch(sum of id bytes not 0) to fetch from database.
    #
    if not @!documents and $!id {

      if $!modern {
        self!get-more;
      }

      else {
        # Request next batch of documents
        my BSON::Document $server-reply =
          MongoDB::Wire.new.get-more( self, :$!server, :$!number-to-return);

        if $server-reply.defined {

          # Get cursor id, It may change to "0" if there are no more
          # documents to fetch.
          my Buf $cid = $server-reply<cursor-id>;
          $!server = Nil unless [+] $cid;

          # Get documents
          @!documents = $server-reply<documents>.list;

          trace-message("Another @!documents.elems() documents retrieved");
        }

        else {
          trace-message("All documents read");
          @!documents = ();
        }
      }
    }

    else {
      trace-message("Still @!documents.elems() documents left");
    }

    # Return a document when there is one. If none left, return Nil
    return +@!documents ?? @!documents.shift !! BSON::Document;
  }

  #-----------------------------------------------------------------------------
  method kill ( --> Nil ) {

    # clear documents
    @!documents = ();

    # Invalidate cursor on database only if id is valid
    if $!id {
      $!server = $!client.select-server;
      MongoDB::Wire.new.kill-cursors( (self,), :$!server);
      trace-message("Cursor killed");

      # Invalidate cursor id with 8 0x00 bytes
      $!id = 0;
      $!server = Nil;
    }

    else {
      trace-message("No cursor available to kill");
    }
  }

  #-----------------------------------------------------------------------------
  # modern type to get more documents (mongodb 3.2)
  method !get-more ( ) {

#TODO test mongodb server version
    my BSON::Document $req .= new;
    $req<getMore> = $!id;
    $req<collection> = $!full-collection-name;

    my BSON::Document $cursor-doc = $!database.run-command($req);
note "Get more: ", $cursor-doc.perl;

    # Get documents from the reply.
    @!documents = @($cursor-doc<cursor><firstBatch>);

    # Get cursor id from cursor document. Will be 0 when there are no more
    # batches left on the server to retrieve. Documents may be present in
    # this reply.
    $!server = Nil unless ?$cursor-doc<id>;

    trace-message("Get-more @!documents.elems() documents (modern method)");
  }

  #-----------------------------------------------------------------------------
  # copied/modified from BSON
  method !decode-int64 ( Buf:D $b --> Int ) {

    my Int $ni = $b[0]         +| $b[1] +< 0x08 +|
                 $b[2] +< 0x10 +| $b[3] +< 0x18 +|
                 $b[4] +< 0x20 +| $b[5] +< 0x28 +|
                 $b[6] +< 0x30 +| $b[7] +< 0x38
                 ;
    return $ni;
  }
}
