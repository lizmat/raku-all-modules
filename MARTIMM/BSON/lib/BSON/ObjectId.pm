# Information about object id construction can be found at
# http://docs.mongodb.org/manual/reference/object-id/
# Here it will be used when the argument to encode() is undefined.
#
use v6;
use Digest::MD5;
use BSON::Exception;
#use BSON::EDCTools;

package BSON {

  class ObjectId {

    # Represents ObjectId BSON type described in
    # http://dochub.mongodb.org/core/objectids
    #
    has Buf $.oid;

    has Int $.seconds;
    has Int $.machine-id;
    has Int $.pid;
    has Int $.count;

    #---------------------------------------------------------------------------
    #
    method encode ( Str $s = '' --> BSON::ObjectId ) {
      # Check length of string
      #
      my Buf $b;
      given $s.chars {
        when 0 {
          my int $ni = my Int $seconds = time;
          $b = Buf.new(
                 $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                 ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
               );

          # Machine name will be 3 bytes from an MD5 generated string from
          # the $*KERNEL variable. Tried to find out what is used but could not
          # find it. uname -m, ip, hostname, localhost, ... nothing! I believe
          # any random 3 byte character string will do!
          #
          $ni = my Int $machine-id
              = :16(Digest::MD5.md5_hex("$*KERNEL").substr( 0, 6));
          $b ~= Buf.new(
                  $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
                  ($ni +> 0x10) +& 0xFF
                );

          $ni = $*PID;
          $b ~= Buf.new( $ni +& 0xFF, ($ni +> 0x08) +& 0xFF);

          # If count is not defined then start with 2 byte random number
          # otherwise increment with one
          #
          # Check if this is an object or a type object
          #
          my Int $count;
          if ?self {
            $ni = $count = ?$!count ?? ++$!count !! 0xFFFF.rand.Int;
          }

          else {
            $ni = $count = 0xFFFF.rand.Int;
          }

          $b ~= Buf.new(
            $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
            ($ni +> 0x10) +& 0xFF
          );

          # Make object
          #
#note "B: ", $b.elems;
          return self.bless( :oid($b), :$seconds, :$machine-id, :$count);
        }

        when 24 {
          # Check if all characters are hex characters.
          #
          die X::BSON::Parse.new(
            :operation('BSON::ObjectId::encode'),
            :error("String is not a hexadecimal number")
          ) unless $s ~~ m:i/^ <[0..9a..f]>+ $/;

          my @a = map {:16($_) }, $s.comb(/../);
          $b = Buf.new(@a);
#note "B: ", $b.elems;
          return self.bless( *, oid => $b);
        }

        default {
          die X::BSON::Parse.new(
            :operation('BSON::ObjectId::encode'),
            :error("String must have 24 hexadecimal characters")
          );
        }
      }
    }

    #---------------------------------------------------------------------------
    #
    method decode ( Buf $b --> BSON::ObjectId ) {
      die X::BSON::Parse.new(
        :operation('BSON::ObjectId::decode'),
        :error("Buffer doesn't have 12 bytes")
      ) unless $b.elems == 12;

      return self.bless( *, oid => $b);
    }

    #---------------------------------------------------------------------------
    #
    method Buf ( ) {
      return $.oid;
    }

    #---------------------------------------------------------------------------
    #
    method perl ( ) {
      my $s = '';
      for $.oid.list {
        $s ~= ( $_ +> 4 ).fmt('%x') ~ ( $_ % 16 ).fmt('%x');
      }

      return 'ObjectId( "' ~ $s ~ '" )';
    }

    #---------------------------------------------------------------------------
    #
    method get-seconds ( --> Int ) {
      return $!seconds;
    }

    #---------------------------------------------------------------------------
    #
    method get-timestamp ( --> DateTime ) {
      return DateTime.new($!seconds);
    }

    #---------------------------------------------------------------------------
    #
    method get-machine-id ( --> Int ) {
      return $!machine-id;
    }

    #---------------------------------------------------------------------------
    #
    method value-of ( --> Str ) {
      my Str $s = $!oid[*].fmt('02X');
      $s ~~ s:g/\s//;
      return $s;
    }
  }
}
