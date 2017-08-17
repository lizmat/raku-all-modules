use v6;
use Test;

use BSON::ObjectId;

#-------------------------------------------------------------------------------
subtest {

  throws-like
    { my BSON::ObjectId $o .= new(:string<67ab4550>); },
    X::BSON, 'Too short oid string',
    :message(/:s String too short or nonhexadecimal/);

  throws-like
    { my BSON::ObjectId $o .= new(:string<Vbghu7988798Vbghu7988798>); },
    X::BSON, 'Nonhexadecimal',
    :message(/:s String too short or nonhexadecimal/);

  my BSON::ObjectId $o .= new(:string<0babc7988798abcde7988798>);
  is $o.oid.elems, 12, 'Properly defined string';

  throws-like
    { my BSON::ObjectId $o .= new(:bytes(Buf.new(5,7,9...15))); },
    X::BSON, 'Too short/long byte buffer',
    :message(/:s Byte buffer too short or long/);

  $o .= new(
    :bytes(
      Buf.new(
        0x0b, 0xab, 0xc7, 0x98, 0x87, 0x98, 0xab, 0xcd, 0xe7, 0x98, 0x87, 0x98,
#        0x0b, 0xab, 0xc7, 0x98, 0x87, 0x98, 0xab, 0xcd, 0xe7, 0x98, 0x87, 0x98
      )
    )
  );
  is $o.oid.elems, 12, 'Properly defined byte buffer';

  $o .= new( :machine-name('my-pc'), :count(234));
  is $o.oid.elems, 12, 'Properly defined machine name and count';

  $o .= new( );
  is $o.oid.elems, 12, 'Properly defined with defaults';

}, 'Object id testing';

#-------------------------------------------------------------------------------
subtest {

  my $time = time;
  my BSON::ObjectId $o .= new;

  is $o.oid.elems, 12, 'Length oid ok';
  ok $time <= $o.time <= $time + 1, 'Time between this and the next second';
  is $o.pid, $*PID, "Process is $*PID";

}, 'Object id encoding/decoding';

#-------------------------------------------------------------------------------
# Cleanup
#
done-testing();
exit(0);
