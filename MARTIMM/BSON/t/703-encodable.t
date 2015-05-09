use v6;
use Test;
use BSON::EDC;

my Buf $doc = Buf.new( 0x10, 0x00, 0x00, 0x00,          # Total size    
                       0x01,                            # Double        
                       0x62, 0x00,                      # 'b' + 0       
                       0x55, 0x55, 0x55, 0x55,          # 8 byte double 
                       0x55, 0x55, 0xD5, 0x3F,
                       0x00                             # + 0           
                     );

my BSON::Encodable $e .= new;
my Hash $h = $e.decode($doc);
#say "H: ", $h.perl;

#is $e.bson_code, 0x01, 'Code = Double = 1';
ok $h<b>:exists, 'Var name "b" exists';
is $h<b>, Num(1/3), "Data is 1/3";

my Buf $b = $e.encode($h);
#say "B: ", $b;

is_deeply $doc.list, $b.list, 'Buffers are equal';

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);


