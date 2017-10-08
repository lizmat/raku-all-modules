unit module Ogg;

use NativeCall;

constant LIB = 'ogg';

## Structures

# == /usr/include/ogg/ogg.h ==

class ogg_iovec_t is repr('CStruct') is export {
	has Pointer                       $.iov_base; # void* iov_base
	has size_t                        $.iov_len; # Typedef<size_t>->|unsigned int| iov_len
}

class oggpack_buffer is repr('CStruct') is export {
	has long                          $.endbyte; # long int endbyte
	has int32                         $.endbit; # int endbit
	has Pointer[uint8]                $.buffer; # unsigned char* buffer
	has Pointer[uint8]                $.ptr; # unsigned char* ptr
	has long                          $.storage; # long int storage
}

class ogg_page is repr('CStruct') is export {
	has Pointer[uint8]                $.header; # unsigned char* header
	has long                          $.header_len; # long int header_len
	has Pointer[uint8]                $.body; # unsigned char* body
	has long                          $.body_len; # long int body_len
}

# cw: Until perl6 can accurately represent a pre-defined array, we will have to 
#     cheat in some circumstances.
#
#     The below struct is to occupy 282 bytes in ogg_stream_state
class ogg_stream_state_header is repr('CStruct') {
		has uint64  $.header00;
        has uint64  $.header01;
        has uint64  $.header02;
        has uint64  $.header03;
        has uint64  $.header04;
        has uint64  $.header05;
        has uint64  $.header06;
        has uint64  $.header07;
        has uint64  $.header08;
        has uint64  $.header09;
        has uint64  $.header10;
        has uint64  $.header11;
        has uint64  $.header12;
        has uint64  $.header13;
        has uint64  $.header14;
        has uint64  $.header15;
        has uint64  $.header16;
        has uint64  $.header17;
        has uint64  $.header18;
        has uint64  $.header19;
        has uint64  $.header20;
        has uint64  $.header21;
        has uint64  $.header22;
        has uint64  $.header23;
        has uint64  $.header24;
        has uint64  $.header25;
        has uint64  $.header26;
        has uint64  $.header27;
        has uint64  $.header28;
        has uint64  $.header29;
        has uint64  $.header30;
        has uint64  $.header31;
        has uint64  $.header32;
        has uint64  $.header33;
        has uint64  $.header34;
        has uint8	$.header35;

        method as_blob {
        	my @uint64_list = (
        		$.header00,
				$.header01,
				$.header02,
				$.header03,
				$.header04,
				$.header05,
				$.header06,
				$.header07,
				$.header08,
				$.header09,
				$.header10,
				$.header11,
				$.header12,
				$.header13,
				$.header14,
				$.header15,
				$.header16,
				$.header17,
				$.header18,
				$.header19,
				$.header20,
				$.header21,
				$.header22,
				$.header23,
				$.header24,
				$.header25,
				$.header26,
				$.header27,
				$.header28,
				$.header29,
				$.header30,
				$.header31,
				$.header32,
				$.header33,
				$.header34
    		);

        	my @b;
    		for @uint64_list -> $u {
    			# cw: Break the uint64 into 8 uint8 chunks.
    			my $ca = Buf[uint8].new(
    				nativecast(CArray[uint8], array[uint64].new($u)[^8])
				);
    			for ^8 -> $i {
    				@b.push($ca[$i]);
    			}
    		}
    		@b.push($.header35);

    		# Return BLOB containing assembled 282 byte header.
    		return Blob[uint8].new(@b);
        }

        # sortiz++
        method as_blob2 {
        	return Blob[uint8].new(
        		nativecast(CArray[uint8], self)[
        			^nativesizeof(ogg_stream_state_header)
    			]
			);
        }
}

class ogg_stream_state is repr('CStruct') is export {
	has Pointer[uint8]                $.body_data; # unsigned char* body_data
	has long                          $.body_storage; # long int body_storage
	has long                          $.body_fill; # long int body_fill
	has long                          $.body_returned; # long int body_returned
	has Pointer[int32]                $.lacing_vals; # int* lacing_vals
	has Pointer[int64]              $.granule_vals; # Typedef<ogg_int64>->|Typedef<int64>->|long long int||* granule_vals
	has long                          $.lacing_storage; # long int lacing_storage
	has long                          $.lacing_fill; # long int lacing_fill
	has long                          $.lacing_packet; # long int lacing_packet
	has long                          $.lacing_returned; # long int lacing_returned
	# cw: --YYY-- Build a method to properly access $.header
	HAS ogg_stream_state_header       $!header; # unsigned char[282] header
	has int32                         $.header_fill; # int header_fill
	has int32                         $.e_o_s; # int e_o_s
	has int32                         $.b_o_s; # int b_o_s
	has long                          $.serialno; # long int serialno
	has long                          $.pageno; # long int pageno
	has int64                       $.packetno; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| packetno
	has int64                       $.granulepos; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| granulepos

