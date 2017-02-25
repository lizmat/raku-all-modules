use v6.c;

#TODO There are some *-native() and *-emulated() subs kept for later benchmarks
# when perl evolves.

use BSON;
use BSON::ObjectId;
use BSON::Regex;
use BSON::Javascript;
use BSON::Binary;

#-------------------------------------------------------------------------------
unit package BSON:auth<https://github.com/MARTIMM>;

#-------------------------------------------------------------------------------
# BSON type codes
constant C-DOUBLE             = 0x01;
constant C-STRING             = 0x02;
constant C-DOCUMENT           = 0x03;
constant C-ARRAY              = 0x04;
constant C-BINARY             = 0x05;
constant C-UNDEFINED          = 0x06;         # Deprecated
constant C-OBJECTID           = 0x07;
constant C-BOOLEAN            = 0x08;
constant C-DATETIME           = 0x09;
constant C-NULL               = 0x0A;
constant C-REGEX              = 0x0B;
constant C-DBPOINTER          = 0x0C;         # Deprecated
constant C-JAVASCRIPT         = 0x0D;
constant C-DEPRECATED         = 0x0E;         # Deprecated
constant C-JAVASCRIPT-SCOPE   = 0x0F;
constant C-INT32              = 0x10;
constant C-TIMESTAMP          = 0x11;         # Used internally
constant C-INT64              = 0x12;
constant C-DECIMAL128         = 0x13;
constant C-MIN-KEY            = 0xFF;
constant C-MAX-KEY            = 0x7F;

#-------------------------------------------------------------------------------
# Fixed sizes
constant C-INT32-SIZE         = 4;
constant C-INT64-SIZE         = 8;
constant C-DOUBLE-SIZE        = 8;

#-------------------------------------------------------------------------------
class Document does Associative {

  subset Index of Int where $_ >= 0;

  has Str @!keys;
  has @!values;

  has Buf $!encoded-document;
  has Buf @!encoded-entries;
  has Index $!index = 0;

  has Promise %!promises;

  # Keep this value global to the class. Any old or new object has the same
  # settings
  #
  my Bool $autovivify = False;
  my Bool $accept-hash = False;

  #-----------------------------------------------------------------------------
  # Make new document and initialize with a list of pairs
#TODO better type checking:  List $pairs where all($_) ~~ Pair
#TODO better API
  multi method new ( List $pairs, *%h ) {
    self.bless( :$pairs, :%h);
  }

  # Make new document and initialize with a pair
  # No default value! is handled by new() above
  #
  multi method new ( Pair $p, *%h ) {
    my List $pairs = $p.List;
    self.bless( :$pairs, :%h);
  }

  # Make new document and initialize with a sequence of pairs
  # No default value! is handled by new() above
  #
  multi method new ( Seq $p, *%h ) {
    my List $pairs = $p.List;
    self.bless( :$pairs, :%h);
  }

  # Make new document and initialize with a byte array. This will call
  # decode.
  #
  multi method new ( Buf $b, *%h ) {
    self.bless( :buf($b), :%h);
  }

  # Other cases. No arguments will init empty document. Named values
  # are associative thingies in a Capture and therefore throw an exception.
  #
  multi method new ( |capture ) {

    if capture.keys {
      die X::BSON::Parse-document.new(
        :operation("new: key => value")
        :error(
          "Cannot use hash values on init.\n",
          "Set accept-hash and use assignments later"
        )
      );
    }

    self.bless( :pairs(List.new()), :h({}));
  }

  #-----------------------------------------------------------------------------
  multi submethod BUILD ( List :$pairs!, :%h ) {

    self!initialize(:%h);

    # self{x} = y will end up at ASSIGN-KEY
    #
    for @$pairs -> $pair {
      die "Pair not defined" unless ?$pair;
      die "Key of pair not defined or empty" unless ?$pair.key;
      die "Value of pair not defined" unless $pair.value.defined;
      self{$pair.key} = $pair.value;
    }
  }

  multi submethod BUILD ( Buf :$buf!, :%h ) {

    self!initialize(:%h);

    # Decode buffer data
    #
    self.decode($buf);
  }

