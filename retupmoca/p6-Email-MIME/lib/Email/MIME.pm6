use Email::Simple;

use Email::MIME::ParseContentType;
use Email::MIME::Header;
use Email::MIME::Exceptions;

use MIME::QuotedPrint;
use Email::MIME::Encoder::Base64;

unit class Email::MIME is Email::Simple does Email::MIME::ParseContentType;

has $!ct;
has @!parts;
has $!body-raw;

method new (Str $text){
    my $self = callwith($text, header-class => Email::MIME::Header);
    $self._finish_new();
    return $self;
}
method _finish_new(){
    $!ct = self.parse-content-type(self.content-type);
    self.fill-parts;
}

method create(:$header is copy, :$header-str is copy, :$attributes is copy, :$parts is copy, :$body, :$body-str) {
    my $self = callwith(header => Array.new(), body => '', header-class => Email::MIME::Header);

    $self.header-set('Content-Type', 'text/plain');
    $self.header-set('MIME-Version', '1.0');

    if $header {
        for $header.list -> $item {
            if $item ~~ Pair {
                $self.header-set($item.key, $item.value);
            } else {
                $self.header-set($item[0], $item[1]);
            }
        }
    }
    if $header-str {
        for $header-str.list -> $item {
            if $item ~~ Pair {
                $self.header-str-set($item.key, $item.value);
            } else {
                $self.header-str-set($item[0], $item[1]);
            }
        }
    }

    # TODO: this is messy
    for $attributes.list -> $item {
        my $key;
        my $value;
        if $item ~~ Pair {
            $key = $item.key;
            $value = $item.value;
        } else {
            $key = $item[0];
            $value = $item[1];
        }
        if lc($key) eq 'content-type' {
            $self.content-type-set($value);
        }
        if lc($key) eq 'charset' {
            $self.charset-set($value);
        }
        if lc($key) eq 'name' {
            $self.name-set($value);
        }
        if lc($key) eq 'format' {
            $self.format-set($value);
        }
        if lc($key) eq 'boundary' {
            $self.boundary-set($value);
        }
        if lc($key) eq 'encoding' {
            $self.encoding-set($value);
        }
        if lc($key) eq 'disposition' {
            $self.disposition-set($value);
        }
        if lc($key) eq 'filename' {
            $self.filename-set($value);
        }
    }
    ##
    
    if $parts {
        for $parts.list -> $part is rw {
            unless $part ~~ Email::MIME {
                $part = Email::MIME.create(attributes => {content-type => 'text/plain'},
                                           body => $part);
            }
        }
        $self.parts-set($parts.list);
    } elsif $body {
        $self.body-set($body);
    } elsif $body-str {
        $self.body-str-set($body-str);
    }

    return $self;
}

method body-raw {
    return $!body-raw // self.body(True);
}

method body-raw-set($body) {
    $!body-raw = $body;
    self.body-set($body, True);
}

method parts {
    if +@!parts {
        return @!parts;
    } else {
        return self;
    }
}

method debug-structure($level = 0) {
    my $rv = ' ' x (5 * $level);
    $rv ~= '+ ' ~ self.content-type ~ "\n";
    if self.parts ~~ Array && +self.parts > 1 {
        for self.parts -> $part {
            $rv ~= $part.debug-structure($level + 1);
        }
    }
    return $rv;
}

method filename($force = False) {
    my $dis = self.header('Content-Disposition') // '';
    my $params = Hash.new;
    if $dis ~~ s/^<-[;]>+\;// {
        $params = self.parse-header-attributes(';' ~ $dis);
    }
    my $name = $params<filename> || $!ct<attributes><name>;
    if $name || !$force {
        return $name;
    }
    
    my $invented = self.invent-filename($!ct<type> ~ '/' ~ $!ct<subtype>);
    self.filename-set($invented);
    return $invented;
}

my $gname = 0;
method invent-filename($ct?) {
    # TODO use content type to find a more correct extension
    return 'attachment-' ~ $*PID ~ '-' ~ $gname++ ~ '.dat';
}

method filename-set($filename) {
    # parse existing header
    my $dis = self.header('Content-Disposition');
    my $disposition;
    my $params;
    if $dis {
        $disposition = ~($dis ~~ /^<-[;]>+/);
        if $dis ~~ s/^<-[;]>+\;// {
            $params = self.parse-header-attributes(';' ~ $dis);
        } else {
            $params = Hash.new;
        }
    } else {
        $disposition = 'inline';
        $params = Hash.new;
    }

    # update filename
    if $filename {
        $params<filename> = $filename;
    } else {
        $params<filename>.delete;
    }

    # rewrite header
    $dis = $disposition;
    for $params.keys {
        $dis ~= '; ' ~ $_ ~ '="' ~ $params{$_} ~ '"';
    }
    self.header-set($dis);
}

