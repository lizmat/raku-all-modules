use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::IP;
use Net::BGP::CIDR;
use Net::BGP::Conversions;

my @TESTS := (
    { ip => '1.2.3.4', val => 16909060 },
);

for @TESTS -> $test {
    is ipv4-to-int($test<ip>), $test<val>, "$test<ip> ipv4-to-int";
    is int-to-ipv4($test<val>), $test<ip>, "$test<ip> int-to-ipv4";
    is int-to-ipv4(ipv4-to-int($test<ip>)), $test<ip>, "$test<ip> ipv4-to-int-to-ipv4";
    is ipv4-to-int(int-to-ipv4($test<val>)), $test<val>, "$test<ip> int-to-ipv4-to-int";
    is nuint32(ipv4-to-buf8($test<ip>)), $test<val>, "$test<ip> ipv4-to-buf8";
    is ip-valid($test<ip>), True, "$test<ip> ip-valid";
}

my @TESTS6 := (
    {
        ip        => '2001:db8::1',
        full      => '2001:0db8:0000:0000:0000:0000:0000:0001',
        val       => 42540766411282592856903984951653826561,
        compact   => '2001:db8::1',
        buf8      => ( 0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00,
                       0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 ),
        buf8-b64  => ( 0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00 ),
        buf8-c64  => '2001:db8::',
        buf8-b127 => ( 0x20, 0x01, 0x0d, 0xb8, 0x00, 0x00, 0x00, 0x00,
                       0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ),
        buf8-c127 => '2001:db8::',
    },
    {
        ip        => '2001:db8:0:2:3::1',
        full      => '2001:0db8:0000:0002:0003:0000:0000:0001',
        val       => 42540766411282592893798317524003061761,
        compact   => '2001:db8:0:2:3::1',
    },
    {
        ip        => '2001:db8:0:002:03::1',
        full      => '2001:0db8:0000:0002:0003:0000:0000:0001',
        val       => 42540766411282592893798317524003061761,
        compact   => '2001:db8:0:2:3::1',
    },
    {
        ip        => '2001:dB8:0:002:03::1',      # Note upper case B
        full      => '2001:0db8:0000:0002:0003:0000:0000:0001',
        val       => 42540766411282592893798317524003061761,
        compact   => '2001:db8:0:2:3::1',
    },
    {
        ip        => '2605:2700:0:3::4713:93e3',
        full      => '2605:2700:0000:0003:0000:0000:4713:93e3',
        val       => 50537416338094019778974086937420469219,
        compact   => '2605:2700:0:3::4713:93e3',
    },
    {
        ip        => '::',
        full      => '0000:0000:0000:0000:0000:0000:0000:0000',
        val       => 0,
        compact   => '::',
        buf8      => ( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                       0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ),
        buf8-b64  => ( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ),
        buf8-c64  => '::',
        buf8-b127 => ( 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                       0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ),
        buf8-c127 => '::',
    },
);

for @TESTS6 -> $test {
    is ipv6-expand($test<ip>), $test<full>, "$test<ip> ipv6-expand";
    is ipv6-expand($test<full>), $test<full>, "$test<ip> ipv6-expand (full)";
    is ipv6-to-int($test<ip>), $test<val>, "$test<ip> ipv6-to-int";
    is ipv6-compact($test<ip>), $test<compact>, "$test<ip> ipv6-compact";
    is int-to-ipv6($test<val>), $test<compact>, "$test<ip> int-to-ipv6";
    is ip-valid($test<ip>), True, "$test<ip> ip-valid";

    my $buf = ipv6-to-buf8($test<ip>);
    if $test<buf8>:exists {
        is $buf.bytes, $test<buf8>.elems, "$test<ip> ipv6-to-buf-length";
        for ^16 -> $byte {
            is $buf[$byte], $test<buf8>[$byte], "$test<ip> $byte ipv6-to-buf8";
        }
    }
    is buf8-to-ipv6($buf), $test<compact>, "$test<ip> buf8-to-ipv6";

    $buf = ipv6-to-buf8($test<ip>, :0bits);
    is $buf.bytes, 0, "$test<ip>/0 ipv6-to-buf-length";
    is buf8-to-ipv6($buf, :0bits), '::', "$test<ip>/0 buf8-to-ipv6";
    
    $buf = ipv6-to-buf8($test<ip>, :64bits);
    if $test<buf8-64>:exists {
        is $buf.bytes, $test<buf8-b64>.elems, "$test<ip>/64 ipv6-to-buf-length";
        for ^8 -> $byte {
            is $buf[$byte], $test<buf8-b64>[$byte], "$test<ip>/64 $byte ipv6-to-buf8";
        }
    }
    if $test<buf8-c64>:exists {
        is buf8-to-ipv6($buf, :64bits), $test<buf8-c64>, "$test<ip>/64 buf8-to-ipv6";
    }

    $buf = ipv6-to-buf8($test<ip>, :127bits);
    if $test<buf8-b127>:exists {
        is $buf.bytes, $test<buf8-b127>.elems, "$test<ip>/127 ipv6-to-buf-length";
        for ^16 -> $byte {
            is $buf[$byte], $test<buf8-b127>[$byte], "$test<ip>/127 $byte ipv6-to-buf8";
        }
    }
    if $test<buf8-c127>:exists {
        is buf8-to-ipv6($buf, :127bits), $test<buf8-c127>, "$test<ip>/127 buf8-to-ipv6";
    }

}

