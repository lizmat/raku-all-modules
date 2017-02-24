use JSON::Fast;
use MIME::Base64;
use OpenSSL::Digest;
use OpenSSL::RSATools;
use Digest::HMAC;

class JSON::JWT {
    multi method decode($jwt, :$alg where 'none') {
        my %pack = self._unpack($jwt);
        if %pack<header><alg> ne 'none' {
            die "Header lists signature type != 'none' ("~%pack<header><alg>~")";
        }
        if %pack<signature> {
            die "Signature exists with signature type = 'none'";
        }

        return %pack<body>;
    }
    multi method decode($jwt, :$alg where 'HS256', :$secret!) {
        my %pack = self._unpack($jwt);
        if %pack<header><alg> ne 'HS256' {
            die "Header lists signature type != 'HS256' ("~%pack<header><alg>~")";
        }
        if !%pack<signature> {
            die "No signature found.";
        }
        my $sign = hmac($secret, %pack<sigblob>, &sha256);
        if $sign ne %pack<signature> { # XXX secure compare? XXX #
            die "Signature does not match.";
        }
        
        return %pack<body>;
    }
    multi method decode($jwt, :$alg where 'RS256', :$pem!) {
        my %pack = self._unpack($jwt);
        if %pack<header><alg> ne 'RS256' {
            die "Header lists signature type != 'RS256' ("~%pack<header><alg>~")";
        }
        if !%pack<signature> {
            die "No signature found.";
        }
        my $key = OpenSSL::RSAKey.new(:public-pem($pem));
        if !$key.verify(%pack<sigblob>, %pack<signature>, :sha256) {
            die "Signature verify failed.";
        }

        return %pack<body>;
    }

    method decode-noverify($jwt) {
        my %pack = self._unpack($jwt);
        return %pack<body>;
    }

    method _unpack(Str:D $jwt) {
        my @parts = $jwt.split('.');
        if @parts < 2 || @parts > 3 {
            die "JWT does not have 2 or 3 parts; cannot unpack.";
        }

        my %pack;
        %pack<sigblob> = join('.', @parts[0], @parts[1]).encode('ascii');
        # MIME::Base64 doesn't do base64url
        @parts[0] ~~ s:g/\-/+/;
        @parts[1] ~~ s:g/\-/+/;
        @parts[2] ~~ s:g/\-/+/ if @parts[2];
        @parts[0] ~~ s:g/_/\//;
        @parts[1] ~~ s:g/_/\//;
        @parts[2] ~~ s:g/_/\// if @parts[2];
        %pack<signature> = MIME::Base64.decode(@parts[2]) if @parts[2];
        %pack<header> = from-json(MIME::Base64.decode-str(@parts[0]));
        %pack<body> = from-json(MIME::Base64.decode-str(@parts[1]));

        if %pack<header><typ> ne 'JWT' {
            die "Not a JWT";
        }

        %pack;
    }

    multi method encode($data, :$alg where 'none') {
        my %header = :typ('JWT'), :alg('none');
        my %pack;
        %pack<body> = $data;
        %pack<header> = %header;

        return self._pack(%pack);
    }

    multi method encode($data, :$alg where 'HS256', :$secret!) {
        my %header = :typ('JWT'), :alg('HS256');
        my %pack;
        %pack<body> = $data;
        %pack<header> = %header;

        my $sigstring = self._pack(%pack, :signing);
        %pack<signature> = hmac($secret, $sigstring.encode('ascii'), &sha256);

        return self._pack(%pack);
    }

    multi method encode($data, :$alg where 'RS256', :$pem!) {
        my %header = :typ('JWT'), :alg('RS256');
        my %pack;
        %pack<body> = $data;
        %pack<header> = %header;

        my $sigstring = self._pack(%pack, :signing);
        my $key = OpenSSL::RSAKey.new(:private-pem($pem));
        %pack<signature> = $key.sign($sigstring.encode('ascii'), :sha256);

        return self._pack(%pack);
    }

    method _pack(%pack, :$signing) {
        my $header-packed = MIME::Base64.encode-str(to-json(%pack<header>), :oneline);
        $header-packed ~~ s:g/\+/-/;
        $header-packed ~~ s:g/\//_/;
        $header-packed ~~ s:g/\=//;

        my $body-packed = MIME::Base64.encode-str(to-json(%pack<body>), :oneline);
        $body-packed ~~ s:g/\+/-/;
        $body-packed ~~ s:g/\//_/;
        $body-packed ~~ s:g/\=//;

        my $sig-part = '';
        if %pack<signature> {
            my $sig-packed = MIME::Base64.encode(%pack<signature>, :oneline);
            $sig-packed ~~ s:g/\+/-/;
            $sig-packed ~~ s:g/\//_/;
            $sig-packed ~~ s:g/\=//;
            $sig-part = '.'~$sig-packed;
        }

        return $header-packed~'.'~$body-packed~$sig-part;
    }
}
