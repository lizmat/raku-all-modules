
unit module Archive::SimpleZip::Headers:ver<0.2.0>:auth<Paul Marquess (pmqs@cpan.org)>;;

# Compression types supported
enum Zip-CM is export (
    Zip-CM-Store      => 0 ,
    Zip-CM-Deflate    => 8 ,
    Zip-CM-Bzip2      => 12 , 
    #Zip-CM-LZMA       => 14 , # Not Supported
    #Zip-CM-PPMD       => 98 , # Not Supported
);

# General Purpose Flag
enum Zip-GP-Flag is export (
    Zip-GP-Encrypted_Mask        => (1 +< 0) ,
    Zip-GP-Streaming-Mask        => (1 +< 3) ,
    Zip-GP-Patched-Mask          => (1 +< 5) ,
    Zip-GP-Strong-Encrypted-Mask => (1 +< 6) ,
    Zip-GP-LZMA-EOS-Present      => (1 +< 1) ,
    Zip-GP-Language-Encoding     => (1 +< 11) ,
);


our %Zip-CM-Min-Versions = 
            Zip-CM-Store.value   => 20,
            Zip-CM-Deflate.value => 20,
            Zip-CM-Bzip2.value   => 46,
            #Zip-CM-LZMA.value   => 63,
            #Zip-CM-PPMD.value   => 63,
            ;

class Local-File-Header is export # does CustomeMarshaller
{

    #   4.3.7  Local file header:
    #
    #      local file header signature     4 bytes  (0x04034b50)
    #      version needed to extract       2 bytes
    #      general purpose bit flag        2 bytes
    #      compression method              2 bytes
    #      last mod file time              2 bytes
    #      last mod file date              2 bytes
    #      crc-32                          4 bytes
    #      compressed size                 4 bytes
    #      uncompressed size               4 bytes
    #      file name length                2 bytes
    #      extra field length              2 bytes
    #
    #      file name (variable size)
    #      extra field (variable size)

    constant local-file-header-signature = 0x04034b50 ; # 4 bytes  (0x04034b50)

    has int32 $.signature  = 0x04034b50;            # 4 bytes
    has int16 $.version-needed-to-extract is rw ;   # 2 bytes
    has int16 $.general-purpose-bit-flag is rw ;    # 2 bytes
    has int16 $.compression-method is rw ;          # 2 bytes
    has int32 $.last-mod-file-time is rw ;          # 4 bytes
    has int32 $.crc32 is rw ;                       # 4 bytes
    has int32 $.compressed-size is rw ;             # 4 bytes
    has int32 $.uncompressed-size is rw ;           # 4 bytes
    has int16 $.file-name-length is rw ;            # 2 bytes
    has int16 $.extra-field-length is rw ;          # 2 bytes
    has Blob  $.file-name is rw ;                   # variable size
    has Blob  $.extra-field is rw ;                 # variable size

    has int16 $.version-made-by is rw = 0;             # 2 bytes
    has Blob  $.file-comment is rw  ;                  # 2 bytes
    has int16 $.internal-file-attributes is rw = 0;    # 2 bytes
    has int32 $.external-file-attributes is rw = 0;    # 4 bytes

    method get()
    {
        $.version-needed-to-extract max=
            %Zip-CM-Min-Versions{$.compression-method} ;

        # hard-wired to unix for now
        # can use $*KERNEL.name to get os
        $.version-made-by = 0x300 + $.version-needed-to-extract;

        my $header = buf8.allocate(30 + $.file-name.elems);
        $header.write-uint32( 0, local-file-header-signature, LittleEndian);
        $header.write-uint16( 4, $.version-needed-to-extract, LittleEndian);
        $header.write-uint16( 6, $.general-purpose-bit-flag,  LittleEndian);
        $header.write-uint16( 8, $.compression-method,        LittleEndian);
        $header.write-uint32(10, $.last-mod-file-time,        LittleEndian);
        $header.write-uint32(14, $.crc32,                     LittleEndian);
        $header.write-uint32(18, $.compressed-size,           LittleEndian);
        $header.write-uint32(22, $.uncompressed-size,         LittleEndian);
        $header.write-uint16(26, $.file-name.elems,           LittleEndian);
        $header.write-uint16(28, $.extra-field-length,        LittleEndian);
        $header.subbuf-rw(30) = $.file-name;

        return $header;
    }

    method data-descriptor()
    {
        #   4.3.9  Data descriptor:
        #
        #        crc-32                          4 bytes
        #        compressed size                 4 bytes
        #        uncompressed size               4 bytes    

        constant signature = 0x08074b50 ; # 4 bytes  (0x04034b50)

        my $header = buf8.allocate(16);
        $header.write-uint32( 0, signature,           LittleEndian);
        $header.write-uint32( 4, $.crc32,             LittleEndian);
        $header.write-uint32( 8, $.compressed-size,   LittleEndian);
        $header.write-uint32(12, $.uncompressed-size, LittleEndian);

        return $header;
    }