my @TESTS-CANNONICAL := (
    {
        ip         => '2001:db8::1',
        cannonical => '2001:db8::1',
    },
    {
        ip         => '2001:db8:0::0:1',
        cannonical => '2001:db8::1',
    },
    {
        ip         => '::ffff:192.0.2.1',
        cannonical => '192.0.2.1',
    },
    {
        ip         => '::FFFF:192.0.2.1',
        cannonical => '192.0.2.1',
    },
    {
        ip         => '192.0.2.1',
        cannonical => '192.0.2.1',
    },
    {
        ip         => '::',
        cannonical => '::',
    },
    {
        ip         => '127.0.0.1',
        cannonical => '127.0.0.1',
    },
    {
        ip         => '::ffff:127.0.0.1',
        cannonical => '127.0.0.1',
    },
);

for @TESTS-CANNONICAL -> $test {
    is ip-cannonical($test<ip>), $test<cannonical>, "$test<ip> ip-cannonical";
    is ip-cannonical(ip-cannonical($test<ip>)), $test<cannonical>, "$test<ip> ip-cannonical²";
}

my @TESTS-INVALID := (
    '1920.0.2.1',
    '1::2::3',
    '2001:db8:g::1',
);

for @TESTS-INVALID -> $test {
    is ip-valid($test), False, "$test ip-valid (invalid)";
}

subtest 'IPv4 CIDRs', {
    my @CIDRS := «
        0.0.0.0/0
        10.0.0.0/8
        10.0.0.0/24
        192.0.2.4/30
        255.255.255.255/32
    »;

        is Net::BGP::CIDR.from-int(0, 0).Str,          "0.0.0.0/0",  "CIDR 0.0.0.0/24";
        is Net::BGP::CIDR.from-int((10 +< 24), 8).Str, "10.0.0.0/8", "CIDR 10.0.0.0/8";

    for @CIDRS -> $cidr {
        is Net::BGP::CIDR.from-str($cidr).Str, $cidr, "CIDR $cidr maps to CIDR";
    }

    dies-ok { Net::BGP::CIDR.from-str('0.0.0.0/a') },    "CIDR 0.0.0.0/a dies ok";
    dies-ok { Net::BGP::CIDR.from-str('192.0.2.1/33') }, "CIDR 192.0.2.1/33 dies ok";
   
    todo "Regex matching is slow...fix lib/Net/BGP/IP.pm6"; 
    dies-ok { Net::BGP::CIDR.from-str('3/29') },         "CIDR 3/29 dies ok";

    my $buf = buf8.new(24, 192, 168, 1);
    my $res = Net::BGP::CIDR.packed-to-array($buf);
    is $res.elems,  1,                "Test 1 - Count Correct";
    is $res[0].Str, "192.168.1.0/24", "Test 1 - String Correct";

    $buf = buf8.new(23, 192, 168, 1);
    $res = Net::BGP::CIDR.packed-to-array($buf);
    is $res.elems,  1,                "Test 2 - Count Correct";
    is $res[0].Str, "192.168.0.0/23", "Test 2 - String Correct";

    $buf = buf8.new(0);
    $res = Net::BGP::CIDR.packed-to-array($buf);
    is $res.elems,  1,           "Test 3 - Count Correct";
    is $res[0].Str, "0.0.0.0/0", "Test 3 - String Correct";

    $buf = buf8.new(32, 255, 255, 255, 255);
    $res = Net::BGP::CIDR.packed-to-array($buf);
    is $res.elems,  1,                    "Test 4 - Count Correct";
    is $res[0].Str, "255.255.255.255/32", "Test 4 - String Correct";

    $buf = buf8.new(32, 255, 255, 255, 255, 24, 192, 168, 1);
    $res = Net::BGP::CIDR.packed-to-array($buf);
    is $res.elems,  2,                    "Test 5 - Count Correct";
    is $res[0].Str, "255.255.255.255/32", "Test 5a - String Correct";
    is $res[1].Str, "192.168.1.0/24",     "Test 5b - String Correct";

    my $net = 0;
    for @CIDRS -> $cidr {
        my $c1 = Net::BGP::CIDR.from-int(0,0);
        my $c2 = Net::BGP::CIDR.from-str($cidr);
        is $c1.contains($c2), True, "0.0.0.0/0 contains {$cidr.Str}";
        
        $c1 = Net::BGP::CIDR.from-int(0,32);
        is $c1.contains($c2), False, "0.0.0.0/32 does not contain {$cidr.Str}";
    }

    my $src = Net::BGP::CIDR.from-str('4.2.2.0/24');
    my $dst = Net::BGP::CIDR.from-str('4.2.2.0/24');
    is $src.contains($dst), True, "{$src.Str} contains {$src.Str}";

    $src = Net::BGP::CIDR.from-str('4.2.2.0/32');
    $dst = Net::BGP::CIDR.from-str('4.2.2.0/24');
    is $src.contains($dst), False, "{$src.Str} does not contain {$src.Str}";

    $src = Net::BGP::CIDR.from-str('4.2.2.0/24');
    $dst = Net::BGP::CIDR.from-str('4.2.2.0/32');
    is $src.contains($dst), True, "{$src.Str} contains {$src.Str}";

    $src = Net::BGP::CIDR.from-str('4.2.2.0/24');
    $dst = Net::BGP::CIDR.from-str('4.2.2.0/31');
    is $src.contains($dst), True, "{$src.Str} contains {$src.Str}";

    done-testing;
}


