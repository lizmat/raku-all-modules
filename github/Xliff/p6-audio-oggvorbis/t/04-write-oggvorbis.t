#!/usr/bin/perl6

use v6.c;
use Test;
use lib 'lib';

use NativeCall;
use Audio::OggVorbis::Ogg;
use Audio::OggVorbis::Vorbis;
use Audio::OggVorbis::VorbisEnc;

constant READ = 1024;

sub writeToFile(IO::Handle $f, $d, $len) {
	my @a := nativecast(CArray[uint8], $d); 
	$f.write(Blob.new(@a[^$len]));
}

# cw: Implements a variation of the following:
#     https://svn.xiph.org/trunk/vorbis/examples/encoder_example.c

my $os = ogg_stream_state.new();
my $og = ogg_page.new();
my $op = ogg_packet.new();
my $vi = vorbis_info.new();
my $vc = vorbis_comment.new();
my $vd = vorbis_dsp_state.new();
my $vb = vorbis_block.new();

my $eos = 0;

my ($ret, $i);

my $fh = open "test_data/SoundMeni.wav", :bin;

# cw: An ammusing comment from the source, that applies here:
# 		"we cheat on the WAV header; we just bypass 44 bytes (simplest WAV
#  		header is 44 bytes) and assume that the data is 44.1khz, stereo, 16 bit
#		little endian pcm samples. This is just an example, after all."

# cw: When the encode() routine goes into Audio::OggVorbis, no assumptions
#     will be made. It will just be *cheating a little more* to read the 
#     header.

# Skip header.
#$fh.read(44);

my $founddata = 0;
loop ($i = 0; $i < 30; $i++) {
	my $b = $fh.read(2);

	if ($b[0] == 'd'.ord && $b[1] == 'a'.ord) {
		$founddata =1;
		$fh.read(6);
		last;
	}
}

ok $founddata = 1, 'found start of data';

vorbis_info_init($vi);
$ret = vorbis_encode_init_vbr($vi, 2, 44100, 0.1e0);

if ($ret != 0) {
	flunk "encoder failed to initialize with error code $ret";
	die "Aborting.";
}

ok $ret == 0, 'encoder initialized';

# Set up output file.
my $fhw = open("test_data/SoundMeni-test.ogg", :w, :bin);
unless ($fhw) {
	flunk "error opening output file.";
	die "Aborting";
}

# cw: Uses original code comment until valid operation can be verified.
vorbis_comment_init($vc);
vorbis_comment_add_tag($vc, "TEST", "Audio::OggVorbis encoder");

vorbis_analysis_init($vd, $vi);
vorbis_block_init($vd, $vb);

my $r = (rand * 1e8).Int;
ogg_stream_init($os, $r);

my ogg_packet $header      .= new;
my ogg_packet $header_comm .= new;
my ogg_packet $header_code .= new;

# cw: Sanity check
isa-ok $header, ogg_packet, 'first header initialized';
isa-ok $header, ogg_packet, 'second header initialized';
isa-ok $header, ogg_packet, 'last header initialized';
	
vorbis_analysis_headerout($vd, $vc, $header, $header_comm, $header_code);

# cw: Will be streamlined when implemented in Audio::OggVorbis
ogg_stream_packetin($os, $header);
ogg_stream_packetin($os, $header_comm);
ogg_stream_packetin($os, $header_code);

# Write headers and insure the data begins on a new page.
while ($eos == 0) {
	$ret = ogg_stream_flush($os, $og);
	last if $ret == 0;

	writeToFile($fhw, $og.header, $og.header_len);
	writeToFile($fhw, $og.body, $og.body_len);

	$eos = 1 if ogg_page_eos($og);
} 

my $loop_count = 0;
my $stop = 40;
while $eos == 0 {
	my $i;
	# cw: libvorbis expects *signed* data, otherwise the
	#     output is corrupted.
	my Blob[int8] $readbuff = Blob[int8].new($fh.read(READ * 4));
	my $bytes = $readbuff.elems;


	if $bytes == 0 {
		# End of file.
		vorbis_analysis_wrote($vd, 0);
	} else {
		my $prebuff_ptr = vorbis_analysis_buffer($vd, READ);
		my @buffer := nativecast(CArray[CArray[num32]], $prebuff_ptr);

		# Uninterleave.
		# cw: I'm sure there's a smarter way to do this in P6...
		loop ($i = 0; $i < $bytes/4; $i++) {
			my num32 $div = 32768e0;
			
			@buffer[0][$i] = 
				(($readbuff[$i * 4 + 1] +< 8) +|
				(0x00ff +& $readbuff[$i * 4].Int)) / $div;

			@buffer[1][$i] = 
				(($readbuff[$i * 4 + 3] +< 8) +|
				(0x00ff +& $readbuff[$i * 4 + 2].Int)) / $div;
		}

		# Update the library.
		vorbis_analysis_wrote($vd, $i);
	}

	while (vorbis_analysis_blockout($vd, $vb) == 1) {
		# cw: This assumes bitrate analysis. Do we leave it out if we don't
		#     want it?
		vorbis_analysis($vb, ogg_packet);
		vorbis_bitrate_addblock($vb);

		while (vorbis_bitrate_flushpacket($vd, $op) != 0) {
			ogg_stream_packetin($os, $op);

			# Write out pages.
			while ($eos == 0) {
				$ret = ogg_stream_pageout($os, $og);
				last if $ret == 0;

				writeToFile($fhw, $og.header, $og.header_len);
				writeToFile($fhw, $og.body, $og.body_len);

				$eos = 1 if ogg_page_eos($og);
			}
		}
	}
	$loop_count++;
}

# cw: We only know it completed, not if the results are valid. 
#     Suggestions welcome!
ok True, "encoding process completed in {$loop_count} loops";


# Properly clear structures after use.
ogg_stream_clear($os);

# cw: This is the only testable routine in the cleanup phase.
$ret = vorbis_block_clear($vb);
ok $ret == 0, 'vorbis_block cleared';

vorbis_dsp_clear($vd);
vorbis_comment_clear($vc);

# Must be called LAST.
vorbis_info_clear($vi);

# Remember: ogg_page and ogg_packet structs always point to storage in
#           libvorbis.  They're never freed or manipulated directly!

done-testing;