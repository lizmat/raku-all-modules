#!/usr/bin/perl6

# Port of the decoder_example.c program, found here:
# https://svn.xiph.org/trunk/vorbis/examples/decoder_example.c

use v6.c;

use Test;
use lib 'lib';

use NativeCall;
use Audio::OggVorbis::Ogg;
use Audio::OggVorbis::Vorbis;

my ($buffer, $bytes, $fh, $data, $result);
my $oy = ogg_sync_state.new();
my $os = ogg_stream_state.new();
my $og = ogg_page.new();
my $op = ogg_packet.new();
my $vi = vorbis_info.new();
my $vc = vorbis_comment.new();
my $vd = vorbis_dsp_state.new();
my $vb = vorbis_block.new();

sub getNextInputBlock {
	$data = $fh.read(4096);
	for $data.subbuf(0).kv -> $i, $c { 
		$buffer[$i] = $c;
	}
	$bytes = $data.elems;
	ogg_sync_wrote($oy, $bytes);
}

isa-ok $vi, vorbis_info, "successfully created vorbis_info instance";
isa-ok $vc, vorbis_comment, "successfully created vorbis_comment instance";
isa-ok $vd, vorbis_dsp_state, "successfully created vorbis_dsp_state instance";
isa-ok $vb, vorbis_block, "successfully created vorbis_block instance";

$fh = open "test_data/SoundMeni.ogg", :bin;

my $eos = 0;
my $i;
my uint16 $convsize = 4096;

$buffer = ogg_sync_buffer($oy, 4096);
getNextInputBlock();

if ($bytes < 4096) {
	flunk 'premature end of file';
	die 'Aborting';
}

ok 
	ogg_sync_pageout($oy, $og) == 1,
	'successfully identified input as Ogg bitstream';

ogg_stream_init($os, ogg_page_serialno($og));
vorbis_info_init($vi);
vorbis_comment_init($vc);

ok 
	ogg_stream_pagein($os, $og) >= 0,
	'successfully read first page of Ogg bitstream data';

ok 
	ogg_stream_packetout($os, $op) == 1, 
	'successfully read initial header packet.';

ok
	vorbis_synthesis_headerin($vi, $vc, $op) >= 0,
	'bitstream contains Vorbis audio data';

# cw: Read header blocks.
$i = 0;
while ($i < 2) {
	while ($i < 2) {
		$result = ogg_sync_pageout($oy, $og);
		last if $result == 0;

		if ($result == 1) {
			ogg_stream_pagein($os, $og);

			while ($i < 2) {
				$result = ogg_stream_packetout($os, $op);
				last if $result == 0;
				if ($result < 0) {
					flunk "received corrupt secondary header from packet";
					die "Aborting.";
				}

				$result = vorbis_synthesis_headerin($vi, $vc, $op);
				if ($result < 0) {
					flunk "received corrupt secondary header";
					die "Aborting.";
				}
				
				$i++;
			}
		}
	}

	$buffer = ogg_sync_buffer($oy, 4096);
	getNextInputBlock();

	if ($bytes == 0 && $i < 2) {
		flunk "reached end of file before finding all Vorbis headers";
		die "Aborting";
	}
}

ok $vi.defined, "found vorbis_info header. Bitstream count is {$vi.channels}, {$vi.rate}Hz";
ok $vc.defined, "found vorbis_comment header";

my @uc := nativecast(CArray[Str], $vc.user_comments);
#loop (my $ci = 0; @uc[$ci].defined; $ci++) {
#	diag "Comment: {@uc[$ci]}";
#}

$convsize = (4096 / $vi.channels).floor;

# Start central decode.
if (vorbis_synthesis_init($vd, $vi) == 0) { 
	vorbis_block_init($vd, $vb);          
      
	# Straight decode loop until end of stream */
	while ($eos != 0) {
        while ($eos != 0) {
			$result = ogg_sync_pageout($oy, $og);

			# check if more data needed.
			last if $result == 0;

			if ($result < 0) { 
				# missing or corrupt data at this page position 
				flunk('corrupt or missing data in bitstream;');
				die 'Aborting';

			}
			
			ogg_stream_pagein($os, $og);
            repeat {
				$result = ogg_stream_packetout($os, $op);
              
              	# check if more data needed.
              	last if $result == 0;

				# check for unexpected error.
				if ($result < 0) { 
					flunk('corrupt or missing data in bitstream;');
					die 'Aborting';				
              	}

                # We have a packet.  Decode it.
                my Pointer $pcm;
                my $samples;
                
                if (vorbis_synthesis($vb, $op) == 0) {
					vorbis_synthesis_blockin($vd, $vb);
                }

                $pcm .= new;
                $samples = vorbis_synthesis_pcmout($vd, $pcm);
                while ($samples > 0) {
            		my ($j, $clipflag, $bout);
					$clipflag = 0;
					$bout = $samples < $convsize ?? $samples !! $convsize;

					my @outer_ap := nativecast(CArray[CArray[num32]], $pcm);
					loop ($i = 0; $i < $vi.channels; $i++) {
						my @chan_a := nativecast(CArray[num32], @outer_ap[i]);
                    
						loop (my $j = 0; $j < $bout; $j++) {
							my ($val) = @chan_a[$j] * 32767.5;

							# cw: Would testing sample data against clipping be useful for 
							#	  anything?
							if ($val > 32767) {
								$val = 32767;
								$clipflag = 1;
							} elsif ($val < -32768) {
						        $val = -32768;
						        $clipflag = 1;
						  	}

						  	# cw: Place value of val into output buffer, here.
						}
					}
                  
					warn sprintf("Clipping in frame %ld", $vd.sequence)
						if $clipflag == 1;                  
                  
                  	# cw: This would write raw PCM data to output.
                  	#fwrite(convbuffer, 2 * vi.channels, bout, stdout);
                  
                  	vorbis_synthesis_read($vd, $bout);
                }            
            } while True;

            $eos = 1 if ogg_page_eos($og) != 0;
        }

        if ($eos == 0) {
			getNextInputBlock();
			$eos = 1 if $bytes == 0;
      	}
  	}
      
  	# cw: This is worth keeping in mind -- 
  	# 
	# * ogg_page and ogg_packet structs always point to storage in
    # * libvorbis.  They're never freed or manipulated directly
  
	vorbis_block_clear($vb);
	vorbis_dsp_clear($vd);
} else {
	flunk 'Error: Corrupt header during playback initialization.';
	die 'Aborting';
}

ok True, 'finished decoding';

# clean up this logical bitstream; 
# cw: If this were a general decoder, we'd handle chained streams. 
#     however, this is a testing method and we'll leave that to the
#     general decoding routine planned for Audio::LibOggVorbis

ogg_stream_clear($os);
vorbis_comment_clear($vc);

# must be called last
vorbis_info_clear($vi);

# OK, clean up the framer
ogg_sync_clear($oy);

ok True, 'finished clean-up';
  
done-testing;