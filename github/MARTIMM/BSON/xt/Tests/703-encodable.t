use v6;
use Test;
use BSON::EDC;

my Buf $doc = Buf.new(
  0x7c, 0x00 xx 3,              # Total size

  0x01,                         # Double       
  0x62, 0x00,                   # 'b' + 0      
  0x55, 0x55, 0x55, 0x55,       # Double 1/3   
  0x55, 0x55, 0xD5, 0x3F,

  0x01,                         # Double       
  0x63, 0x00,                   # 'c' + 0      
  0x7A, 0xDA, 0x1E, 0xB9,       # 12.3/2.456
  0x56, 0x08, 0x14, 0x40,

  0x01,                         # Double       
  0x64, 0x00,                   # 'd' + 0
  0x00, 0x00, 0x00, 0x00,       # Inf
  0x00, 0x00, 0xF0, 0x7F,

  0x01,                         # Double       
  0x65, 0x00,                   # 'e' + 0
  0x00, 0x00, 0x00, 0x00,       # -Inf
  0x00, 0x00, 0xF0, 0xFF,

  0x01,                         # Double       
  0x66, 0x00,                   # 'f' + 0      
  0x00, 0x00, 0x00, 0x00,       # 0
  0x00, 0x00, 0x00, 0x00,

  0x03,
  0x66, 0x66, 0x00,             # 'ff' + 0      
    0x3c, 0x00 xx 3,
    
    0x01,                       # Double       
    0x62, 0x00,                 # 'b' + 0      
    0x55, 0x55, 0x55, 0x55,     # Double 1/3   
    0x55, 0x55, 0xD5, 0x3F,

    0x01,                       # Double       
    0x63, 0x00,                 # 'c' + 0      
    0x7A, 0xDA, 0x1E, 0xB9,     # 12.3/2.456
    0x56, 0x08, 0x14, 0x40,

    0x01,                       # Double       
    0x64, 0x00,                 # 'd' + 0      
    0x00, 0x00, 0x00, 0x00,     # Inf
    0x00, 0x00, 0xF0, 0x7F,

    0x01,                       # Double       
    0x65, 0x00,                 # 'e' + 0      
    0x00, 0x00, 0x00, 0x00,     # -Inf
    0x00, 0x00, 0xF0, 0xFF,

    0x01,                       # Double       
    0x66, 0x00,                 # 'f' + 0      
    0x00, 0x00, 0x00, 0x00,     # 0
    0x00, 0x00, 0x00, 0x00,
    
    0x00,

  0x00                          # + 0          
);

my BSON::Encodable $e .= new;
my Hash $h = $e.decode($doc);
#say "H: ", $h.perl;

#is $e.bson_code, 0x01, 'Code = Double = 1';
ok $h<b>:exists, 'Var name "b" exists';
ok $h<c>:exists, 'Var name "c" exists';
ok $h<d>:exists, 'Var name "d" exists';
ok $h<e>:exists, 'Var name "e" exists';
ok $h<f>:exists, 'Var name "f" exists';
ok $h<ff>:exists, 'Var name "ff" exists';
ok $h<ff><b>:exists, 'Var name "ff/b" exists';
ok $h<ff><c>:exists, 'Var name "ff/c" exists';
ok $h<ff><d>:exists, 'Var name "ff/d" exists';
ok $h<ff><e>:exists, 'Var name "ff/e" exists';
ok $h<ff><f>:exists, 'Var name "ff/f" exists';

is $h<b>, Num(1/3), "Data of b is 1/3";
is $h<c>, Num(12.3/2.456), "Data of c is 12.3/2.456";
is $h<d>, Inf, "Data of d is Inf";
is $h<e>, -Inf, "Data of e is -Inf";
is $h<f>, 0, "Data of f is 0";
ok $h<ff> ~~ Hash, "Data of ff is Hash";



my Buf $b = $e.encode($h);
#say "B: ", $b;

# Elaborate encoded hashes/arrays cannot be compared!
#
is $doc.elems, $b.elems, 'Buffers have equal length';

# ???
# expected: {:b(0.333333333333333e0), :c(5.00814332247557e0), :d(Inf), :e(-Inf), :f(0e0), :ff({:b(0.333333333333333e0), :c(5.00814332247557e0), :d(Inf), :e(-Inf), :f(0e0)})}
#      got: {:b(0.333333333333333e0), :c(5.00814332247557e0), :d(Inf), :e(-Inf), :f(0e0), :ff({:b(0.333333333333333e0), :c(5.00814332247557e0), :d(Inf), :e(-Inf), :f(0e0)})}
#is-deeply $h, $e.decode($b), 'Decode results';

#-------------------------------------------------------------------------------
# Cleanup
#
done();
exit(0);


