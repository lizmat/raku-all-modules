use v6.c;
use Test;

#
# Copyright © 2018 Joelle Maslak
# See License 
#

use Net::Netmask;

my @tests =
    {
        input   => '0.0.0.0',
        desc    => '0.0.0.0/32',
        base    => '0.0.0.0',
        mask    => '255.255.255.255',
        hmask   => '0.0.0.0',
        bcast   => '0.0.0.0',
        next    => '0.0.0.1/32',
        prev    => Nil,
        bits    => 32,
        size    => 1,
        int     => 0,
        match   => ( '0.0.0.0' => 0 ),
        nomatch => [ '0.0.0.1', '10.0.0.0', '255.255.255.255' ],
    },
    {
        input   => '0.0.0.0/0',
        desc    => '0.0.0.0/0',
        base    => '0.0.0.0',
        mask    => '0.0.0.0',
        hmask   => '255.255.255.255',
        bcast   => '255.255.255.255',
        next    => Nil,
        prev    => Nil,
        bits    => 0,
        size    => 2³²,
        int     => 0,
        match   => [ '0.0.0.0' => 0, '0.0.0.1' => 1, '10.0.0.0' => 10*2²⁴, '255.255.255.255' => 2³²-1 ],
        nomatch => [ ],
    },
    {
        input   => '192.168.75.8',
        desc    => '192.168.75.8/32',
        base    => '192.168.75.8',
        mask    => '255.255.255.255',
        hmask   => '0.0.0.0',
        bcast   => '192.168.75.8',
        next    => '192.168.75.9/32',
        prev    => '192.168.75.7/32',
        bits    => 32,
        size    => 1,
        int     => 0xc0a84b08,
        match   => [ ],
        nomatch => [ '0.0.0.0', '0.0.0.1', '10.0.0.0', '255.255.255.255' ],
    },
    {
        input   => '192.168.75.8/29',
        desc    => '192.168.75.8/29',
        base    => '192.168.75.8',
        mask    => '255.255.255.248',
        hmask   => '0.0.0.7',
        bcast   => '192.168.75.15',
        next    => '192.168.75.16/29',
        prev    => '192.168.75.0/29',
        bits    => 29,
        size    => 8,
        int     => 0xc0a84b08,
        match   => [ '192.168.75.8' => 0, '192.168.75.10' => 2, '192.168.75.15' => 7 ],
        nomatch => [ '0.0.0.0', '0.0.0.1', '10.0.0.0', '192.168.75.16', '255.255.255.255' ],
    },
    {
        input   => '255.255.255.255/32',
        desc    => '255.255.255.255/32',
        base    => '255.255.255.255',
        mask    => '255.255.255.255',
        hmask   => '0.0.0.0',
        bcast   => '255.255.255.255',
        next    => Nil,
        prev    => '255.255.255.254/32',
        bits    => 32,
        size    => 1,
        int     => 0xffffffff,
        match   => [ '255.255.255.255' => 0 ],
        nomatch => [ '0.0.0.0', '0.0.0.1', '10.0.0.0', '192.168.75.16' ],
    };

