use v6;

class ABC::LongRest {
    has $.measures_rest;

    method new($measures_rest) {
        self.bless(:measures_rest(+$measures_rest));
    }

    method Str() {
        "Z" ~ $.measures_rest;
    }
}