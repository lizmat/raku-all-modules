#!/usr/bin/perl6

use v6;

use Test;
use lib 'lib';

use NativeCall;
use Audio::OggVorbis::Ogg;

plan 15;

# cw: For now, we only test basic reading functions. More comprehensive tests
#     can be compiled, later.
my $s = ogg_sync_state.new();
isa-ok $s, ogg_sync_state, 'can create ogg_sync_state';

my ($ret, $page, $p, $b, $fh);

$ret = ogg_sync_init($s);
ok $ret == 0, 'can call ogg_sync_init';

$p = ogg_page.new();
isa-ok $p, ogg_page, 'can create ogg_page';

$ret = ogg_sync_pageout($s, $p);
ok $ret != 1, 'can call ogg_sync_pageout';

$b = ogg_sync_buffer($s, 4096);
isa-ok $b, CArray, 'can allocate buffer with ogg_sync_buffer';

$fh = open "test_data/SoundMeni.ogg", :bin;
my $data = $fh.read(4096);
for $data.subbuf(0).kv -> $i, $c { 
	$b[$i] = $c;
}
$ret = ogg_sync_wrote($s, 4096);
ok $ret == 0, 'read first block successfully and called ogg_sync_wrote';

my $count = 0;
repeat {
	$ret = ogg_sync_pageout($s, $p);
	last if $ret == 1;

	$b = ogg_sync_buffer($s, 4096);
	$data = $fh.read(4096);
	for $data.subbuf(0).kv -> $i, $c { 
		$b[$i] = $c;
	}
	$ret = ogg_sync_wrote($s, 4096);
	if ($ret != 0) {
			fail "ogg_sync_wrote returned error condition";
	}
	$ret = ogg_sync_pageout($s, $p);
} until $count++ > 15;
ok $count <= 15, "ogg_page filled after $count (<16) read loops";

my $sn = ogg_page_serialno($p);
ok $sn.defined, "retrieved serial number $sn from ogg_page_serialno";

$ret = ogg_page_bos($p);
ok $ret > 0, 'ogg_page at beginning of bitstream';

ok True, "size of ogg_stream_state: {nativesizeof(ogg_stream_state)}";

my $st = ogg_stream_state.new();
isa-ok $st, ogg_stream_state, 'can create ogg_stream_state';

$ret = ogg_stream_init($st, $sn);
ok $ret == 0, 'can initialize ogg_stream';

$ret = ogg_stream_pagein($st, $p);
ok $ret == 0, 'can write ogg_page to ogg_stream';

my $pkt = ogg_packet.new();
isa-ok $pkt, ogg_packet, 'can initialize ogg_packet';

$ret = ogg_stream_packetout($st, $pkt);
ok $ret == 1, 'can retrieve packet using ogg_stream_packetout';

done-testing;
