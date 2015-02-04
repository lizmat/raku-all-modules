use v6;

class X::Email::MIME::CharsetNeeded is Exception {
    method message { "body-str and body-str-set require a charset!"; }
}

class X::Email::MIME::InvalidBody is Exception {
    method message {
        "Invalid body from encoding handler"
        ~ "- I need a Str or something that I can .decode to a Str";
    }
}
