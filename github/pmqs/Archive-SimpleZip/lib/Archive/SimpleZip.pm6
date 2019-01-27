
unit module Archive::SimpleZip;

need Compress::Zlib;
need Compress::Bzip2;

use IO::Blob;

use Archive::SimpleZip::Utils ;
use Archive::SimpleZip::Headers ;#:ALL :DEFAULT<Zip-CM>;

# Use CompUnit::Util for now to re-export the Zip-CM enum 
# from Archive::SimpleZip::Headers. 
# rakudo issue seems to be this ticket: https://github.com/perl6/roast/issues/45
use CompUnit::Util :re-export;
BEGIN re-export('Archive::SimpleZip::Headers');


class SimpleZip is export
{
    has IO::Handle               $!zip-filehandle ;
    has IO::Path                 $.filename ;
    has Str                      $.comment ;
    has Instant                  $!now = DateTime.now.Instant;
    has Zip-CM                   $!default-method ;
    has Bool                     $!any-zip64 = False;
    # Defaults
    has Bool                     $!zip64 = False ;
    has Bool                     $.default-stream ;
    has Bool                     $.default-canonical ;

    has Central-Header-Directory $!cd .= new() ;

    has Bool                     $!opened = True;

    multi method new(Str $filename, |c)
    {
        my $zip-filehandle = open $filename, :w, :bin ;
        self.bless(:$zip-filehandle, filename => $filename.IO, |c);
    }

    multi method new(IO::Path $filename, |c)
    {
        my $zip-filehandle = open $filename, :w, :bin ;
        self.bless(:$zip-filehandle, :$filename, |c);
    }

    multi method new(Blob $data, |c)
    {
        my IO::Blob $zip-filehandle .= new($data);
        self.bless(:$zip-filehandle, |c);
    }

    multi submethod BUILD(IO::Handle :$!zip-filehandle?, 
                          IO::Path   :$!filename?,
                          Str        :$!comment = "",
                          Bool       :stream($!default-stream) = False, 
                          Bool       :canonical-name($!default-canonical) = True,
                          Zip-CM     :method($!default-method) = Zip-CM-Deflate,
                         #Bool       :$!zip64   = False, 
                         )
    {
        $!any-zip64 = True 
            if $!zip64 ;
    }

    multi method add(Str $string, |c)
    {
        #say "add Str";
        my IO::Blob $fh .= new($string);
        samewith($fh, |c);
    }

    multi method add(IO::Path $path, |c)
    {
        #say "add IO";
        my IO::Handle $fh = open($path, :r, :bin);
        samewith($fh, :name(Str($path)), :time($path.modified), |c);
    }

    multi method add(IO::Handle  $handle, 
                     Str        :$name    = '', 
                     Str        :$comment = '',
                     Instant    :$time    = $!now,
                     Bool       :$stream  = $!default-stream,
                     Bool       :$canonical-name = $!default-canonical,
                     Zip-CM     :$method  = $!default-method)
    {
        my $compressed-size = 0;
        my $uncompressed-size = 0;
        my $crc32 = 0;

        my $hdr = Local-File-Header.new();

        $hdr.last-mod-file-time = get-DOS-time($time);
        $hdr.compression-method = $method ;
        if $canonical-name
            { $hdr.file-name = make-canonical-name($name).encode }
        else
            { $hdr.file-name = $name.encode }
        $hdr.file-comment = $comment.encode;

        $hdr.general-purpose-bit-flag +|= Zip-GP-Streaming-Mask 
            if $stream ;

        my $start-local-hdr = $!zip-filehandle.tell();
        my $local-hdr = $hdr.get();
        $!zip-filehandle.write($local-hdr) ;

        my $read-action;
        my $flush-action;

        given $method
        {
            when Zip-CM-Deflate 
            {
                my $zlib = Compress::Zlib::Stream.new(:deflate);
                $read-action  = -> $in { $zlib.deflate($in) } ;
                $flush-action = ->     { $zlib.finish()     } ;
            }

            when Zip-CM-Bzip2 
            {
                my $zlib = Compress::Bzip2::Stream.new(:deflate);
                $read-action  = -> $in { $zlib.compress($in) } ;
                $flush-action = ->     { $zlib.finish()      } ;
            }

            when Zip-CM-Store
            {
                $read-action  = -> $in { $in         } ;
                $flush-action = ->     { Blob.new()  } ;
            }
        }

        # These are done for all compression formats
        my $reader  = -> $in { $uncompressed-size += $in.elems;  
                               $crc32 = crc32($crc32, $in);
                               my $out = $read-action($in); 
                               $compressed-size += $out.elems; 
                               $out
                             } ; 
        my $flusher = ->     { my $out = $flush-action(); 
                               $compressed-size += $out.elems; 
                               $out
                             } ;

        while $handle.read(1024 * 4) -> $chunk
        {
            $!zip-filehandle.write($reader($chunk));
        }
        $!zip-filehandle.write($flusher());

        $hdr.compressed-size = $compressed-size ;
        $hdr.uncompressed-size = $uncompressed-size;
        $hdr.crc32 = $crc32;

        if $stream
        {
            $!zip-filehandle.write($hdr.data-descriptor()) ;
        }
        else
        {
            my $here = $!zip-filehandle.tell();
            $!zip-filehandle.seek($start-local-hdr + 14, SeekFromBeginning);
            $!zip-filehandle.write($hdr.crc-and-sizes());
            $!zip-filehandle.seek($here, SeekFromBeginning);
        }

        $!cd.save-hdr($hdr, $start-local-hdr);
    }