subtest 'IPv6 CIDRs', {
    my @CIDRS :=
        '::/0',
        '2001:db8::/32',
        '2001:db8:1234::/48',
        '2001:db8:4321::ff00/120',
        'ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128',
    ;

        is Net::BGP::CIDR.from-int(0, 0, 6).Str, "::/0",  "CIDR ::/0";
        is Net::BGP::CIDR.from-int((0x2001 +< 112), 16, 6).Str, "2001::/16",
            "CIDR 2001::/16";

    for @CIDRS -> $cidr {
        is Net::BGP::CIDR.from-str($cidr).Str, $cidr, "CIDR $cidr maps to CIDR";
    }

    my @BAD-CIDRS := «
        ::/a
        2001:db8::/129
        2001:/16
    »;

    for @BAD-CIDRS -> $cidr {
        dies-ok { Net::BGP::CIDR.from-str($cidr) }, "CIDR $cidr dies ok";
    }

    my $buf = buf8.new(16, 0x20, 0x01);
    my $res = Net::BGP::CIDR.packed-to-array($buf, 6);
    is $res.elems,  1,                "Test 1 - Count Correct";
    is $res[0].Str, "2001::/16",       "Test 1 - String Correct";

    $buf = buf8.new(127,
        0x20, 0x01, 0x0d, 0xb8,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x02
    );
    $res = Net::BGP::CIDR.packed-to-array($buf, 6);
    is $res.elems,  1,                 "Test 2 - Count Correct";
    is $res[0].Str, "2001:db8::2/127", "Test 2 - String Correct";

    $buf = buf8.new(0);
    $res = Net::BGP::CIDR.packed-to-array($buf, 6);
    is $res.elems,  1,      "Test 3 - Count Correct";
    is $res[0].Str, "::/0", "Test 3 - String Correct";

    $buf = buf8.new(128,
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
    );
    $res = Net::BGP::CIDR.packed-to-array($buf, 6);
    is $res.elems,  1,                    "Test 4 - Count Correct";
    is $res[0].Str, "ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff/128",
        "Test 4 - String Correct";

    $buf = buf8.new(32, 0x20, 0x01, 0x0d, 0xb8, 3, 0x20);
    $res = Net::BGP::CIDR.packed-to-array($buf, 6);
    is $res.elems,  2,                    "Test 5 - Count Correct";
    is $res[0].Str, "2001:db8::/32", "Test 5a - String Correct";
    is $res[1].Str, "2000::/3",      "Test 5b - String Correct";

    my $net = 0;
    for @CIDRS -> $cidr {
        my $c1 = Net::BGP::CIDR.from-int(0,0,6);
        my $c2 = Net::BGP::CIDR.from-str($cidr);
        is $c1.contains($c2), True, "::/0 contains {$cidr.Str}";
        
        $c1 = Net::BGP::CIDR.from-int(0,128,6);
        is $c1.contains($c2), False, "::/128 does not contain {$cidr.Str}";
    }

    my $src = Net::BGP::CIDR.from-str('2001:db8::/32');
    my $dst = Net::BGP::CIDR.from-str('2001:db8::/32');
    is $src.contains($dst), True, "{$src.Str} contains {$src.Str}";

    $src = Net::BGP::CIDR.from-str('2001:db8::/48');
    $dst = Net::BGP::CIDR.from-str('2001:db8::/32');
    is $src.contains($dst), False, "{$src.Str} does not contain {$src.Str}";

    $src = Net::BGP::CIDR.from-str('2001:db8::/32');
    $dst = Net::BGP::CIDR.from-str('2001:db8::/48');
    is $src.contains($dst), True, "{$src.Str} contains {$src.Str}";

    $src = Net::BGP::CIDR.from-str('2001:db8::/32');
    $dst = Net::BGP::CIDR.from-str('2001:db8::/127');
    is $src.contains($dst), True, "{$src.Str} contains {$src.Str}";

    done-testing;
}

subtest 'Misc. Tests' => {
    is buf8-to-ipv4(192, 0, 2, 1), '192.0.2.1', "buf8-to-ipv4 returns good value";
}


done-testing;