  #-----------------------------------------------------------------------------
  method !initialize ( :%h ) {

    @!keys = ();
    @!values = ();

    $!encoded-document = Buf.new();
    @!encoded-entries = ();

    %!promises = ();
  }

  #-----------------------------------------------------------------------------
  method perl ( Int $indent = 0, Bool :$skip-indent = False --> Str ) {
    $indent = 0 if $indent < 0;

    my Str $perl = '';
    $perl ~= '  ' x $indent unless $skip-indent;
    $perl ~= "BSON::Document.new((\n";
    $perl ~= self!str-pairs( $indent + 1, self.pairs);
    $perl ~= ('  ' x $indent) ~ "))";
    $perl ~= ($indent == 0 ?? '' !! ',') ~ "\n";
    return $perl;
  }

  #-----------------------------------------------------------------------------
  method !str-pairs ( Int $indent, List $items --> Str ) {
    my Str $perl = '';
    for @$items -> $item {
      my $key;
      my $value;

      if $item.^can('key') {
        $key = $item.key;
        $value = $item.value // 'Nil';
        $perl ~= '  ' x $indent ~ "$key => ";
      }

      else {
        $value = $item // 'Nil';
      }

      given $value {
        when $value ~~ BSON::Document {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= $value.perl( $indent, :skip-indent($key.defined));
        }

        when $value ~~ Array {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= "[\n";
          $perl ~= self!str-pairs( $indent + 1, @$value);
          $perl ~= '  ' x $indent ~ "],\n";
        }

        when $value ~~ List {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= "(\n";
          $perl ~= self!str-pairs( $indent + 1, @$value);
          $perl ~= '  ' x $indent ~ "),\n";
        }

#TODO check if this can be removed in later perl versions
        when $value ~~ Buf {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= $value.perl ~ ",\n";
        }

#          when $value.^name eq 'BSON::ObjectId' {
#            $perl ~= '  ' x $indent unless $key.defined;
#            $perl ~= $value.perl,\n";
#          }

        when $value.^name eq 'BSON::Binary' {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= $value.perl($indent) ~ ",\n";
        }

        when $value.^name eq 'BSON::Regex' {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= $value.perl($indent) ~ ",\n";
        }

        when $value.^name eq 'BSON::Javascript' {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= $value.perl($indent) ~ ",\n";
        }

        when ?$value.^can('perl') {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= $value.perl ~ ",\n";
        }

        default {
          $perl ~= '  ' x $indent unless $key.defined;
          $perl ~= "$value,\n";
        }
      }
    }
    return $perl;
  }

  #-----------------------------------------------------------------------------
  submethod Str ( --> Str ) {
    self.perl;
  }

  #-----------------------------------------------------------------------------
  submethod autovivify ( Bool $avvf = True ) {
    $autovivify = $avvf;
  }

  #-----------------------------------------------------------------------------
  submethod accept-hash ( Bool $acch = True ) {
    $accept-hash = $acch;
  }

  #-----------------------------------------------------------------------------
  multi method find-key ( Int:D $idx --> Str ) {

    my $key = $idx >= @!keys.elems ?? 'key' ~ $idx !! @!keys[$idx];
    return self{$key}:exists ?? $key !! Str;
  }

  #-----------------------------------------------------------------------------
  multi method find-key ( Str:D $key --> Int ) {

    my Int $idx;
    loop ( my $i = 0; $i < @!keys.elems; $i++) {
      if @!keys[$i] eq $key {
        $idx = $i;
        last;
      }
    }

    $idx;
  }


  #-----------------------------------------------------------------------------
  # Associative role methods
  #-----------------------------------------------------------------------------
  method AT-KEY ( Str $key --> Any ) {
#note "At-key($?LINE): $key, $autovivify";

    my $value;
    my Int $idx = self.find-key($key);
    if $idx.defined {
      $value = @!values[$idx];
    }

    # No key found so its undefined, check if we must make a new entry
    #
    elsif $autovivify {
      $value = BSON::Document.new;
      self{$key} = $value;
#say "At-key($?LINE): $key => ", $value.WHAT;
    }

    $value;
  }

  #-----------------------------------------------------------------------------
  method EXISTS-KEY ( Str $key --> Bool ) {
    self.find-key($key).defined;
  }

