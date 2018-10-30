unit module Vorbis;

use NativeCall;
use Audio::OggVorbis::Ogg;

constant LIB = 'vorbis';

# == /usr/include/vorbis/codec.h ==
class vorbis_info is repr('CStruct') is export {
	has int32                         $.version; # int version
	has int32                         $.channels; # int channels
	has long                          $.rate; # long int rate
	has long                          $.bitrate_upper; # long int bitrate_upper
	has long                          $.bitrate_nominal; # long int bitrate_nominal
	has long                          $.bitrate_lower; # long int bitrate_lower
	has long                          $.bitrate_window; # long int bitrate_window
	has Pointer                       $.codec_setup; # void* codec_setup
}

class vorbis_dsp_state is repr('CStruct') is export {
	has int32                         $.analysisp; # int analysisp
	has vorbis_info                   $.vi; # Typedef<vorbis_info>->|vorbis_info|* vi
	has Pointer[Pointer[num32]]       $.pcm; # float** pcm
	has Pointer[Pointer[num32]]       $.pcmret; # float** pcmret
	has int32                         $.pcm_storage; # int pcm_storage
	has int32                         $.pcm_current; # int pcm_current
	has int32                         $.pcm_returned; # int pcm_returned
	has int32                         $.preextrapolate; # int preextrapolate
	has int32                         $.eofflag; # int eofflag
	has long                          $.lW; # long int lW
	has long                          $.W; # long int W
	has long                          $.nW; # long int nW
	has long                          $.centerW; # long int centerW
	has int64                       $.granulepos; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| granulepos
	has int64                       $.sequence; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| sequence
	has int64                       $.glue_bits; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| glue_bits
	has int64                       $.time_bits; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| time_bits
	has int64                       $.floor_bits; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| floor_bits
	has int64                       $.res_bits; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| res_bits
	has Pointer                       $.backend_state; # void* backend_state
}

class alloc_chain is repr('CStruct') is export {
	has Pointer                       $.ptr; 	# void* ptr
	has alloc_chain                   $.next; 	# alloc_chain* next
}

class vorbis_block is repr('CStruct') is export {
	has Pointer[Pointer[num32]]       $.pcm; # float** pcm
	HAS oggpack_buffer                $.opb; # oggpack_buffer opb
	has long                          $.lW; # long int lW
	has long                          $.W; # long int W
	has long                          $.nW; # long int nW
	has int32                         $.pcmend; # int pcmend
	has int32                         $.mode; # int mode
	has int32                         $.eofflag; # int eofflag
	has int64                       $.granulepos; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| granulepos
	has int64                       $.sequence; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| sequence
	has vorbis_dsp_state              $.vd; # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|* vd
	has Pointer                       $.localstore; # void* localstore
	has long                          $.localtop; # long int localtop
	has long                          $.localalloc; # long int localalloc
	has long                          $.totaluse; # long int totaluse
	has alloc_chain                   $.reap; # alloc_chain* reap
	has long                          $.glue_bits; # long int glue_bits
	has long                          $.time_bits; # long int time_bits
	has long                          $.floor_bits; # long int floor_bits
	has long                          $.res_bits; # long int res_bits
	has Pointer                       $.internal; # void* internal
}

# cw: $.user_comments is probably going to be difficult, since it might
#     be a CArray[Str]
class vorbis_comment is repr('CStruct') is export {
	has Pointer[Str]                  $.user_comments; # char** user_comments
	has Pointer[int32]                $.comment_lengths; # int* comment_lengths
	has int32                         $.comments; # int comments
	has Str                           $.vendor; # char* vendor
}

## Functions

# == /usr/include/vorbis/codec.h ==


#extern void     vorbis_info_init(vorbis_info *vi);
sub vorbis_info_init(
	vorbis_info	$vi # Typedef<vorbis_info>->|vorbis_info|*
) is native(LIB)  is export { * }


#extern void     vorbis_info_clear(vorbis_info *vi);
sub vorbis_info_clear(
	vorbis_info	$vi # Typedef<vorbis_info>->|vorbis_info|*
) is native(LIB)  is export { * }


