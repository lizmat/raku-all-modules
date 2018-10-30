unit class RT::REST::Client;

use HTTP::UserAgent;
use URI;
use URI::Escape;

use RT::REST::Client::Grammar;
use RT::REST::Client::Grammar::Actions;

has $!user;
has $!pass;
has $!rt-url;
has $!ticket-url;
has $!ua = HTTP::UserAgent.new;

submethod BUILD (:$!user!, :$!pass!, :$!rt-url = 'https://rt.perl.org/REST/1.0') {
    $!ticket-url = do given URI.new: $!rt-url {
        [~] .scheme, '://', .host, (':' ~ .port if .port != 80|443),
            '/Ticket/Display.html?id=';
    }
}

method search (
    Dateish :$after, Dateish :$before, Str :$queue = 'perl6',
    :$status = [], :$not-status is copy = [],
) {
    $not-status = ('resolved', 'rejected')
        unless $status or $not-status;

    my $cond = join " AND ",
        ("Created >= '$after.yyyy-mm-dd()'"  if $after ),
        ("Created < '$before.yyyy-mm-dd()'"  if $before),
        ( "(" ~ $status.map({"Status = '$_'"}).join(' OR ')  ~ ")" if $status ),
        $not-status.map({"Status != '$_'"});

    my $url = "$!rt-url/search/ticket?user=$!user&pass=$!pass&orderby=-Created"
        ~ "&query=" ~ uri-escape("Queue = '$queue' AND ($cond)");

    my $s = $!ua.get: $url;
    fail $s.status-line unless $s.is-success;

    return RT::REST::Client::Grammar::Tickets.parse(
        $s.content,
        :actions(RT::REST::Client::Grammar::Actions::Tickets.new: :$!ticket-url)
    ).made // fail 'Failed to parse response which was: ' ~ $s.content;
}

method ticket ($id) {
    my $url
    = "$!rt-url/ticket/$id/history?format=l&user=$!user&pass=$!pass";

    my $s = $!ua.get: $url;
    fail $s.status-line unless $s.is-success;

    $s.content;
}