  #-----------------------------------------------------------------------------
  method DELETE-KEY ( Str $key --> Any ) {

    my $value;
    if (my Int $idx = self.find-key($key)).defined {
      $value = @!values.splice( $idx, 1);
      @!keys.splice( $idx, 1);
      @!encoded-entries.splice( $idx, 1) if @!encoded-entries.elems;
    }

    $value;
  }

  #-----------------------------------------------------------------------------
  # All assignments of values which become or already are BSON::Documents
  # will not be encoded in parallel.
  #
  multi method ASSIGN-KEY ( Str:D $key, BSON::Document:D $new --> Nil ) {

#say "Asign-key($?LINE): $key => ", $new.WHAT;

    my Str $k = $key;
    my BSON::Document $v = $new;

    my Int $idx = self.find-key($k);
    if $idx.defined {
      if %!promises{$k}.defined {
        %!promises{$k}.result;
        %!promises{$k}:delete;
      }
    }

    else {
      $idx = @!keys.elems;
    }

    @!keys[$idx] = $k;
    @!values[$idx] = $v;
  }

  multi method ASSIGN-KEY ( Str:D $key, List:D $new --> Nil ) {

#say "$*THREAD.id(), List, Asign-key($?LINE): $key => ", $new.WHAT, ', ', $new[0].WHAT;
    my BSON::Document $v .= new;
    for @$new -> $pair {
      if $pair ~~ Pair {
        $v{$pair.key} = $pair.value;
      }

      else {
        die X::BSON::Parse-document.new(
          :operation("\$d<$key> = ({$pair.perl}, ...)")
          :error("Can only use lists of Pair")
        );
      }
    }

    my Str $k = $key;
    my Int $idx = self.find-key($k);
    if $idx.defined {
      if %!promises{$k}.defined {
        %!promises{$k}.result;
        %!promises{$k}:delete;
      }
    }

    else {
      $idx = @!keys.elems;
    }

    @!keys[$idx] = $k;
    @!values[$idx] = $v;
  }

  multi method ASSIGN-KEY ( Str:D $key, Pair $new --> Nil ) {

#say "$*THREAD.id(), Pair, Asign-key($?LINE): $key => ", $new.WHAT;

    my Str $k = $key;
    my BSON::Document $v .= new;

    $v{$new.key} = $new.value;

    my Int $idx = self.find-key($k);
    if $idx.defined {
      if %!promises{$k}.defined {
        %!promises{$k}.result;
        %!promises{$k}:delete;
      }
    }

    else {
      $idx = @!keys.elems;
    }

    @!keys[$idx] = $k;
    @!values[$idx] = $v;
  }

  # Hashes and sequences are reprocessed as lists
  #
  multi method ASSIGN-KEY ( Str:D $key, Hash $new --> Nil ) {

#say "$*THREAD.id(), Hash, Asign-key($?LINE): $key => ", $new;

    if ! $accept-hash {
      die X::BSON::Parse-document.new(
        :operation("\$d<$key> = {$new.perl}")
        :error("Cannot use hash values.\nSet accept-hash if you really want to")
      );
    }

    self.ASSIGN-KEY( $key, $new.List);
  }

  multi method ASSIGN-KEY ( Str:D $key, Seq $new --> Nil ) {

#say "$*THREAD.id(), Seq, Asign-key($?LINE): $key => ", $new;
    self.ASSIGN-KEY( $key, $new.List);
  }

  # Array will become a document but is not nested into subdocs and can
  # be calculated in parallel.
  #
  multi method ASSIGN-KEY ( Str:D $key, Array:D $new --> Nil ) {

#TODO Test pushes and pops

#say "$*THREAD.id(), Array, Asign-key($?LINE): $key => ", $new;

    my Str $k = $key;
    my Array $v = $new;

    my Int $idx = self.find-key($k);
    if $idx.defined {
      if %!promises{$k}.defined {
        %!promises{$k}.result;
        %!promises{$k}:delete;
      }
    }

    else {
      $idx = @!keys.elems;
    }

    @!keys[$idx] = $k;
    @!values[$idx] = $v;

#    %!promises{$k} = Promise.start({self!encode-element: ($k => $v);});
    %!promises{$k} = Promise.start( {
#say "$*THREAD.id(), Array, E key = $k, val = ", $v, ', ', $v.WHAT();
      my Buf $b = self!encode-element: ($k => $v);

      CATCH {
#say .WHAT;
#say "Error at line $?LINE: ";
#.say;
        default {
          say "Error at $?FILE $?LINE:",  $_;
          .rethrow;
        }
      }

      $b;
    });
  }