#extern int      vorbis_info_blocksize(vorbis_info *vi,int zo);
sub vorbis_info_blocksize(
	vorbis_info		$vi # Typedef<vorbis_info>->|vorbis_info|*
	,int32          $zo # int
) is native(LIB) returns int32 is export { * }


#extern void     vorbis_comment_init(vorbis_comment *vc);
sub vorbis_comment_init(
	vorbis_comment	$vc # Typedef<vorbis_comment>->|vorbis_comment|*
) is native(LIB)  is export { * }


#extern void     vorbis_comment_add(vorbis_comment *vc, const char *comment);
sub vorbis_comment_add(
	vorbis_comment	$vc 		# Typedef<vorbis_comment>->|vorbis_comment|*
	,Str			$comment 	# const char*
) is native(LIB)  is export { * }


#extern void     vorbis_comment_add_tag(vorbis_comment *vc,
#                                       const char *tag, const char *contents);
sub vorbis_comment_add_tag(
	vorbis_comment	$vc # Typedef<vorbis_comment>->|vorbis_comment|*
	,Str            $tag # const char*
	,Str            $contents # const char*
) is native(LIB)  is export { * }


#extern char    *vorbis_comment_query(vorbis_comment *vc, const char *tag, int count);
sub vorbis_comment_query(
	vorbis_comment	$vc # Typedef<vorbis_comment>->|vorbis_comment|*
	,Str            $tag # const char*
	,int32			$count # int
) is native(LIB) returns Str is export { * }


#extern int      vorbis_comment_query_count(vorbis_comment *vc, const char *tag);
sub vorbis_comment_query_count(
	vorbis_comment	$vc # Typedef<vorbis_comment>->|vorbis_comment|*
	,Str 			$tag # const char*
) is native(LIB) returns int32 is export { * }


#extern void     vorbis_comment_clear(vorbis_comment *vc);
sub vorbis_comment_clear(
	vorbis_comment	$vc # Typedef<vorbis_comment>->|vorbis_comment|*
) is native(LIB)  is export { * }


