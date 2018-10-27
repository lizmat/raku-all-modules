use v6;
use NativeCall;

class MPD {
    class Connection is repr('CPointer') {};
    class Song       is repr('CPointer') {};
    class Status     is repr('CPointer') {};

    has OpaquePointer $!conn;

    method new(Str $host, Int $port) {
        my $conn = mpd_connection_new($host, $port);
        if mpd_connection_get_error($conn) {
            die mpd_connection_get_error_message($conn);
        }
        self.bless(*, :$conn);
    }

    submethod BUILD (:$!conn) {}

    method current-song {
        # TODO: a proper Song object
        my $s = mpd_run_current_song($!conn);
        my $ret = mpd_song_get_id($s);
        $ret ~= ": " ~ mpd_song_get_uri($s);
        mpd_song_free($s);
        return $ret;
    }

    method state {
        my $s = mpd_run_status($!conn);
        my $r = mpd_status_get_state($s);
        mpd_status_free($s);
        return <unknown stop play pause>[$r];
    }
}

sub mpd_connection_new(Str $host, int32 $port)
    returns OpaquePointer
    is native('libmpdclient') { ... }

sub mpd_connection_free(OpaquePointer)
    is native('libmpdclient') { ... }

sub mpd_connection_get_error(OpaquePointer)
    returns int32
    is native('libmpdclient') { ... }

sub mpd_connection_get_error_message(OpaquePointer)
    returns Str
    is native('libmpdclient') { ... }

sub mpd_run_current_song(OpaquePointer)
    returns OpaquePointer
    is native('libmpdclient') { ... }

sub mpd_song_free(OpaquePointer)
    is native('libmpdclient') { ... }

sub mpd_song_get_uri(OpaquePointer)
    returns Str
    is native('libmpdclient') { ... }

sub mpd_song_get_id(OpaquePointer)
    returns int32
    is native('libmpdclient') { ... }

sub mpd_run_status(OpaquePointer)
    returns OpaquePointer
    is native('libmpdclient') { ... }

sub mpd_status_free(OpaquePointer)
    is native('libmpdclient') { ... }

sub mpd_status_get_state(OpaquePointer)
    returns int32
    is native('libmpdclient') { ... }

# vim: ft=perl6
