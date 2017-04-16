use v6.c;

=begin pod

=head1 NAME

WebService::Soundcloud - Provide access to the Soundcloud API

=head1 SYNOPSIS

You can use the Full OAuth flow:

=begin code

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
    my $user = $scloud.get('/me');
    
    # a PUT request '/me' - updated users details
    my $user = $scloud.put('/me', to-json( { user => { description => 'Have fun with Perl wrapper to Soundcloud API' } } ) );
                
    # Comment on a Track POSt request usage
    my $comment = $scloud.post('/tracks/<track_id>/comments', 
                            { body => 'I love this hip-hop track' } );
    
    # Delete a track
    my $track = $scloud.delete('/tracks/{id}');
    
=end code

or you can use direct credential based authorisation that can skip the redirections:

=begin code

    use WebService::Soundcloud;


    my $sc = WebService::Soundcloud.new(:$client-id,:$client-secret,:$username,:$password);

    # Because the credentials were provided  the access-token can be requested directly
    # without the need for a grant code
    my $token = $sc.get-access-token();
    my $me = $sc.get-object('/me');
    my $tracks = $sc.get-list('/me/tracks');

=end code


=head1 DESCRIPTION

This module provides a wrapper around Soundcloud REST API to work with 
different kinds of soundcloud resources. It contains many functions for 
convenient use rather than standard Soundcloud REST API.

The complete API is documented at L<http://developers.soundcloud.com/docs>.

In order to use this module you will need to register your application
with Soundcloud at L<http://soundcloud.com/you/apps> : your application will
be given a client ID and a client secret which you will need to use to 
connect. The client ID used in the tests will not work correctly for your
own application as the callback URI is set to 'localhost'.

=head2 METHODS

=head3 method new

    method new(Str :$!client-id!, Str :$!client-secret!, Str :$!redirect-uri, Str :$!scope, Str :$!username, Str :$!password, HTTP::UserAgent :$!ua )

Returns a newly created C<WebService::Soundcloud> object. The first
named argument is client-id, the second argument is client-secret - these
are required and will have been provided when you registered your
application with Soundcloud. If C<username> and C<password> are provided then
credentials based authentication will be performed.

An optional L<HTTP::UserAgent> can be passed if there is some requirement
for special configuration that isn't allowed for.

=head3 method client-id

Accessor for the Client ID that was provided when you registered your
application.


=head3 method client-secret

Accessor for the Client Secret that was provided when you registered
your application.

=head3 method redirect-uri

Accessor for the redirect-uri this can be passed as an option to the
constructor or supplied later (before any connect call.) This must
match that provided when you registered your application.

This can be supplied as an option to the constructor.

It is the URI of your application that the user will be redirected
(with the authorization code as a parameter,) after they have clicked
"Connect" on the soundcloud connect page.  This will not be used if
you are using the credential based authentication to obtain the OAuth token
(e.g if you are an application with no UI that is operating for a single
user.) 

=head3 method basic-params

This returns a L<Hash> that is suitable to be used as the basic parameters
in most places, containing the application credentials (ID and Secret) and
redirect-uri

=head3 method ua

Returns the L<HTTP::UserAgent> object that will be used to connect to the
API host


=head3 method get-authorization-url

    method get-authorization-url(*%args)

This method is used to get the authorization ("connect") uri which the
user should be redirected to authenticate with soundcloud and indicate
they permit the connection to your application. This will return the
URL to which user should be redirected.

Any additional named style arguments will be appended as query parameters
to the URI.

=head3 method get-access-token

    method get-access-token(Str $code?, *%args) returns Hash

This method is used to receive access-token, refresh-token,
scope and expires-in details from Soundcloud once the user is
authenticated. access-token, refresh-token should be stored as it should
be sent along with every request to access private resources on the
user behalf.

The argument C<$code> is required unless you are using credential based
authentication, and will have been supplied to your C<redirect-uri> after
the user pressed "Connect" on the soundcloud connect page.

=head3 method get-access-token-refresh

    method get-access-token-refresh(Str $refresh-token, *%args)

This method is used to get a new access_token by exchanging refresh_token
before the earlier access_token is expired. You will receive new
access_token, refresh_token, scope and expires_in details from
soundcloud. access_token, refresh_token should be stored as it should
be sent along with every request to access private resources on the
user behalf.

If a C<scope> of 'non-expiring' was supplied at the time the initial tokem
was obtained then this should not be necessary.

