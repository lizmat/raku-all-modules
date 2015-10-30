use v6;
use HTTP::Tinyish::Base;
use HTTP::Tinyish::FileTempFactory;

unit class HTTP::Tinyish::Curl is HTTP::Tinyish::Base;

my constant DEBUG = %*ENV<HTTP_TINYISH_DEBUG>;

has $.curl = "curl";
has Int $.timeout = 60;
has Int $.max-redirect = 5;
has $.agent = $?PACKAGE.perl;
has %.default-headers;
has Bool $.verify-ssl = True;
has $!factory = HTTP::Tinyish::FileTempFactory.new;

method request($method, $url, Bool :$bin = False, *%opts) {
    LEAVE { $!factory.cleanup }
    my ($out-file, $out-fh) = $!factory.tempfile;
    my ($err-file, $err-fh) = $!factory.tempfile;
    my ($header-file, $header-fh) = $!factory.tempfile;
    my @cmd =
        $!curl,
        "-X", $method,
        self!build-options($url, |%opts),
        "--dump-header", $header-file
    ;
    @cmd.push("--head") if $method eq "HEAD";
    @cmd.push($url);
    warn "=> @cmd[]" if DEBUG;
    my $status = run |@cmd, :out($out-fh), :err($err-fh);
    $_.close for $out-fh, $err-fh; # XXX
    if $status.exitcode != 0 {
        my $err = $err-file.IO.slurp(:$bin);
        return self.internal-error($url, $err);
    }
    my %res = url => $url, content => $out-file.IO.slurp(:$bin);
    self.parse-http-header($header-file.IO.slurp, %res);
    return %res;
}

method mirror($url, $file, Bool :$bin = False, *%opts) {
    LEAVE { $!factory.cleanup }
    my ($out-file, $out-fh) = $!factory.tempfile;
    my ($err-file, $err-fh) = $!factory.tempfile;
    my ($header-file, $header-fh) = $!factory.tempfile;
    my @cmd =
        $!curl,
        self!build-options($url, |%opts),
        "-z", $file,
        "-o", $file,
        "--dump-header", $header-file,
        "--remote-time",
        $url,
    ;
    my $status = run |@cmd, :out($out-fh), :err($err-fh);
    $_.close for $out-fh, $err-fh; # XXX
    if ($status.exitcode != 0) {
        my $err = $err-file.IO.slurp(:$bin);
        return self.internal-error($url, $err);
    }
    my %res = url => $url, content => $out-file.IO.slurp(:$bin);
    self.parse-http-header($header-file.IO.slurp, %res);
    return %res;
}

method !build-options($url, *%opts) {
    my %headers;
    if %!default-headers {
        %headers = |%!default-headers;
    }
    if %opts<headers> {
        %headers = |%headers, |%opts<headers>;
    }

    my @options =
        '--location',
        '--silent',
        '--max-time', $!timeout,
        '--max-redirs', $!max-redirect,
        '--user-agent', $!agent,
    ;
    self!translate-headers(%headers, @options);
    @options.push("--insecure") unless $.verify-ssl;
    if %opts<content>:exists {
        my ($data-file, $data-fh) = $!factory.tempfile;
        if %opts<content> ~~ Callable {
            while %opts<content>() -> $chunk {
                $data-fh.write($chunk ~~ Str ?? $chunk.encode !! $chunk);
            }
        } else {
            $data-fh.write(%opts<content> ~~ Str ?? %opts<content>.encode !! %opts<content>);
        }
        @options.push('--data-binary', "\@$data-file");
    }
    |@options;
}

method !translate-headers(%headers, @options) {
    for %headers.kv -> $field, $value {
        if $value ~~ Positional {
            @options.append( $value.map({|("-H", "$field:$_")}) );
        } else {
            @options.push("-H", "$field:$value");
        }
    }
}
