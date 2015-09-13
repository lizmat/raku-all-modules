use v6;

#| Enumeration of standard headers
enum HTTP::Header::Standard::Name is export
    # General, Request, Response, Entity Headers
    <
        Cache-Control Connection Date Pragma Trailer Transfer-Encoding
        Upgrade Via Warning

        Accept Accept-Charset Accept-Encoding Accept-Language
        Authorization Cookie Expect From Host If-Match If-Modified-Since
        If-None-Match If-Range If-Unmodified-Since Max-Forwards
        Proxy-Authorization Range Referer TE User-Agent

        Accept-Ranges Age ETag Location Proxy-Authenticate Retry-After
        Server Set-Cookie Vary WWW-Authenticate

        Allow Content-Encoding Content-Language Content-Length
        Content-Location Content-MD5 Content-Range Content-Type
        Expires Last-Modified
    >;

class HTTP::Headers { ... }

#| Role for defining all header objects
role HTTP::Header {
    has @.values is rw; #= The values stored by a header

    my @dow = <Mon Tue Wed Thu Fri Sat Sun>;
    my @moy = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

    #| Convert objects stored into appropriately formatted strings
    method prepared-values {
        do for @!values -> $value is copy {
            given $value {
                when Instant {
                    $value = DateTime.new($value);
                    proceed;
                }
                when DateTime {
                    $value .= utc;
                    $value = sprintf "%s, %02d %s %04d %02d:%02d:%02d GMT",
                        @dow[.day-of-week - 1],
                        .day, @moy[.month - 1], .year,
                        .hour, .minute, .second;
                }
                when Duration {
                    $value .= Str;
                }
            }

            $value;
        }
    }

    #| Treat the values of this header as a single value
    method value is rw {
        my $self = self;
        Proxy.new(
            FETCH => method ()     { $self.prepared-values.join(', ') },
            STORE => method ($new) { $self.values = $new },
        );
    }

    #| Retrieve the primary value out of the header value
    method primary {
        my $self = self;
        Proxy.new(
            FETCH => method () {
                try {
                    if $self.values.elems > 0 {
                        $self.prepared-values[0].comb(/ <-[ ; ]>+ /)[0].trim
                    }
                    else {
                        Str
                    }
                }
            },
            STORE => method ($new) {
                my $value = @($self.prepared-values)[0];
                my @items = try { $value.comb(/ <-[ ; ]>+ /, 2) };
                @items[0] = $new.trim;
                @!values[0] = @items.join('; ');
                $new.trim;
            },
        );
    }

    #| Retrieve all the parameters associated with this header value
    method params {
        my %result;
        my @pairs = try { self.prepared-values».comb(/ <-[ ; ]>+ /)».grep(/'='/) };
        for @pairs -> $pair {
            my ($key, $value) = $pair.split('=', 2);
            %result{$key.trim.lc} = $value.trim;
        }
        %result;
    }

    #| Set a header value on the string (this is semi-internal)
    method set-param($name, $new-value) {
        my $found = False;
        @!values = do for @(self.prepared-values) -> $prep-value {
            my @pairs = try { $prep-value.comb(/ <-[ ; ]>+ /) };
            my @result-pairs = gather for @pairs {
                when !$found && /'='/ { # only change the first
                    my ($key, $value) = .split('=', 2);
                    if ($key.trim.lc eq $name.trim.lc) {
                        $found++;
                        if ($new-value.defined) {
                            take "{$key.trim}={$new-value.trim}"
                        }
                    }
                    else {
                        take $_
                    }
                }
                default { take $_ }
            };

            @result-pairs.push: "{$name.trim}={$new-value.trim}"
                unless $found;

            @result-pairs.join('; ');
        }
    }

    #| Read/write a parameter set within a value
    method param($name) is rw {
        my $self = self;
        Proxy.new(
            FETCH => method ()     { $self.params{$name} },
            STORE => method ($new) { $self.set-param($name, $new) },
        );
    }

    #| Read the individual values as an array lookup
    method AT-POS($index) { @!values[$index] }

    # TODO Why can't I make this a stub ... ?
    #method name { } #= The name of the header

    method key returns Str { self.name.lc } #= The header lookup key

    method push(*@values) { @!values.push: @values } #= Push values into the header
    method unshift(*@values) { @!values.push: @values } #= Unshift values into the header
    method shift() { @!values.shift } #= Shift values off the header
    method pop() { @!values.pop } #= Pop values off the header

    #| Set the given values only if the header has none already
    method init(*@values) {
        unless @!values {
            @!values = @values;
        }
    }

    #| Remove all values from this header
    method remove() { @!values = () }

    #| Output the header in Name: Value form for each value
    method as-string(Str :$eol = "\n") {
        join $eol, do for self.prepared-values -> $value {
            "{self.name.Str}: $value";
        }
    }

    method Bool { ?@!values } #= True if this header has values
    method Str  { self.value } #= Same as calling .value
    method Int  { self.value.Int } #= Treat the whole value as an Int
    method list { self.prepared-values } #= Same as calling .prepared-values
}