  # All other values are calculated in parallel
  #
  multi method ASSIGN-KEY ( Str:D $key, Any $new --> Nil ) {

#say "$*THREAD.id(), Any, Asign-key($?LINE): $key => ", $new.WHAT;

    my Str $k = $key;
    my $v = $new;

    my Int $idx = self.find-key($k);
    if $idx.defined {
      if %!promises{$k}.defined {
        %!promises{$k}.result;
        %!promises{$k}:delete;
      }
    }

    else {
      $idx = @!keys.elems;
    }

    @!keys[$idx] = $k;
    @!values[$idx] = $v;

#    %!promises{$k} = Promise.start({ self!encode-element: ($k => $v); });
    %!promises{$k} = Promise.start( {
#say "E key = $k, val = ", $v, ', ', $v.WHAT();
      my Buf $b = self!encode-element: ($k => $v);
      CATCH {
#say .WHAT;
        when X::BSON::Parse-objectid    { .rethrow; }
        when X::BSON::Parse-document    { .rethrow; }
        when X::BSON::NYS               { .rethrow; }
        when X::BSON::Deprecated        { .rethrow; }

        default {
          note "Error at $?FILE $?LINE: $_";
          .rethrow;
        }
      }

      $b;
    });
  }

  #-----------------------------------------------------------------------------
  # Cannot use binding because when value changes this object cannot know that
  # the location is changed. This is nessesary to encode the key, value pair.
  #
  method BIND-KEY ( Str $key, \new ) {

    die X::BSON::Parse-document.new(
      :operation("\$d<$key> := {new}")
      :error("Cannot use binding")
    );
  }

  #-----------------------------------------------------------------------------
  # Must be defined because of Positional and Associative sources of of()
  #-----------------------------------------------------------------------------
  method of ( ) {
    BSON::Document;
  }

  #-----------------------------------------------------------------------------
  method CALL-ME ( |capture ) {
#say "Call me capture: ", capture.perl;
  }

  #-----------------------------------------------------------------------------
  # And some extra methods
  #-----------------------------------------------------------------------------
  method elems ( --> Int ) {

    @!keys.elems;
  }

  #-----------------------------------------------------------------------------
  method kv ( --> List ) {

    my @kv-list;
    loop ( my $i = 0; $i < @!keys.elems; $i++) {
      @kv-list.push( @!keys[$i], @!values[$i]);
    }

    @kv-list;
  }

  #-----------------------------------------------------------------------------
  method pairs ( --> List ) {

    my @pair-list;
    loop ( my $i = 0; $i < @!keys.elems; $i++) {
      @pair-list.push: ( @!keys[$i] => @!values[$i]);
    }

    @pair-list;
  }

  #-----------------------------------------------------------------------------
  method keys ( --> List ) {

    @!keys.list;
  }

  #-----------------------------------------------------------------------------
  method values ( --> List ) {

    @!values.list;
  }

  #-----------------------------------------------------------------------------
#TODO very slow method
  method modify-array ( Str $key, Str $operation, $data --> List ) {

    my Int $idx = self.find-key($key);
    if self{$key}:exists
       and self{$key} ~~ Array
       and self{$key}.can($operation) {

      my $array = self{$key};
      $array."$operation"($data);
      self{$key} = $array;
    }
  }

