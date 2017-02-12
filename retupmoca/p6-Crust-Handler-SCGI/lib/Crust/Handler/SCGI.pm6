use v6;

use SCGI;
use IO::Blob;

unit class Crust::Handler::SCGI;

has $!scgi;

submethod BUILD(:$host, :$port) {
    $!scgi = SCGI.new(:addr($host), :port($port));
}

method run($app) {
    my $fixed = -> %env {
        # To satisfy Crust's Lint "middleware" paranoia and fascism
        %env{'HTTP_CONTENT_TYPE'}:delete   if %env{'HTTP_CONTENT_TYPE'}:exists;
        %env{'HTTP_CONTENT_LENGTH'}:delete if %env{'HTTP_CONTENT_LENGTH'}:exists;

        my $input = %env<p6sgi.input>;
        $input = IO::Blob.new($input) if $input && $input ~~ Blob;
        %env<p6sgi.input> = $input;
        $app(%env);
    };
    $!scgi.handle: $fixed;
}
