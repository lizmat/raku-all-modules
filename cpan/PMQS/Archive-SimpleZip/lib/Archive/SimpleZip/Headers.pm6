
unit module Archive::SimpleZip::Headers;

use experimental :pack;

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
            Zip-CM-Store         => 20,
            Zip-CM-Deflate       => 20,
            Zip-CM-Bzip2         => 46,
            #Zip-CM-LZMA         => 63,
            #Zip-CM-PPMD         => 63,
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

        my Blob $hdr ;
        $hdr  = pack 'V', local-file-header-signature ;

        $hdr ~= pack 'v', $.version-needed-to-extract   ; # 2 bytes
        $hdr ~= pack 'v', $.general-purpose-bit-flag ;    # 2 bytes
        $hdr ~= pack 'v', $.compression-method ;          # 2 bytes
        $hdr ~= pack 'V', $.last-mod-file-time ;          # 2 bytes
        $hdr ~= pack 'V', $.crc32 ;                       # 4 bytes
        $hdr ~= pack 'V', $.compressed-size ;             # 4 bytes
        $hdr ~= pack 'V', $.uncompressed-size ;           # 4 bytes
        $hdr ~= pack 'v', $.file-name.elems;              # 2 bytes
        $hdr ~= pack 'v', $.extra-field-length ;          # 2 bytes
        $hdr ~= $.file-name ;

        return $hdr ;
    }

    method data-descriptor()
    {
        #   4.3.9  Data descriptor:
        #
        #        crc-32                          4 bytes
        #        compressed size                 4 bytes
        #        uncompressed size               4 bytes    

        constant signature = 0x08074b50 ; # 4 bytes  (0x04034b50)
        my Blob $hdr ;
        $hdr  = pack 'V', signature ;
        $hdr ~= pack 'V', $.crc32 ;                       # 4 bytes
        $hdr ~= pack 'V', $.compressed-size ;             # 4 bytes
        $hdr ~= pack 'V', $.uncompressed-size ;           # 4 bytes

        return $hdr ;
    }


    method crc-and-sizes()
    {
        my Blob $hdr ;
        $hdr  = pack 'V', $.crc32 ;                       # 4 bytes
        $hdr ~= pack 'V', $.compressed-size ;             # 4 bytes
        $hdr ~= pack 'V', $.uncompressed-size ;           # 4 bytes

        return $hdr ;
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

        my Blob $ecd ;
        $ecd  = pack "V", 0x06054b50 ; #ZIP_END_CENTRAL_HDR_SIG ; # signature
        $ecd ~= pack 'v', 0          ; # number of disk
        $ecd ~= pack 'v', 0          ; # number of disk with central dir
        $ecd ~= pack 'v', $!entries   ; # entries in central dir on this disk
        $ecd ~= pack 'v', $!entries   ; # entries in central dir
        $ecd ~= pack 'V', $!cd-len    ; # size of central dir
        $ecd ~= pack 'V', $cd_offset ; # offset to start central dir
        $ecd ~= pack 'v', $comment.elems ; # zipfile comment length
        $ecd ~= $comment;

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
        
        my Blob $ctl ;

        $ctl  = pack "V", 0x02014b50 ; # ZIP_CENTRAL_HDR_SIG ; # signature
        $ctl ~= pack 'v', $hdr.version-made-by    ;          # version made by
        $ctl ~= pack 'v', $hdr.version-needed-to-extract   ; # extract Version & OS
        $ctl ~= pack 'v', $hdr.general-purpose-bit-flag ;    # 2 bytes
        $ctl ~= pack 'v', $hdr.compression-method ;          # 2 bytes
        $ctl ~= pack 'V', $hdr.last-mod-file-time ;          # 4 bytes
        $ctl ~= pack 'V', $hdr.crc32 ;                       # 4 bytes
        $ctl ~= pack 'V', $hdr.compressed-size ;             # 4 bytes
        $ctl ~= pack 'V', $hdr.uncompressed-size ;           # 4 bytes
        $ctl ~= pack 'v', $hdr.file-name.elems ;             # 2 bytes
        $ctl ~= pack 'v', $hdr.extra-field-length ;          # 2 bytes
        $ctl ~= pack 'v', $hdr.file-comment.elems ;          # 2 bytes
        $ctl ~= pack 'v', 0                     ;            # 2 bytes
        $ctl ~= pack 'v', $hdr.internal-file-attributes ;    # 2 bytes
        $ctl ~= pack 'V', $hdr.external-file-attributes ;    # 4 bytes
        $ctl ~= pack 'V', $offset ;                          # 4 bytes
        $ctl ~= $hdr.file-name ;
        $ctl ~= $hdr.file-comment ;

        @!central-headers.push($ctl) ;
        $!cd-len += $ctl.elems ; 
        ++ $!entries;
    }
}

