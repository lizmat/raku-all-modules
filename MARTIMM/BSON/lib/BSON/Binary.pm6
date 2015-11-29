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
  }
}

