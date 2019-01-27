use v6;

#
# A simple Tika server wrapper that provides the following methods:
# - meta
# - text
# - version
# -TODO document more...
#
unit class Tika;

use HTTP::UserAgent;
use HTTP::Request::Common;

# Fields
has Str             $.hostname;
has Int             $.port;
has Proc::Async     $!tika-server-process;
has HTTP::UserAgent $!ua;

# Constructor
method BUILD {
    $!ua          = HTTP::UserAgent.new;
    $!ua.timeout  = 10;
    $!hostname    = 'localhost';
    $!port        = 9998;
}

method start {
    my $proc = Proc::Async.new(
        'java',
        '-jar',
        %?RESOURCES{'tika-server-1.19.1.jar'}
    );

    $proc.stdout.tap(
        -> $v   { print "Output: $v" },
        quit => { say 'caught exception ' ~ .^name }
    );
    $proc.stderr.tap(
        -> $v { print "Error:  $v" }
    );

    $!tika-server-process = $proc;

    $proc.start;
    #TODO what to do with promise
}

method stop {
    $!tika-server-process.kill
        if $!tika-server-process.defined;
}

method rmeta {
    ...
}

method unpack {
    ...
}

method parsers {
    my $response = $!ua.get(self._url("parsers"));
    die $response.status-line unless $response.is-success;
    $response.content;
}

method detectors {
    my $response = $!ua.get(self._url("detectors"));
    die $response.status-line unless $response.is-success;
    $response.content;
}

method version {
    my $response = $!ua.get(self._url("version"));
    die $response.status-line unless $response.is-success;
    $response.content;
}

method meta(Str $filename, $content-type = Nil) {
    #TODO content_type ||= MIME::Types.type_for(filename).first.content_type
    my $request = PUT(
        self._url('meta'),
        :content($filename.IO.slurp(:bin)),
        :Content-Type($content-type)
    );
    my $response = $!ua.request($request);
    die $response.status-line unless $response.is-success;
    $response.content;
}

method text(Str $filename, $content-type = Nil) {
    #TODO content_type ||= MIME::Types.type_for(filename).first.content_type
    my $request = PUT(
        self._url('tika'),
        :content($filename.IO.slurp(:bin)),
        :Content-Type($content-type)
    );
    my $response = $!ua.request($request);
    die $response.status-line unless $response.is-success;
    $response.content;
}

method mime-type(Str $filename) {
    my $request = PUT(
        self._url('detect/stream'),
        :content($filename.IO.slurp(:bin)),
        :Content-Disposition("attachment; filename=$filename")
    );
    my $response = $!ua.request($request);
    die $response.status-line unless $response.is-success;
    $response.content;
}

method language(Str $string) {
    my $request = PUT(
        self._url('language/string'),
        :content($string)
    );
    my $response = $!ua.request($request);
    die $response.status-line unless $response.is-success;
    $response.content;
}

method _url(Str $endpoint) {
    "http://$!hostname:$!port/$endpoint"
}

method _truncate(Str $string, Int $length) {
    if $string.chars <= $length {
        $string
    } else {
        $string.substr(0..$length - 3).trim ~ '...'
    }
}
