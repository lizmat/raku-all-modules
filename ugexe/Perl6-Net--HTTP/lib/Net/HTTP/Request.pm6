use Net::HTTP::Interfaces;
use Net::HTTP::Utils;

class Net::HTTP::Request does Request {
    has URL $.url is rw;
    has $.method  is rw;
    has %.header  is rw;
    has %.trailer is rw;
    has $.body    is rw;
    has $.nl is rw = "\r\n";

    method proto { 'HTTP/1.1' }
    method start-line  {$ = "{$!method} {self.path} {self.proto}" }

    method Stringy {self.Str}
    method Str { $ = "{self.start-line}{$!nl}{self!header-str}{$!nl}{$!nl}{self!body-str}{self!trailer-str}" }
    method str { self.Str }

    # An over-the-wire representation of the Request
    method raw { with $!nl.ords -> @sep {
        $ = Blob[uint8].new( grep * ~~ Int,
        |self.start-line.ords,
        |@sep,
        |self!header-raw.Slip,
        |@sep,
        |@sep,
        |self!body-raw,
        |self!trailer-raw,
    ) } }

    # The `path` part of the start line. Defaults to a relative path.
    # If you wanted to modify the path to use a proxy you would apply a
    # role with an alternative path method to the Request object such as:
    # `$req = Request.new(...) but role { method path { ~$req.url } }`
    method path {
        my $rel-url = '/';
        if "{$!url.path}"      -> $_ { $rel-url ~= .starts-with('/') ?? .substr(1) !! $_ }
        if "{$!url.?query}"    -> $_ { $rel-url ~= "?{~$_}" }
        if "{$!url.?fragment}" -> $_ { $rel-url ~= "#{~$_}" }
        $rel-url;
    }


    method !header-str  {
        temp %!header<Host> = self.url.host unless %!header.grep(*.key.lc eq 'host').first(*.value);
        $ = header2str(%!header)  // ''
    }
    method !body-str    { body2str($!body)      // ''    }
    method !trailer-str { header2str(%!trailer) // ''    }

    method !header-raw  { Blob.new(self!header-str.ords)  }
    method !body-raw    { body2raw($!body)                }
    method !trailer-raw { Blob.new(self!trailer-str.ords) }

    sub header2str(%_) { $ = %_.grep(*.value.so).map({ "{hc ~$_.key}: {~$_.value}" }).join("\r\n") }
    sub body2str($_)   { $_ ~~ Blob ?? $_.unpack("A*") !! $_  }
    sub body2raw($_)   { $_ ~~ Blob ?? $_ !! $_ ~~ Str ?? $_.chars ?? Blob[uint8].new($_.ords) !! '' !! '' }
}
