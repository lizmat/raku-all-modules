Perl6 realization of URI - Uniform Resource Identifiers handler

A URI implementation using Perl 6 grammars to implement RFC 3986 BNF. 
Currently only implements parsing.  Includes URI::Escape to (un?)escape
characters that aren't otherwise allowed in a URI with % and a hex
character numbering.

    use URI;
    my URI $u .= new('http://her.com/foo/bar?tag=woow#bla');
    my $scheme = $u.scheme;
    my $authority = $u.authority;
    my $host = $u.host;
    my $port = $u.port;
    my $path = $u.path;
    my $query = $u.query;
    my $frag = $u.frag; # or $u.fragment;
    my $tag = $u.query-form<tag>; # should be woow
    # etc.

    use URI::Escape;
    my $escaped = uri-escape("10% is enough\n");
    my $un-escaped = uri-unescape('10%25%20is%20enough%0A'); 

### Status
[![Build Status](https://travis-ci.org/perl6-community-modules/uri.png)](https://travis-ci.org/perl6-community-modules/uri)

