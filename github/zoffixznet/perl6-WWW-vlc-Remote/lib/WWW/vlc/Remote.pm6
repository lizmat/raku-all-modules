unit class WWW::vlc::Remote;
use DOM::Tiny;
use HTTP::UserAgent;
use URI::Encode;

has HTTP::UserAgent:D $!ua  is required;
has Str:D             $!url is required;

submethod BUILD (
    Str    :$pass = 'pass',
    Str:D  :$host = 'http://127.0.0.1',
    UInt:D :$port = 8080,
) {
    $!url := $host.subst(rx{'/'+$}, '') ~ ':' ~ $port;
    $!ua  := HTTP::UserAgent.new;
    $!ua.auth: '', $pass;
}

class X is Exception {
    has Str:D $.error is required;
    method message { "vlc Remote error: $!error" }
}
class X::Network is Exception {
    has HTTP::Response:D $.res is required;
    method message { "Network error: {$!res.code} - {$!res.status-line}" }
}
class Track {
    has WWW::vlc::Remote:D $.vlc is required;
    has Str:D  $.uri      is required;
    has Str:D  $.name     is required;
    has UInt:D $.id       is required;
    has Int:D  $.duration is required;
    method play(--> WWW::vlc::Remote:D) { $!vlc.play: $!id }
    method Str(--> Str:D)  {
        my $id = "#$!id";
        $id [R~]= ' ' x 5 - $id.chars;
        if $!duration ≤ 0 {
            "$id $!name (N/A)"
        }
        else {
            my $m = $!duration div 60;
            my $s = $!duration - $m*60;
            "$id $!name ({$m}m{$s}s)"
        }
    }
    method gist(--> Str:D) { self.Str }
}

method !path(Str:D \p) { $!url ~ p }
method !command(Str:D \c) { self!path: '/requests/status.xml?command=' ~ c }
method !com-self(Str:D \c --> ::?CLASS:D) {
    my $res := $!ua.get: self!command: c;
    $res.is-success or fail X::Network.new: :$res;
    my $dom := DOM::Tiny.parse: $res.content;
    fail X.new: error => $dom.at('h1').all-text ~ "\n" ~ $dom.at('pre').all-text
        if $dom.at('title').all-text andthen .starts-with: 'Error loading';
    self
}

method empty (--> ::?CLASS:D) { self!com-self: 'pl_empty' }
method enqueue (Str:D \url --> ::?CLASS:D) {
    self!com-self: 'in_enqueue&input=' ~ uri_encode_component url
}
method enqueue-and-play (Str:D \url --> ::?CLASS:D) {
    self!com-self: 'in_play&input=' ~ uri_encode_component url
}

multi method delete (Track:D \track --> ::?CLASS:D) {
    self.delete: track.id
}
multi method delete ( UInt:D \id    --> ::?CLASS:D) {
    self!com-self: 'pl_delete&id=' ~ uri_encode_component id
}

method playlist(Bool :$skip-meta --> Seq:D) {
    my $res := $!ua.get: self!path: '/requests/playlist.xml';
    $res.is-success or fail X::Network.new: :$res;
    my $dom := DOM::Tiny.parse($res.content).at: 'node[name="Playlist"]'
        or fail X.new: error => 'Could not find playlist node';
    fail X.new: error => $dom.at('h1').all-text ~ "\n" ~ $dom.at('pre').all-text
        if $dom.at('title').all-text andthen .starts-with: 'Error loading';

    my $leafs := $dom.find: 'leaf';
    $skip-meta and $leafs := $leafs.grep: *.<duration> > 0;
    $leafs.map: {
        Track.new: :uri(.<uri>), :id(+.<id>), :name(.<name>),
          :duration(+.<duration>), :vlc(self)
    }
}

multi method play (               --> ::?CLASS:D) { self!com-self: 'pl_play' }
multi method play (Track:D \track --> ::?CLASS:D) { self.play: track.id      }
multi method play ( UInt:D \id    --> ::?CLASS:D) {
    self!com-self: 'pl_play&id=' ~ uri_encode_component id
}

      method stop (--> ::?CLASS:D) { self!com-self: 'pl_stop'     }
multi method next (--> ::?CLASS:D) { self!com-self: 'pl_next'     }
multi method prev (--> ::?CLASS:D) { self!com-self: 'pl_previous' }

method seek (\v where Str:D|Numeric:D = '0%' --> ::?CLASS:D) {
    self!com-self: 'seek&val=' ~ uri_encode_component v
}

method status (--> DOM::Tiny:D) {
    my $res := $!ua.get: self!path: '/requests/status.xml';
    $res.is-success or fail X::Network.new: :$res;
    my $dom := DOM::Tiny.parse($res.content);
    fail X.new: error => $dom.at('h1').all-text ~ "\n" ~ $dom.at('pre').all-text
        if $dom.at('title').all-text andthen .starts-with: 'Error loading';
    $dom
}

method toggle-random (--> ::?CLASS:D) { self!com-self: 'pl_random' }
method toggle-loop   (--> ::?CLASS:D) { self!com-self: 'pl_loop'   }
method toggle-repeat (--> ::?CLASS:D) { self!com-self: 'pl_repeat' }
method toggle-fullscreen (--> ::?CLASS:D) { self!com-self: 'fullscreen' }
method toggle-service-discovery (Str:D \v --> ::?CLASS:D) {
    self!com-self: 'pl_sd&val=' ~ uri_encode_component v
}

method volume (Str:D \v where Str:D|Numeric:D --> ::?CLASS:D) {
    self!com-self: 'volume&val=' ~ uri_encode_component v
}
