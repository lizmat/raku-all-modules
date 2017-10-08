use v6;

use MIME::Base64::Perl;

class MIME::Base64 is MIME::Base64::Perl {
    method encode-str(Str $string, :$oneline --> Str) {
        return self.encode($string.encode('utf8'), :$oneline);
    }

    method decode-str(Str $encoded --> Str) {
        return self.decode($encoded).decode('utf8');
    }

    # compatibility methods
    method encode_base64(Str $str --> Str) {
        return self.encode-str($str);
    }

    method decode_base64(Str $str --> Str) {
        return self.decode-str($str);
    }
}
