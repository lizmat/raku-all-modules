unit class Pastebin::Shadowcat:ver<2.001001>;

use HTTP::UserAgent;
use URI::Encode;
use HTML::Entity;

has $!pastebin_url = 'http://fpaste.scsys.co.uk/';

method paste ($paste, $summary?) returns Str {
    my $res = HTTP::UserAgent.new.post: $!pastebin_url ~ 'paste', %(
        :channel(''), :nick(''), :summary($summary // ''), :paste($paste),
        'Paste it' => 'Paste it'
    );
    $res.is-success or fail $res.status-line;
    $res.content ~~ /
        'meta http-equiv="refresh" content="5;url=' $<url>=<-["]>+
    / or fail 'Did not find paste URL in response from the pastebin';
    return ~$<url>;
}

method fetch ($what) returns List {
    my $paste_url = $what ~~ m:P5/\D/ ?? $what !! $!pastebin_url ~ $what;

    my $res = HTTP::UserAgent.new.get: $paste_url;
    $res.is-success or fail 'Did not find that paste';
    $res.content ~~ /
        '<br>' \s+ '<b>' $<summary>=.+ '</b>' .+ '<pre>' $<paste>=.+ '</pre>'
    / or fail 'Could not find paste content on the returned page';

    return (
        decode-entities( ~$<paste>   ),
        decode-entities( ~$<summary> ),
    );
}
