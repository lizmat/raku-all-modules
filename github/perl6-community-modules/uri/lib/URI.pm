unit class URI;

use IETF::RFC_Grammar;
use IETF::RFC_Grammar::URI;
use URI::Escape;
need URI::DefaultPort;

class X::URI::Invalid is Exception {
    has $.source;
    method message { "Could not parse URI: $!source" }
}

has $.grammar;
has Bool $.match-prefix = False;
has $!path;
has $!is_absolute;  # part of deprecated code scheduled for removal
has $!scheme;
has $!authority;
has $!query;
has $!frag;
has %!query_form;
has $!uri;  # use of this now deprecated

has @.segments;

method parse (Str $str, :$match-prefix) {

    # clear string before parsing
    my Str $c_str = $str;
    $c_str .= subst(/^ \s* ['<' | '"'] /, '');
    $c_str .= subst(/ ['>' | '"'] \s* $/, '');

    $!uri = $!path = $!is_absolute = $!scheme = $!authority = $!query =
        $!frag = Mu;
    %!query_form = @!segments = ();

    if ($!match-prefix or $match-prefix) {
        $!grammar.subparse($c_str);
    }
    else {
        try $!grammar.parse($c_str);
    }

    # hacky but for the time being an improvement
    if (not $!grammar.parse_result) {
        X::URI::Invalid.new(source => $str).throw
    }

    # now deprecated
    $!uri = $!grammar.parse_result;

    my $comp_container = $!grammar.parse_result<URI-reference><URI> ||
        $!grammar.parse_result<URI-reference><relative-ref>;
    $!scheme = $comp_container<scheme>;
    $!query = $comp_container<query>;
    $!frag = $comp_container<fragment>;
    $comp_container = $comp_container<hier-part> || $comp_container<relative-part>;

    $!authority = $comp_container<authority>;
    $!path =    $comp_container<path-abempty>       ||
                $comp_container<path-absolute>      ;
    $!is_absolute = ?($!path || $!scheme); # part of deprecated code

    $!path ||=  $comp_container<path-noscheme>      ||
                $comp_container<path-rootless>      ;

    @!segments = $!path<segment>.list() || ('');
    if my $first_chunk = $!path<segment-nz-nc> || $!path<segment-nz> {
        unshift @!segments, $first_chunk;
    }
    if @!segments.elems == 0 {
        @!segments = ('');
    }
#    @!segments ||= ('');

    try {
        %!query_form = split_query( ~$!query ) if $!query;
        CATCH {
            default {
                %!query_form = ();
            }
        }
    }
}

our sub split-query(Str $query) {
    my %query_form;

    for map { [split(/<[=]>/, $_) ]}, split(/<[&;]>/, $query) -> $qmap {
        for (0, 1) -> $i { # could go past 1 in theory ...
            $qmap[ $i ] = uri-unescape($qmap[ $i ]);
        }
        if %query_form{$qmap[0]}:exists {
            if %query_form{ $qmap[0] } ~~ Array  {
                %query_form{ $qmap[0] }.push($qmap[1])
            }
            else {
                %query_form{ $qmap[0] } = [
                    %query_form{ $qmap[0] }, $qmap[1]
                ]
            }
        }
        else {
            %query_form{ $qmap[0]} = $qmap[1]
        }
    }

    return %query_form;

}

# artifact form
our sub split_query(Str $query) { split-query($query) }

# deprecated old call for parse
method init ($str) {
    warn "init method now deprecated in favor of parse method";
    $.parse($str);
}

# new can pass alternate grammars some day ...
submethod BUILD(:$match-prefix) {
    $!match-prefix = ? $match-prefix;
    $!grammar = IETF::RFC_Grammar.new('rfc3986');
}

multi method new(Str $uri, :$match-prefix) {
    my $obj = self.bless(:$match-prefix);

    $obj.parse($uri) if $uri.defined;
    return $obj;
}

multi method new(Str :$uri, :$match-prefix) {
    return self.new($uri, :$match-prefix);
}

method scheme {
    return ($!scheme // '').lc;
}

method authority {
    return ($!authority // '').lc;
}

method host {
    return ($!authority<host> // '').lc;
}

method default-port {
    URI::DefaultPort.scheme-port($.scheme)
}
method default_port { $.default-port() } # artifact form

method _port {
    # port 0 is off limits and see also RT 96424
    # $!authority<port>.Int doesn't work because of RT 96472
    $!authority<port> ?? ($!authority<port> ~ '').Int !! Int;
}

method port {
    $._port // $.default-port;
}

method userinfo {
    return ~($!authority<userinfo> // '');
}

method path {
    return ~($!path // '');
}

my $warn-deprecate-abs-rel = q:to/WARN-END/;
    The absolute and relative methods are artifacts carried over from an old
    version of the p6 module.  The perl 5 module does not provide such
    functionality.  The Ruby equivalent just checks for the presence or
    absence of a scheme.  The URI rfc does identify absolute URIs and
    absolute URI paths and these methods somewhat confused the two.  Their
    functionality at the URI level is no longer seen as needed and is
    being removed.
WARN-END
 
method absolute {
    warn "deprecated -\n$warn-deprecate-abs-rel";
    return Bool.new;
}

method relative {
    warn "deprecated -\n$warn-deprecate-abs-rel";
    return Bool.new;
}

method query {
    item ~($!query // '');
}

method path-query {
    $.query ?? $.path ~ '?' ~ $.query !! $.path
}
method path_query { $.path-query } #artifact form

method frag {
    return ($!frag // '').lc;
}

method fragment { $.frag }

method gist() {
    my Str $s;
    $s ~= $.scheme if $.scheme;
    $s ~= '://' ~ $.authority if $.authority;
    $s ~= $.path;
    $s ~= '?' ~ $.query if $.query;
    $s ~= '#' ~ $.frag if $.frag;
    return $s;
}

method Str() {
    return $.gist;
}

# chunks now strongly deprecated
# it's segments in p5 URI and segment is part of rfc so no more chunks soon!
method chunks {
    warn "chunks attribute now deprecated in favor of segments";
    return @!segments;
}

method uri {
    warn "uri attribute now deprecated in favor of .grammar.parse_result";
    return $!uri;
}

method query-form {
    return %!query_form;
}

method query_form { $.query-form }

=begin pod

=head1 NAME

URI — Uniform Resource Identifiers (absolute and relative)

=head1 SYNOPSIS

    use URI;
    my $u = URI.new('http://her.com/foo/bar?tag=woow#bla');

    my $scheme = $u.scheme;
    my $authority = $u.authority;
    my $host = $u.host;
    my $port = $u.port;
    my $path = $u.path;
    my $query = $u.query;
    my $frag = $u.frag; # or $u.fragment;
    my $tag = $u.query_form<tag>; # should be woow

    # something p5 URI without grammar could not easily do !
    my $host_in_grammar =
        $u.grammar.parse_result<URI-reference><URI><hier-part><authority><host>;
    if ($host_in_grammar<reg-name>) {
        say 'Host looks like registered domain name - approved!';
    }
    else {
        say 'Sorry we do not take ip address hosts at this time.';
        say 'Please use registered domain name!';
    }

    {
    # require whole string matches URI and throw exception otherwise ..
    my $u_v = URI.new('http://?#?#');
    CATCH { when X::URI::Invalid { ... } }
    }

    my $u_pfx = URI.new('http://example.com } function(var mm){',
        match-prefix => True);
=end pod


# vim:ft=perl6
