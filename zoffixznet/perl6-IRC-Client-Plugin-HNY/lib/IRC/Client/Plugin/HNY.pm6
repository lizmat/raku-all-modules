use IRC::Client;
unit class IRC::Client::Plugin::HNY is IRC::Client::Plugin;

my \term:<☃> = DateTime.new(year => .year + (1 if .month >= 6)).utc.Instant
    given DateTime.now.utc;

use WWW::Google::Time;
use Number::Denominate;

method irc-to-me   ($ where /:i ^\s*  'hny' \s+ $<where>=.+ /) { hny ~$<where> }
method irc-privmsg ($ where /:i ^\s* '!hny' \s+ $<where>=.+ /) { hny ~$<where> }

sub hny ($where) {
    my %info = (google-time-in $where
        or return 'Never heard of that place…');

    my \Δ = round ☃ - %info<DateTime>.clone(:0timezone).Instant;
    Δ <= 0
        ?? "New Year already happened in %info<where> &denominate(abs Δ) ago"
        !! "New Year will happen in %info<where> in &denominate(Δ)";
}
