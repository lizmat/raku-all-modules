use v6.c;
use Test;
use Algorithm::GooglePolylineEncoding;

plan 7;

my @tests = (
    { in => -179.9832104, out => '`~oia@' },
    { in => 38.5, out => '_p~iF' },
    { in => -120.2, out => '~ps|U' },
    { in => 2.2, out => '_ulL' },
    { in => -0.75, out => 'nnqC' },
    { in => 2.552, out => '_mqN' },
    { in => -5.503, out => 'vxq`@' }
);

for @tests -> %test-data {
    is encode-number( %test-data<in> ), %test-data<out>, "{%test-data<in>} encodes to {%test-data<out>}";
}
