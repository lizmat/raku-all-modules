unit module File::Temp:ver<0.0.3>;

use File::Directory::Tree;

# Characters used to create temporary file/directory names
my @filechars = flat('a'..'z', 'A'..'Z', 0..9, '_');
constant MAX-RETRIES = 10;

my %roster = ();
my Lock $roster-lock;
BEGIN { # Because --doc runs END
    $roster-lock = Lock.new;
}

my role File::Temp::AutoUnlink {
    submethod DESTROY {
        given self.path {
            if $_.path.IO ~~ :f { # Workaround, should just be $_ ~~ :f
                my $did;
                $roster-lock.protect: {
                    $did = %roster{$_.path}:delete;
                    $_.unlink if $did;
                };
                unless $did {
                    # Something (probably END) already unlinked it
                    # We could have a debug/testing flag do something here.
                }
            }
            # Directories will not get here yet
        }
    }
}

sub make-temp($type, $template, $tempdir, $prefix, $suffix, $unlink) {
    my $count = MAX-RETRIES;
    while ($count--) {
        my $tempfile = $template;
        $tempfile ~~ s/ '*' ** 4..* /{ @filechars.roll($/.chars).join }/;
        my $name = $*SPEC.catfile($tempdir,"$prefix$tempfile$suffix");
        next if $name.IO ~~ :e;
        my $fh;
        if $type eq 'file' {
            $fh = try { CATCH { next }; open $name, :rw, :exclusive;  };
            chmod(0o600,$name);
        }
        else {
            try { CATCH { next }; mkdir($name, 0o700) };
        }
        if $unlink {
            $roster-lock.protect: {
                %roster{$name} = True;
            };
            $fh &&= $fh does File::Temp::AutoUnlink;
        }
        return $type eq 'file' ?? ($name,$fh) !! $name;
    }
    fail "Unable to open temporary $type after {MAX-RETRIES} attempts";
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
    $roster-lock.protect: {
        # Workaround -- directly using %roster.keys not reliable under stress.
        my @rk = %roster.keys;
        for @rk -> $fn {
            if $fn.IO ~~ :f
            {
                unlink($fn);
            }
            elsif $fn.IO ~~ :d
            {
                rmtree($fn);
            }
        }
        %roster = ();
    }
}


=begin pod
=NAME       File::Temp
=SYNOPSIS

    # Generate a temp file in a temp dir
    my ($filename,$filehandle) = tempfile;

    # specify a template for the filename
    #  * are replaced with random characters
    my ($filename,$filehandle) = tempfile("******");

    # Automatically unlink files at end of program (this is the default)
    my ($filename,$filehandle) = tempfile("******", :unlink);

    # Specify the directory where the tempfile will be created
    my ($filename,$filehandle) = tempfile(:tempdir("/path/to/my/dir"));

    # don't unlink this one
    my ($filename,$filehandle) = tempfile(:tempdir('.'), :!unlink);

    # specify a prefix and suffix for the filename
    my ($filename,$filehandle) = tempfile(:prefix('foo'), :suffix(".txt"));

=DESCRIPTION

This module exports two routines:
=item tempfile
=item tempdir

=AUTHOR Jonathan Scott Duff <duff@pobox.com>
=end pod
