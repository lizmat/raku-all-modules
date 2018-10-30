use v6;

use ABC::Duration;

class ABC::Rest does ABC::Duration {
    has $.type;

    method new($type, ABC::Duration $duration) {
        self.bless(:$type, :ticks($duration.ticks));
    }

    method Str() {
        $.type ~ self.duration-to-str;
    }
}