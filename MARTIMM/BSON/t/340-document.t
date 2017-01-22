use v6;
use Test;
use BSON::Document;

#-------------------------------------------------------------------------------
subtest "Extending array", {

  my BSON::Document $d .= new: (docs => []);
  $d.modify-array( 'docs', 'push', (a => 1, b => 2));

  my Buf $hand-made .= new(
    0x26, 0x00, 0x00, 0x00,
      0x04, 0x64, 0x6f, 0x63, 0x73, 0x00,       # Array 'docs'
      0x1b, 0x00, 0x00, 0x00,
        0x03, 0x30, 0x00,                       # Document '0'
        0x13, 0x00, 0x00, 0x00,
          0x10, 0x61, 0x00,                     # Int 'a'
          0x01, 0x00, 0x00, 0x00,               # 1
          0x10, 0x62, 0x00,                     # Int 'b'
          0x02, 0x00, 0x00, 0x00,               # 2
        0x00,
      0x00,
    0x00,
  );

  my Buf $encoded = $d.encode;
  is-deeply $encoded, $hand-made, 'Document encoded ok';

#$d.perl.say;
#say "E: ", $encoded;

}


#-------------------------------------------------------------------------------
# Cleanup
#
done-testing;
exit(0);
