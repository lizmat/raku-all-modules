use v6;
unit class Email::MIME::Encoder::Base64;

use MIME::Base64;

method encode($stuff, :$mime-header) {
    return MIME::Base64.encode($stuff, oneline => $mime-header);
}

method decode($stuff, :$mime-header) {
    return MIME::Base64.decode($stuff);
}
