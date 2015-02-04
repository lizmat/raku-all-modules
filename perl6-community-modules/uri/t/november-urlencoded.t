use v6;

# lifted more or less completely from the Novemver project
# just now uses URI::Escape rather than November::CGI

use Test;
use URI::Escape;

my @t =
    '%61'                  => 'a',
    '%C3%A5'               => 'å',
    '%C4%AC'               => 'Ĭ',
    '%C7%82'               => 'ǂ',
    '%E2%98%BA'            => '☺',
    '%E2%98%BB'            => '☻',
    'alla+snubbar'         => 'alla snubbar',
    'text%61+abc'          => 'texta abc',
    'unicode+%C7%82%C3%A5' => 'unicode ǂå',
    '%25'                  => '%',
    '%25+25'               => '% 25',
    '%25rr'                => '%rr',
    '%2561'                => '%61',
    ;

plan +@t;

for @t {
    my $ans = uri_unescape( ~.key );
    ok( $ans eq .value, 'Decoding ' ~ .key )
        or say "GOT: {$ans.perl}\nEXPECTED: {.value.perl}";

}

# vim: ft=perl6