method subparts {
    return @!parts;
}

method fill-parts {
    if $!ct<type> eq "multipart" || $!ct<type> eq "message" {
        self.parts-multipart;
    } else {
        self.parts-single-part;
    }
    
    return self;
}

method parts-single-part {
    @!parts = ();
}

method parts-multipart {
    my $boundary = $!ct<attributes><boundary>;

    $!body-raw //= self.body(True);
    my @bits = split(/\-\-$boundary/, self.body-raw);
    my $x = 0;
    for @bits {
        if $x {
            unless $_ ~~ /^\-\-/ {
                $_ ~~ s/^\n//;
                $_ ~~ s/\n$//;
                @!parts.push(self.new($_));
            }
        } else {
            $x++;
            self.body-set($_, True);
        }
    }

    return @!parts;
}

method parts-set(@parts) {
    my $body = '';

    my $ct = self.parse-content-type(self.content-type);

    if +@parts > 1 || $!ct<type> eq 'multipart' {
        $ct<attributes><boundary> //= self!create-boundary;
        my $boundary = $ct<attributes><boundary>;

        for @parts -> $part {
            $body ~= self.crlf ~ "--" ~ $boundary ~ self.crlf;
            $body ~= ~$part;
        }
        $body ~= self.crlf ~ "--" ~ $boundary ~ "--" ~ self.crlf;
        unless $ct<type> eq 'multipart' || $ct<type> eq 'message' {
            $ct<type> = 'multipart';
            $ct<subtype> = 'mixed';
        }
    } elsif +@parts == 1 {
        my $part = @parts[0];
        $body = $part.body;
        my $thispart_ct = self.parse-content-type($part.content-type);
        $ct<type> = $thispart_ct<type>;
        $ct<subtype> = $thispart_ct<subtype>;
        self.encoding-set($part.header('Content-Transfer-Encoding'));
        $ct<attributes><boundary>.delete;
    }

    self!compose-content-type($ct);
    self.body-raw-set($body);
    self.fill-parts;
    self!reset-cids;
}

method parts-add(@parts) {
    my @allparts = self.parts, @parts;
    self.parts-set(@allparts);
}

method walk-parts($callback) {
    $callback(self);

    for self.subparts {
        $_.walk-parts($callback);
    }

    return self;
}

method boundary-set($data) {
    my $ct-hash = self.parse-content-type(self.content-type);
    if $data {
        $ct-hash<attributes><boundary> = $data;
    } else {
        $ct-hash<attributes><boundary>.delete;
    }
    self!compose-content-type($ct-hash);
    
    if +self.parts > 1 {
        self.parts-set(self.parts)
    }
}

method content-type(){
  return ~self.header("Content-type");
}

method content-type-set($ct) {
    my $ct-hash = self.parse-content-type($ct);
    self!compose-content-type($ct-hash);
    self!reset-cids;
    return $ct;
}

# TODO: make the next three methods into a macro call
method charset-set($data) {
    my $ct-hash = self.parse-content-type(self.content-type);
    if $data {
        $ct-hash<attributes><charset> = $data;
    } else {
        $ct-hash<attributes><charset>.delete;
    }
    self!compose-content-type($ct-hash);
    return $data;
}
method name-set($data) {
    my $ct-hash = self.parse-content-type(self.content-type);
    if $data {
        $ct-hash<attributes><name> = $data;
    } else {
        $ct-hash<attributes><name>.delete;
    }
    self!compose-content-type($ct-hash);
    return $data;
}
method format-set($data) {
    my $ct-hash = self.parse-content-type(self.content-type);
    if $data {
        $ct-hash<attributes><format> = $data;
    } else {
        $ct-hash<attributes><format>.delete;
    }
    self!compose-content-type($ct-hash);
    return $data;
}

method disposition-set($data) {
    $data //= 'inline';
    my $current = self.header('Content-Disposition');
    if $current {
        $current ~~ s/^<-[;]>+/$data/;
    } else {
        $current = $data;
    }
    self.header-set('Content-Disposition', $current);
}

method as-string {
    return self.header-obj.as-string ~ self.crlf ~ self.body-raw;
}

