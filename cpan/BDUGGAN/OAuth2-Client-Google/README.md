NAME
====

OAuth2::Client::Google -- Authenticate with Google using OAuth2.

Quick how-to
============

1. Go to http://console.developers.google.com and create a project.

2. Set up credentials for a web server and set your redirect URIs.

3. Download the JSON file (client_id.json).

4. In your application, create an oauth2 object like this:

            my $oauth = OAuth2::Client::Google.new(
                config => from-json('./client_id.json'.IO.slurp),
                redirect-uri => 'http://localhost:3334/oauth',
                scope => 'email'
            );

where redirect-uri is one of your redirect URIs and scope is a space or comma-separated list of scopes from <https://developers.google.com/identity/protocols/googlescopes>.

To authenticate, redirect the user to

    $oauth.auth-uri

Then when they come back and send a request to '/oauth', grab the "code" parameter from the query string. Use it to call

    my $token = $oauth.code-to-token(code => $code)

This will give you `$token<access_token>`, which you can then use with google APIs.

If you also included "email" in the scope, you will get id-token, which you can use like this:

    my $identity = $oauth.verify-id(id-token => $token<id_token>)

which has, e.g. `$identity<email>` and `$identity<given_name>`.

For a working example, see [eg/get-calendar-data.p6](eg/get-calendar-data.p6).

STATUS
======

[![Build Status](https://travis-ci.org/bduggan/p6-oauth2-client-google.svg?branch=master)](https://travis-ci.org/bduggan/p6-oauth2-client-google)

SEE ALSO
========

https://developers.google.com/identity/protocols/OAuth2WebServer

TODO
====

* Better documentation

* Refresh tokens