for @tests -> $test {
    my $net = Net::Netmask.new( $test<input> );

    is ~$net, $test<desc>, "Stringification (1) of $test<input>";
    is $net.Str, $test<desc>, "Stringification (2) of $test<input>";
    is $net.desc, $test<desc>, "desc of $test<input>";
    
    is $net.first, $test<base>, "first of $test<input>";
    is $net.base, $test<base>, "base of $test<input>";
    is $net.mask, $test<mask>, "mask of $test<input>";

    is $net.hostmask, $test<hmask>, "hostmask of $test<input>";
    is $net.broadcast, $test<bcast>, "broadcast of $test<input>";
    is $net.last, $test<bcast>, "last of $test<input>";

    is $net.bits, $test<bits>, "bits of $test<input>";
    is $net.size, $test<size>, "size of $test<input>";

    is $net.Numeric, $test<int>, "Numeric of $test<input>";
    is $net.Int,     $test<int>, "Int of $test<input>";

    if defined $test<next> {
        is $net.next, $test<next>, "next of $test<input>";
        is $net.succ, $test<next>, "succ of $test<input>";
    } else {
        dies-ok { $net.next }, "next of $test<input>";
        dies-ok { $net.succ }, "succ of $test<input>";
    }

    if defined $test<prev> {
        is $net.prev, $test<prev>, "prev of $test<input>";
        is $net.pred, $test<prev>, "pred of $test<input>";
    } else {
        dies-ok { $net.prev }, "prev of $test<input>";
        dies-ok { $net.pred }, "pred of $test<input>";
    }

    my $net2 = Net::Netmask.new( $test<base>, $test<mask> );
    is ~$net2, ~$net, "Construction $test<base> via 2 parameter new";

    $net2 = Net::Netmask.new( "$test<base> $test<mask>" );
    is ~$net2, ~$net, "Construction $test<base> via 1 parameter new with netmask";

    $net2 = Net::Netmask.new( :address($test<base>) :netmask($test<mask>) );
    is ~$net2, ~$net, "Construction $test<base> via 2 named parameter new";

    is $net.match($test<base>), 0, "Match test of $test<desc> for $test<base>";
    for @($test<match>) -> $match {
        is $net.match($match.key), $match.value, "Match test of $test<desc> for $match.key";
    }

    my $n = $net;
    if defined $test<next> {
        $n++;
        is $n, $test<next>, "++ of $test<input>";
    } else {
        dies-ok { $n++ }, "++ of $test<input>";
    }

    my $p = $net;
    if defined $test<prev> {
        $p--;
        is $p, $test<prev>, "-- of $test<input>";
    } else {
        dies-ok { $p-- }, "-- of $test<input>";
    }

    is ip2dec($test<base>), $test<int>,  "ip2dec conversion";
    is dec2ip($test<int>),  $test<base>, "dec2ip conversion";
}

#IPv4 range 0 to 4294967295
throws-like { dec2ip(-1) },    Exception, message => 'not in IPv4 range 0-4294967295';
throws-like { dec2ip(2**32) }, Exception, message => 'not in IPv4 range 0-4294967295';

my $obj = Net::Netmask.new('0.0.0.0/0');
is $obj.enumerate[1024], '0.0.4.0', '0.0.0.0/0 enumerate[1024] = 0.0.4.0';

@tests =
    {
        input    => '0.0.0.0/32',
        output24 => «0.0.0.0»,
        output28 => «0.0.0.0»,
        output32 => «0.0.0.0»,
        nth0     => «0.0.0.0»,
        nth1     => Nil,
        nth256   => Nil,
    },
    {
        input    => '1.0.0.0/32',
        output24 => «1.0.0.0»,
        output28 => «1.0.0.0»,
        output32 => «1.0.0.0»,
        nth0     => «1.0.0.0»,
        nth1     => Nil, 
        nth2     => Nil, 
    },
    {
        input    => '10.20.9.0/24',
        output24 => «10.20.9.0»,
        output28 => ( 0,16,32...240 ).map( { "10.20.9.$^a" } ),
        output32 => (^256).map( { "10.20.9.$^a" } ),
        nth0     => «10.20.9.0»,
        nth1     => «10.20.9.1»,
        nth2     => «10.20.9.255»,
    }
;

