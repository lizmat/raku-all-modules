use Net::HTTP::Interfaces;
use Net::HTTP::Utils;

my $CRLF = Buf.new(13, 10);

my sub pathify        { $^a.starts-with('/') ?? $^a.substr(1) !! $^a }
my sub header2str(%_) { %_.grep(*.value.defined).map({ hc(~$_.key) ~ ': ' ~ $_.value }).join("\r\n") }
my sub body2str($_)   { $_ ~~ Blob ?? $_.unpack("A*") !! $_  }
my sub body2bin($_)   { $_ ~~ Blob ?? $_ !! $_ ~~ Str ?? $_.chars ?? $_.encode !! '' !! '' }

class Net::HTTP::Request does Request {
    has URL $.url;
    has $.method;
    has %.header  is rw;
    has %.trailer is rw;
    has $.body    is rw;

    method proto { 'HTTP/1.1' }
    method start-line { join ' ', $!method, self.path, self.proto }

    method Stringy {self.Str}
    method Str {
        return  self.start-line ~ $CRLF.decode
            ~   self!header-str ~ $CRLF.decode ~ $CRLF.decode
            ~   self!body-str
            ~   self!trailer-str;
    }
    method str { self.Str }

    # An over-the-wire representation of the Request
    method raw {
        return buf8.new( grep * ~~ Int,
            |self.start-line.encode, |$CRLF,
            |self!header-bin, |$CRLF, |$CRLF,
            |self!body-bin,
            |self!trailer-bin,
            )
    }

    # The `path` part of the start line. Defaults to a relative path.
    # If you wanted to modify the path to use a proxy you would apply a
    # role with an alternative path method to the Request object such as:
    # `$req = Request.new(...) but role { method path { ~$req.url } }`
    method path {
        my $rel-url = '/';
        $rel-url ~= pathify(~$_) with $!url.path;
        $rel-url ~= "?{$_}"      with $!url.?query;
        $rel-url ~= "#{$_}"      with $!url.?fragment;
        return $rel-url;
    }


    method !header-str  {
        temp %!header<Host> = self.url.host unless %!header.grep(*.key.lc eq 'host').first(*.value);
        return header2str(%!header) // ''
    }
    method !body-str    { body2str($!body)      // '' }
    method !trailer-str { header2str(%!trailer) // '' }

    method !header-bin  { self!header-str.encode  }
    method !body-bin    { body2bin($!body)        }
    method !trailer-bin { self!trailer-str.encode }
}
