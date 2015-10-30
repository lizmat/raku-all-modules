unit module File::Temp:ver<0.02>;

use File::Directory::Tree;

# Characters used to create temporary file/directory names
my @filechars = flat('a'..'z', 'A'..'Z', 0..9, '_');
constant MAX-RETRIES = 10;

sub gen-random($n) {
    @filechars.roll($n).join
}

my @open-files;

sub make-temp($type, $template, $tempdir, $prefix, $suffix, $unlink) {
    my $count = MAX-RETRIES;
    while ($count--) {
        my $tempfile = $template;
        $tempfile ~~ s/ '*' ** 4..* /{ gen-random($/.chars) }/;
        my $name = $*SPEC.catfile($tempdir,"$prefix$tempfile$suffix");
        next if $name.IO ~~ :e;
        my $fh;
        if $type eq 'file' {
            $fh = try { CATCH { next }; open $name, :rw, :exclusive;  };
        }
        else {
            try { CATCH { next }; mkdir($name) };
        }
        push @open-files, $name if $unlink;
        return $type eq 'file' ?? ($name,$fh) !! $name;
    }
    return ();
}


sub tempfile (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = $*TMPDIR,      # where to create these temp files
    :$prefix? = '',             # filename prefix
    :$suffix? = '',             # filename suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {
    return make-temp('file', $template, $tempdir, $prefix, $suffix, $unlink);
}

our sub tempdir (
    $tmpl? = '*' x 10,          # positional template
    :$tempdir? = $*TMPDIR,      # where to create tempdir
    :$prefix? = '',             # directory prefix
    :$suffix? = '',             # directory suffix
    :$unlink?  = 1,             # remove when program exits?
    :$template = $tmpl          # required named template
) is export {
    return make-temp('dir', $template, $tempdir, $prefix, $suffix, $unlink);
}

END {
    for @open-files -> $f {
        next unless $f.IO ~~ :e; # maybe warn here

        if $f.IO ~~ :f
        {
            unlink($f);
        }
        elsif $f.IO ~~ :d
        {
            rmtree($f);
        }
    }
}

