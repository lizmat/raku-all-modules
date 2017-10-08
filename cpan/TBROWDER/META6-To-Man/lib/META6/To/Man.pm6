unit module META6::To::Man;

use META6;

enum DirStat <NoWrite NoDir CanWrite>;

# variables set from input args
my $section;
# mandatory args
my $meta6      = 0; # META6 object
# options
my $man        = 0; # file name
my $debug      = 0; # 0 | 1
my $install    = 0; # 0 | 1
my $install-to = 0; # dir name
my $date       = Date.today.Str; # default

my $verbose    = 1; # default
my $quiet      = 0; # if true, then $verbose is set to 0

sub meta6-to-man(@*ARGS) is export {
    handle-args @*ARGS;

    my $f = write-man-file $man;

    if $verbose {
	say "Normal end.  See output file:";
	say "  $f";
    }

} # meta6-to-man

sub write-man-file($man is rw) {

    # extract data from the META6 file

    # mandatory: guaranteed to have these
    my $version = $meta6.AT-KEY: 'version';
    my $name    = $meta6.AT-KEY: 'name';
    my $descrip = $meta6.AT-KEY: 'description';

    # optional per spec
    my $src-url = $meta6.AT-KEY: 'source-url';
    my $license = $meta6.AT-KEY: 'license';

    my $supp    = $meta6.support;
    my $bugs    = $supp.bugtracker;

    if $debug {
	say "DEBUG: \$descrip  = '$descrip'";
	say "       \$name     = '$name'";
	say "       \$src-url  = '$src-url'";
	say "       \$bugs     = '$bugs'";
	say "       \$license  = '$license'";
    }

    # check required fields
    # need a file name
    if !$man {
        $section = 1;
        $man = $name ~ ".$section";
    }

    # generate the man file as a string first
    my $s  = ".TH $name $section $date Perl6.org\n";

    $s    ~= ".SH NAME $name\n";
    $s    ~= "item \- $descrip\n";

    $s    ~= ".SH SYNOPSIS\n";
    $s    ~= "use $name;\n";

    $s    ~= ".SH DESCRIPTION\n";
    $s    ~= "This module is in the Perl 6 ecosystem.\n";
    if $src-url {
	$s ~= "Its source can be found at\n";
	$s    ~= ".UR $src-url\n";
	$s    ~= ".UE .\n";
    }
    else {
	$s ~= "However, its source location is unknown.\n";
    }

    $s    ~= ".SH BUGS\n";
    $s    ~= "Submit bug reports to\n";
    if $bugs {
	$s    ~= ".UR $bugs\n";
	$s    ~= ".UE .\n";
    }
    else {
	$s    ~= "Perl 6 IRC channel #perl6.\n";
    }

    if $license {
	$s    ~= ".SH LICENSE\n";
	$s    ~= "$license\n";
    }

    #$s    ~= ".SH SEE ALSO\n";

    my $f = $man;
    if $install {
	# check the standard dirs
	my $d = check-install-standard $section;
	if $d {
            $f = "$d/$f";
	}
	else {
	    say "FATAL:  Unable to install to dir '$d'--check it exists with write privileges." if $verbose;
	    exit 1;
            #$f = "./$f";
	}
    }
    elsif $install-to {
        $f = "$install-to/$f";
    }

    # write the file
    spurt $f, $s;
    return $f;

} # write-man-file

sub check-date-value($val) {
    # date should be in yyyy-mm-dd format
    my $d = Date.new: $val;
    CATCH {
        say "FATAL: Date entry '$val' is not in YYYY-MM-DD format." if $verbose;
        exit 1;
    }
    $date = $d.Str;

} # check-date-value

sub check-meta6-value($val){
    # val is a valid META6.json file
    if !$val.IO.f {
        say "FATAL: File '$val' doesn't exist." if $verbose;
        exit 1;
    }
    my $m = META6.new: :file($val);
    CATCH {
        say "FATAL: File '$val' is not a valid META6 file." if $verbose;
        exit 1;
    }

    check-meta6-validity $m;

    $meta6 = $m;

} # check-meta6-value

sub check-install-to-value($val) {
    # $val is a directory name the user must be able to write to
    my $res = check-dir-status $val;

    if $res ~~ NoWrite  {
	say "FATAL: Unable to write to directory $val." if $verbose;
	exit 1;
    }
    elsif $res ~~ NoDir {
        say "FATAL: Directory $val doesn't exist." if $verbose;
        exit 1;
    }

    # must be okay
    $install-to = $val;

} # check-install-to-value