=head3 method request

    method request(Str $method, URI $url, HTTP::Header $headers, %content?) returns HTTP::Response

This performs an HTTP request with the $method supplied to the supplied
$url. The third argument $headers can be supplied to insert any required
headers into the request, if $content is supplied it will be processed
appropriately and inserted into the request.

An L<HTTP::Response> will be returned and this should be checked to
determine the status of the request.

=head3 method get-object

    method get-object($url, %params?, %headers? )

This returns a decoded object corresponding to the URI. C<%params> is
a L<Hash> of query parameters that will be added to the request URI,
C<%headers> provides a set of additional header fields that will be
added to the request.

=head3 method get-list

    method get-list($url, %params?, %headers?)

This returns an L<Array> of the list method specified by URI.  C<%params>
is a L<Hash> of query parameters that will be added to the request URI,
C<%headers> provides a set of additional header fields that will be added
to the request.

=item method get

    method get( Str $path, %params?, %extra_headers? )


This method is used to dispatch GET request on the give URL(first
argument).  second argument is a L<Hash> of request parameters to be
send along with GET request.  The third optional argument
is used to add headers.  This method will return a L<HTTP::Response> object.


=head3 method post

    method post(Str $path, $content, %extra_headers? )

This method is used to make a POST request on the given path.  The second
argument is the content to be posted to URL.  The third optional argument
are additional headers to be added to the request.  This method will
return a L<HTTP::Response> object.

=head3 method put

    method put( Str $path, $content, %extra_headers? )

This method is used to dispatch PUT request to the given URL second
argument is the content to be sent to URL.  The third optional argument is
a set of aditional headers that will be added to the request.  This method
returns a  L<HTTP::Response> object.

=head3 method delete

    method delete(Str $path, %params?, %extra_headers? )

This method is used to dispatch DELETE request to the given URL the
second argument is a L<Hash> of request parameters to be sent along
with the DELETE request. Any additional named style parameters will be
added to the headers of the request to be sent.  This method returns a
L<HTTP::Response> object

=head3 method download

** NOT YET IMPLEMENTED **

This method is used to download a particular track id given as first argument.
second argument is name of the destination path where the downloaded track will 
be saved to. This method will return the file path of downloaded track.

=head3 method request-format

Accessor for the request format to be used.  The default is 'json' which 
should be suitable for all applications. If the format is set to something
which Soundcloud can't deal with there will be a "406" ("Not acceptable")
response from the API.

=head3 method response-format

Accessor for the response format to be used. The default is 'json'.
If the format is set to something which Soundcloud can't deal with there
will be a "406" ("Not acceptable") response from the API.


=head3 method parse-content

    method parse-content(Str $content)

This will return the parsed object corresponding to the response content
passed as an argument.  Currently only JSON data is parsed.

It will return undef if there is a problem with the parsing.

=head3 method log

    method log(Str() $msg)

This method is used to write some text to $*ERR if C<debug> is a true
value.

=end pod

class WebService::Soundcloud:ver<0.0.5>:auth<github:jonathanstowe> {

    use HTTP::UserAgent;
    use URI;
    use JSON::Fast;
    use URI::Template;

    class X::NoAuthDetails is Exception {
        method message() {
            "neither credentials or auth code provided";
        }
    }

    # declare domains
    our %domain-for = (
        'prod'        => 'https://api.soundcloud.com/',
        'production'  => 'https://api.soundcloud.com/',
        'development' => 'https://api.sandbox-soundcloud.com/',
        'dev'         => 'https://api.sandbox-soundcloud.com/',
        'sandbox'     => 'https://api.sandbox-soundcloud.com/'
    );

    our $DEBUG    = False;

    our %path-for = (
        'authorize'    => 'connect',
        'access_token' => 'oauth2/token'
    );

    our %formats = (
        '*'    => '*/*',
        'json' => 'application/json',
        'xml'  => 'application/xml'
    );


    has Str $.client-id;
    has Str $.client-secret;
    has %!options;
    has Str $.redirect-uri is rw;
    has HTTP::UserAgent $.ua is rw;
    has Bool $!development = False;
    has $!scope;
    has Str $.username is rw;
    has Str $.password is rw;
    has Str $.response-format is rw = 'json';
    has Str $.request-format is rw = 'json';
    has %.auth-details;
    has Bool $!debug = False;

