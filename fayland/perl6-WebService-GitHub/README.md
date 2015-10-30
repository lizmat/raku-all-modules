# perl6-WebService-GitHub

[![Build Status](https://travis-ci.org/fayland/perl6-WebService-GitHub.svg?branch=master)](https://travis-ci.org/fayland/perl6-WebService-GitHub)

*ALPHA STAGE, SUBJECT TO CHANGE*

## SYNOPSIS

    use WebServices::GitHub;

    my $gh = WebServices::GitHub.new(
        access-token => 'my-access-token'
    );

    my $res = $gh.request('/user');
    say $res.data.name;

## TODO

Patches welcome

 * Break down modules (Users, Repos, Issues etc.)
 * Errors Handle
 * Conditional requests
 * Auto Pagination
 * API Throttle

## Methods

### Args

 * `endpoint`

useful for GitHub Enterprise. default to https://api.github.com

 * `access-token`

Required for Authorized API Request

 * `auth_login` & `auth_password`

Basic Authenticaation. useful to get `access-token`.

 * `per_page`

from [Doc](https://developer.github.com/v3/#pagination), default to 30, max to 100.

 * `jsonp_callback`

[JSONP Callback](https://developer.github.com/v3/#json-p-callbacks)

 * `time-zone`

UTC by default, [Doc](https://developer.github.com/v3/#timezones)

### Response

 * `raw`

HTTP::Response instance

 * `data`

JSON decoded data

 * `header(Str $field)`

Get header of HTTP Response

 * `first-page-url`, `prev-page-url`, `next-page-url`, `last-page-url`

Parsed from Link header, [Doc](https://developer.github.com/v3/#pagination)

 * `x-ratelimit-limit`, `x-ratelimit-remaining`, `x-ratelimit-reset`

[Rate Limit](https://developer.github.com/v3/#rate-limiting)

## Examples

### Public Access without access-token

#### get user info

```
my $gh = WebServices::GitHub.new;
my $user = $gh.request('/users/fayland').data;
say $user<name>;
```

#### search repositories

```
use WebServices::GitHub::Search;

my $search = WebServices::GitHub::Search.new;
my $data = $search.repositories({
    :q<perl6>,
    :sort<stars>,
    :order<desc>
}).data;
```

### OAuth

#### get token from user/login

[examples/create_access_token.pl](examples/create_access_token.pl)

```perl6
use WebServices::GitHub::OAuth;

my $gh = WebServices::GitHub::OAuth.new(
    auth_login => 'username',
    auth_password => 'password'
);

my $auth = $gh.create_authorization({
    :scopes(['user', 'public_repo', 'repo', 'gist']), # just ['public_repo']
    :note<'test purpose'>
}).data;
say $auth<token>;
```

### Gist

#### create a gist

```
use WebServices::GitHub::Gist;

my $gist = WebServices::GitHub::Gist.new(
    access-token => %*ENV<GITHUB_ACCESS_TOKEN>
);

my $data = $gist.create_gist({
    description => 'Test from perl6 WebServices::GitHub::Gist',
    public => True,
    files => {
        'test.txt' => {
            content => "Created on " ~ now
        }
    }
}).data;
say $data<url>;
```

#### update gist

```
$data = $gist.update_gist($id, {
    files => {
        "test_another.txt" => {
            content => "Updated on " ~ now
        }
    }
}).data;
```

#### delete gist

```
$res = $gist.delete_gist($id);
say 'Deleted' if $res.is-success;
```