for @tests -> $test {
    my $net = Net::Netmask.new( $test<input> );

    is $net.enumerate, $test<output32>, "$test<input> /32 Enumerations";
    is $net.enumerate :28bit, $test<output28>, "$test<input> /28 Enumerations";
    is $net.enumerate :24bit, $test<output24>, "$test<input> /24 Enumerations";

    $test<net_output32> = $test<output32>.map( { "$^a/32" } );
    $test<net_output28> = $test<output28>.map( { "$^a/28" } );
    $test<net_output24> = $test<output24>.map( { "$^a/24" } );

    is $net.enumerate :nets,         $test<net_output32>, "$test<input> /32 Net Enumerations";
    is $net.enumerate(:28bit :nets), $test<net_output28>, "$test<input> /28 Net Enumerations";
    is $net.enumerate(:24bit :nets), $test<net_output24>, "$test<input> /24 Net Enumerations";

    is $net.nth(0), $test<nth0>, "$test<input> nth0";
    is $net.nth(0, :32bit), $test<nth0>, "$test<input> nth0 2 Param";
    is $net.nth(0, :32bit, :nets), "$test<nth0>/32", "$test<input> nth0 /32 nets";

    if defined $net.nth(1) {
        is $net.nth(1), $test<nth1>, "$test<input> nth1";
        is $net.nth(1, :32bit), $test<nth1>, "$test<input> nth1 2 Param";
        is $net.nth(1, :32bit, :nets), "$test<nth1>/32", "$test<input> nth1 /32 nets";
    } else {
        dies-ok { $net.nth(1) }, "$test<input> nth1";
        dies-ok { $net.nth(1, :32bit) }, "$test<input> nth1 2 Param";
        dies-ok { $net.nth(1, :32bit, :nets) }, "$test<input> nth1 /32 nets";
    }

    if defined $net.nth(256) {
        is $net.nth(256), $test<nth1>, "$test<input> nth256";
        is $net.nth(256, :32bit), $test<nth256>, "$test<input> nth256 2 Param";
        is $net.nth(256, :32bit, :nets), "$test<nth256>/32", "$test<input> nth256 /32 nets";
    } else {
        dies-ok { $net.nth(256) }, "$test<input> nth256";
        dies-ok { $net.nth(256, :32bit) }, "$test<input> nth256 2 Param";
        dies-ok { $net.nth(256, :32bit, :nets) }, "$test<input> nth256 /32 nets";
    }
}

subtest "nth large" => {
    my $net0_1 = Net::Netmask.new( '0.0.0.0/1' );
    is $net0_1.nth(65535), '0.0.255.255', '0.0.0.0/1 nth65535 /15';
    is $net0_1.nth(0, :15bit), '0.0.0.0', '0.0.0.0/1 nth0 /15';
    is $net0_1.nth(0, :15bit, :nets), '0.0.0.0/15', '0.0.0.0/1 nth0 /15 nets';
    is $net0_1.nth(2, :15bit), '0.4.0.0', '0.0.0.0/1 nth2 /15';
    is $net0_1.nth(2, :15bit, :nets), '0.4.0.0/15', '0.4.0.0/1 nth0 /15 nets';

    my $net0_0 = Net::Netmask.new( '0.0.0.0/0' );
    is $net0_0.nth(65535), '0.0.255.255', '0.0.0.0/0 nth65535 /15';
    is $net0_0.nth(0, :15bit), '0.0.0.0', '0.0.0.0/0 nth0 /15';
    is $net0_0.nth(0, :15bit, :nets), '0.0.0.0/15', '0.0.0.0/0 nth0 /15 nets';
    is $net0_0.nth(2, :15bit), '0.4.0.0', '0.0.0.0/0 nth2 /15';
    is $net0_0.nth(2, :15bit, :nets), '0.4.0.0/15', '0.4.0.0/0 nth0 /15 nets';
}

subtest "nth example" => {
    my $net0_1 = Net::Netmask.new( '0.0.0.0/1' );
    dies-ok { $net0_1.nth(2³²) }, 'Too big throws exception';

    # Tests based on examples in POD
    my $net192 = Net::Netmask.new('192.168.75.8/29');
    is $net192.nth(3), '192.168.75.11', '192.168.75.8 nth3';
    dies-ok { $net192.nth(3, :30bit) }, '192.168.75.8 nth3 /30';
    is $net192.nth(^2, :30bit), «192.168.75.8 192.168.75.12», '192.168.75.8 nth ^2';
    is $net192.nth(^2, :30bit :nets), «192.168.75.8/30 192.168.75.12/30», '192.168.75.8 nth ^2 nets';
    is $net192.nth(^2, :30bit :nets)».nth(^2),
        («192.168.75.8 192.168.75.9»,«192.168.75.12 192.168.75.13»),
        '192.168.75.8 nth ^2 x ^2';
}

done-testing;