	method get_header {
		return $!header.as_blob;		
	}

	submethod DESTROY {
		# Identify elements that might leak.
	}
}

class ogg_packet is repr('CStruct') is export {
	has Pointer[uint8]                $.packet; # unsigned char* packet
	has long                          $.bytes; # long int bytes
	has long                          $.b_o_s; # long int b_o_s
	has long                          $.e_o_s; # long int e_o_s
	has int64                         $.granulepos; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| granulepos
	has int64                         $.packetno; # Typedef<ogg_int64>->|Typedef<int64>->|long long int|| packetno

	method as_blob {
    	return Blob[uint8].new(
    		nativecast(CArray[uint8], self)[
    			^nativesizeof(ogg_packet)
			]
		);
    }
}

class ogg_sync_state is repr('CStruct') is export {
	has Pointer[uint8]                $.data; # unsigned char* data
	has int32                         $.storage; # int storage
	has int32                         $.fill; # int fill
	has int32                         $.returned; # int returned
	has int32                         $.unsynced; # int unsynced
	has int32                         $.headerbytes; # int headerbytes
	has int32                         $.bodybytes; # int bodybytes
}


# == /usr/include/ogg/ogg.h ==

#extern void  oggpack_writeinit(oggpack_buffer *b);
sub oggpack_writeinit(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#extern int   oggpack_writecheck(oggpack_buffer *b);
sub oggpack_writecheck(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns int32 is export { * }

#extern void  oggpack_writetrunc(oggpack_buffer *b,long bits);
sub oggpack_writetrunc(
	oggpack_buffer                $b # oggpack_buffer*
       ,long                          $bits # long int
) is native(LIB)  is export { * }

#extern void  oggpack_writealign(oggpack_buffer *b);
sub oggpack_writealign(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#extern void  oggpack_writecopy(oggpack_buffer *b,void *source,long bits);
sub oggpack_writecopy(
	oggpack_buffer                $b # oggpack_buffer*
       ,Pointer                       $source # void*
       ,long                          $bits # long int
) is native(LIB)  is export { * }

#extern void  oggpack_reset(oggpack_buffer *b);
sub oggpack_reset(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#extern void  oggpack_writeclear(oggpack_buffer *b);
sub oggpack_writeclear(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#extern void  oggpack_readinit(oggpack_buffer *b,unsigned char *buf,int bytes);
sub oggpack_readinit(
	oggpack_buffer                $b # oggpack_buffer*
       ,Pointer[uint8]                $buf # unsigned char*
       ,int32                         $bytes # int
) is native(LIB)  is export { * }

#extern void  oggpack_write(oggpack_buffer *b,unsigned long value,int bits);
sub oggpack_write(
        oggpack_buffer                $b # oggpack_buffer*
       ,ulong                         $value # long unsigned int
       ,int32                         $bits # int
) is native(LIB)  is export { * }

#extern long  oggpack_look(oggpack_buffer *b,int bits);
sub oggpack_look(
	oggpack_buffer                $b # oggpack_buffer*
       ,int32                         $bits # int
) is native(LIB) returns long is export { * }

#extern long  oggpack_look1(oggpack_buffer *b);
sub oggpack_look1(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#extern void  oggpack_adv(oggpack_buffer *b,int bits);
sub oggpack_adv(
	oggpack_buffer                $b # oggpack_buffer*
	,int32                         $bits # int
) is native(LIB)  is export { * }

#extern void  oggpack_adv1(oggpack_buffer *b);
sub oggpack_adv1(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#extern long  oggpack_read(oggpack_buffer *b,int bits);
sub oggpack_read(
	oggpack_buffer                $b # oggpack_buffer*
	,int32                         $bits # int
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:132
#extern long  oggpack_read1(oggpack_buffer *b);
sub oggpack_read1(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:133
#extern long  oggpack_bytes(oggpack_buffer *b);
sub oggpack_bytes(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:134
#extern long  oggpack_bits(oggpack_buffer *b);
sub oggpack_bits(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:135
#extern unsigned char *oggpack_get_buffer(oggpack_buffer *b);
sub oggpack_get_buffer(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns Pointer[uint8] is export { * }

#-From /usr/include/ogg/ogg.h:137
#extern void  oggpackB_writeinit(oggpack_buffer *b);
sub oggpackB_writeinit(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:138
#extern int   oggpackB_writecheck(oggpack_buffer *b);
sub oggpackB_writecheck(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:139
#extern void  oggpackB_writetrunc(oggpack_buffer *b,long bits);
sub oggpackB_writetrunc(
	oggpack_buffer $b # oggpack_buffer*
	,long                          $bits # long int
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:140
#extern void  oggpackB_writealign(oggpack_buffer *b);
sub oggpackB_writealign(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:141
#extern void  oggpackB_writecopy(oggpack_buffer *b,void *source,long bits);
sub oggpackB_writecopy(
	oggpack_buffer $b # oggpack_buffer*
	,Pointer                       $source # void*
	,long                          $bits # long int
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:142
#extern void  oggpackB_reset(oggpack_buffer *b);
sub oggpackB_reset(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:143
#extern void  oggpackB_writeclear(oggpack_buffer *b);
sub oggpackB_writeclear(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:144
#extern void  oggpackB_readinit(oggpack_buffer *b,unsigned char *buf,int bytes);
sub oggpackB_readinit(
	oggpack_buffer $b # oggpack_buffer*
	,Pointer[uint8]                $buf # unsigned char*
	,int32                         $bytes # int
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:145
#extern void  oggpackB_write(oggpack_buffer *b,unsigned long value,int bits);
sub oggpackB_write(
	oggpack_buffer $b # oggpack_buffer*
	,ulong                         $value # long unsigned int
	,int32                         $bits # int
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:146
#extern long  oggpackB_look(oggpack_buffer *b,int bits);
sub oggpackB_look(oggpack_buffer 
	$b # oggpack_buffer*
	,int32                         $bits # int
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:147
#extern long  oggpackB_look1(oggpack_buffer *b);
sub oggpackB_look1(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:148
#extern void  oggpackB_adv(oggpack_buffer *b,int bits);
sub oggpackB_adv(
	oggpack_buffer                $b # oggpack_buffer*
	,int32                         $bits # int
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:149
#extern void  oggpackB_adv1(oggpack_buffer *b);
sub oggpackB_adv1(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:150
#extern long  oggpackB_read(oggpack_buffer *b,int bits);
sub oggpackB_read(
	oggpack_buffer                $b # oggpack_buffer*
	,int32                         $bits # int
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:151
#extern long  oggpackB_read1(oggpack_buffer *b);
sub oggpackB_read1(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:152
#extern long  oggpackB_bytes(oggpack_buffer *b);
sub oggpackB_bytes(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:153
#extern long  oggpackB_bits(oggpack_buffer *b);
sub oggpackB_bits(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:154
#extern unsigned char *oggpackB_get_buffer(oggpack_buffer *b);
sub oggpackB_get_buffer(
	oggpack_buffer $b # oggpack_buffer*
) is native(LIB) returns Pointer[uint8] is export { * }

#-From /usr/include/ogg/ogg.h:158
#extern int      ogg_stream_packetin(ogg_stream_state *os, ogg_packet *op);
sub ogg_stream_packetin(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_packet                    $op # ogg_packet*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:160
#extern int      ogg_stream_iovecin(ogg_stream_state *os, ogg_iovec_t *iov,
#                                   int count, long e_o_s, ogg_int64 granulepos);
sub ogg_stream_iovecin(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_iovec_t                   $iov # ogg_iovec_t*
	,int32                         $count # int
	,long                          $e_o_s # long int
	,int64                       $granulepos # Typedef<ogg_int64>->|Typedef<int64>->|long long int||
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:161
#extern int      ogg_stream_pageout(ogg_stream_state *os, ogg_page *og);
sub ogg_stream_pageout(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_page                      $og # ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:162
#extern int      ogg_stream_pageout_fill(ogg_stream_state *os, ogg_page *og, int nfill);
sub ogg_stream_pageout_fill(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_page                      $og # ogg_page*
	,int32                         $nfill # int
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:163
#extern int      ogg_stream_flush(ogg_stream_state *os, ogg_page *og);
sub ogg_stream_flush(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_page                      $og # ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:164
#extern int      ogg_stream_flush_fill(ogg_stream_state *os, ogg_page *og, int nfill);
sub ogg_stream_flush_fill(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_page                      $og # ogg_page*
	,int32                         $nfill # int
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:168
#extern int      ogg_sync_init(ogg_sync_state *oy);
sub ogg_sync_init(
	ogg_sync_state $oy # ogg_sync_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:169
#extern int      ogg_sync_clear(ogg_sync_state *oy);
sub ogg_sync_clear(
	ogg_sync_state $oy # ogg_sync_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:170
#extern int      ogg_sync_reset(ogg_sync_state *oy);
sub ogg_sync_reset(
	ogg_sync_state $oy # ogg_sync_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:171
#extern int      ogg_sync_destroy(ogg_sync_state *oy);
sub ogg_sync_destroy(
	ogg_sync_state $oy # ogg_sync_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:172
#extern int      ogg_sync_check(ogg_sync_state *oy);
sub ogg_sync_check(
	ogg_sync_state $oy # ogg_sync_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:174
#extern char    *ogg_sync_buffer(ogg_sync_state *oy, long size);
sub ogg_sync_buffer(
	ogg_sync_state $oy # ogg_sync_state*
	,long                          $size # long int
) is native(LIB) returns CArray[uint8] is export { * }

#-From /usr/include/ogg/ogg.h:175
#extern int      ogg_sync_wrote(ogg_sync_state *oy, long bytes);
sub ogg_sync_wrote(
	ogg_sync_state $oy # ogg_sync_state*
	,long                          $bytes # long int
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:176
#extern long     ogg_sync_pageseek(ogg_sync_state *oy,ogg_page *og);
sub ogg_sync_pageseek(
	ogg_sync_state $oy # ogg_sync_state*
	,ogg_page                      $og # ogg_page*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:177
#extern int      ogg_sync_pageout(ogg_sync_state *oy, ogg_page *og);
sub ogg_sync_pageout(
	ogg_sync_state $oy # ogg_sync_state*
	,ogg_page                      $og # ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:178
#extern int      ogg_stream_pagein(ogg_stream_state *os, ogg_page *og);
sub ogg_stream_pagein(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_page                      $og # ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:179
#extern int      ogg_stream_packetout(ogg_stream_state *os,ogg_packet *op);
sub ogg_stream_packetout(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_packet                    $op # ogg_packet*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:180
#extern int      ogg_stream_packetpeek(ogg_stream_state *os,ogg_packet *op);
sub ogg_stream_packetpeek(
	ogg_stream_state $os # ogg_stream_state*
	,ogg_packet                    $op # ogg_packet*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:184
#extern int      ogg_stream_init(ogg_stream_state *os,int serialno);
sub ogg_stream_init(
	ogg_stream_state $os # ogg_stream_state*
	,int32                         $serialno # int
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:185
#extern int      ogg_stream_clear(ogg_stream_state *os);
sub ogg_stream_clear(
	ogg_stream_state $os # ogg_stream_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:186
#extern int      ogg_stream_reset(ogg_stream_state *os);
sub ogg_stream_reset(
	ogg_stream_state $os # ogg_stream_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:187
#extern int      ogg_stream_reset_serialno(ogg_stream_state *os,int serialno);
sub ogg_stream_reset_serialno(
	ogg_stream_state $os # ogg_stream_state*
	,int32                         $serialno # int
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:188
#extern int      ogg_stream_destroy(ogg_stream_state *os);
sub ogg_stream_destroy(
	ogg_stream_state $os # ogg_stream_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:189
#extern int      ogg_stream_check(ogg_stream_state *os);
sub ogg_stream_check(
	ogg_stream_state $os # ogg_stream_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:190
#extern int      ogg_stream_eos(ogg_stream_state *os);
sub ogg_stream_eos(
	ogg_stream_state $os # ogg_stream_state*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:192
#extern void     ogg_page_checksum_set(ogg_page *og);
sub ogg_page_checksum_set(
	ogg_page $og # ogg_page*
) is native(LIB)  is export { * }

#-From /usr/include/ogg/ogg.h:194
#extern int      ogg_page_version(const ogg_page *og);
sub ogg_page_version(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:195
#extern int      ogg_page_continued(const ogg_page *og);
sub ogg_page_continued(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:196
#extern int      ogg_page_bos(const ogg_page *og);
sub ogg_page_bos(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:197
#extern int      ogg_page_eos(const ogg_page *og);
sub ogg_page_eos(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:198
#extern ogg_int64  ogg_page_granulepos(const ogg_page *og);
sub ogg_page_granulepos(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int64 is export { * }

#-From /usr/include/ogg/ogg.h:199
#extern int      ogg_page_serialno(const ogg_page *og);
sub ogg_page_serialno(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:200
#extern long     ogg_page_pageno(const ogg_page *og);
sub ogg_page_pageno(
	ogg_page $og # const ogg_page*
) is native(LIB) returns long is export { * }

#-From /usr/include/ogg/ogg.h:201
#extern int      ogg_page_packets(const ogg_page *og);
sub ogg_page_packets(
	ogg_page $og # const ogg_page*
) is native(LIB) returns int32 is export { * }

#-From /usr/include/ogg/ogg.h:203
#extern void     ogg_packet_clear(ogg_packet *op);
sub ogg_packet_clear(
	ogg_packet $op # ogg_packet*
) is native(LIB)  is export { * }


# For explicit memory management of returned objects.
sub native_free(Pointer) 
	is native(Str)
	is symbol('free') { * }