use lib <lib>;
use WWW::vlc::Remote;

my $vlc := WWW::vlc::Remote.new;

#|(add item to playlist)
multi MAIN('add', $url) { $vlc.enqueue-and-play: $url }
#|(Show items on the playlist)
multi MAIN('pl') {
    say "Available songs are:";
    .say for $vlc.playlist
}

#|(play current playlist item)
multi MAIN('play') { $vlc.play }
#|(play playlist item with ID <id>)
multi MAIN('play', UInt:D $id) {
    with $vlc.playlist.first: *.id == $id { say "Playing $_"; .play }
    else { say "Did not find any songs with ID `$id`" }
}

#|(stop vlc)
multi MAIN('stop') { $vlc.stop }
#|(play next track)
multi MAIN('next') { $vlc.next }
#|(play previous track)
multi MAIN('prev') { $vlc.prev }
#|(seek to a value)
multi MAIN('seek', $val) { $vlc.seek: $val }
#|(set volume)
multi MAIN('vol', $val) { $vlc.volume: $val }
#|(show current status)
multi MAIN('status') { say ~$vlc.status }
