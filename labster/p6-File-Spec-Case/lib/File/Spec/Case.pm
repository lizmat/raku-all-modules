class File::Spec::Case;

method default-case-tolerant ($OS = $*OS) {
    so $OS eq any <MacOS Mac VMS darwin Win32 MSWin32 os2 dos NetWare symbian cygwin Cygwin epoc>;
}

method always-case-tolerant  ($OS = $*OS) {
    so $OS eq any <MacOS Mac VMS os2 dos>;
}

method sensitive(|c)   { not self.tolerant( |c ) }
method insensitive(|c) {     self.tolerant( |c ) }

method tolerant (Cool:D $path is copy = ~$*CWD, :$no_write = False ) {
    return True if self.always-case-tolerant($*OS);

    $path = $path.IO;
    $path.e or fail "Invalid path given";

    if $path.f and $path.basename ~~ /<+upper+lower-[\x00DF]>/ {
        return self!case-tolerant-file($path);
    }

    # try looking at everything in the current dir for letters
    $path = $path.parent unless $path.d;
    for $path.dir -> $fn {
        if $fn.basename ~~ /<+upper+lower-[\x00DF]>/ {
            return self!case-tolerant-file($fn);
        }
    }


    #if nothing in $path contains a letter, try writing a test file
    unless $no_write and !$path.w {
        # we already know this dir don't contain <lower+upper>,
        # so pick a random 8.3 name to avoid race conditions
        my $tmpname = "{('a'..'z').pick(8).join}.tmp";
        my $filelc = $path.child($tmpname);
        my $fileuc = $path.child($tmpname.uc);
        try {
            $filelc.spurt: :createonly,
                'temporary test file for p6 IO::Spec, feel free to delete';
            my $result = $fileuc.e;
            unlink $filelc;
            return $result;
        }
        CATCH { unlink $filelc if $filelc.e; }
    }

    # Okay, we don't have write access... give up and just return the platform default
    return self.default-case-tolerant($*OS);

}

method !case-tolerant-file( $path ) {
    my ($volume, $dirname, $basename) = $path.parts<volume dirname basename>;

    return False unless
           IO::Path.new( :$volume, :$dirname, basename => $basename.uc ).e
        && IO::Path.new( :$volume, :$dirname, basename => $basename.lc ).e;
    return +$path.parent.dir».basename.grep(/:i ^ {$path.basename} $/) <= 1;
    # this could be faster by comparing inodes of .uc and .lc
    # but we can't guarantee POSIXness of every platform that calls this
}



