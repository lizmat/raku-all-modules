use v6;

#TODO There are some *-native() and *-emulated() subs kept for later benchmarks
# when perl evolves.

#------------------------------------------------------------------------------
unit package BSON:auth<github:MARTIMM>;

use BSON;
use BSON::ObjectId;
use BSON::Regex;
use BSON::Javascript;
use BSON::Binary;
#use BSON::Decimal128;

class Decimal128 { }

#class TemporaryContainer { }

#------------------------------------------------------------------------------
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
  my Bool $accept-rat = False;

  #----------------------------------------------------------------------------
  # Make new document and initialize with a list of pairs
#TODO better type checking:  List $pairs where all($_) ~~ Pair
#TODO better API
  multi method new ( List $pairs ) {
    self.bless(:$pairs);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Make new document and initialize with a pair
  # No default value! is handled by new() above
  multi method new ( Pair $p ) {
    my List $pairs = $p.List;
    self.bless(:$pairs);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Make new document and initialize with a sequence of pairs
  # No default value! is handled by new() above
  multi method new ( Seq $p ) {
    my List $pairs = $p.List;
    self.bless(:$pairs);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Make new document and initialize with a byte array. This will call
  # decode.
  multi method new ( Buf $b ) {
    self.bless(:buf($b));
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Other cases. No arguments will init empty document. Named values
  # are associative thingies in a Capture and therefore throw an exception.
  multi method new ( |capture ) {

    if capture.keys {
      die X::BSON.new(
        :operation("new: " ~ capture.gist), :type<capture>,
        :error(
          "Cannot use hash values on init.\n",
          "Set accept-hash and use assignments later"
        )
      );
    }

    self.bless( :pairs(List.new()), :h({}));
  }

  #----------------------------------------------------------------------------
  multi submethod BUILD ( List :$pairs! ) {

    self!initialize;

    # self{x} = y will end up at ASSIGN-KEY
    for @$pairs -> $pair {
#note "P: ", $pair.perl, ', ', $pair.value.defined;
      die X::BSON.new(
        :operation("new: List $pairs.gist()"), :type<List>,
        :error("Pair not defined")
      ) unless ?$pair;

      die X::BSON.new(
        :operation("new: List $pairs.gist()"), :type<List>,
        :error("Key of pair not defined or empty")
      ) unless ?$pair.key;

      die X::BSON.new(
        :operation("new: List $pairs.gist()"), :type<List>,
        :error("Value of pair not defined")
      ) unless $pair.value.defined;

      self{$pair.key} = $pair.value;
    }
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  multi submethod BUILD ( Buf :$buf! ) {

    self!initialize;

    # Decode buffer data
    self.decode($buf);
  }

  #----------------------------------------------------------------------------
  method !initialize ( ) {

    @!keys = ();
    @!values = ();

    $!encoded-document = Buf.new();
    @!encoded-entries = ();

    %!promises = ();
  }

  #----------------------------------------------------------------------------
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

  #----------------------------------------------------------------------------
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

  #----------------------------------------------------------------------------
  submethod Str ( --> Str ) {
    self.perl;
  }

  #----------------------------------------------------------------------------
  submethod autovivify ( Bool $avvf = True ) {
    $autovivify = $avvf;
  }

  #----------------------------------------------------------------------------
  submethod accept-hash ( Bool $acch = True ) {
    $accept-hash = $acch;
  }

  #----------------------------------------------------------------------------
  submethod accept-rat ( Bool $accr = True ) {
    $accept-rat = $accr;
  }

  #----------------------------------------------------------------------------
  multi method find-key ( Int:D $idx --> Str ) {

    my $key = $idx >= @!keys.elems ?? 'key' ~ $idx !! @!keys[$idx];
    return self{$key}:exists ?? $key !! Str;
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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


  #----------------------------------------------------------------------------
  # Associative role methods
  #----------------------------------------------------------------------------
  method AT-KEY ( Str $key --> Any ) {
#note "At-key($?LINE): $key, $autovivify";

    my $value;
    my Int $idx = self.find-key($key);
#note "Key: $key, {$idx//'-'}, $autovivify";

    if $idx.defined {
#note "return @!values[$idx]";
      return-rw @!values[$idx];
    }

    # No key found so its undefined, check if we must make a new entry
    elsif $autovivify {
#note 'autovivify';
      $value = BSON::Document.new;
      self{$key} = $value;
      return-rw self{$key};
#note "At-key($?LINE): $key => ", $value.WHAT;
    }

    else {
#note 'return temporary container';
      return Any;

      # next gives a proper version but leaves an Nil value when only reading
      # that should be removed when only reading instead of asssigning.
#      self{$key} = TemporaryContainer;
      $idx = self.find-key($key);

      return-rw @!values[$idx];
    }
  }

  #----------------------------------------------------------------------------
  # Enable BSON::Document to be destructured.
  method Capture ( BSON::Document:D: --> Capture ) {

    return (self.keys Z=> self.values).Capture;
  }

  #----------------------------------------------------------------------------
  method EXISTS-KEY ( Str $key --> Bool ) {

#note "Key $key ", self.find-key($key).defined ?? 'exists' !! 'does not exist';
    self.find-key($key).defined;
  }

  #----------------------------------------------------------------------------
  method DELETE-KEY ( Str $key --> Any ) {

    my $value;
    if (my Int $idx = self.find-key($key)).defined {
      $value = @!values.splice( $idx, 1);
      @!keys.splice( $idx, 1);
      @!encoded-entries.splice( $idx, 1) if @!encoded-entries.elems;
    }

    $value;
  }

  #----------------------------------------------------------------------------
  # All assignments of values which become or already are BSON::Documents
  # will not be encoded in parallel.
  multi method ASSIGN-KEY ( Str:D $key, BSON::Document:D $new --> Nil ) {

#note "Asign-key($?LINE): $key => ", $new.WHAT;

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

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  multi method ASSIGN-KEY ( Str:D $key, List:D $new --> Nil ) {

#note "$*THREAD.id(), List, Asign-key($?LINE): $key => ", $new.WHAT, ', ', $new[0].WHAT;
    my BSON::Document $v .= new;
    for @$new -> $pair {
      if $pair ~~ Pair {
        $v{$pair.key} = $pair.value;
      }

      else {
        die X::BSON.new(
          :operation("\$d<$key> = ({$pair.perl}, ...)"), :type<List>,
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

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  multi method ASSIGN-KEY ( Str:D $key, Pair $new --> Nil ) {

#note "$*THREAD.id(), Pair, Asign-key($?LINE): $key => ", $new.WHAT;

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

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Hashes and sequences are reprocessed as lists
  multi method ASSIGN-KEY ( Str:D $key, Hash $new --> Nil ) {

#note "$*THREAD.id(), Hash, Asign-key($?LINE): $key => ", $new;

    if ! $accept-hash {
      die X::BSON.new(
        :operation("\$d<$key> = {$new.perl}"), :type<Hash>,
        :error("Cannot use hash values.\nSet accept-hash if you really want to")
      );
    }

    self.ASSIGN-KEY( $key, $new.List);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  multi method ASSIGN-KEY ( Str:D $key, Seq $new --> Nil ) {

#note "$*THREAD.id(), Seq, Asign-key($?LINE): $key => ", $new;
    self.ASSIGN-KEY( $key, $new.List);
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # Array will become a document but is not nested into subdocs and can
  # be calculated in parallel.
  #
  multi method ASSIGN-KEY ( Str:D $key, Array:D $new --> Nil ) {

#TODO Test pushes and pops

#note "$*THREAD.id(), Array, Asign-key($?LINE): $key => ", $new;

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
#note "$*THREAD.id(), Array, E key = $k, val = ", $v, ', ', $v.WHAT();
      my Buf $b = self!encode-element: ($k => $v);

      CATCH {
#note .WHAT;
#note "Error at line $?LINE: ";
#.note;
        default {
          note "Error at $?FILE $?LINE: ",  $_;
          .rethrow;
        }
      }

      $b;
    });
  }

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # All other values are calculated in parallel
  #
  multi method ASSIGN-KEY ( Str:D $key, Any $new --> Nil ) {

#note "$*THREAD.id(), Any, Asign-key($?LINE): $key => ", $new.WHAT;

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
#note "E key = $k, val = ", $v, ', ', $v.WHAT();
      my Buf $b = self!encode-element: ($k => $v);
      CATCH {
#note .WHAT;
#.note;
        when X::BSON { .rethrow; }

        default {
          note "Error at $?FILE $?LINE: $_";
          .rethrow;
        }
      }

      $b;
    });
  }

  #----------------------------------------------------------------------------
  # Cannot use binding because when value changes this object cannot know that
  # the location is changed. This is nessesary to encode the key, value pair.
  #
  method BIND-KEY ( Str $key, \new ) {

    die X::BSON.new(
      :operation("\$d<$key> := {new}"), :type<any>,
      :error("Cannot use binding")
    );
  }

  #----------------------------------------------------------------------------
  # Must be defined because of Associative sources of of()
  #----------------------------------------------------------------------------
  method of ( ) {
    BSON::Document;
  }

  #----------------------------------------------------------------------------
  method CALL-ME ( |capture ) {
    die "Call me capture: ", capture.perl;
  }

  #----------------------------------------------------------------------------
  # And some extra methods
  #----------------------------------------------------------------------------
  method elems ( --> Int ) {

    @!keys.elems;
  }

  #----------------------------------------------------------------------------
  method kv ( --> List ) {

    my @kv-list;
    loop ( my $i = 0; $i < @!keys.elems; $i++) {
      @kv-list.push( @!keys[$i], @!values[$i]);
    }

    @kv-list;
  }

  #----------------------------------------------------------------------------
  method pairs ( --> List ) {

    my @pair-list;
    loop ( my $i = 0; $i < @!keys.elems; $i++) {
      @pair-list.push: ( @!keys[$i] => @!values[$i]);
    }

    @pair-list;
  }

  #----------------------------------------------------------------------------
  method keys ( --> List ) {

    @!keys.list;
  }

  #----------------------------------------------------------------------------
  method values ( --> List ) {

    @!values.list;
  }

  #----------------------------------------------------------------------------
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

  #----------------------------------------------------------------------------
  # Encoding document
  #----------------------------------------------------------------------------
  # Called from user to get encoded document or by a request from an
  # encoding Document to encode a subdocument.
  method encode ( --> Buf ) {

    my Bool $still-planned = True;
    while $still-planned {
      $still-planned = False;

      loop ( my $idx = 0; $idx < @!keys.elems; $idx++) {
        my $key = @!keys[$idx];
#note "$*THREAD.id(), $key, ", @!values[$idx], ', ',
#     %!promises{$key}.defined ?? %!promises{$key}.status !! 'promise processed';

        # Test if a promise is created to calculate stuff in parallel
        if %!promises{$key}.defined {
          my PromiseStatus $pstat = %!promises{$key}.status;
          if $pstat ~~ Kept {
            @!encoded-entries[$idx] = %!promises{$key}.result;
            %!promises{$key} = Nil;
#note "$*THREAD.id(), Kept: $key, ", @!values[$idx];
          }

          elsif $pstat ~~ Planned {
#note "$*THREAD.id(), Planned: $key, ", @!values[$idx];
            $still-planned = True;
            next;
          }

          elsif $pstat ~~ Broken {
#note "$*THREAD.id(), Broken: $key";
#note %!promises{$key}.cause.WHAT;
#note %!promises{$key}.cause.message;
            die X::BSON.new(
              :operation<encode>, :type<any>,
              :error(%!promises{$key}.cause)
            );
          }
        }

        # Test if a value is a document. These are never done in parallel
        # Subdocuments entries are also calculated in parallel but also
        # except for subdocuments. When encodng a Document here it calls
        # its own encode() which will gather the data. This happens depth
        # first so ends up here returning the complete encoded subdocument.
        #
        elsif @!values[$idx] ~~ BSON::Document {
#note "$*THREAD.id(), D: $key, ", @!values[$idx];
          @!encoded-entries[$idx] =
            self!encode-element: (@!keys[$idx] => @!values[$idx]);
        }

        else {
#note "$*THREAD.id(), EK: $key, ", @!values[$idx];
        }
      }
    }

    %!promises = ();


    # if there are entries
    my Buf $b;
    if @!encoded-entries.elems {

      $!encoded-document = Buf.new;
#note @!encoded-entries.perl;
      for @!encoded-entries -> $e {
#        next unless ?$e;
        $!encoded-document ~= $e;
      }

      # encode size: number of elems + null byte at the end
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

  #----------------------------------------------------------------------------
  # Encode a key value pair. Called from the insertion methods above when a
  # key value pair is inserted.
  #
  # element ::= type-code e_name some-encoding
  #
  method !encode-element ( Pair:D $p --> Buf ) {
#note "Encode element ", $p.perl, ', ', $p.key.WHAT, ', ', $p.value.WHAT;

    my Buf $b;

    given $p.value {

      # skip all temporay containers
#      when TemporaryContainer {
#note "Tempvalue: KV: $p.perl()";
#        $b = [~] Buf.new()
#      }

  	  when Rat {
  		  # Only handle Rat if it can be converted without precision loss
  		  if $accept-rat || .Num.Rat(0) == $_ {
  			  $_ .= Num;
  		  }

        # Now that Rat is converted to Num, proceed to encode the Num. But
        # when the Rat stays a Rat, it will end up in an exception.
        proceed;
  	  }

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
#note "Array, pairs: ", $pairs.perl;
        my BSON::Document $d .= new($pairs);
#note "Array: ", $d.perl;
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
                 encode-int64((( .posix + .second - .whole-second) * 1000).Int);
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
        die X::BSON.new(
          :operation('encoding DBPointer'), :type('0x0C'),
          :error('DBPointer is deprecated')
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
        if -0x7fffffff <= $p.value <= 0x7fffffff {
          $b = [~] Buf.new(BSON::C-INT32),
                   encode-e-name($p.key),
                   encode-int32($p.value);
        }

        elsif -0x7fffffff_ffffffff <= $p.value <= 0x7fffffff_ffffffff {
          $b = [~] Buf.new(BSON::C-INT64),
                   encode-e-name($p.key),
                   encode-int64($p.value);
        }

        else {
          my $reason = 'small' if $p.value < -0x7fffffff_ffffffff;
          $reason = 'large' if $p.value > 0x7fffffff_ffffffff;
          die X::BSON.new(
            :operation<encode>, :type<Int>,
            :error("Number too $reason")
          );
        }
      }

      when BSON::Timestamp {
        # timestamp as an unsigned 64 bit integer
        # '\x11' e_name int64
        $b = [~] Buf.new(BSON::C-TIMESTAMP),
                 encode-e-name($p.key),
                 encode-uint64($p.value);
      }

      when Decimal128 {
        #`{{
        $b = [~] Buf.new(BSON::C-DECIMAL128),
                 encode-e-name($p.key),
                 .encode;

        }}

        die X::BSON.new( :operation<encode>, :type($_), :error('Not yet implemented'));
      }

      default {
#note "Default {$p.key} => {$p.value//'(Any)'}: ", $p.value.WHAT;
#        if .can('encode') and .can('bson-code') {
#          my $code = .bson-code;
#          $b = [~] Buf.new($code), encode-e-name($p.key), .encode;
#        }
#
#        else {
          die X::BSON.new( :operation<encode>, :type($_), :error('Not yet implemented'));
#        }
      }
    }

#note "\nEE: ", ", {$p.key} => {$p.value//'(Any)'}: ", $p.value.WHAT, ', ', $b;

    $b;
  }

  #----------------------------------------------------------------------------
  # Decoding document
  #----------------------------------------------------------------------------
  method decode ( Buf:D $data --> Nil ) {
#note "Decode data: ", $data.perl;
    $!encoded-document = $data;

    @!keys = ();
    @!values = ();
    @!encoded-entries = ();

    # document decoding start: init index
    $!index = 0;

    # decode the document, then wait for any started parallel tracks
    # first get the size of the (nested-)document
    my Int $doc-size = decode-int32( $!encoded-document, $!index);

    # step to the document content
    $!index += BSON::C-INT32-SIZE;

    # decode elements until end of doc (byte 0x00)
    while $!encoded-document[$!index] !~~ 0x00 {

      self!decode-element;
    }

    # step over the last byte: index should now be the doc size
    $!index++;

    # check size of document with final byte location
    die X::BSON.new(
      :operation<decode>, :type<Document>,
      :error(
        [~] 'Size of document(', $doc-size,
            ') does not match with index(', $!index, ')'
      )
    ) if $doc-size != $!index;

    # wait for promises to end for this document
    self!process-decode-promises;
  }

  #----------------------------------------------------------------------------
  method !decode-element ( --> Nil ) {

    # Decode start point
    my $decode-start = $!index;

    # Get the value type of next pair
    my $bson-code = $!encoded-document[$!index++];

    # Get the key value, Index is adjusted to just after the 0x00
    # of the string.
    my Str $key = decode-e-name( $!encoded-document, $!index);
#note "$*THREAD.id() $key found, type $bson-code, idx now $!index";

    # Keys are pushed in the proper order as they are seen in the
    # byte buffer.
    my Int $idx = @!keys.elems;
    @!keys[$idx] = $key;              # index on new location == push()
    my Int $size;

    given $bson-code {

      # 64-bit floating point
      when BSON::C-DOUBLE {

        my Int $i = $!index;
        $!index += BSON::C-DOUBLE-SIZE;
#note "DBL Subbuf: ", $!encoded-document.subbuf( $i, BSON::C-DOUBLE-SIZE);

        %!promises{$key} = Promise.start( {
            @!values[$idx] = decode-double( $!encoded-document, $i);
#note "DBL: $key, $idx = @!values[$idx]";

            # Return total section of binary data
            $!encoded-document.subbuf(
              $decode-start ..^               # At bson code
              ($i + BSON::C-DOUBLE-SIZE)      # $i is at code + key further
            );
          }
        );
      }

      # String type
      when BSON::C-STRING {

        my Int $i = $!index;
        my Int $nbr-bytes = decode-int32( $!encoded-document, $!index);

        # Step over the size field and the null terminated string
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
      when BSON::C-DOCUMENT {
        my Int $i = $!index;
        my Int $doc-size = decode-int32( $!encoded-document, $i);
        $!index += $doc-size;

        # Wait for any threads to complete before decoding the subdocument
        # If not, the threads are eaten up and we end up waiting for
        # non-started threads.
        self!process-decode-promises;

        my BSON::Document $d .= new;
        $d.decode($!encoded-document.subbuf($i ..^ ($i + $doc-size)));
        @!values[$idx] = $d;

        %!promises{$key} = Promise.start( {
            $!encoded-document.subbuf( $decode-start ..^ ($i + $doc-size));
          }
        );
      }

      # Array code
      when BSON::C-ARRAY {

        my Int $i = $!index;
        my Int $doc-size = decode-int32( $!encoded-document, $!index);
        $!index += $doc-size;

        self!process-decode-promises;
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
      when BSON::C-BINARY {

        my Int $buf-size = decode-int32( $!encoded-document, $!index);
        my Int $i = $!index + BSON::C-INT32-SIZE;

        # Step over size field, subtype and binary data
        $!index += BSON::C-INT32-SIZE + 1 + $buf-size;

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
      when BSON::C-DATETIME {
        my Int $i = $!index;
        $!index += BSON::C-INT64-SIZE;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = DateTime.new(
              decode-int64( $!encoded-document, $i) / 1000,
              :timezone(0)
            );

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-INT64-SIZE)
            );
          }
        );
      }

      # Null value -> Any
      when BSON::C-NULL {
        %!promises{$key} = Promise.start( {
            @!values[$idx] = Any;
            my $i = $!index;
            $!encoded-document.subbuf($decode-start ..^ $i);
          }
        );
      }

      # regular expressions. these are perl5 like
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
      when BSON::C-JAVASCRIPT {

        # Get the size of the javascript code text, then adjust index
        # for this size and set i for the decoding. Then adjust index again
        # for the next action.
        my Int $i = $!index;
        my Int $buf-size = decode-int32( $!encoded-document, $i);

        # Step over size field and the javascript text
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
      when BSON::C-JAVASCRIPT-SCOPE {

        my Int $i1 = $!index;
        my Int $js-size = decode-int32( $!encoded-document, $i1);
        my Int $i2 = $!index + BSON::C-INT32-SIZE + $js-size;
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

      # timestamp
      when BSON::C-TIMESTAMP {

        my Int $i = $!index;
        $!index += BSON::C-UINT64-SIZE;

        %!promises{$key} = Promise.start( {
#            @!values[$idx] = BSON::Timestamp.new( :timestamp(
#                decode-uint64( $!encoded-document, $i)
#              )
#            );
            @!values[$idx] = decode-uint64( $!encoded-document, $i);
#note "Timestamp: ", @!values[$idx];

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-UINT64-SIZE)
            );
          }
        );
      }

      # 64-bit Integer
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

      # 128-bit Decimal
      when BSON::C-DECIMAL128 {
        #`{{

        my Int $i = $!index;
        $!index += BSON::C-DECIMAL128-SIZE;

        %!promises{$key} = Promise.start( {
            @!values[$idx] = BSON::Decimal128.decode( $!encoded-document, $i);

            $!encoded-document.subbuf(
              $decode-start ..^ ($i + BSON::C-DECIMAL128-SIZE)
            );
          }
        );
      }}

        die X::BSON.new(
          :operation<decode>, :type($_),
          :error("BSON code '{.fmt('0x%02x')}' not yet implemented"),
        );
      }

      default {
        # We must stop because we do not know what the length should be of
        # this particular structure.
        die X::BSON.new(
          :operation<decode>,
          :error("BSON code '{.fmt('0x%02x')}' not implemented"),
          :type($_)
        );
      } # default
    } # given
  } # method

  #----------------------------------------------------------------------------
  method !process-decode-promises {

    if %!promises.elems {
      await Promise.allof(%!promises.values);
      loop ( my $idx = 0; $idx < @!keys.elems; $idx++) {
        my $key = @!keys[$idx];
#note "$*THREAD.id() Prom from $key, $idx, {%!promises{$key}:exists}";

        if %!promises{$key}:exists {
          # Return the Buffer slices in each entry so it can be
          # concatenated again when encoding
#note "$*THREAD.id() Before wait for result of $key";
          @!encoded-entries[$idx] = %!promises{$key}.result;
#note "$*THREAD.id() After wait for $key";
        } # if
      } # loop

      %!promises = ();
    } # if
  } # method
}
