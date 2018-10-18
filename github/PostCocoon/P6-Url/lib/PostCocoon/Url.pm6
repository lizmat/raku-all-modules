use v6;


=TITLE PostCocoon::Url
=SUBTITLE Some simple but useful URL utils
=begin SYNOPSIS
A collection of functions that can be used for URL parsing, building and changing.

Also provides an loose URL tokenizer
=end SYNOPSIS

unit module PostCocoon::Url;

#| Transforms an string into an percent encoded string
sub url-encode (Str $data --> Str) is export {
  my $start = 0;
  my $encoded-data = $data;

  for $data ~~ m:c:g:i/<-[a .. z 0 .. 9 \- \. _]>/ -> $match {
    my $current-start = $start + $match.from;
    my $current-end = $start + $match.to;
    my $current-match = ~$match;

    $current-match = $current-match.encode("utf-8")>>.base(16).map({ "%" ~ (($_.chars % 2) > 0 ?? "0" !! "") ~ $_ }).join();

    $start += $current-match.chars - (~$match).chars;
    $encoded-data =
      $encoded-data.substr(0, $current-start) ~
      $current-match ~
      $encoded-data.substr($current-end);
  }

  return $encoded-data;
}

#| Transforms an percent encoded string into an plain string
sub url-decode (Str $data --> Str) is export {
  my $start = 0;
  my $decoded-data = $data.encode("utf-8");

  for $data ~~ m:c:g:i/\%(<[a .. f 0 .. 9]> ** 2)/ -> $match {
    my $current-start = $start + $match.from - 1;
    my $current-end = $start + $match.to;
    # Our result is always 2 bytes shorter: "%20" vs " "
    $start -= 2;
    $decoded-data = Blob.new(|$decoded-data[0..$current-start], (~$match[0]).parse-base(16), |$decoded-data[$current-end..*]);
  }

  return $decoded-data.decode("utf-8");
}

#| Build an query string from an Hash
multi sub build-query-string (Hash $hash --> Str) is export {
  my @query-items;
  for $hash.kv -> $key, $value {
    if ($value eq True) {
      @query-items.push: url-encode($key);
    } elsif ($value ~~ List) {
      for $value.kv -> $k, $v {
        @query-items.push: url-encode($key) ~ "=" ~ url-encode($v);
      }
    } else {
      @query-items.push: url-encode($key) ~ "=" ~ url-encode($value);
    }
  }

  return @query-items.join("&");
}

#| Build an query string from the named arguments
multi sub build-query-string (*%hash --> Str) is export {
  build-query-string(%hash);
}

#| Parse a query string
sub parse-query-string(Str $query-string --> Hash) is export {
  my $items = $query-string.split("&");
  my $result = {};

  for $items.kv -> $k, $v {
    my ($key, $value) = $v.split("=", 2);
    $key = url-decode $key;

    if defined $value {
      $value = url-decode $value;
    }

    $value //= True;

    if defined $result{$key} {
      if $result{$key} ~~ Positional {
        $result{$key}.push: $value;
      } else {
        my $item = $result{$key};
        $result{$key} = ($item, $value);
      }
    } else {
      $result{$key} = $value;
    }
  }

  return $result;
}

#| Loose URL parser that doesn't follow RFC3986 not completly.
grammar URL-Parser is export {
  token TOP {
    [<scheme> ':' ]? '//'? [ <auth> '@' ]? [ <host> <path> | <host> | <path> ] [ '?' <query-string> ]? [ '#' <fragment> ]?
  }

  token scheme {
    <[ a..z ]> <[a..z 0..9 + \- .]>*
  }

  token path {
    '/' <-[ ? # ]>*
  }

  token auth {
    <username> [ ':' <password> ]?
  }

  token query-string {
    <-[ # ]>*
  }

  token fragment {
    <-[ \s ]>*
  }

  token username {
    <-[ : @ ]>*
  }

  token password {
    <-[ @ ]>*
  }

  token host {
    <hostname> [ ':' <port> ]?
  }

  token hostname {
    [
    <-[ / : # ? \h ]>+ |
    \[ <-[ \] ]>+ \]
    ]
  }

  token port {
    <[ 0..9 ]>+
  }
}

#| Check if something is a valid url according to the parser
sub is-valid-url (Str $uri --> Bool) is export {
  return URL-Parser.parse($uri) !~~ Nil;
}

#| Return an hash with all items of the url
sub parse-url (Str $uri --> Hash) is export {
  my $result = {};
  my $grammar = URL-Parser.parse($uri);
  if ($grammar ~~ Nil) {
    X::AdHoc.new(payload => "$uri is not an valid url").throw;
  }

  for <scheme fragment path query-string host auth> -> $key {
    if defined $grammar{$key} {
      $result{$key} = ~$grammar{$key};
    }
  }

  if defined $grammar<host> {
    $result<hostname> [R//]= ~$grammar<host><hostname>;
    $result<port> [R//]= ~$grammar<host><port>;
  }

  if defined $grammar<auth> {
    $result<username> [R//]= ~$grammar<auth><username>;
    $result<password> [R//]= ~$grammar<auth><password>;
  }

  return $result;
}

#| Build an url from given hash,
#| this function does no error checking at all, it may result in an invalid url
multi sub build-url (Hash $hash --> Str) is export {
  my $url = "";

  if defined $hash<scheme> {
    $url ~= $hash<scheme> ~ '://';
  }

  if defined $hash<auth> {
    $url ~= $hash<auth> ~ "@";
  } elsif defined $hash<username> {
    $url ~= $hash<username>;
    if defined $hash<password> {
      $url ~= ":" ~ $hash<password>
    }
    $url ~= "@";
  }

  if defined $hash<host> {
    $url ~= $hash<host>;
  } elsif defined $hash<hostname> {
    $url ~= $hash<hostname>;
    if defined $hash<port> {
      $url ~= ':' ~ $hash<port>
    }
  }

  if defined $hash<path> {
    if $hash<path>.substr(0, 1) ne "/" {
      $url ~= "/";
    }

    $url ~= $hash<path>
  }

  if defined $hash<query-string> {
    $url ~= '?' ~ $hash<query-string>;
  }

  if defined $hash<fragment> {
    $url ~= '#' ~ $hash<fragment>
  }

  return $url
}

#| Build an url from given named parameters,
#| this function does no error checking at all, it may result in an invalid url
multi sub build-url (*%hash --> Str) is export {
  build-url(%hash);
}
