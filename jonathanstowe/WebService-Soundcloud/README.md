# WebService::Soundcloud 


Provide a Perl 6 interface to the Soundcloud REST API.

[![Build Status](https://travis-ci.org/jonathanstowe/WebService-Soundcloud.svg?branch=master)](https://travis-ci.org/jonathanstowe/WebService-Soundcloud)

## Synopsis

You can use the Full OAuth flow:

```perl6

    use WebService::Soundcloud;
    
    my $scloud = WebService::Soundcloud.new(:$client-id, :$client-secret, redirect-uri => 'http://mydomain.com/callback' );
    
    # Now get authorization url
    my $authorization_url = $scloud.get-authorization-url();
    
    # Now your appplication should redirect the user to the authorization uri
    # When the User has authenticated and approved the connection they will
    # in turn be redirected back to your redirect URI with either the grant code
    # (as code) or an error (as error) as query parameters
    
    # Get Access Token with the code provided as query parameter to the redirect
    my $access_token = $scloud.get-access-token($code);
    
    # Save access_token and refresh_token, expires_in, scope for future use
    my $oauth_token = $access_token<access_token>;
    
    # a GET request '/me' - gets users details
    my $user = $scloud->get('/me');
    
    # a PUT request '/me' - updated users details
    my $user = $scloud->put('/me', to-json( { user => { description => 'Have fun with Perl wrapper to Soundcloud API' } } ) );
                
    # Comment on a Track POSt request usage
    my $comment = $scloud->post('/tracks/<track_id>/comments', 
                            { body => 'I love this hip-hop track' } );
    
    # Delete a track
    my $track = $scloud->delete('/tracks/{id}');
    
```

or you can use direct credential based authorisation that can skip the redirections:

```perl6

    use WebService::Soundcloud;


    my $sc = WebService::Soundcloud.new(:$client-id,:$client-secret,:$username,:$password);

    # Because the credentials were provided  the access-token can be requested directly
    # without the need for a grant code
    my $token = $sc.get-access-token();
    my $me = $sc.get-object('/me');
    my $tracks = $sc.get-list('/me/tracks');

```


## Description

This provides an interface to the [Soundcloud
API](https://developers.soundcloud.com/docs/api/reference), managing
the authorisation, connection and marshalling of the data.

You can build client side applications that authenticate with user
credentials or server applications that use the full OAuth authorization.

In order to use this module you will need to register your application
with Soundcloud at http://soundcloud.com/you/apps : your application will
be given a client ID and a client secret which you will need to use to
connect. The client ID used in the tests will not work correctly for your
own application as the callback URI is set to 'localhost'.

## Installation

If you have a working Rakudo Perl 6 installation can install directly with
"panda":

    # From the source directory
   
    panda install .

    # Remote installation

    panda install WebService::Soundcloud

Although I haven't tested it, I can't so any reason why this
should not work with "zef" or some other similarly capable
package manager

## Support

Suggestions/patches are welcomed via github at:

https://github.com/jonathanstowe/WebService-Soundcloud

## Licence

Please see the [LICENCE](LICENCE) file in the distribution

© Jonathan Stowe 2015, 2016



