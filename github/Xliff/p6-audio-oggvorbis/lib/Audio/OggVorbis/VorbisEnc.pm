unit module VorbisEnc;

use NativeCall;
use Audio::OggVorbis::Vorbis;

constant LIB = 'vorbisenc';
constant VER = v2;

# == /usr/include/vorbis/vorbisenc.h ==

class ovectl_ratemanage_arg is repr('CStruct') is export {
	has int32                         $.management_active; # int management_active
	has long                          $.bitrate_hard_min; # long int bitrate_hard_min
	has long                          $.bitrate_hard_max; # long int bitrate_hard_max
	has num64                         $.bitrate_hard_window; # double bitrate_hard_window
	has long                          $.bitrate_av_lo; # long int bitrate_av_lo
	has long                          $.bitrate_av_hi; # long int bitrate_av_hi
	has num64                         $.bitrate_av_window; # double bitrate_av_window
	has num64                         $.bitrate_av_window_center; # double bitrate_av_window_center
}

class ovectl_ratemanage2_arg is repr('CStruct') is export {
	has int32                         $.management_active; # int management_active
	has long                          $.bitrate_limit_min_kbps; # long int bitrate_limit_min_kbps
	has long                          $.bitrate_limit_max_kbps; # long int bitrate_limit_max_kbps
	has long                          $.bitrate_limit_reservoir_bits; # long int bitrate_limit_reservoir_bits
	has num64                         $.bitrate_limit_reservoir_bias; # double bitrate_limit_reservoir_bias
	has long                          $.bitrate_average_kbps; # long int bitrate_average_kbps
	has num64                         $.bitrate_average_damping; # double bitrate_average_damping
}


# == /usr/include/vorbis/vorbisenc.h ==

sub vorbis_encode_init(
	vorbis_info             $vi 				# Typedef<vorbis_info>->|vorbis_info|*
	,long                   $channels 			# long int
	,long                   $rate 				# long int
	,long                   $max_bitrate 		# long int
	,long                   $nominal_bitrate 	# long int
	,long                   $min_bitrate 		# long int
) is native(LIB,VER) returns int32 is export { * }


sub vorbis_encode_setup_managed(
	vorbis_info             $vi 				# Typedef<vorbis_info>->|vorbis_info|*
	,long                   $channels 			# long int
	,long                   $rate 				# long int
	,long                   $max_bitrate 		# long int
	,long                   $nominal_bitrate 	# long int
	,long                   $min_bitrate 		# long int
) is native(LIB,VER) returns int32 is export { * }

sub vorbis_encode_setup_vbr(
	vorbis_info             $vi 			# Typedef<vorbis_info>->|vorbis_info|*
	,long                   $channels 		# long int
	,long                   $rate 			# long int
	,num32                  $quality 		# float
) is native(LIB,VER) returns int32 is export { * }


sub vorbis_encode_init_vbr(
	vorbis_info				$vi 			# Typedef<vorbis_info>->|vorbis_info|*
	,long                   $channels 		# long int
	,long                   $rate 			# long int
	,num32                  $base_quality 	# float
) is native(LIB,VER) returns int32 is export { * }


#extern int vorbis_encode_setup_init(vorbis_info *vi);
sub vorbis_encode_setup_init(
	vorbis_info 			$vi 		# Typedef<vorbis_info>->|vorbis_info|*
) is native(LIB,VER) returns int32 is export { * }


#extern int vorbis_encode_ctl(vorbis_info *vi,int number,void *arg);
sub vorbis_encode_ctl(
	vorbis_info             $vi 		# Typedef<vorbis_info>->|vorbis_info|*
	,int32                  $number 	# int
	,Pointer                $arg 		# void*
) is native(LIB,VER) returns int32 is export { * }