#| A standard header definition
class HTTP::Header::Standard does HTTP::Header {
    has HTTP::Header::Standard::Name $.name;

    method clone {
        my HTTP::Header::Standard $obj .= new(:$!name);
        $obj.values = @.values;
        $obj;
    }
}

#| A Content-Type header definition
role HTTP::Header::Standard::Content-Type {
    method is-text { ?(self.primary ~~ /^ "text/" /) } #= True if the Content-Type is text/*
    method is-html { self.primary eq 'text/html' || self.is-xhtml } #= True if Content-Type is text/html or .is-xhtml
    method is-xhtml { #= True if Content-Type is xhtml
        ?(self.primary ~~ any(<
            application/xhtml+xml
            application/vnd.wap.xhtml+xml
        >));
    }
    method is-xml { #= True if Content-Type is xml
        ?(self.primary ~~ any(<
            text/xml
            application/xml
        >, /"+xml"/));
    }

    #| Read or write the charset parameter
    method charset is rw { self.param('charset') }
}

#| A custom header definition
class HTTP::Header::Custom does HTTP::Header {
    has Str $.name;

    method clone {
        my HTTP::Header::Custom $obj .= new(:$!name);
        $obj.values = @.values;
        $obj;
    }
}

#! A group of headers
class HTTP::Headers {
    has HTTP::Header %!headers; #= Internal header storage... no touchy
    has Bool $.quiet = False; #= Silence all warnings

    method internal-headers() { %!headers }

    #| Initialze headers with a list of pairs
    multi method new(@headers, Bool :$quiet = False) {
        my $self = self.bless(:$quiet);
        $self.headers(@headers) if @headers;
        $self;
    }

    #| Initialize headers with an array
    multi method new(%headers, Bool :$quiet = False) {
        my $self = self.bless(:$quiet);
        $self.headers(%headers) if %headers;
        $self;
    }

    #| Initialize headers empty or with a slurpy list of pairs or a slurpy hash
    multi method new(Bool :$quiet = False, *@headers, *%headers) {
        my $self = self.bless(:$quiet);
        $self.headers(%headers) if %headers;
        $self.headers(@headers) if @headers;
        $self;
    }

    #| Set multiple headers from a list of pairs
    multi method headers(@headers) {
        my $seen = SetHash.new;
        for flat @headers».kv -> $k, $v {
            if $seen ∋ $k {
                self.header($k).push: $v;
            }
            else {
                self.header($k) = $v;
                $seen{$k}++;
            }
        }
    }

    #| Set multiple headers from a hash
    multi method headers(%headers) {
        for flat %headers.kv -> $k, $v {
            self.header($k) = $v;
        }
    }

    #| Set multiple headers from a slurpy list of pairs or slurpy hash
    multi method headers(*@headers, *%headers) {
        my $seen = SetHash.new;
        for flat @headers».kv, %headers.kv -> $k, $v {
            if $seen ∋ $k {
                self.header($k).push: $v;
            }
            else {
                self.header($k) = $v;
                $seen{$k}++;
            }
        }
    }

    #| Helper for building header objects
    method build-header($name, *@values) returns HTTP::Header {
        my $std-name = $name;
        if $name ~~ Str {
            $std-name = $name.trans('_' => ' ', '-' => ' ').wordcase.trans(' ' => '-');
        }

        if my $std = ::($std-name) {
            my $h = HTTP::Header::Standard.new(:name($std), :@values);
            if $std ~~ HTTP::Header::Standard::Name::Content-Type {
                $h but HTTP::Header::Standard::Content-Type;
            }
            else {
                $h
            }
        }
        else {
            HTTP::Header::Custom.new(:name($std-name), :@values);
        }
    }