  #-----------------------------------------------------------------------------
  # Encoding document
  #-----------------------------------------------------------------------------
  # Called from user to get encoded document or by a request from an
  # encoding Document to encode a subdocument.
  #
  method encode ( --> Buf ) {

    my Bool $still-planned = True;
    while $still-planned {
      $still-planned = False;

      loop ( my $idx = 0; $idx < @!keys.elems; $idx++) {
        my $key = @!keys[$idx];
#say "$*THREAD.id(), $key, ", @!values[$idx];    #, ', ',
#    %!promises{$key}.defined ?? %!promises{$key}.status !! 'no promise';

        # Test if a promise is created to calculate stuff in parallel
        if %!promises{$key}.defined {
          my PromiseStatus $pstat = %!promises{$key}.status;
          if $pstat ~~ Kept {
            @!encoded-entries[$idx] = %!promises{$key}.result;
            %!promises{$key} = Nil;
#say "$*THREAD.id(), Kept: $key, ", @!values[$idx];
          }

          elsif $pstat ~~ Planned {
#say "$*THREAD.id(), Planned: $key, ", @!values[$idx];
            $still-planned = True;
            next;
          }

          elsif $pstat ~~ Broken {
#say "$*THREAD.id(), Broken: $key";
#say %!promises{$key}.cause.WHAT;
#say %!promises{$key}.cause.message;
            die %!promises{$key}.cause;
#            die "Promise for key '$key' broken, %!promises{$key}.cause()";
          }
        }

        # Test if a value is a document. These are never done in parallel
        # Subdocuments entries are also calculated in parallel but also
        # except for subdocuments. When encodng a Document here it calls
        # its own encode() which will gather the data. This happens depth
        # first so ends up here returning the complete encoded subdocument.
        #
        elsif @!values[$idx] ~~ BSON::Document {
#say "$*THREAD.id(), D: $key, ", @!values[$idx];
          @!encoded-entries[$idx] =
            self!encode-element: (@!keys[$idx] => @!values[$idx]);
        }

        else {
#say "$*THREAD.id(), EK: $key, ", @!values[$idx];
        }
      }
    }

    %!promises = ();


    # if there are entries
    my Buf $b;
    if @!encoded-entries.elems {

      $!encoded-document = Buf.new;
      for @!encoded-entries -> $e {

        $!encoded-document ~= $e;
      }

      $b = [~] encode-int32($!encoded-document.elems + 5),
               $!encoded-document,
               Buf.new(0x00);
    }

    # otherwise generate an empty document
    else {
      $b = [~] encode-int32(5), Buf.new(0x00);
    }

    return $b;
  }

  #-----------------------------------------------------------------------------
  # Encode a key value pair. Called from the insertion methods above when a
  # key value pair is inserted.
  #
  # element ::= type-code e_name some-encoding
  #
  method !encode-element ( Pair:D $p --> Buf ) {
#say "Encode element ", $p.perl, ', ', $p.key.WHAT, ', ', $p.value.WHAT;

    my Buf $b;

    given $p.value {

      when Num {
        # Double precision
        # "\x01" e_name Num
        #
        $b = [~] Buf.new(BSON::C-DOUBLE),
                 encode-e-name($p.key),
                 encode-double($p.value);
      }

      when Str {
        # UTF-8 string
        # "\x02" e_name string
        #
        $b = [~] Buf.new(BSON::C-STRING),
                 encode-e-name($p.key),
                 encode-string($p.value);
      }

      when BSON::Document {
        # Embedded document
        # "\x03" e_name document
        #
        $b = [~] Buf.new(BSON::C-DOCUMENT), encode-e-name($p.key), .encode;
#note "Encoded doc ($?LINE): ", $b;
      }

      when Array {
        # Array
        # "\x04" e_name document

        # The document for an array is a normal BSON document
        # with integer values for the keys,
        # starting with 0 and continuing sequentially.
        # For example, the array ['red', 'blue']
        # would be encoded as the document {'0': 'red', '1': 'blue'}.
        # The keys must be in ascending numerical order.
        #
        my $pairs = (for .kv -> $k, $v { "$k" => $v });
        my BSON::Document $d .= new($pairs);
#say "Array: ", $d.perl;
        $b = [~] Buf.new(BSON::C-ARRAY), encode-e-name($p.key), $d.encode;
#note "Encoded array ($?LINE): ", $b;
      }

      when BSON::Binary {
        # Binary data
        # "\x05" e_name int32 subtype byte*
        # subtype is '\x00' for the moment (Generic binary subtype)
        #
        $b = [~] Buf.new(BSON::C-BINARY), encode-e-name($p.key), .encode;
      }

      when BSON::ObjectId {
        # ObjectId
        # "\x07" e_name (byte*12)
        #
        $b = [~] Buf.new(BSON::C-OBJECTID), encode-e-name($p.key), .encode;
      }

      when Bool {
        # Bool
        # \0x08 e_name (\0x00 or \0x01)
        #
        if .Bool {
          # Boolean "true"
          # "\x08" e_name "\x01
          #
          $b = [~] Buf.new(BSON::C-BOOLEAN),
                   encode-e-name($p.key),
                   Buf.new(0x01);
        }
        else {
          # Boolean "false"
          # "\x08" e_name "\x00
          #
          $b = [~] Buf.new(BSON::C-BOOLEAN),
                   encode-e-name($p.key),
                   Buf.new(0x00);
        }
      }

      when DateTime {
        # UTC dateime
        # "\x09" e_name int64
        #
        $b = [~] Buf.new(BSON::C-DATETIME),
                 encode-e-name($p.key),
                 encode-int64(.posix);
      }

      when not .defined {
        # Nil == Undefined value == typed object
        # "\x0A" e_name
        #
        $b = Buf.new(BSON::C-NULL) ~ encode-e-name($p.key);
      }

      when BSON::Regex {
        # Regular expression
        # "\x0B" e_name cstring cstring
        #
        $b = [~] Buf.new(BSON::C-REGEX),
                 encode-e-name($p.key),
                 encode-cstring(.regex),
                 encode-cstring(.options);
      }

#`{{
      when ... {
        # DBPointer - deprecated
        # "\x0C" e_name string (byte*12)
        #
        die X::BSON::Deprecated(
          operation => 'encoding DBPointer',
          type => '0x0C'
        );
      }
}}

