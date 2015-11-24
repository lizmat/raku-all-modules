unit class Pastebin::Shadowcat:ver<2.001001>;

use LWP::Simple;
use URI::Encode;
use HTML::Entity;

has $!pastebin_url = 'http://fpaste.scsys.co.uk/';

method paste ($paste, $summary?) returns Str {
    my $paste_id = (LWP::Simple.new.post( $!pastebin_url ~ 'paste', {},
        'channel='
        ~ '&nick='
        ~ '&summary=' ~ uri_encode_component( ($summary // '').Str )
        ~ '&paste='   ~ uri_encode_component( $paste.Str )
        ~ '&Paste+it=Paste+it'
    ) ~~ m:P5{meta http-equiv="refresh" content="5;url=http://fpaste.scsys.co.uk/(\d+)">})[0];

    $paste_id
        or fail 'Did not find paste ID in response from the pastebin';

    return $!pastebin_url ~ $paste_id;
}

method fetch ($what) returns List {
    my $paste_url = $what ~~ m:P5/\D/ ?? $what !! $!pastebin_url ~ $what;

    my $content = LWP::Simple.get($paste_url)
        or fail 'Did not find that paste';

    my $paste   = ($content ~~ m{'<pre>' (.+) '</pre>'       } )[0].Str;
    my $summary = ($content ~~ m{'<br>' \s+ '<b>' (.+) '</b>'} )[0].Str;
    return (
        decode-entities( $paste   ),
        decode-entities( $summary ),
    );
}