#extern int      vorbis_block_init(vorbis_dsp_state *v, vorbis_block *vb);
sub vorbis_block_init(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
 	,vorbis_block       $vb # Typedef<vorbis_block>->|vorbis_block|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_block_clear(vorbis_block *vb);
sub vorbis_block_clear(
	vorbis_block	$vb # Typedef<vorbis_block>->|vorbis_block|*
) is native(LIB) returns int32 is export { * }


#extern void     vorbis_dsp_clear(vorbis_dsp_state *v);
sub vorbis_dsp_clear(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
) is native(LIB)  is export { * }


#extern double   vorbis_granule_time(vorbis_dsp_state *v,
#                                    ogg_int64 granulepos);
sub vorbis_granule_time(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,int64              $granulepos # Typedef<ogg_int64>->|Typedef<int64>->|long long int||
) is native(LIB) returns num64 is export { * }


#extern const char *vorbis_version_string(void);
sub vorbis_version_string() is native(LIB) returns Str is export { * }


#extern int      vorbis_analysis_init(vorbis_dsp_state *v,vorbis_info *vi);
sub vorbis_analysis_init(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,vorbis_info        $vi # Typedef<vorbis_info>->|vorbis_info|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_commentheader_out(vorbis_comment *vc, ogg_packet *op);
sub vorbis_commentheader_out(
	vorbis_comment	$vc # Typedef<vorbis_comment>->|vorbis_comment|*
	,ogg_packet		$op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_analysis_headerout(vorbis_dsp_state *v,
#                                          vorbis_comment *vc,
#                                          ogg_packet *op,
#                                          ogg_packet *op_comm,
#                                          ogg_packet *op_code);
sub vorbis_analysis_headerout(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,vorbis_comment     $vc # Typedef<vorbis_comment>->|vorbis_comment|*
	,ogg_packet         $op # ogg_packet*
	,ogg_packet         $op_comm # ogg_packet*
	,ogg_packet         $op_code # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern float  **vorbis_analysis_buffer(vorbis_dsp_state *v,int vals);
sub vorbis_analysis_buffer(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,int32              $vals # int
) is native(LIB) returns Pointer[Pointer[num32]] is export { * }


#extern int      vorbis_analysis_wrote(vorbis_dsp_state *v,int vals);
sub vorbis_analysis_wrote(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,int32              $vals # int
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_analysis_blockout(vorbis_dsp_state *v,vorbis_block *vb);
sub vorbis_analysis_blockout(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
    ,vorbis_block       $vb # Typedef<vorbis_block>->|vorbis_block|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_analysis(vorbis_block *vb,ogg_packet *op);
sub vorbis_analysis(
	vorbis_block	$vb # Typedef<vorbis_block>->|vorbis_block|*
	,ogg_packet     $op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_bitrate_addblock(vorbis_block *vb);
sub vorbis_bitrate_addblock(
	vorbis_block	$vb # Typedef<vorbis_block>->|vorbis_block|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_bitrate_flushpacket(vorbis_dsp_state *vd,
#                                           ogg_packet *op);
sub vorbis_bitrate_flushpacket(
	vorbis_dsp_state	$vd # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,ogg_packet         $op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#/* Vorbis PRIMITIVES: synthesis layer *******************************/
#extern int      vorbis_synthesis_idheader(ogg_packet *op);
sub vorbis_synthesis_idheader(
	ogg_packet $op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_headerin(vorbis_info *vi,vorbis_comment *vc,
#                                          ogg_packet *op);
sub vorbis_synthesis_headerin(
	vorbis_info		$vi # Typedef<vorbis_info>->|vorbis_info|*
    ,vorbis_comment $vc # Typedef<vorbis_comment>->|vorbis_comment|*
    ,ogg_packet     $op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_init(vorbis_dsp_state *v,vorbis_info *vi);
sub vorbis_synthesis_init(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
    ,vorbis_info        $vi # Typedef<vorbis_info>->|vorbis_info|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_restart(vorbis_dsp_state *v);
sub vorbis_synthesis_restart(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis(vorbis_block *vb,ogg_packet *op);
sub vorbis_synthesis(
	vorbis_block	$vb # Typedef<vorbis_block>->|vorbis_block|*
    ,ogg_packet     $op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_trackonly(vorbis_block *vb,ogg_packet *op);
sub vorbis_synthesis_trackonly(
	vorbis_block	$vb # Typedef<vorbis_block>->|vorbis_block|*
	,ogg_packet     $op # ogg_packet*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_blockin(vorbis_dsp_state *v,vorbis_block *vb);
sub vorbis_synthesis_blockin(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
    ,vorbis_block       $vb # Typedef<vorbis_block>->|vorbis_block|*
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_pcmout(vorbis_dsp_state *v,float ***pcm);
sub vorbis_synthesis_pcmout(
	vorbis_dsp_state	$v 			# Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,Pointer 			$pcm is rw 	# float***
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_lapout(vorbis_dsp_state *v,float ***pcm);
sub vorbis_synthesis_lapout(
	vorbis_dsp_state	$v 			# Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,Pointer			$pcm is rw	# float***
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_read(vorbis_dsp_state *v,int samples);
sub vorbis_synthesis_read(
	vorbis_dsp_state	$v # Typedef<vorbis_dsp_state>->|vorbis_dsp_state|*
	,int32              $samples # int
) is native(LIB) returns int32 is export { * }


#extern long     vorbis_packet_blocksize(vorbis_info *vi,ogg_packet *op);
sub vorbis_packet_blocksize(
	vorbis_info		$vi # Typedef<vorbis_info>->|vorbis_info|*
	,ogg_packet     $op # ogg_packet*
) is native(LIB) returns long is export { * }


#extern int      vorbis_synthesis_halfrate(vorbis_info *v,int flag);
sub vorbis_synthesis_halfrate(
	vorbis_info 	$vi # Typedef<vorbis_info>->|vorbis_info|*
    ,int32          $flag # int
) is native(LIB) returns int32 is export { * }


#extern int      vorbis_synthesis_halfrate_p(vorbis_info *v);
sub vorbis_synthesis_halfrate_p(
	vorbis_info $v # Typedef<vorbis_info>->|vorbis_info|*
) is native(LIB) returns int32 is export { * }
