# NAME

WebService::Lastfm - interact with Last.fm's API

# SYNOPSIS

```perl6
my $lastfm = WebService::Lastfm.new(:api-key<1234>, :api-secret<music>);

# Read request
say $lastfm.request('user.getInfo', :user<avuserow>);

# Update now playing
say $lastfm.write('track.updateNowPlaying',
    :sk<SECRET KEY>,
    :artist("Alan Parsons Project"),
    :track<Time>,
    :duration<360>,
);
```

# DESCRIPTION

Bindings for Last.fm's API using the JSON format (instead of their default
XML). You must register for their API to get an API key and API secret.

# METHODS

## new($api-key, $api-secret)

Standard new method. All parameters are optional, but the API key is needed for
all known requests, and the secret is needed for write methods.

## request($method, \*%params)

Make an unsigned GET request, used for read-only operations.

## write($method, \*%params)

Make a signed POST request, used for writing operations, the most famous of
which is "scrobbling" (track.scrobble).

# EXCEPTIONS

X::WebService::Lastfm is thrown on any error responses, with the decoded error
message from Last.fm. Check the method's documentation (or the API
documentation overall) for the meaning of the code.

# CAVEATS

- No packaged tests -- testing things that require API keys is nontrivial
- The assumption about requests being either GET/unsigned or POST/signed may
  not be true, in which case more methods may be needed.
- Undertested in general

# TODO

- Switch to HTTP::UserAgent, which needs work to implement this
- Add tests somehow
- Example scripts. Ideas include a history exporter and a CLI scrobbler
- Optional caching mode
- Some sort of pagination helper for some API calls

# REQUIREMENTS

- Rakudo Perl 6
- LWP::Simple
- JSON::Tiny
- URI::Encode
- Digest::MD5

# SEE ALSO

[Last.fm's API documentation](http://www.last.fm/api/intro)
