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
        my $input = %env<p6sgi.input>;
        $input = IO::Blob.new($input) if $input && $input ~~ Blob;
        %env<p6sgi.input> = $input;
        $app(%env);
    };
    $!scgi.handle: $fixed;
}
