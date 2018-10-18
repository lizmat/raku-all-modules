use lib <lib>;
use WWW::vlc::Remote;

my $vlc := WWW::vlc::Remote.new;
say "Available songs are:";
.say for $vlc.playlist: :skip-meta;

my UInt:D $song := val prompt "\nEnter an ID of song to play: ";
with $vlc.playlist.first: *.id == $song {
    say "Playing $_";
    .play
}
else {
    say "Did not find any songs with ID `$song`";
}
