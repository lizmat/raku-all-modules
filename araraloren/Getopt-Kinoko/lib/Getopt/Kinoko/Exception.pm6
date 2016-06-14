use v6;

#| throw this expection when error
class X::Kinoko is Exception {
    has $.msg handles <Str>;

    method message() {
        $!msg;
    }
}

#| throw this exception when parse failed
class X::Kinoko::Fail is Exception {
    has $.msg handles <Str>;

    method new(:$msg = "") {
        self.bless(:$msg);
    }

    method message() {
        $!msg;
    }
}

#| warnings, not using
class W::Kinoko {
    has $.msg handles <Str>;

    method warn() {
        note "Warning: " ~ $!msg;
    }
}