    method AT-KEY($key)             { self.header($key) } #= use $headers{*} to fetch headers
    method ASSIGN-KEY($key, $value) { self.header($key) = $value } #= use $headers{*} to set headers
    method DELETE-KEY($key)         { self.remove-header($key) } #= use $headers{*} :delete to remove headers
    method EXISTS-KEY($key)         { ?self.header($key) } #= use $headers{*} :exists to test for the existance of a header

    #| Returns the number of headers set
    method elems { self.vacuum; %!headers.elems }

    #| Returns the headers as a sorted list
    method list { self.sorted-headers }

    #| Performs a safe deep clone of the headers
    method clone {
        my HTTP::Headers $obj .= new;
        for %!headers.kv -> $k, $v {
            $obj.internal-headers{$k} = $v.clone;
        }
        $obj;
    }

    #| Helper for use by .header()
    method header-proxy($name) {
        my $tmp = self.build-header($name);
        my $h = %!headers{$tmp.key} //= $tmp;
        Proxy.new(
            FETCH => method ()      { $h },
            STORE => method (*@new) { $h.values = @new }
        );
    }

    #| Read or write a standard header
    multi method header(HTTP::Header::Standard::Name $name) is rw returns HTTP::Header {
        self.header-proxy($name);
    }

    #| Read or write a custom header
    multi method header(Str $name, :$quiet = False) is rw returns HTTP::Header {
        warn qq{Calling .header($name) is preferred to .header("$name") for standard HTTP headers.}
            if !$!quiet && !$quiet && ::($name).defined;

        self.header-proxy($name);
    }

    #| Remove a header
    multi method remove-header($name) {
        my $tmp = self.build-header($name);
        %!headers{$tmp.key} :delete;
    }

    method remove-headers(*@names) {
        DEPRECATED('remove-header',|<0.2 1.0>);
        self.remove-header(|@names);
    }

    #| Remove more than one header
    multi method remove-header(*@names) {
        do for @names -> $name {
            my $tmp = self.build-header($name);
            %!headers{$tmp.key} :delete;
        }
    }

    #| Remove all the entity and Content-* headers
    method remove-content-headers {
        self.remove-header( %!headers.keys.grep(/^ content "-"/), <
            Allow Content-Encoding Content-Language Content-Length
            Content-Location Content-MD5 Content-Range Content-Type
            Expires Last-Modified
        >);
    }

    #| Remove all headers
    method clear { %!headers = () }

    #| Clean up header objects that have no values
    method vacuum {
        for %!headers.kv -> $k, $v {
            %!headers{$k} :delete if !$v;
        }
    }

    #| Return the headers as a sorted list
    method sorted-headers {
        self.vacuum;

        %!headers.values.sort: -> $a, $b {
            given $a.name {
                when HTTP::Header::Standard::Name {
                    given $b.name {
                        when HTTP::Header::Standard::Name { $a.name cmp $b.name }
                        default { Order::Less }
                    }
                }
                default {
                    given $b.name {
                        when HTTP::Header::Standard::Name { Order::More }
                        default { $a.name leg $b.name }
                    }
                }
            }
        }
    }

    method for(&code) {
        # DEPRECATED WITHIN RAKUDO!!!
        self.sorted-headers.for: &code;
    }

    #| Iterate over the headers in sorted order
    method flatmap(&code) {
        self.sorted-headers.flatmap: &code;
    }

    #| Output the headers as a string in sorted order
    method as-string(Str :$eol = "\n") {
        self.vacuum;

        my $string = join $eol, self.flatmap: -> $header {
            $header.as-string(:$eol);
        };

        $string ~= $eol if $string;
        $string;
    }

    #! Same as as-string
    method Str { self.as-string }

    #| Return the headers as a list of Pairs for use with PSGI
    method for-PSGI {
        # Should be deprecated...
        self.for-P6SGI;
    }

    method for-P6SGI {
        self.flatmap: -> $h {
            do for $h.prepared-values -> $v {
                ~$h.name => ~$v
            }
        }
    }