method !compose-content-type($ct-hash) {
    my $ct = $ct-hash<type> ~ '/' ~ $ct-hash<subtype>;
    for keys $ct-hash<attributes> -> $attr {
        $ct ~= "; " ~ $attr ~ '="' ~ $ct-hash<attributes>{$attr} ~ '"';
    }
    self.header-set('Content-Type', $ct);
    $!ct = $ct-hash;
}

method !get-cid {
    return '<' ~ self!create-cid ~ '>';
}

method !reset-cids {
    my $ct-hash = self.parse-content-type(self.content-type);

    if self.parts ~~ Array && +self.parts > 1 {
        if $ct-hash<subtype> eq 'alternative' {
            my $cids;
            for self.parts -> $part {
                my $cid = $part.header('Content-ID') // '';
                $cids{$cid}++;
            }
            if +$cids.keys == 1 {
                return;
            }

            my $cid = self!get-cid;
            for self.parts -> $part {
                $part.header-set('Content-ID', $cid);
            }
        } else {
            for self.parts -> $part {
                my $cid = self!get-cid;
                unless $part.header('Content-ID') {
                    $part.header-set('Content-ID', $cid);
                }
            }
        }
    }
}

###
# content transfer encoding stuff here
###

my %cte-coders = ('base64' => Email::MIME::Encoder::Base64,
                  'quoted-printable' => MIME::QuotedPrint);

method set-encoding-handler($cte, $coder) {
    %cte-coders{$cte} = $coder;
    Email::MIME::Header.set-encoding-handler($cte, $coder);
}

method body($callsame_only?) {
    my $body = callwith();
    if $callsame_only {
        return $body;
    }
    my $cte = ~self.header('Content-Transfer-Encoding') // '';
    $cte ~~ s/\;.*$//;
    $cte ~~ s:g/\s//;

    if $cte && %cte-coders{$cte}.can('decode') {
        return %cte-coders{$cte}.decode($body);
    } else {
        return $body.encode('ascii');
    }
}

method body-set($body, $super?) {
    if $super {
        nextwith($body);
    }
    my $cte = ~self.header('Content-Transfer-Encoding') // '';
    $cte ~~ s/\;.*$//;
    $cte ~~ s:g/\s//;

    my $body-encoded;
    if $cte && %cte-coders{$cte}.can('encode') {
        $body-encoded = %cte-coders{$cte}.encode($body);
    } else {
        if $body ~~ Str {
            # ensure everything is ascii like it should be
            $body-encoded = $body.encode('ascii').decode('ascii');
        } else {
            $body-encoded = $body.decode('ascii');
        }
    }

    $!body-raw = $body-encoded;
    callwith($body-encoded);
}

method encoding-set($enc) {
    my $body = self.body;
    self.header-set('Content-Transfer-Encoding', $enc);
    self.body-set($body);
}

###
# charset stuff here
###

method body-str {
    my $body = self.body;
    if $body ~~ Str {
        # if body is a Str, we assume it's already been decoded
        return $body;
    }
    if $body ~~ Blob {
        my $charset = $!ct<attributes><charset>;

        if $charset ~~ m:i/^us\-ascii$/ {
            $charset = 'ascii';
        }

        unless $charset {
            if $!ct<type> eq 'text' && ($!ct<subtype> eq 'plain'
                                        || $!ct<subtype> eq 'html') {
                return $body.decode('ascii');
            }

            # I have a Buf with no charset. Can't really do anything...
            die X::Email::MIME::CharsetNeeded.new();
        }

        return $body.decode($charset);
    }
    die X::Email::MIME::InvalidBody.new();
}

method body-str-set(Str $body) {
    my $charset = $!ct<attributes><charset>;

    unless $charset {
        # well, we can't really do anything with this
        die X::Email::MIME::CharsetNeeded.new();
    }

    if $charset ~~ m:i/^us\-ascii$/ {
        $charset = 'ascii';
    }

    self.body-set($body.encode($charset));
}

method header-str-pairs {
    self.header-obj.header-str-pairs;
}

method header-str($header) {
    self.header-obj.header-str($header);
}

method header-str-set($header, *@lines) {
    self.header-obj.header-str-set($header, |@lines);
}

###
# methods to replace Email::MessageID
# TODO pull these into a new Email::MessageID module
###

my @chars = ('A'..'F','a'..'f',0..9);

method !create-boundary {
    return now.Num ~ '.' ~ (@chars.roll((4..8).pick)).join ~ '.' ~ $*PID;
}

method !create-cid {
    return self!create-boundary ~ '@' ~ gethostname;
}