    method crc-and-sizes()
    {
        my $header = buf8.allocate(12);
        $header.write-uint32(0, $.crc32,             LittleEndian);
        $header.write-uint32(4, $.compressed-size,   LittleEndian);
        $header.write-uint32(8, $.uncompressed-size, LittleEndian);

        return $header;
    }
} 

class Central-Header-Directory is export
{
    has Blob  @.central-headers ;
    has       $!entries;
    has       $!cd-len ;

    method get-hdrs()
    {
        return @!central-headers ;
    }

    method end-central-directory(Int $cd_offset, Blob $comment)
    {
        #   4.3.16  End of central directory record:
        #
        #      end of central dir signature    4 bytes  (0x06054b50)
        #      number of this disk             2 bytes
        #      number of the disk with the
        #      start of the central directory  2 bytes
        #      total number of entries in the
        #      central directory on this disk  2 bytes
        #      total number of entries in
        #      the central directory           2 bytes
        #      size of the central directory   4 bytes
        #      offset of start of central
        #      directory with respect to
        #      the starting disk number        4 bytes
        #      .ZIP file comment length        2 bytes
        #      .ZIP file comment       (variable size)

        my $ecd = buf8.allocate(22 + $comment.elems);
        $ecd.write-uint32( 0, 0x06054b50,     LittleEndian); #ZIP_END_CENTRAL_HDR_SIG ; # signature
        $ecd.write-uint16( 4, 0,              LittleEndian); # number of disk
        $ecd.write-uint16( 6, 0,              LittleEndian); # number of disk with central dir
        $ecd.write-uint16( 8, $!entries,      LittleEndian); # entries in central dir on this disk
        $ecd.write-uint16(10, $!entries,      LittleEndian); # entries in central dir
        $ecd.write-uint32(12, $!cd-len,       LittleEndian); # size of central dir
        $ecd.write-uint32(16, $cd_offset,     LittleEndian); # offset to start central dir
        $ecd.write-uint16(20, $comment.elems, LittleEndian); # zipfile comment length
        $ecd.subbuf-rw(22) = $comment;

        return $ecd;
    }

    method save-hdr(Local-File-Header $hdr, Int $offset)
    {
        #   4.3.12  Central directory structure:
        #
        #      [central directory header 1]
        #      .
        #      .
        #      . 
        #      [central directory header n]
        #      [digital signature] 
        #
        #      File header:
        #
        #        central file header signature   4 bytes  (0x02014b50)
        #        version made by                 2 bytes
        #        version needed to extract       2 bytes
        #        general purpose bit flag        2 bytes
        #        compression method              2 bytes
        #        last mod file time              2 bytes
        #        last mod file date              2 bytes
        #        crc-32                          4 bytes
        #        compressed size                 4 bytes
        #        uncompressed size               4 bytes
        #        file name length                2 bytes
        #        extra field length              2 bytes
        #        file comment length             2 bytes
        #        disk number start               2 bytes
        #        internal file attributes        2 bytes
        #        external file attributes        4 bytes
        #        relative offset of local header 4 bytes
        #
        #        file name (variable size)
        #        extra field (variable size)
        #        file comment (variable size)
        
        my $ctl = buf8.allocate(46 + $hdr.file-name.elems + $hdr.file-comment.elems);
        $ctl.write-uint32( 0, 0x02014b50,                    LittleEndian);
        $ctl.write-uint16( 4, $hdr.version-made-by,          LittleEndian);
        $ctl.write-uint16( 6, $hdr.version-needed-to-extract,LittleEndian);
        $ctl.write-uint16( 8, $hdr.general-purpose-bit-flag, LittleEndian);
        $ctl.write-uint16(10, $hdr.compression-method,       LittleEndian);
        $ctl.write-uint32(12, $hdr.last-mod-file-time,       LittleEndian);
        $ctl.write-uint32(16, $hdr.crc32,                    LittleEndian);
        $ctl.write-uint32(20, $hdr.compressed-size,          LittleEndian);
        $ctl.write-uint32(24, $hdr.uncompressed-size,        LittleEndian);
        $ctl.write-uint16(28, $hdr.file-name.elems,          LittleEndian);
        $ctl.write-uint16(30, $hdr.extra-field-length,       LittleEndian);
        $ctl.write-uint16(32, $hdr.file-comment.elems,       LittleEndian);
        $ctl.write-uint16(34, 0,                             LittleEndian);
        $ctl.write-uint16(36, $hdr.internal-file-attributes, LittleEndian);
        $ctl.write-uint32(38, $hdr.external-file-attributes, LittleEndian);
        $ctl.write-uint32(42, $offset,                       LittleEndian);
        $ctl.subbuf-rw(46, $hdr.file-name.elems) = $hdr.file-name ;
        $ctl.subbuf-rw(46 + $hdr.file-name.elems, $hdr.file-comment.elems) = $hdr.file-comment ;

        @!central-headers.push($ctl) ;
        $!cd-len += $ctl.elems ; 
        ++ $!entries;
    }
}