    method Cache-Control       is rw { self.header(HTTP::Header::Standard::Name::Cache-Control) }
    method Connection          is rw { self.header(HTTP::Header::Standard::Name::Connection) }
    method Date                is rw { self.header(HTTP::Header::Standard::Name::Date) }
    method Pragma              is rw { self.header(HTTP::Header::Standard::Name::Pragma) }
    method Trailer             is rw { self.header(HTTP::Header::Standard::Name::Trailer) }
    method Transfer-Encoding   is rw { self.header(HTTP::Header::Standard::Name::Transfer-Encoding) }
    method Upgrade             is rw { self.header(HTTP::Header::Standard::Name::Upgrade) }
    method Via                 is rw { self.header(HTTP::Header::Standard::Name::Via) }
    method Warning             is rw { self.header(HTTP::Header::Standard::Name::Warning) }

    method Accept              is rw { self.header(HTTP::Header::Standard::Name::Accept) }
    method Accept-Charset      is rw { self.header(HTTP::Header::Standard::Name::Accept-Charset) }
    method Accept-Encoding     is rw { self.header(HTTP::Header::Standard::Name::Accept-Encoding) }
    method Accept-Langauge     is rw { self.header(HTTP::Header::Standard::Name::Accept-Language) }
    method Authorization       is rw { self.header(HTTP::Header::Standard::Name::Authorization) }
    method Cookie              is rw { self.header(HTTP::Header::Standard::Name::Cookie) }
    method Expect              is rw { self.header(HTTP::Header::Standard::Name::Expect) }
    method From                is rw { self.header(HTTP::Header::Standard::Name::From) }
    method Host                is rw { self.header(HTTP::Header::Standard::Name::Host) }
    method If-Match            is rw { self.header(HTTP::Header::Standard::Name::If-Match) }
    method If-Modified-Since   is rw { self.header(HTTP::Header::Standard::Name::If-Modified-Since) }
    method If-None-Match       is rw { self.header(HTTP::Header::Standard::Name::If-None-Match) }
    method If-Range            is rw { self.header(HTTP::Header::Standard::Name::If-Range) }
    method If-Unmodified-Since is rw { self.header(HTTP::Header::Standard::Name::If-Unmodified-Since) }
    method Max-Forwards        is rw { self.header(HTTP::Header::Standard::Name::Max-Forwards) }
    method Proxy-Authorization is rw { self.header(HTTP::Header::Standard::Name::Proxy-Authorization) }
    method Range               is rw { self.header(HTTP::Header::Standard::Name::Range) }
    method Referer             is rw { self.header(HTTP::Header::Standard::Name::Referer) }
    method TE                  is rw { self.header(HTTP::Header::Standard::Name::TE) }
    method User-Agent          is rw { self.header(HTTP::Header::Standard::Name::User-Agent) }

    method Accept-Ranges       is rw { self.header(HTTP::Header::Standard::Name::Accept-Ranges) }
    method Age                 is rw { self.header(HTTP::Header::Standard::Name::Age) }
    method ETag                is rw { self.header(HTTP::Header::Standard::Name::ETag) }
    method Location            is rw { self.header(HTTP::Header::Standard::Name::Location) }
    method Proxy-Authenticate  is rw { self.header(HTTP::Header::Standard::Name::Proxy-Authenticate) }
    method Retry-After         is rw { self.header(HTTP::Header::Standard::Name::Retry-After) }
    method Server              is rw { self.header(HTTP::Header::Standard::Name::Server) }
    method Set-Cookie          is rw { self.header(HTTP::Header::Standard::Name::Set-Cookie) }
    method Vary                is rw { self.header(HTTP::Header::Standard::Name::Vary) }
    method WWW-Authenticate    is rw { self.header(HTTP::Header::Standard::Name::WWW-Authenticate) }

    method Allow               is rw { self.header(HTTP::Header::Standard::Name::Allow) }
    method Content-Encoding    is rw { self.header(HTTP::Header::Standard::Name::Content-Encoding) }
    method Content-Language    is rw { self.header(HTTP::Header::Standard::Name::Content-Language) }
    method Content-Length      is rw { self.header(HTTP::Header::Standard::Name::Content-Length) }
    method Content-Location    is rw { self.header(HTTP::Header::Standard::Name::Content-Location) }
    method Content-MD5         is rw { self.header(HTTP::Header::Standard::Name::Content-MD5) }
    method Content-Range       is rw { self.header(HTTP::Header::Standard::Name::Content-Range) }
    method Content-Type        is rw { self.header(HTTP::Header::Standard::Name::Content-Type) }
    method Expires             is rw { self.header(HTTP::Header::Standard::Name::Expires) }
    method Last-Modified       is rw { self.header(HTTP::Header::Standard::Name::Last-Modified) }
}
