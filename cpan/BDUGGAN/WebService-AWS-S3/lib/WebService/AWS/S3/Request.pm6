unit class S3::Request;
use Digest::SHA;
use Digest::HMAC;
use URI::Escape;

has $.verb is required;
has $.path is required;
has $.host is required;
has $.query-string = "";
has $.body = "";
has %.headers;

has $.access-key-id is required;
has $.secret-access-key;
has $.region is required;
has $.service = 's3';
has DateTime $.date is required;

sub timestamp($d!) is export {
    with ($d.DateTime.utc) {
      return sprintf "%04d%02d%02dT%02d%02d%02dZ",
        .year, .month, .day, .hour, .minute, .second; 
    }
}

sub hmac-sha256($x,$y)     { return hmac($x,$y,&sha256); }
sub hex-hmac-sha256($x,$y) { hmac-hex($x,$y,&sha256); }
sub hex-sha256($x)         { sha256($x).map({.fmt('%02x')}).join }

method date-ymd {
    return sprintf('%04d%02d%02d',$!date.year,$!date.month,$!date.day);
}

# http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
method canonical-request {
    return join "\n",
    self.verb.uc,
    self.canonical-uri,
    (self.query-string // ""),
    self.canonical-headers.sort.map({"{.key}:{.value}"}).join("\n"),
    "",
    self.signed-headers,
    self.hashed-payload
}

method string-to-sign {
    join "\n",
    "AWS4-HMAC-SHA256",
    timestamp($!date),
    self.scope,
    hex-sha256(self.canonical-request)
}

method scope {
    join '/', self.date-ymd, self.region, self.service, 'aws4_request';
}

method canonical-uri {
   $.path.split("/").map({uri_escape($_)}).join("/");
}

method canonical-headers {
    %.headers<X-Amz-Date> //= timestamp(self.date);
    %.headers<Host> //= self.host;
    my %canonical = map { .key.lc => .value }, %.headers;
    %canonical;
}

method signed-headers {
    self.canonical-headers.keys.sort.join(';');
}

method hashed-payload {
    hex-sha256($.body);
}

method signing-key {
    my \DateKey              = hmac-sha256("AWS4" ~ $.secret-access-key, self.date-ymd);
    my \DateRegionKey        = hmac-sha256(DateKey, $.region);
    my \DateRegionServiceKey = hmac-sha256(DateRegionKey, self.service);
    my \SigningKey           = hmac-sha256(DateRegionServiceKey, 'aws4_request');
    return SigningKey;
}

method signature {
    hex-hmac-sha256(self.signing-key, self.string-to-sign())
}

method credential {
    join '/', self.access-key-id, self.date-ymd, self.region, self.service, 'aws4_request';
}

# http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-authenticating-requests.html
method authorization {
     "AWS4-HMAC-SHA256 " ~ join ',',
     map { "{.key}={.value}" },
         'Credential'    => self.credential,
         'SignedHeaders' => self.signed-headers,
         'Signature'     => self.signature
}