    submethod BUILD(Str :$!client-id!, Str :$!client-secret!, Str :$!redirect-uri, Str :$!scope, Str :$!username, Str :$!password, HTTP::UserAgent :$!ua, *%opts) {

        %!options = %opts;
        if not $!ua.defined {
            $!ua  = HTTP::UserAgent.new;
        }
    }



    method !basic-params() is rw {
        my %params = (
            client_id       => $!client-id,
            client_secret   => $!client-secret,
        );

        if $!redirect-uri.defined {
            %params<redirect_uri> = $!redirect-uri;
        }

        return %params;
    }


    method get-authorization-url(*%args) {
        my $call   = 'get_authorization_url';
        my %params = self!basic-params();

        %params<response_type> = 'code';

        %params.push: %args.pairs;

        self!build-url( %path-for<authorize>, %params );
    }


    method get-access-token(Str $code?, *%args) {

        my %params = self!access-token-params($code);

        %params.push: %args.pairs;
        self!access-token(%params);
    }

    method !access-token-params(Str $code?) {
        my %params = self!basic-params();

        if  $!scope.defined {
            %params<scope> = $!scope;
        }
        if $!username && $!password {
            %params<username>   = $!username;
            %params<password>   = $!password;
            %params<grant_type> = 'password';
        }
        elsif $code.defined {
            %params<code>       = $code;
            %params<grant_type> = 'authorization_code';
        }
        else {
            X::NoAuthDetails.new.throw;
        }
        %params;
    }


    method get-access-token-refresh(Str $refresh-token, *%args) {
        my %params = self.basic-params();

        %params<refresh_token> = $refresh-token;
        %params<grant_type>    = 'refresh_token';

        %params =  %params, %args;
        self!access-token(%params);
    }


    method request(Str $method, URI $url, HTTP::Header $headers, %content?) returns HTTP::Response {
        my $req = HTTP::Request.new( $method, $url, $headers );

        if %content.keys.elems {
            $req.add-form-data(%content);
        }
        self.log($req.Str);
        $!ua.request($req);
    }


    method get-object($url, %params?, %headers? ) {
        my $obj;

        my $save_response_format = $!response-format;
        $!response-format = 'json';

        my HTTP::Response $res = self.get( $url, %params, %headers );

        if  $res.is-success {
            $obj = from-json( $res.decoded-content );
        }

        $!response-format = $save_response_format;
        $obj;
    }


    method get-list($url, %params?, %headers?) {
        my @ret;
        my Bool $continue = True;
        my Int $offset   = 0;
        my Int $limit    = 50;

        my $save_response_format = $!response-format;
        $!response-format        = 'json';

        while $continue {
            %params<limit>  = $limit;
            %params<offset> = $offset;

            my $res = self.get( $url, %params, %headers );

            if  $res.is-success {
                if (my $obj = self.parse-content( $res.decoded-content)).defined {
                    if $obj ~~ Array {
                        $offset += $limit;
                        $continue = $obj.elems > 0;
                    }
                    elsif $obj ~~ Hash {
                        if $obj<collection>:exists {
                            $url = $obj<next_href>;
                            $continue = $url.defined;
                            $obj = $obj<collection>;
                        }
                        else {
                            die "not a collection";
                        }
                    }
                    else {
                        die "Unexpected { $obj.WHAT } reference instead of list";
                    }
                    @ret.append($obj.list);
                }
                else {
                    $continue = False;
                }
            }
            else {
                warn $res.request.uri;
                die $res.status-line;
            }
        }
        $!response-format = $save_response_format;
        @ret;
    }

    method get( Str $path, %params?, %extra_headers? ) {
        my $url = self!build-url( $path, %params );
        my HTTP::Header $headers = self!build-headers(%extra_headers);
        self.request( 'GET', $url, $headers );
    }


    method post(Str $path, $content, %extra_headers ) {
        my $url     = self!build-url($path);
        my HTTP::Header $headers = self!build-headers(%extra_headers);
        self.request( 'POST', $url, $headers, $content );
    }


    method put( Str $path, $content, %extra_headers ) {
        my $url = self!build-url($path);

        %extra_headers<Content-Length> = 0 unless %extra_headers<Content-Length>;
        my %headers = self!build-headers(%extra_headers);
        self.request( 'PUT', $url, %headers, $content );
    }

    method delete(Str $path, %params, %extra_headers ) {
        my $url = self!build-url( $path, %params );
        my %headers = self!build-headers(%extra_headers);
        self.request( 'DELETE', $url, %headers );
    }


