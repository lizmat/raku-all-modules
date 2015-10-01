use v6;
use Test;

use BSON::EDCTools;

#-------------------------------------------------------------------------------
my $index;

#-------------------------------------------------------------------------------
# Cstring encoding
#
my Str $s = "abc def";
my Buf $b = encode_cstring($s);
is-deeply $b,
          Buf.new( 0x61, 0x62, 0x63, 0x20, 0x64, 0x65, 0x66, 0x00),
          "C string encode";

#-------------------------------------------------------------------------------
# Cstring encoding with 0-character in it
#
if 1 {
  $s = "abc\0def";
  $b = encode_cstring($s);

  CATCH {
    my $msg = .message;
    $msg ~~ s:g/\n//;
    when X::BSON::Parse {
      ok .message ~~ m/'Forbidden 0x00 sequence in'/, $msg;
    }
  }
}

#-------------------------------------------------------------------------------
# Cstring encoding
#
$index = 0;
$b = Buf.new( 0x61, 0x62, 0x63, 0x20, 0x64, 0x65, 0x66, 0x00);
$s = decode_cstring( $b.list, $index);
is $s, "abc def", "Decoded cstring";
is $index, 8, 'Check index after decode';

#-------------------------------------------------------------------------------
# Cstring encoding split by 0x00 character
#
$index = 0;
$b = Buf.new( 0x61, 0x62, 0x63, 0x00, 0x64, 0x65, 0x66, 0x00);
$s = decode_cstring( $b.list, $index);
is $s, "abc", "Decoded cstring 'abc'";
is $index, 4, 'Check index';

$s = decode_cstring( $b.list, $index);
is $s, "def", "Decoded cstring 'def'";
is $index, 8, 'Check index after decode';

#-------------------------------------------------------------------------------
# Cstring encoding missing 0x00 character
#
if 1 {
  $index = 0;
  $b = Buf.new( 0x61, 0x62, 0x63);
  $s = decode_cstring( $b.list, $index);

  CATCH {
    my $msg = .message;
    $msg ~~ s:g/\n//;
    when X::BSON::Parse {
      ok .message ~~ m/'Missing trailing 0x00'/, $msg;
    }
  }
}


#-------------------------------------------------------------------------------
# String encoding
#
$s = "abc def";
$b = encode_string($s);
is-deeply $b,
          Buf.new( 0x08, 0x00 xx 3,
                   0x61, 0x62, 0x63, 0x20, 0x64, 0x65, 0x66, 0x00
                 ),
          "String encode";

#-------------------------------------------------------------------------------
# String encoding with 0-character in it
#
$s = "abc\0def";
$b = encode_string($s);
is-deeply $b,
          Buf.new( 0x08, 0x00 xx 3,
                   0x61, 0x62, 0x63, 0x00, 0x64, 0x65, 0x66, 0x00
                 ),
          "String encode with 0x00";

#-------------------------------------------------------------------------------
# String encoding with 0x00 character
#
$index = 0;
$b = Buf.new( 0x08, 0x00 xx 3,
              0x61, 0x62, 0x63, 0x00, 0x64, 0x65, 0x66, 0x00
            );
$s = decode_string( $b.list, $index);
is $s, "abc\0def", "Decoded string 'abc\\0def'";
is $index, 12, 'Check index after decode';

#-------------------------------------------------------------------------------
# String encoding size of string too short
#
if 1 {
  $index = 0;
  $b = Buf.new( 0x08, 0x00 xx 3,
                0x61, 0x62, 0x63, 0x20 #, 0x64, 0x65, 0x66, 0x00
              );
  $s = decode_string( $b.list, $index);

  CATCH {
    my $msg = .message;
    $msg ~~ s:g/\n//;
    when X::BSON::Parse {
      ok .message ~~ m/'Not enaugh characters left'/, $msg;
    }
  }
}

#-------------------------------------------------------------------------------
# String encoding missing 0x00 character
#
if 1 {
  $index = 0;
  $b = Buf.new( 0x08, 0x00 xx 3,
                0x61, 0x62, 0x63, 0x00, 0x64, 0x65, 0x66, 0x66,
                0x01, 0x00 xx 3,                # Some other string
                0x61, 0x00
              );
  $s = decode_string( $b.list, $index);

  CATCH {
    my $msg = .message;
    $msg ~~ s:g/\n//;
    when X::BSON::Parse {
      ok .message ~~ m/'Missing trailing 0x00'/, $msg;
    }
  }
}


#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);
