module IO::Capture::Simple;

my $stdout = $*OUT;
my $stderr = $*ERR;
my $stdin = $*IN;

sub capture(Callable $code) is export {
    my ($out, $err, $in);

    capture_on($out, $err, $in);
    $code.();
    capture_off;

    $out, $err, $in;
}

sub capture_on($out is rw, $err is rw, $in is rw) is export {
    capture_stdout_on($out);
    capture_stderr_on($err);
    capture_stdin_on($in);
}

sub capture_off is export {
    $*OUT = $stdout;
    $*ERR = $stderr;
    $*IN = $stdin;
}

sub capture_stdout(Callable $code) is export {
    my $result;

    my $*OUT = class {
        method print(*@args) {
            $result ~= @args.join;
        }
        method flush {}
    }

    $code.();

    $result;
}

sub capture_stdout_on($target is rw) is export {
    $*OUT = class {
        method print(*@args) {
            $target ~= @args.join;
        }
        method flush {}
    }
}

sub capture_stdout_off is export {
    $*OUT = $stdout;
}

sub capture_stderr(Callable $code) is export {
    my $result;

    my $*ERR = class {
        method print(*@args) {
            $result ~= @args.join;
        }
    }

    $code.();

    $result;
}

sub capture_stderr_on($target is rw) is export {
    $*ERR = class {
        method print(*@args) {
            $target ~= @args.join;
        }
    }
}

sub capture_stderr_off is export {
    $*ERR = $stderr;
}

sub capture_stdin(Callable $code) is export {
    my $result;

    my $*IN = class {
        method get() {
            $result ~= $stdin.get;
        }
    }

    $code.();

    $result;
}

sub capture_stdin_on($target is rw) is export {
    $*IN = class {
        method get() {
            $target ~= $stdin.get;
        }
    }
}

sub capture_stdin_off is export {
    $*IN = $stdin;
}
