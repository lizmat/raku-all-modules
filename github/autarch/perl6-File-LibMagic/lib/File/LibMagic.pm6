use v6;
use NativeCall;

unit class File::LibMagic:ver<0.0.1>:auth<github:autarch>;

my class X is Exception {
    has $!message;
    submethod BUILD (:$!message) { }
    method message {
        return "error from libmagic: $!message";
    }
}

my class Cookie is repr('CPointer') {
    method new (int32 $flags, Cool @magic-files) returns Cookie {
        my $cookie = magic_open($flags)
            or X.new( message => 'out of memory' ).throw;

        my $files = @magic-files.elems ?? @magic-files.join(':') !! (Str);
        my $ok = magic_load( $cookie, $files );
        unless $ok >= 0 {
            X.new( message => magic_error($cookie) ).throw;
        }

        return $cookie;
    }
    sub magic_open (int32) returns Cookie is native('magic', v1) { * }
    sub magic_load (Cookie, Str) returns int32 is native('magic', v1) { * }

    method DESTROY is native('magic', v1) is symbol('magic_close') { * }

    # It's a lot easier to just read this much data in and then call
    # magic_buffer than it is to try to actually pass a Perl handle to
    # magic_descriptor.
    #
    # The BUFSIZE is how much data libmagic will want, so we just pass that
    # much.
    my \BUFSIZE = 256 * 1024;
    method magic-descriptor (int32 $flags, IO::Handle $file) returns Str {
        $file.seek(0);
        my $buffer = $file.read(BUFSIZE);
        return self.magic-buffer( $flags, $buffer );
    }

    method magic-file (int32 $flags, Cool $filename) returns Str {
        self.setflags($flags);
        # We need the .Str to turn things like an IO::Path into an actual Str
        # for the benefit of NativeCall.
        return magic_file( self, $filename.Str )
            // self.throw-error;
    }
    sub magic_file (Cookie, Str) returns Str is native('magic', v1) { * }

    # I tried making magic-buffer a multi method with magic_buffer as a
    # corresponding multi sub but I kept getting errors about signatures not
    # matching. I'll go the ugly but working route for now.
    method magic-string (int32 $flags, Str $buffer) returns Str {
        self.setflags($flags);
        return magic_string( self, $buffer, $buffer.encode('UTF-8').elems )
            // self.throw-error;
    }
    sub magic_string (Cookie, Str, int32) returns Str is native('magic', v1) is symbol('magic_buffer') { * }

    method magic-buffer (int32 $flags, Buf[uint8] $buffer) returns Str {
        self.setflags($flags);

        my $c-array = CArray[uint8].new;
        $c-array[$_] = $buffer[$_] for ^$buffer.elems;

        return magic_buffer( self, $c-array, $buffer.elems )
            // self.throw-error;
    }
    sub magic_buffer (Cookie, CArray[uint8], int32) returns Str is native('magic', v1) { * }

    method setflags(int32 $flags) {
        magic_setflags(self, $flags);
    }
    sub magic_setflags (Cookie, int32) is native('magic', v1) { * }

    method throw-error {
        X.new( message => magic_error(self) // 'failed without error' ).throw;
    }
    sub magic_error (Cookie) returns Str is native('magic', v1) { * }
}

has Cookie $!cookie;
has int32 $!flags;
has Cool @magic-files;

# Copied from /usr/include/magic.h on my system
my \MAGIC_NONE               = 0x000000; #  No flags 
my \MAGIC_DEBUG              = 0x000001; #  Turn on debugging 
my \MAGIC_SYMLINK            = 0x000002; #  Follow symlinks 
my \MAGIC_COMPRESS           = 0x000004; #  Check inside compressed files 
my \MAGIC_DEVICES            = 0x000008; #  Look at the contents of devices 
my \MAGIC_MIME_TYPE          = 0x000010; #  Return the MIME type 
my \MAGIC_CONTINUE           = 0x000020; #  Return all matches 
my \MAGIC_CHECK              = 0x000040; #  Print warnings to stderr 
my \MAGIC_PRESERVE_ATIME     = 0x000080; #  Restore access time on exit 
my \MAGIC_RAW                = 0x000100; #  Don't translate unprintable chars 
my \MAGIC_ERROR              = 0x000200; #  Handle ENOENT etc as real errors 
my \MAGIC_MIME_ENCODING      = 0x000400; #  Return the MIME encoding 
my \MAGIC_MIME               = (MAGIC_MIME_TYPE +| MAGIC_MIME_ENCODING);
my \MAGIC_APPLE              = 0x000800; #  Return the Apple creator and type 
my \MAGIC_NO_CHECK_COMPRESS  = 0x001000; #  Don't check for compressed files 
my \MAGIC_NO_CHECK_TAR       = 0x002000; #  Don't check for tar files 
my \MAGIC_NO_CHECK_SOFT      = 0x004000; #  Don't check magic entries 
my \MAGIC_NO_CHECK_APPTYPE   = 0x008000; #  Don't check application type 
my \MAGIC_NO_CHECK_ELF       = 0x010000; #  Don't check for elf details 
my \MAGIC_NO_CHECK_TEXT      = 0x020000; #  Don't check for text files 
my \MAGIC_NO_CHECK_CDF       = 0x040000; #  Don't check for cdf files 
my \MAGIC_NO_CHECK_TOKENS    = 0x100000; #  Don't check tokens 
my \MAGIC_NO_CHECK_ENCODING  = 0x200000; #  Don't check text encodings 

submethod BUILD (:@!magic-files = (), *%flag-args) {
    $!flags = 0;
    $!flags = self.flags-from-args(%flag-args);
    $!cookie = Cookie.new( $!flags, @!magic-files );
    return;
}

method from-filename (Cool $filename, *%flag-args) returns Hash {
    return self!info-using( 'magic-file', $filename, %flag-args );
}

method from-handle (IO::Handle $handle, *%flag-args) returns Hash {
    return self!info-using( 'magic-descriptor', $handle, %flag-args );
}

method from-buffer (Stringy $buffer, *%flag-args) returns Hash {
    my $method = $buffer ~~ Buf[uint8] ?? 'magic-buffer' !! 'magic-string',
    return self!info-using( $method, $buffer, %flag-args );
}

method !info-using(Str $method, $arg, %flag-args) returns Hash {
    my $flags = self.flags-from-args(%flag-args);

    my $description = $!cookie."$method"( $flags +| MAGIC_NONE,          $arg );
    my $mime-type   = $!cookie."$method"( $flags +| MAGIC_MIME_TYPE,     $arg );
    my $encoding    = $!cookie."$method"( $flags +| MAGIC_MIME_ENCODING, $arg );

    return %(
        description => $description,
        mime-type   => $mime-type,
        encoding    => $encoding,
        mime-type-with-encoding => self!mime-type-with-encoding( $mime-type, $encoding ),
    );
}

method flags-from-args(%flag-args) {
    state %flag-map = (
        debug           => MAGIC_DEBUG,
        follow-symlinks => MAGIC_SYMLINK,
        uncompress      => MAGIC_COMPRESS,
        open-devices    => MAGIC_DEVICES,
        preserve-atime  => MAGIC_PRESERVE_ATIME,
        raw             => MAGIC_RAW,
    );

    my $flags = 0;
    for %flag-map.keys -> $k {
        $flags +|= %flag-map{$k} if %flag-args{$k};
    }

    return $!flags +| $flags;
}

method !mime-type-with-encoding ($mime-type, $encoding) returns Str {
    return $mime-type unless $encoding;
    return "$mime-type; charset=$encoding";
}

method magic-version returns int32 {
    return magic_version();
    # libmagic didn't define magic_version until relatively late, so there are
    # distros out there which don't provide this function.
    CATCH {
        return 0;
    }
}

sub magic_version returns int32 is native('magic', v1) { * }

=begin pod

=NAME

File::LibMagic - Determine content type and encoding using libmagic

=SYNOPSIS

    use File::LibMagic;

    my $magic = File::LibMagic.new;

    my %info = $magic.from-filename( 'path/to/file.pm6' );
    if %info<mime-type> ~~ rx{ ^ 'text/' } { ... }

=DESCRIPTION

This class provides an API that allows you to get the MIME type and encoding
of a file or chunk of in-memory content. It uses the libmagic C library, so
you will need to have this installed in order for this class to work.

=METHOD File::LibMagic.new(...)

The constructor creates a new magic object. It accepts the following
named parameters:

=item C<Str @magic-files>

This should be a list of filenames containing magic definitions. This is
optional, and if it's not provided then libmagic will use the default magic
file on your system (usually something like C</usr/share/file/magic.mgc>).

=item C<Bool $follow-symlinks>

By default, libmagic simply returns C<inode/symlink> as the MIME type for
symlinks. If this parameter is set to C<True>, then libmagic will resolve
symlinks and given the MIME information for the file that the symlink points.

=item C<Bool $uncompress>

By default, when given a compressed file, libmagic gives you a MIME type based
on the compression format like C<application/gzip>. If this is set to C<True>
then libmagic will uncompress the file and give you the MIME information for
the uncompressed file.

=item C<Bool $open-devices>

By default, libmagic gives you the type of the device file, something like
C<inode/blockdevice>. If this is set to C<True>, then libmagic will open the
device, read data from it, and give you the MIME information for that data.

=item C<Bool $preserve-atime>

If this is set to C<True>, libmagic will attempt to preserve the file access
time of files it reads.

B<Note that because of some internal implementation details of this Perl 6
class, this does not work if you call the C<from-handle> method>.

=item C<Bool $raw>

If this is set to C<True>, then non-printable characters in any data returned
by the library are left as-is, rather than being translated into an octal
representation (\011).

=item C<Bool $debug>

If this is true then libmagic will print out a lot of debugging information as
it goes.

=METHODS

All of the information methods for this class return the same hash structure:

    {
        description => 'A description of this MIME type',
        mime-type   => 'mime/type',
        encoding    => 'UTF-8',
        mime-type-with-encoding => 'mime/type; charset=UTF-8',
    }

All of the methods take any of the flags that can be passed to
constructor. These flags only apply for the method call during which they're
passed, and override any flags passed to the constructor for that one method
call.

=METHOD $magic.from-filename( $filename, %flags )

This method takes a filename as a string or L<IO::Path> and returns the MIME
information for that filename.

=METHOD $magic.from-handle( $handle, %flags )

This method takes a handle opened for reading and returns the MIME information
for that filename.

Note that this method will actually read data from the file, moving the file
pointer. If you want to use the handle later, you should probably could
C<.seek> on it.

=METHOD $magic.from-buffer( $buffer, %flags )

This method accepts a C<Str> or C<Buf> and returns the MIME information for
the data in that object.

=end pod
