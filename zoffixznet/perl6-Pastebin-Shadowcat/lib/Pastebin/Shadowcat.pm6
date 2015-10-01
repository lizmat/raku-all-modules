module Pastebin::Shadowcat {
    use LWP::Simple;
    use URI::Encode;
    use HTML::Entity;
    my $Pastebin_URL = 'http://fpaste.scsys.co.uk/';

    sub paste ($paste, $summary?) is export {
        my $paste_id = (LWP::Simple.new.post( $Pastebin_URL ~ 'paste', {},
            'channel='
            ~ '&nick='
            ~ '&summary=' ~ uri_encode_component( ($summary // '').Str )
            ~ '&paste='   ~ uri_encode_component( $paste.Str )
            ~ '&Paste+it=Paste+it'
        ) ~~ m:P5{meta http-equiv="refresh" content="5;url=http://fpaste.scsys.co.uk/(\d+)">})[0];

        $paste_id
            or fail 'Did not find paste ID in response from the pastebin';

        return $Pastebin_URL ~ $paste_id;
    }

    sub get_paste ($what) is export {
        my $paste_url = $what ~~ m:P5/\D/ ?? $what !! $Pastebin_URL ~ $what;

        my $content = LWP::Simple.get($paste_url)
            or fail 'Did not find that paste';

        my $paste   = ($content ~~ m{'<pre>' (.+) '</pre>'       } )[0].Str;
        my $summary = ($content ~~ m{'<br>' \s+ '<b>' (.+) '</b>'} )[0].Str;
        return (
            decode-entities( $paste   ),
            decode-entities( $summary ),
        );
    }
}