      # This entry does 2 codes. 0x0D for javascript only and 0x0F when
      # there is a scope document defined in the object
      #
      when BSON::Javascript {

        # Javascript code
        # "\x0D" e_name string
        # "\x0F" e_name int32 string document
        #
        if .has-scope {
          $b = [~] Buf.new(BSON::C-JAVASCRIPT-SCOPE),
                   encode-e-name($p.key),
                   .encode;
        }

        else {
          $b = [~] Buf.new(BSON::C-JAVASCRIPT),
                   encode-e-name($p.key),
                   .encode;
        }
      }

      when Int {
        # Integer
        # "\x10" e_name int32
        # '\x12' e_name int64
        #
        if -0xffffffff < $p.value < 0xffffffff {
          $b = [~] Buf.new(BSON::C-INT32),
                   encode-e-name($p.key),
                   encode-int32($p.value);
        }

        elsif -0x7fffffff_ffffffff < $p.value < 0x7fffffff_ffffffff {
          $b = [~] Buf.new(BSON::C-INT64),
                   encode-e-name($p.key),
                   encode-int64($p.value);
        }

        else {
          my $reason = 'small' if $p.value < -0x7fffffff_ffffffff;
          $reason = 'large' if $p.value > 0x7fffffff_ffffffff;
          die X::BSON::Parse-document.new(
            :operation('encode Int'),
            :error("Number too $reason")
          );
        }
      }

      default {
        if .can('encode') and .can('bson-code') {
          my $code = .bson-code;
          $b = [~] Buf.new($code), encode-e-name($p.key), .encode;
        }

        else {
          die X::BSON::NYS.new( :operation('encode-element()'), :type($_));
        }
      }
    }