sub check-man-value($val) {
    # $val is the desired name of the man file. ensure it
    # has a valid file extension
    if $val ~~ / '.' (<[1..8>]> ** 1) $/ {
        # name is okay
        $man = $val;
        $section = ~$0;
    }
    else {
        say "FATAL: Man name '$val' needs a number extension in the range '1..8'." if $verbose;
        exit 1;
    }

} # check-man-value

sub handle-args(@*ARGS) {
    # check for debug first
    my @args;
    for @*ARGS {
        if /:i debug / {
	    $debug = 1;
            next;
        }
        @args.append: $_;
    }

    for @args {
	say "DEBUG: arg '$_'" if $debug;
	my $val;
	my $need-value = 0;
	if /:i ^ \s* '--' (<-[=]>+) \s* $ / {
	    # good arg format
	    $_ = ~$0;
	    say "  DEBUG: good arg format" if $debug;
	}
	elsif /:i ^ \s* '--' (<-[=]>+) '=' (<-[=]>+) \s* $ / {
	    # good arg format
	    say "  DEBUG: good arg format" if $debug;
	    $_   = ~$0;
	    $val = ~$1;
	}
	else {
	    say "FATAL: Unknown arg '$_'." if $verbose;
	    exit 1;
	}

	if $debug {
	    say "  DEBUG: good arg '$_'";
	    say "  DEBUG: good val '$val'" if $val.defined;
	}

	#===== options with a value
        when /:i ^ man  $ / {
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
            check-man-value $val;
	}
        when /:i ^ 'install-to'  $ / {
	    # option with value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
            check-install-to-value $val;
	}
        when /:i ^ meta6  $ / {
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
            check-meta6-value $val;
	}
        when /:i ^ date  $ / {
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if no value
	    if !$val.defined { $need-value++; proceed }
            check-date-value $val;
	}

	#===== options with NO value
        when /:i ^ install $ / {
	    # option with no value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if it has a value
	    proceed if $val.defined;
            $install = 1;
        }
        when /:i ^ quiet $ / {
	    # option with no value
	    say "  DEBUG: inside when block, option = '$_'" if $debug;
	    # skip if it has a value
	    proceed if $val.defined;
            $quiet = 1;
            $verbose = !$quiet;
        }
        default {
            my $msg;
	    if $val.defined {
		 $msg = "FATAL: Unknown arg with value '{$_}={$val}'.";
	    }
	    elsif $need-value {
		$msg = "FATAL: Known arg '{$_}' also needs a value (e.g., 'arg=value').";
	    }
	    else {
		$msg = "FATAL: Unknown arg '{$_}' with no value.";
	    }
            say "$msg" if $verbose;
	    exit 1;
        }
    }

    # one more check
    if !$meta6 {
	say "FATAL: Missing option '--meta6=M'." if $verbose;
        exit 1;
    }

} # handle-args

sub check-meta6-validity(META6 $m, :$file?) is export {
    # check for validity
    my $err = 0;
    my $msg = "ERROR:  META6 is missing mandatory key:";

    # mandatory attributes per spec
    for 'version', 'name', 'description' -> $k {
        unless $m.AT-KEY($k) {
            ++$err;
            say "$msg $k";
        }
    }
    =begin comment
    # doesn't work as expected; I filed META6 issue #9
    for 'version', 'name', 'description' -> $k {
        unless $m.EXISTS-KEY($k) {
            ++$err;
            say "$msg $k";
        }
    }
    =end comment

    if $err {
	if $file {
            say "FATAL:  Invalid META6 file: $file" if $verbose;
	}
	else {
            say "FATAL:  Invalid META6 file." if $verbose;
	}
        exit 1;
    }

} # check-meta6-validity

sub check-dir-status($dir --> DirStat) {
    if $dir.IO.d {
        # dir exists, can the user write to it?
        my $f = "$dir/.meta6-to-man";
        spurt $f, 'some text';
        CATCH {
	    say "WARNING: Unable to write to directory $dir." if $verbose;
	    return NoWrite;
        }
        # write is okay, remove the evidence
	unlink $f;
        return CanWrite;
    }

    # if we got here the dir doesn't exist
    say "WARNING: Directory $dir doesn't exist." if $verbose;
    return NoDir;
} # check-dir-status

sub check-install-standard($section --> Str) {
    # check the Linux FHS standard locations
    # and return the one to use, if any
    my @fhs = [
        "/usr/share/man/man{$section}",
        "/usr/local/share/man/man{$section}",
        "/usr/local/man/man{$section}",
    ];

    for @fhs -> $d {
	my $res = check-dir-status $d;
	return $d if $res ~~ CanWrite;
    }

    return '';

} # check-install-standard
