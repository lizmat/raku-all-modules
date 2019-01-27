use v6;
use BSON::D;
use BSON::EDC-Tools;

#-------------------------------------------------------------------------------
#
class X::BSON::Encodable is Exception {
  has $.operation;                      # Operation encode, decode or other
  has $.type;                           # Type to handle
  has $.emsg;                           # Extra message


  method message () {
      return "\n$!operation\() on $!type error: $!emsg";
  }
}

#-------------------------------------------------------------------------------
# This role implements BSON serialization functions. To provide full encoding
# of a type more information must be stored. This class must represent
# a document such as { key => SomeType.new(...) }. Therefore it needs to store
# the key name and the data representing the class.
# Furthermore it needs a code for the specific BSON type.
# 
#
# Role to encode to and/or decode from a BSON representation.
#
package BSON {
  class Encodable is BSON::Encodable-Tools {

    constant $BSON-DOUBLE       = 0x01;
    constant $BSON-DOCUMENT     = 0x03;

    # Visible in all objects of this class
    #
    my Int $index = 0;
#    has Int $thread-count = 0;
#    has Array $!threads;

    #---------------------------------------------------------------------------
    #
    method encode ( Hash $document --> Buf ) {

      my Int $doc-length = 0;
      my Buf $stream-part;
      my Buf $stream = Buf.new();

      # Process the document. The order in which the keys are selected
      # is not important.
      #
      for $document.keys -> $var-name {

        # Get the data of the given key and test for its type
        #
        my $data = $document{$var-name};
        given $data {

          # Embedded document
          # element     ::= "\x03" e_name document
          # document    ::= int32 e_list "\x00"
          # e_list      ::= element e_list | ""
          #
          when Hash {
            $stream-part = [~] Buf.new($BSON-DOCUMENT),
                               self.enc_cstring($var-name),
                               self.encode($data);
            $stream ~= $stream-part;
          }

          # Double precision, e_name is a cstring, double is 64-bit IEEE 754
          # floating point number
          # element     ::= "\x01" e_name double.
          #
          when Num {
            my $promoted-self = self.clone;
            $promoted-self does BSON::Double;

            $stream-part = [~] Buf.new($BSON-DOUBLE),
                               self.enc_cstring($var-name),
                               $promoted-self.encode_obj($data);
            $stream ~= $stream-part;
          }
        }
      }

      # Build document
      # document    ::= int32 e_list "\x00"
      #
      return [~] self.enc_int32($stream.elems + 5), $stream, Buf.new(0x00);
    }

    #---------------------------------------------------------------------------
    # This one is used to start decode process
    #
    multi method decode ( Buf $stream --> Hash ) {
      $index = 0;
#      $thread-count = 0;
#      $!threads = [];
      return self!decode_document($stream.list);
    }

    # This one is used to recursively decode sub documents
    #
    multi method decode ( Array $stream --> Hash ) {
      return self!decode_document($stream);
    }

    method !decode_document ( Array $encoded-document --> Hash ) {
      # Result document
      #
      my Hash $document;      

      # document    ::= int32 e_list "\x00"
      # 
      my Int $doc-length = self.dec_int32( $encoded-document, $index);

      # element     ::= bson_code e_name data
      # 
      my Int $bson_code = $encoded-document[$index++];
      while $bson_code {
        # Get e_name
        #
        my Str $key_name = self.dec_cstring( $encoded-document, $index);

        given $bson_code {
          when $BSON-DOUBLE {
            # Clone this object and then promote it to play the role of the
            # matched type. In this case BSON::Double.
            #
            my $nbr-bytes-channel = Channel.new;
            my $promoted-self = self.clone;
            $promoted-self does BSON::Double;
            
#            $!threads[$thread-count] = Thread.new(
#              code => {
              $*SCHEDULER.cue( {
#say "Code started";
                my Num $keyval = $promoted-self.decode_obj(
                                   $encoded-document,
                                   $index,
                                   $nbr-bytes-channel
                                 );

                cas(
                  $document,
                  -> $doc {
                    my Hash $new-doc = $doc;
                    $new-doc{$key_name} = $keyval;
                    $new-doc;
                  }
                );
#say "Code stopped";
              },

#              name => 't ' ~ $thread-count
            );
#say "Code scheduled, ";

#            $!threads[$thread-count].run;
#            $thread-count++;
            $index += $nbr-bytes-channel.receive;
#say "New index $index";
            $nbr-bytes-channel.close;
          }

          when $BSON-DOCUMENT {
            my Hash $sub-doc = self.decode($encoded-document);
            cas(
              $document,
              -> $doc {
                my Hash $new-doc = $doc;
                $new-doc{$key_name} = $sub-doc;
                $new-doc;
              }
            );
          }

          default {
            say "What?!: $bson_code";
          }
        }

#        if $thread-count > 9 {
#          self!clear-threads;
#          $thread-count = 0;
#        }

        $bson_code = $encoded-document[$index++];
      }

#      self!clear-threads;

      return $document;
    }
    
#    method !clear-threads ( ) {
#      for $!threads.list -> $thread is rw {
#say "Finished $thread" if $thread.defined;
#        $thread.finish if $thread.defined;
#        undefine($thread);
#      }
#    }
  }
}
