use v6;

package BSON {

  constant C-GENERIC            = 0x00;
  constant C-FUNCTION           = 0x01;
  constant C-BINARY-OLD         = 0x02;         # Deprecated
  constant C-UUID-OLD           = 0x03;         # Deprecated
  constant C-UUID               = 0x04;
  constant C-MD5                = 0x05;

  constant C-UUID-SIZE          = 16;
  constant C-MD5-SIZE           = 16;

  class Binary {

    has Buf $.binary-data;
    has Bool $.has-binary-data = False;
    has Int $.binary-type;

    #-----------------------------------------------------------------------------
    #
    submethod BUILD ( Buf :$data, Int :$type = C-GENERIC ) {
      $!binary-data = $data;
      $!has-binary-data = ?$!binary-data;
      $!binary-type = $type;
    }

    #---------------------------------------------------------------------------
    method perl ( Int $indent = 0 --> Str ) {
      $indent = 0 if $indent < 0;

      my $perl = "BSON::Binary.new(";
      my $bin-i1 = '  ' x ($indent + 1);
      my $bin-i2 = '  ' x ($indent + 2);

      my Str $str-type = <C-GENERIC C-FUNCTION C-BINARY-OLD C-UUID-OLD
                          C-UUID C-MD5
                         >[$!binary-type];

      if ? $str-type {
        $str-type = "BSON::$str-type";
      }

      else {
#TODO extend with new user types
      }

      $perl ~= "\n$bin-i1\:type\($str-type)";

      if $!binary-data {
        my Str $bstr = $!binary-data.perl;
        $bstr ~~ s:g/ (\d+) (<[,\)]>) /{$0.fmt('0x%02x')}$1/;
        my $nspaces = ($bstr ~~ m:g/\s/).elems;
        for 8,16...Inf -> $space-loc {
          $bstr = $bstr.subst( /\s+/, "\n$bin-i2", :nth($space-loc));
          last if $space-loc > $nspaces;
        }
        $bstr ~~ s/\.new\(/.new(\n$bin-i2/;
        $bstr ~~ s:m/'))'/\n$bin-i1)/;
        $perl ~= ",\n$bin-i1\:data($bstr)\n";
      }

      else {
        $perl ~= "\n" ~ $bin-i1 ~ ")\n";
      }

      $perl ~= '  ' x $indent ~ ")";
    }

    #---------------------------------------------------------------------------
    method encode ( ) {
      my Buf $b .= new;
      if self.has-binary-data {
        $b ~= encode-int32(self.binary-data.elems);
        $b ~= Buf.new(self.binary-type);
        $b ~= self.binary-data;
      }

      else {
        $b ~= encode-int32(0);
        $b ~= Buf.new(self.binary-type);
      }

      $b;
    }

    #---------------------------------------------------------------------------
#TODO Remove duplicate sub into other module
    sub encode-int32 ( Int:D $i --> Buf ) {
      my int $ni = $i;
      return Buf.new(
        $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
        ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF
      );
    }

    #---------------------------------------------------------------------------
    method decode (
      Buf:D $b,
      Int:D $index is copy,
      Int:D $nbr-bytes
      --> BSON::Binary
    ) {

      # Get subtype
      #
      my $sub_type = $b[$index++];

      # Most of the tests are not necessary because of arbitrary sizes.
      # UUID and MD5 can be tested.
      #
      given $sub_type {
        when BSON::C-GENERIC {
          # Generic binary subtype
        }

        when BSON::C-FUNCTION {
          # Function
        }

        when BSON::C-BINARY-OLD {
          # Binary (Old - deprecated)
          die X::Parse-document.new(
            :operantion<decode Binary>,
            :error('Code (0x02) Deprecated binary data')
          );
        }

        when BSON::C-UUID-OLD {
          # UUID (Old - deprecated)
          die 'UUID(0x03) Deprecated binary data';
          die X::Parse-document.new(
            :operantion<decode Binary>,
            :error('UUID(0x03) Deprecated binary data')
          );
        }

        when BSON::C-UUID {
          # UUID. According to
          # http://en.wikipedia.org/wiki/Universally_unique_identifier the
          # universally unique identifier is a 128-bit (16 byte) value.
          #
          die X::Parse-document.new(
            :operation('decode Binary'),
            :error('UUID(0x04) Length mismatch')
          ) unless $nbr-bytes ~~ BSON::C-UUID-SIZE;
        }

        when BSON::C-MD5 {
          # MD5. This is a 16 byte number (32 character hex string)
          die X::Parse-document.new(
            :operation('decode Binary'),
            :error('MD5(0x05) Length mismatch')
          ) unless $nbr-bytes ~~ BSON::C-MD5-SIZE;
        }

        when 0x80 {
          # User defined. That is, all other codes 0x80 .. 0xFF
        }
      }

      return BSON::Binary.new(
        :data(Buf.new($b[$index ..^ ($index + $nbr-bytes)])),
        :type($sub_type)
      );
    }
  }
}

