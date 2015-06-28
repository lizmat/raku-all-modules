#!perl6

use v6;

use Test;
use HTTP::Headers;

plan 3;

constant PREFERRED = qq{Calling .header(Content-Length) is preferred to .header("Content-Length") for standard HTTP headers.};

{
    my $h = HTTP::Headers.new;
    $h.header("Content-Length") = 42;
    flunk('should not have gotten here');

    CONTROL {
        when CX::Warn {
            is $_, PREFERRED, 'got preferred warning';
        }
    }
}

{
    my $h = HTTP::Headers.new(:quiet);
    $h.header("Content-Length") = 42;
    pass('class quiet worked');

    CONTROL {
        when CX::Warn {
            flunk 'class quiet did not work';
        }
    }
}

{
    my $h = HTTP::Headers.new;
    $h.header("Content-Length", :quiet) = 42;
    pass('method quiet worked');

    CONTROL {
        when CX::Warn {
            flunk 'method quiet did not work';
        }
    }
}