    method close()
    {
        return True
            if ! $!opened;

        $!opened = False;

        my $start-cd = $!zip-filehandle.tell();
        
        for $!cd.get-hdrs() -> $ch
        {
            $!zip-filehandle.write($ch) ;
        }

        $!zip-filehandle.write($!cd.end-central-directory($start-cd, $.comment.encode));

        $!zip-filehandle.close();

        return True;
    }

    method DESTROY()
    {
        self.close();
    }

}

=begin pod
=NAME       Archive::SimpleZip
=SYNOPSIS

    use Archive::SimpleZip;

    # Create a zip archive in filesystem
    my $obj = SimpleZip.new("mine.zip");

    # Create a zip archive in memory
    my $blob = Blob.new();
    my $obj2 = SimpleZip.new($blob);

    # Add a file to the zip archive
    $obj.add("somefile.txt".IO);

    # Add a Blob/String to the zip archive
    $obj.add("payload data here", :name<data1>);

    $obj.close();

=DESCRIPTION

Simple write-only interface to allow creation of Zip files.

Please note - this is module is a prototype. The interface will change.

=head1 METHODS

=head2 method new

Instantiate a SimpleZip object

    my $zip = SimpleZip.new("my.zip");

If the first parameter is a string or IO::Path the zip archive will be
created in the filesystem.

To create an in-memory zip archive the first parmameter must be a Blob.

    my $archive = Blob.new;
    my $zip = SimpleZip.new($archive);

=head3 Options

Most of these options control the setting of defaults that will be used in
subsequent calls to the C<add> method.

The default setting can be overridden for an individual member where the
constructor, C<new>, and the C<add> method have an identically named
options.

For example:

    #  Set the default to make all members in the archive streamed.
    my $zip = SimpleZip.new($archive, :stream);

    # This uses the default, so is streamed
    $zip.add("file1".IO)  ;

    # This changes the default, so is NOT streamed
    $zip.add("file1".IO, :!stream)  ;

    # This uses the default, so is streamed
    $zip.add("file1".IO)  ;

=head4 stream => True|False

Write the zip archive in streaming mode. Default is False.

    my $zip = SimpleZip.new($archive, :stream);

Specify the C<stream> option on individual call to C<add> to override
this default.

=head4 method => Zip-CM-Deflate|Zip-CM-Bzip2|Zip-CM-Store

Used to set the default compression algorithm used for all members of the
archive. If not specified then <Zip-CM-Deflate> is the default.

Specify the C<method> option on individual call to C<add> to override
this default.

Valid values are

=item Zip-CM-Deflate
=item Zip-CM-Bzip2
=item Zip-CM-Store

=head4 comment => String

Creates a comment for the archive.

    my $zip = SimpleZip.new($archive, comment => "my comment");

=head4 canonical-name => True|False

Used to set the default for I<normalizing> the I<name> field before it is
written to the zip archive. The normalization carried out involves
converting the name into a Unix-style relative path.

To be precise, this is what APPNOTE.TXT (the specification for Zip
archives) has to say on what should be stored in the zip name header field.

    The name of the file, with optional relative path.
    The path stored MUST not contain a drive or
    device letter, or a leading slash.  All slashes
    MUST be forward slashes '/' as opposed to
    backwards slashes '\' for compatibility with Amiga
    and UNIX file systems etc.  

Unless you have a use-case that needs non-standard Zip member names, you
should leave this option well alone.

Unsurprizingly then, the default for this option is True.

Example

    my $zip = SimpleZip.new($archive, :!canonical-name); # 

=head4 Bool zip64 => True|False

TODO

Specify the C<zip64> option on individual call to C<add> to override
this default.

=head2 method add

Used to add a file or blob to a Zip archive. The method expects one
mandatory parameter and zero or more optional parameters.

To add a file from the filesystem the first parameter must be of type
IO::Path

    # Add a file to the zip archive
    $zip.add("/tmp/fred".IO);

To add a string/blob to 

    # Add a string to the zip archive
    $zip.add("payload data here", :name<data1>);

    # Add a blob to the zip archive
    my Blob $data .= new;
    $zip.add($data, :name<data1>);

=head3 Options

=head4 name => String

Set the B<name> field in the zip archive. 

When a filename is passed to C<add>, the value passed in this option will
be stored in the Zip archive, rather than the filename.

If the canonical-name option is True, the name will be normalized to Unix
format before being written to the Zip archive.

=head4 method => Zip-CM-Deflate|Zip-CM-Bzip2|Zip-CM-Store

Used to set the compression algorithm used for this member. If C<method>
has not been specifed here or in C<new> it will default to
C<Zip-CM-Deflate>.

Valid values are

=item Zip-CM-Deflate
=item Zip-CM-Bzip2
=item Zip-CM-Store

=head4 Bool stream => True|False

Write this member in streaming mode.

=head4 comment

Creates a comment for the member.

    my $zip = SimpleZip.new($archive, comment => "my comment");

=head4 canonical-name  => True|False

Controls how the I<name> field is written top the zip archive. See the 

=head4 zip64 => True|False

=head1 TODO

=item Zip64
=item Support for extra fields
=item Standard extra fields for better time
=item Adding directories & symbolic links

=AUTHOR Paul Marquess <pmqs@cpan.org>
=end pod