#say "\nEE: ", ", {$p.key} => {$p.value//'(Any)'}: ", $p.value.WHAT, ', ', $b;

    $b;
  }

  #-----------------------------------------------------------------------------
  # Decoding document
  #-----------------------------------------------------------------------------
  method decode ( Buf $data --> Nil ) {

    $!encoded-document = $data;

    @!keys = ();
    @!values = ();
    @!encoded-entries = ();

    # Document decoding start: init index
    #
    $!index = 0;

    # Decode the document, then wait for any started parallel tracks
    #
    self!decode-document;

    if %!promises.elems {
      loop ( my $idx = 0; $idx < @!keys.elems; $idx++) {
        my $key = @!keys[$idx];
#say "Prom from $key, $idx, {%!promises{$key}:exists}";

        if %!promises{$key}:exists {
          # Return the Buffer slices in each entry so it can be
          # concatenated again when encoding
          #
          @!encoded-entries[$idx] = %!promises{$key}.result;
        }
      }

      %!promises = ();
    }
  }

  #-----------------------------------------------------------------------------
  method !decode-document ( --> Nil ) {

    # Get the size of the (nested-)document
    #
    my Int $doc-size = decode-int32( $!encoded-document, $!index);
    $!index += C-INT32-SIZE;

    while $!encoded-document[$!index] !~~ 0x00 {
      self!decode-element;
    }

    $!index++;

    # Check size of document with final byte location
    #
    die X::BSON::Parse-document.new(
      :operation<decode-document()>,
      :error(
        [~] 'Size of document(', $doc-size,
            ') does not match with index(', $!index, ')'
      )
    ) if $doc-size != $!index;
  }

  #-----------------------------------------------------------------------------
  method !decode-element ( --> Nil ) {

    # Decode start point
    #
    my $decode-start = $!index;

    # Get the value type of next pair
    #
    my $bson-code = $!encoded-document[$!index++];

    # Get the key value, Index is adjusted to just after the 0x00
    # of the string.
    #
    my Str $key = decode-e-name( $!encoded-document, $!index);

    # Keys are pushed in the proper order as they are seen in the
    # byte buffer.
    #
    my Int $idx = @!keys.elems;
    @!keys[$idx] = $key;              # index on new location == push()
    my Int $size;

    given $bson-code {

      # 64-bit floating point
      #
      when BSON::C-DOUBLE {

        my Int $i = $!index;
        $!index += BSON::C-DOUBLE-SIZE;
#say "DBL Subbuf: ", $!encoded-document.subbuf( $i, BSON::C-DOUBLE-SIZE);

        %!promises{$key} = Promise.start( {
            @!values[$idx] = decode-double( $!encoded-document, $i);
#say "DBL: $key, $idx = @!values[$idx]";

            # Return total section of binary data
            #
            $!encoded-document.subbuf(
              $decode-start ..^               # At bson code
              ($i + BSON::C-DOUBLE-SIZE)      # $i is at code + key further
            );
          }
        );
      }

      # String type
      #
      when BSON::C-STRING {

        my Int $i = $!index;
        my Int $nbr-bytes = decode-int32( $!encoded-document, $!index);

        # Step over the size field and the null terminated string
        #
        $!index += BSON::C-INT32-SIZE + $nbr-bytes;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = decode-string( $!encoded-document, $i);
            $!encoded-document.subbuf(
              $decode-start ..^
              ($i + BSON::C-INT32-SIZE + $nbr-bytes)
            );
          }
        );
      }

      # Nested document
      #
      when BSON::C-DOCUMENT {
        my Int $i = $!index;
        my Int $doc-size = decode-int32( $!encoded-document, $i);
        $!index += $doc-size;

        # Keep this decoding out of the promise routine. It gets problems
        # when waiting for it.
        #
        my BSON::Document $d .= new;
        $d.decode($!encoded-document.subbuf($i ..^ ($i + $doc-size)));
        @!values[$idx] = $d;

        %!promises{$key} = Promise.start( {
            $!encoded-document.subbuf( $decode-start ..^ ($i + $doc-size));
          }
        );
      }

      # Array code
      #
      when BSON::C-ARRAY {

        my Int $i = $!index;
        my Int $doc-size = decode-int32( $!encoded-document, $!index);
        $!index += $doc-size;

        %!promises{$key} = Promise.start( {
            my BSON::Document $d .= new;

            $d.decode($!encoded-document.subbuf($i ..^ ($i + $doc-size)));
            @!values[$idx] = [$d.values];

            $!encoded-document.subbuf( $decode-start ..^ ($i + $doc-size));
          }
        );
      }

      # Binary code
      # "\x05 e_name int32 subtype byte*
      # subtype = byte \x00 .. \x05, .. \xFF
      # subtypes \x80 to \xFF are user defined
      #
      when BSON::C-BINARY {

        my Int $buf-size = decode-int32( $!encoded-document, $!index);
        my Int $i = $!index + C-INT32-SIZE;

        # Step over size field, subtype and binary data
        #
        $!index += C-INT32-SIZE + 1 + $buf-size;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = BSON::Binary.decode(
              $!encoded-document, $i, :$buf-size
            );

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + 1 + $buf-size)
            );
          }
        );
      }

      # Object id
      #
      when BSON::C-OBJECTID {

        my Int $i = $!index;
        $!index += 12;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = BSON::ObjectId.decode( $!encoded-document, $i);
            $!encoded-document.subbuf($decode-start ..^ ($i + 12));
          }
        );
      }

      # Boolean code
      #
      when BSON::C-BOOLEAN {

        my Int $i = $!index;
        $!index++;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = $!encoded-document[$i] ~~ 0x00 ?? False !! True;
            $!encoded-document.subbuf($decode-start .. ($i + 1));
          }
        );
      }

      # Datetime code
      #
      when BSON::C-DATETIME {
        my Int $i = $!index;
        $!index += BSON::C-INT64-SIZE;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = DateTime.new(
              decode-int64( $!encoded-document, $i),
              :timezone($*TZ)
            );

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-INT64-SIZE)
            );
          }
        );
      }

      when BSON::C-NULL {
        %!promises{$key} = Promise.start( {
            @!values[$idx] = Any;
            my $i = $!index;
            $!encoded-document.subbuf($decode-start ..^ $i);
          }
        );
      }

      when BSON::C-REGEX {

        my $doc-size = $!encoded-document.elems;
        my $i1 = $!index;
        while $!encoded-document[$!index] !~~ 0x00 and $!index < $doc-size {
          $!index++;
        }
        $!index++;
        my $i2 = $!index;

        while $!encoded-document[$!index] !~~ 0x00 and $!index < $doc-size {
          $!index++;
        }
        $!index++;
        my $i3 = $!index;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = BSON::Regex.new(
              :regex(decode-cstring( $!encoded-document, $i1)),
              :options(decode-cstring( $!encoded-document, $i2))
            );

            $!encoded-document.subbuf($decode-start ..^ $i3);
          }
        );
      }

      # Javascript code
      #
      when BSON::C-JAVASCRIPT {

        # Get the size of the javascript code text, then adjust index
        # for this size and set i for the decoding. Then adjust index again
        # for the next action.
        #
        my Int $i = $!index;
        my Int $buf-size = decode-int32( $!encoded-document, $i);

        # Step over size field and the javascript text
        #
        $!index += (BSON::C-INT32-SIZE + $buf-size);

        %!promises{$key} = Promise.start( {
            @!values[$idx] = BSON::Javascript.decode( $!encoded-document, $i);
            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-INT32-SIZE + $buf-size)
            );
          }
        );
      }

      # Javascript code with scope
      #
      when BSON::C-JAVASCRIPT-SCOPE {

        my Int $i1 = $!index;
        my Int $js-size = decode-int32( $!encoded-document, $i1);
        my Int $i2 = $!index + C-INT32-SIZE + $js-size;
        my Int $js-scope-size = decode-int32( $!encoded-document, $i2);

        $!index += (BSON::C-INT32-SIZE + $js-size + $js-scope-size);
        my Int $i3 = $!index;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = BSON::Javascript.decode(
              $!encoded-document, $i1,
              :bson-doc(BSON::Document.new),
              :scope(Buf.new($!encoded-document[$i2 ..^ ($i2 + $js-size)]))
            );

            $!encoded-document.subbuf($decode-start ..^ $i3);
          }
        );
      }

      # 32-bit Integer
      #
      when BSON::C-INT32 {

        my Int $i = $!index;
        $!index += BSON::C-INT32-SIZE;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = decode-int32( $!encoded-document, $i);

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-INT32-SIZE)
            );
          }
        );
      }

      # 64-bit Integer
      #
      when BSON::C-INT64 {

        my Int $i = $!index;
        $!index += BSON::C-INT64-SIZE;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = decode-int64( $!encoded-document, $i);

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-INT64-SIZE)
            );
          }
        );
      }

      default {
        # We must stop because we do not know what the length should be of
        # this particular structure.
        #
        die X::BSON::Parse-document.new(
          :operation<decode-element()>,
          :error("BSON code '{.fmt('0x%02x')}' not supported")
        );
      }
    }
  }
}

