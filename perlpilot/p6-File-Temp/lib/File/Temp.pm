module File::Temp:ver<0.02>;

# Characters used to create temporary file/directory names
my @filechars = 'a'..'z', 'A'..'Z', 0..9, '_';
constant MAX-RETRIES = 10;

sub gen-random($n) {
    @filechars.roll($n).join
}

my @open-files;

sub tempfile (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = $*TMPDIR,      # where to create these temp files
    :$prefix? = '',             # filename prefix
    :$suffix? = '',             # filename suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {

    my $count = MAX-RETRIES;
    while ($count--) {
        my $tempfile = $template;
        $tempfile ~~ s/ '*' ** 4..* /{ gen-random($/.chars) }/;
        my $filename = "$tempdir/$prefix$tempfile$suffix";
        next if $filename.IO ~~ :e;
        my $fh = try { CATCH { next }; open $filename, :w;  };
        push @open-files, $filename if $unlink;
        return $filename,$fh;
    }
    return ();
}

END {
    for @open-files -> $f {
        unlink($f);
    }
}

