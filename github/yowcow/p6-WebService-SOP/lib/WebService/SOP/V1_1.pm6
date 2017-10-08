use v6;
use HTTP::Request;
use URI;
use WebService::SOP::V1_1::Request::DELETE;
use WebService::SOP::V1_1::Request::GET;
use WebService::SOP::V1_1::Request::POST;
use WebService::SOP::V1_1::Request::POST_JSON;
use WebService::SOP::V1_1::Request::PUT;
use WebService::SOP::V1_1::Request::PUT_JSON;

unit class WebService::SOP::V1_1;

has Int $!app-id;
has Str $!app-secret;
has Int $!time;

submethod BUILD(Int:D :$!app-id, Str:D :$!app-secret, Int :$!time = time) {}

method get-req($uri, Hash:D $params --> HTTP::Request) {
    self.create-request('GET', $uri, $params);
}

method post-req($uri, Hash:D $params --> HTTP::Request) {
    self.create-request('POST', $uri, $params);
}

method post-json-req($uri, Hash:D $params --> HTTP::Request) {
    self.create-request('POST_JSON', $uri, $params);
}

method put-req($uri, Hash:D $params --> HTTP::Request) {
    self.create-request('PUT', $uri, $params);
}

method put-json-req($uri, Hash:D $params --> HTTP::Request) {
    self.create-request('PUT_JSON', $uri, $params);
}

method delete-req($uri, Hash:D $params --> HTTP::Request) {
    self.create-request('DELETE', $uri, $params);
}

multi method create-request(Str:D $method, Str:D $uri, Hash:D $params --> HTTP::Request) {
    samewith($method, URI.new($uri), $params);
}

multi method create-request(Str:D $method, URI:D $uri, Hash:D $params is copy --> HTTP::Request) {

    $params<app_id> = $!app-id;
    $params<time>   = $!time;

    ::("WebService::SOP::V1_1::Request::{$method}").create-request(
        uri        => $uri,
        params     => $params,
        app-secret => $!app-secret,
    );
}

=begin pod

=head1 NAME

WebService::SOP::V1_1 - SOP v1.1 API request authentication

=head1 SYNOPSIS

  use WebService::SOP::V1_1;

  my WebService::SOP::V1_1 $sop
    .= new(app-id => 1234, app-secret => 'foobar');

  #
  # To create a GET request object
  #
  my HTTP::Request $req = $sop.get-req(
    'https://partners.surveyon.com/path/to/endpoint',
    { aaa => 'aaa', bbb => 'bbb' },
  );

  #
  # To create a POST request object
  #
  my HTTP::Request $req = $sop.post-req(
    'https://partners.surveyon.com/path/to/endpoint',
    { aaa => 'aaa', bbb => 'bbb' },
  );

  #
  # To create a POST request with JSON body
  #
  my HTTP::Request $req = $sop.post-json-req(
    'https://partners.surveyon.com/path/to/endpoint',
    { aaa => 'aaa', bbb => 'bbb },
  );

=head1 DESCRIPTION

WebService::SOP::Auth::V1_1 is SOP v1.1 authenticated request creator and validator.

=head1 METHODS

=head2 get-req($uri, Hash:D $params) returns HTTP::Request

Creates a GET request object.

=head2 post-req($uri, Hash:D $params) returns HTTP::Request

Creates a POST request object with content-type `application/x-www-form-urlencoded`.

=head2 post-json-req($uri, Hash:D $params) returns HTTP::Request

Creates a POST request object with content-type `application/json`.

=head2 put-req($uri, Hash:D $params) returns HTTP::Request

Creates a PUT request object with content-type `application/x-www-form-urlencoded`.

=head2 put-json-req($uri, Hash:D $params) returns HTTP::Request

Creates a PUT request object with content-type `application/json`.

=head2 delete-req($uri, Hash:D $params) returns HTTP::Request

Creates a DELETE request object.

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
