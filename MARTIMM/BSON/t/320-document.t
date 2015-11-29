use v6;
use Test;
use BSON::Document;
use BSON::Javascript;
use BSON::Binary;
use BSON::ObjectId;
use BSON::Regex;
use UUID;

#-------------------------------------------------------------------------------
subtest {

  my BSON::Javascript $js .= new(
    :javascript('function(x){return x;}')
  );

  my BSON::Javascript $js-scope .= new(
    :javascript('function(x){return x;}'),
    :scope(BSON::Document.new: (nn => 10, a1 => 2))
  );

  my UUID $uuid .= new(:version(4));
  my BSON::Binary $bin .= new(
    :data($uuid.Blob),
    :type(BSON::C-UUID)
  );

  my BSON::ObjectId $oid .= new;

  my DateTime $datetime .= now;

  my BSON::Regex $rex .= new( :regex('abc|def'), :options<is>);

  # Checklist/Tests of
  #
  # 0x01 Double
  # 0x02 String
  # 0x03 Document
  # 0x04 Array
  # 0x05 Binary
  # 0x06 -
  # 0x07 ObjectId
  # 0x08 Boolean
  # 0x09 Date and time
  # 0x0A Null value
  # 0x0B Regex
  # 0x0C -
  # 0x0D Javascript
  # 0x0E -
  # 0x0F Javascript with scope
  # 0x10 int32
  # 0x11 -
  # 0x12 int64
  #
  my BSON::Document $d .= new;

  # Filling with data
  #
  $d<b> = -203.345.Num;
  $d<a> = 1234;
  $d<v> = 4295392664;
  $d<w> = $js;
  $d<abcdef> = a1 => 10, bb => 11;
  $d<abcdef><b1> = q => 255;
  $d<jss> = $js-scope;
  $d<bin> = $bin;
  $d<bf> = False;
  $d<bt> = True;
  $d<str> = "String text";
  $d<array> = [ 10, 'abc', 345];
  $d<oid> = $oid;
  $d<dtime> = $datetime;
  $d<null> = Any;
  $d<rex> = $rex;

  # Handcrafted encoded BSON data
  #
  my Buf $etst = Buf.new(
    # 310 (4 + 11 + 7 + 11 + 30 + 45 + 53 + 26 + 5 + 5 + 21 + 37
    #      + 17 + 15 + 6 + 16 + 1)
    0x36, 0x01, 0x00, 0x00,                     # Size document

    # 11
    BSON::C-DOUBLE,                             # 0x01
      0x62, 0x00,                               # 'b'
      0xd7, 0xa3, 0x70, 0x3d,                   # -203.345
      0x0a, 0x6b, 0x69, 0xc0,

    # 7
    BSON::C-INT32,                              # 0x10
      0x61, 0x00,                               # 'a'
      0xd2, 0x04, 0x00, 0x00,                   # 1234

    # 11
    BSON::C-INT64,                              # 0x12
      0x76, 0x00,                               # 'v'
      0x98, 0x7d, 0x06, 0x00,                   # 4295392664
      0x01, 0x00, 0x00, 0x00,

    # 30
    BSON::C-JAVASCRIPT,                         # 0x0D
      0x77, 0x00,                               # 'w'
      0x17, 0x00, 0x00, 0x00,                   # 23 bytes js code + 1
      0x66, 0x75, 0x6e, 0x63, 0x74, 0x69,       # UTF8 encoded Javascript
      0x6f, 0x6e, 0x28, 0x78, 0x29, 0x7b,       # 'function(x){return x;}'
      0x72, 0x65, 0x74, 0x75, 0x72, 0x6e,
      0x20, 0x78, 0x3b, 0x7d, 0x00,

    # 45 (37 + 8)
    BSON::C-DOCUMENT,                           # 0x03
      0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x00, # 'abcdef'

      # 37 (4 + 8 + 8 + 16 + 1)
      0x25, 0x00, 0x00, 0x00,                   # Size nested document

      # 8
      BSON::C-INT32,                            # 0x10
        0x61, 0x31, 0x00,                       # 'a1'
        0x0a, 0x00, 0x00, 0x00,                 # 10

      # 8
      BSON::C-INT32,                            # 0x10
        0x62, 0x62, 0x00,                       # 'bb'
        0x0b, 0x00, 0x00, 0x00,                 # 11

      # 16 (12 + 4)
      BSON::C-DOCUMENT,                         # 0x03
        0x62, 0x31, 0x00,                       # 'b1'

        # 12 (4 + 7 + 1)
        0x0c, 0x00, 0x00, 0x00,                 # Size nested document

        # 7
        BSON::C-INT32,                          # 0x10
          0x71, 0x00,                           # 'q'
          0xff, 0x00, 0x00, 0x00,               # 255

        # 1
        0x00,                                   # End nested document

      # 1
      0x00,                                     # End nested document

    # 53 (32 + 21)
    BSON::C-JAVASCRIPT-SCOPE,                   # 0x0F
      0x6a, 0x73, 0x73, 0x00,                   # 'jss'
      0x17, 0x00, 0x00, 0x00,                   # 23 bytes js code + 1
      0x66, 0x75, 0x6e, 0x63, 0x74, 0x69,       # UTF8 encoded Javascript
      0x6f, 0x6e, 0x28, 0x78, 0x29, 0x7b,       # 'function(x){return x;}'
      0x72, 0x65, 0x74, 0x75, 0x72, 0x6e,
      0x20, 0x78, 0x3b, 0x7d, 0x00,

      # 21                                      # No key encoded
                                                # No BSON::C-DOCUMENT# code

        # 21 (4 + 8 + 8 + 1)
        0x15, 0x00, 0x00, 0x00,                 # Size nested document

        # 8
        BSON::C-INT32,                          # 0x10
          0x6e, 0x6e, 0x00,                     # 'nn'
          0x0a, 0x00, 0x00, 0x00,               # 10

        # 8
        BSON::C-INT32,                          # 0x10
          0x61, 0x31, 0x00,                     # 'a1'
          0x02, 0x00, 0x00, 0x00,               # 2

        # 1
        0x00,                                   # End nested document

    # 26
    BSON::C-BINARY,                             # 0x05
      0x62, 0x69, 0x6e, 0x00,                   # 'bin'
      BSON::C-UUID-SIZE, 0x00, 0x00, 0x00,      # UUID size
      BSON::C-UUID,                             # Binary type = UUID
      $uuid.Blob.List,                          # Binary Data

    # 5
    BSON::C-BOOLEAN,                            # 0x08
      0x62, 0x66, 0x00,                         # 'bf'
      0x00,                                     # False

    # 5
    BSON::C-BOOLEAN,                            # 0x08
      0x62, 0x74, 0x00,                         # 'bt'
      0x01,                                     # True

    # 21 (5 + 16)
    BSON::C-STRING,                             # 0x02
      0x73, 0x74, 0x72, 0x00,                   # 'str'

      # 16 (4 + 12)
      0x0c, 0x00, 0x00, 0x00,                   # String size
      0x53, 0x74, 0x72, 0x69, 0x6e, 0x67,       # 'String text'
      0x20, 0x74, 0x65, 0x78, 0x74, 0x00,

    # 37 (7 + 30)
    BSON::C-ARRAY,                              # 0x04
      0x61, 0x72, 0x72, 0x61, 0x79, 0x00,       # 'array'

      # 30 (4 + 7 + 11 + 7 + 1)
      0x1e, 0x00, 0x00, 0x00,                   # Size array document

        # 7
        BSON::C-INT32,                          # 0x10
          0x30, 0x00,                           # '0'
          0x0a, 0x00, 0x00, 0x00,               # 10

        # 11 (3 + 8)
        BSON::C-STRING,                         # 0x02
          0x31, 0x00,                           # '1'

          # 8 (4 + 4)
          0x04, 0x00, 0x00, 0x00,               # String size
          0x61, 0x62, 0x63, 0x00,               # 'abc'

        # 7
        BSON::C-INT32,                          # 0x10
          0x32, 0x00,                           # '2'
          0x59, 0x01, 0x00, 0x00,               # 345

        # 1
        0x00,                                   # End array document

    # 17
    BSON::C-OBJECTID,                           # 0x07
      0x6f, 0x69, 0x64, 0x00,                   # 'oid'
      $oid.oid.List,

    # 15
    BSON::C-DATETIME,                           # 0x09
      0x64, 0x74, 0x69, 0x6d, 0x65, 0x00,       # 'dtime'
      local-encode-int64($datetime.posix).List, # time

    # 6
    BSON::C-NULL,                               # 0x0A
      0x6e, 0x75, 0x6c, 0x6c, 0x00,             # 'null'

    # 16
    BSON::C-REGEX,                              # 0x0B
      0x72, 0x65, 0x78, 0x00,                   # 'rex'
      0x61, 0x62, 0x63, 0x7c,                   # 'abc|def' regex
      0x64, 0x65, 0x66, 0x00,
      0x69, 0x73, 0x00,                         # 'is' options

    # 1
    0x00                                        # End document
  );

  # Encode document and compare with handcrafted byte array
  #
  my Buf $edoc = $d.encode;
  is-deeply $edoc, $etst, 'Encoded document is correct';

  # Fresh doc, load handcrafted data and decode into document
  #
  diag "Sequence of keys";

  $d .= new;
  $d.decode($etst);
  is $d<a>, 1234, "a => $d<a>, int32";
  is $d<b>, -203.345, "b => $d<b>, double";
  is $d<v>, 4295392664, "v => $d<v>, int64";

  is $d<w>.^name, 'BSON::Javascript', 'Javascript code on $d<w>';
  is $d<w>.javascript, 'function(x){return x;}', 'Code is same';

  is $d<abcdef><a1>, 10, "nest \$d<abcdef><a1> = $d<abcdef><a1>";
  is $d<abcdef><b1><q>, 255, "nest \$d<abcdef><b1><q> = $d<abcdef><b1><q>";

  is $d<jss>.^name, 'BSON::Javascript', 'Javascript code on $d<w>';
  is $d<jss>.javascript, 'function(x){return x;}', 'Code is same';
  is $d<jss>.scope<nn>, 10, "\$d<jss>.scope<nn> = {$d<jss>.scope<nn>}";

  is-deeply $d<bin>.binary-data.List, $uuid.Blob.List, "UUID binary data ok";
  is $d<bin>.binary-type, BSON::C-UUID, "Binary type is UUID";

  ok !?$d<bf>, "Boolean False";
  ok ?$d<bt>, "Boolean True";

  is $d<str>, 'String text', 'Text ok';

  is $d<array>[[1]], 'abc', 'A[[1]] = abc';
  is $d<array>[[2]], 345, 'A[[2]] = 345';

  is $d<oid>.oid.elems, 12, 'Length of object id ok';
  is $d<oid>.pid, $*PID, "Pid = $*PID";

  is $d<dtime>.Str, $datetime.Str, 'Date and time ok';

  nok $d<null>.defined, 'Null not defined';

  is $d<rex>.regex, 'abc|def', 'Regex ok';
  is $d<rex>.options, 'is', 'Regex options ok';

  # Test sequence
  #
  diag "Sequence of index";

  is $d[0], -203.345.Num, "0: $d[0], double";
  is $d[1], 1234, "1: $d[1], int32";
  is $d[2], 4295392664, "2: $d[2], int64";
  is $d[3].^name, 'BSON::Javascript', '3:Javascript code on $d<w>';
  is $d[4][0], 10, "4: nest 10";
  is $d[4][1], 11, "4: nest 11";
  is $d[4][2][0], 255, "4: subnest 255";
  is $d[5].javascript, 'function(x){return x;}', "5: '{$d[5].javascript}'";
  is $d[6].binary-type, BSON::C-UUID, "6: Binary type is UUID";
  ok !?$d[7], "7: Boolean False";
  ok ?$d[8], "8: Boolean True";
  is $d[9], 'String text', '9: Text ok';
  is $d[10][[1]], 'abc', '10: A[[1]] = abc';
  is $d[10][[2]], 345, '10: A[[2]] = 345';
  is $d[11].oid.elems, 12, '11: Length of object id ok';
  is $d[12].Str, $datetime.Str, '12: Date and time ok';
  nok $d[13].defined, '13: Null not defined';
  is $d[14].regex, 'abc|def', '14: Regex ok';
  is $d[14].options, 'is', '14: Regex options ok';

}, "Document encoding decoding types";

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);

#---------------------------------------------------------------------------
sub local-encode-int64 ( Int:D $i ) {
  # No tests for too large/small numbers because it is called from
  # _enc_element normally where it is checked
  #
  my int $ni = $i;
  return Buf.new(
    $ni +& 0xFF, ($ni +> 0x08) +& 0xFF,
    ($ni +> 0x10) +& 0xFF, ($ni +> 0x18) +& 0xFF,
    ($ni +> 0x20) +& 0xFF, ($ni +> 0x28) +& 0xFF,
    ($ni +> 0x30) +& 0xFF, ($ni +> 0x38) +& 0xFF
  );
}
