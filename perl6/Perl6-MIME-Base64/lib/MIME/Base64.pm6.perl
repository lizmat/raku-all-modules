use v6;

use MIME::Base64::Perl;

class MIME::Base64:auth<cpan:SNARKY>:ver<1.1> {
    my $default-backend = MIME::Base64::Perl;
    has $.backend;

    method new($backend = 0) {
        if $backend ~~ Numeric {
            return self.bless(backend => $default-backend);
        } else {
            return self.bless(backend => $backend);
        }
    }

    method set-backend($class){
        if self {
            self.backend = $class;
        } else {
            $default-backend = $class;
        }
    }

    method get-backend() {
        if self {
            return self.backend;
        } else {
            return $default-backend;
        }
    }

    method encode(Blob $data, :$oneline --> Str) {
        if self {
            return self.backend.encode($data, :$oneline);
        } else {
            return $default-backend.encode($data, :$oneline);
        }
    }

    method decode(Str $encoded --> Buf) {
        if self {
            return self.backend.decode($encoded);
        } else {
            return $default-backend.decode($encoded);
        }
    }

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
