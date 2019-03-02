use v6;

use Smack::Component;

unit class Smack::App::File does Smack::Component;

use Smack::Date;
use Smack::Exception;
use Smack::MIME;

has IO::Path $.root;
has IO::Path $.file;
has $.content-type;
has Str $.encoding;
has UInt $.chunk-size = 8192;

submethod TWEAK() {
    die "either root or file must be defined, but not both"
        unless $!root.defined ^^ $!file.defined;
}

method configure(%env) { }

method should-handle($file) { $file.f }

method call(%env) {
    start {
        my $response;
        try {
            my ($file, $path-info) = $.file // self.locate-file(%env);

            CATCH {
                when (X::Smack::Exception) {
                    $response = .response;
                }
            }

            if $path-info {
                %env<smack.file.SCRIPT_NAME> = %env<SCRIPT_NAME> ~ %env<PATH_INFO>;
                %env<smack.file.SCRIPT_NAME>.=subst(/$path-info$/, '');
                %env<smack.file.PATH_INFO> = $path-info;
            }
            else {
                %env<smack.file.SCRIPT_NAME> = (%env<SCRIPT_NAME>//'') ~ (%env<PATH_INFO>//'');
                %env<smack.file.PATH_INFO> = '';
            }

            $response = self.serve-path(%env, $file);
        }

        $response;
    }
}

method locate-file(%env) {
    my $path = %env<PATH_INFO> // '';

    die X::Smack::Exception::BadRequest.new if $path ~~ /\0/;

    my @path = $path.split(/<[ \\ \/ ]>/);
    if @path {
        @path.shift if @path[0] eq '';
    }
    else {
        @path = '.';
    }

    die X::Smack::Exception::Forbidden.new if any(|@path) eq '..';

    my ($file, @path-info);
    while @path {
        my $try = ($.root, |@path).reduce: -> $p, $c {
            if $p.d {
                $p.add($c)
            }
            else {
                die X::Smack::Exception::NotFound.new;
            }
        }

        if self.should-handle($try) {
            $file = $try;
            last;
        }
        elsif !self.allow-path-info {
            last;
        }
        @path-info.unshift: @path.pop;
    }

    die X::Smack::Exception::NotFound.new unless $file;
    die X::Smack::Exception::Forbidden.new unless $file.r;

    $file, join("/", "", |@path-info);
}

method allow-path-info { False }

method serve-path(%env, IO() $file) {
    my $content-type = $.content-type
                    // Smack::MIME.mime-type($file)
                    // 'text/plain';

    if $content-type ~~ Callable {
        $content-type = $content-type.($file);
    }

    if $content-type.starts-with('text/') {
        $content-type ~= '; charset=' ~ ($.encoding // 'utf-8');
    }

    my $fh = $file.open(:r) or die X::Smack::Exception::Forbidden.new;

    200, [
        Content-Type   => $content-type,
        Content-Length => $file.s,
        Last-Modified  => time2str($file.modified.DateTime),
    ],
    Supply.on-demand(-> $s {
        $s.emit($fh.read($.chunk-size))
            until $fh.eof;
        $s.done;
    });
}

