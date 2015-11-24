use v6;
use Test;
use BSON;
use BSON::Binary;
use UUID;
use Digest::MD5;

#-------------------------------------------------------------------------------
# Binary object. Generic binary
#
subtest {
#  my BSON::Binary $bin-obj .= new;
  my Buf $raw-bin = Buf.new(0x55 xx 3);
  my BSON::Binary $bin-obj .= new(
    data => $raw-bin,
  );

  is-deeply( $bin-obj.Buf, $raw-bin, 'compare data');

  my Array $bin-test = [ ( 0x03, 0x00, 0x00, 0x00,        # Size of buf
                           0x00,                          # Generic binary type
                           0x55 xx 3,                     # Raw Buf
                         ).flat
                       ];

  my Buf $enc-bin = $bin-obj.encode-binary;
  is-deeply( $enc-bin.Array, $bin-test, 'encode general binary test');

  my $index = 0;
  $bin-obj .= new;
  $bin-obj.decode-binary( $enc-bin.list, $index);
  is-deeply( $bin-obj.Buf, $raw-bin, 'compare data after decoding');
  is( $index, $bin-test.elems, "Index is shifted $index bytes");

}, "Test generic binary data";

#-------------------------------------------------------------------------------
# Binary object. UUID binary
#
subtest {
  my UUID $uuid .= new: version => 4;

  my BSON::Binary $bin-obj .= new(
    data => $uuid.Blob,
    type => $BSON::UUID
  );

  is-deeply( $bin-obj.Buf, $uuid.Blob, 'compare uuid binary data');

  my Array $bin-test = [ ( 0x10, 0x00, 0x00, 0x00,        # Size of buf
                           $BSON::UUID,                   # UUID binary type
                           $uuid.Blob.list,               # Raw Buf
                         ).flat
                       ];
  my Buf $enc-bin = $bin-obj.encode-binary;
  is-deeply( $enc-bin.Array, $bin-test, 'encode uuid test');

  my $index = 0;
  $bin-obj .= new;
  $bin-obj.decode-binary( $enc-bin.list, $index);
  is-deeply( $bin-obj.Buf.list,
             $uuid.Blob.list,
             'compare uuid data after decoding'
           );
  is( $index, $bin-test.elems, "Index is shifted $index bytes");
  is( $bin-obj.get-type, $BSON::UUID, "Test UUID type");

}, "Test uuid binary data";

#-------------------------------------------------------------------------------
# Binary object. MD5 binary
#
subtest {

  my Digest::MD5 $md5 .= new;
  my Buf $md5-b = $md5.md5_buf('Something I like to be md5-ed');
  my BSON::Binary $bin-obj .= new( data => $md5-b, type => $BSON::MD5);

  is-deeply( $bin-obj.Buf, $md5-b, 'compare md5 binary data');

  my Array $bin-test = [ ( 0x10, 0x00, 0x00, 0x00,        # Size of buf
                           $BSON::MD5,                    # MD5 binary type
                           $md5-b.list,                   # Raw Buf
                         ).flat
                       ];
  my Buf $enc-bin = $bin-obj.encode-binary;
  is-deeply( $enc-bin.Array, $bin-test, 'encode md5 test');

  my $index = 0;
  $bin-obj .= new;
  $bin-obj.decode-binary( $enc-bin.list, $index);
  is-deeply( $bin-obj.Buf.list,
             $md5-b.list,
             'compare md5 data after decoding'
           );
  is( $index, $bin-test.elems, "Index is shifted $index bytes");
  is( $bin-obj.get-type, $BSON::MD5, "Test MD5 type");

}, "Test md5 binary data";

#-------------------------------------------------------------------------------
# Test complete document encoding
#
subtest {
  my BSON::Bson $bson .= new;

  my %test = 
      %( decoded => { b => BSON::Binary.new(:data(Buf.new(^5))) },
         encoded => [ 0x12, 0x00, 0x00, 0x00,             # Total size
                      0x05,                               # Type
                      0x62, 0x00,                         # 'b' + 0
                      0x05, 0x00, 0x00, 0x00,             # Size of buf
                      0x00,                               # Generic binary type
                      0x00, 0x01, 0x02, 0x03, 0x04,       # Buf.new(^5)
                      0x00                                # + 0
                    ],
         type => 'Binary';
       );

  is-deeply
      $bson.encode(%test<decoded>).Array,
      %test<encoded>,
      "encode type {%test<type>}";

  $bson.init-index;
  is-deeply
      $bson.decode(Buf.new(%test<encoded>))<b>.Buf,
      %test<decoded><b>.Buf,
      "decode type {%test<type>}";

}, 'Test complete document encoding/decoding';

#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);