    method download( $trackid, $file ) {
        X::NYI.new(feature => "download").throw();
        my $url = self!build-url( "/tracks/$trackid/download");
        self.log($url);

        my Bool $rc = False;

        my $old_response_format = $!response-format;
        $!response-format = '*';
        my $headers = self!build-headers();
        #$self.ua().add_handler('response_redirect',\&_our_redirect);
        my $response = self.request( 'GET', $url, $headers );

        say $response.Str;
        #$self.ua().remove_handler('response_redirect');

        if !($rc = $response.is_success()) {
            self.log($response.request);
            self.log($response);
            for ( $response.redirects() ) -> $red {
                self.log($red.request);
                self.log($red);
            }
        }
        $!response-format = $old_response_format;
        $rc;
    }


    sub our-redirect( $response, $ua, $h ) {
        my $code = $response.code();

        my $req;

        if is-redirect($code) {
            my $referal =  $response.request().clone();
            $referal.remove_header('Host','Cookie','Referer','Authorization');

            if (my $ref_uri = $response.header('Location'))
            {
                my $uri = URI.new($ref_uri);
                $referal.header('Host' => $uri.host());
                $referal.uri($uri);
                if ( $ua.redirect_ok($referal, $response) )
                {
                    $req = $referal;
                }
            }
        }
        $req;
    }


    sub is-redirect(Int() $code) returns Bool {
        my Bool $rc = False;

        $rc = ($code ~~ 301|302|303|307);
        $rc;
    }



    method parse-content(Str $content) {
        my $object;

        given $!response-format {
            when 'json' {
                $object = from-json($content);
            }
            when 'xml' {
                # for the time being
                require XML::Simple:from<Perl5>;
                my $xs = XML::Simple.new();
                $object = $xs.XMLin($content);
            }
        }
        CATCH {
            default {
                warn $_;
            }
        }
        $object;
    }

    method !access-token(%params) {
        my $call     = '_access_token';
        my $url      = self!access-token-url();
        my $headers  = self!build-headers();
        $headers.remove-field('Content-Type');
        my $response = self.request( 'POST', $url, $headers, %params );

        say $response.Str;

        if ! $response.is-success() {
            die "Failed to fetch " 
                ~ $url ~ " "
                ~ $response.content() ~ " ("
                ~ $response.status-line() ~ ")"
        }
        my $access_token = from-json( $response.content );

        # store access_token, refresh_token
        # Needs an object
        for <access_token refresh_token expire expires_in> {
            %!auth-details{$_} = $access_token{$_};
        }

        # set access_token, refresh_token
        $access_token;
    }

    method !access-token-url(*%params) {
        self!build-url( %path-for<access_token>, %params );
    }

    has $!query-template = URI::Template.new(template => '{?query*}');

    method !build-url(Str $path, %params?) {
        my $base_url = $!development ?? %domain-for<development> !! %domain-for<production>;

        my Bool $b-slash = ?($base_url ~~ /\/$$/);
        my Bool $p-slash = ?($path ~~ /^^\//);

        my $abs-url = do if $p-slash {
            if $b-slash {
                $base_url ~ $path.substr(1);
            }
            else {
                $base_url ~ $path;
            }
        }
        else {
            if $b-slash {
                $base_url ~ $path;
            }
            else {
                $base_url ~ '/' ~ $path;
            }
        }

        my $uri = URI.new( $abs-url );
   
        my $url-noq = $uri.Str.subst(/\?.*/,"");

        if  $uri.query.defined {
            %params.push: $uri.query-form().pairs;
        }
        $abs-url = $url-noq ~ $!query-template.process(query => %params);

        $uri = URI.new($abs-url);


        $uri;
    }


    method !build-headers(%extra?) returns HTTP::Header {
        my $headers = HTTP::Header.new;

        if $!response-format.defined {
            $headers.field( Accept => %formats{ $!response-format } );
        }
        if $!request-format.defined {
            $headers.field( Content-Type => %formats{ $!request-format } ~ '; charset=utf-8' );
        }
        if %!auth-details<access_token>.defined && not %extra<no_auth>:exists {
            $headers.field( Authorization => "OAuth " ~ %!auth-details<access_token> );
        }
        for  %extra.kv -> $key, $value {
            $headers.field( $key => $value );
        }
        $headers;
    }


    method log(Str() $msg) {
        if $!debug {
            $*ERR.say($msg);
        }
    }



}
# vim: ft=perl6 expandtab sw=4
