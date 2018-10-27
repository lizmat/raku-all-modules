use v6;

unit class WWW::SilverGoldBull:ver<0.0.1>:auth<github:dboys>;

use JSON::Fast;
use HTTP::UserAgent;
use URI;

use WWW::SilverGoldBull::Response;
use WWW::SilverGoldBull::Order;
use WWW::SilverGoldBull::Quote;

constant UA-TIMEOUT          = 10;
constant DEFAULT-API-VERSION = 1;
constant DEFAULT-URI-API     = 'https://api.silvergoldbull.com/';

has Str $!api-key;
has Int $!api-version;
has HTTP::UserAgent $!ua;
has URI $!api-uri;

submethod BUILD(Str:D :$key, Int :$version = DEFAULT-API-VERSION, Int :$timeout = UA-TIMEOUT, URI :$uri = URI.new(DEFAULT-URI-API)) {
  $!api-key = $key;
  $!ua = HTTP::UserAgent.new(timeout => $timeout);
  $!api-version = $version;
  $!api-uri = $uri;
}

method !build-uri(*@params) returns URI {
  my @url-params = ("v{$!api-version}", |@params);

  my $uri = $!api-uri.Str ~ @url-params.join('/');
  return URI.new($uri);
}

method !request(Str :$method, URI :$uri, :%params?) returns WWW::SilverGoldBull::Response {
  my %header-params = (
    'X-API-KEY' => $!api-key,
    Content-Type => 'application/json; charset=utf-8',
  );
  my $headers = HTTP::Header.new(|%header-params);
  my $req = HTTP::Request.new( $method, $uri, $headers );

  if %params.keys.elems {
      $req.add-form-data(%params);
  }

  my $res = $!ua.request($req);
  my $data = Nil;
  my $error = Nil;

  if $res.is-success {
    $data = try from-json($res.content);
  }
  else {
    $error = try from-json($res.content);
  }

  return WWW::SilverGoldBull::Response.new(data => $data, error => $error);
}

method get-currency-list() returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('currencies'));
}

method get-payment-method-list() returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('payments/method'));
}

method get-shipping-method-list() returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('shipping/method'));
}

method get-product-list() returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('products'));
}

method get-product($id) returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('products', $id));
}

method get-order-list() returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('orders'));
}

method get-order($id) returns WWW::SilverGoldBull::Response {
  return self!request(method => 'GET', uri => self!build-uri('orders', $id));
}

method create-order(WWW::SilverGoldBull::Order $order) returns WWW::SilverGoldBull::Response {
  return self!request(method => 'POST', uri => self!build-uri('orders/create'), params => $order.to-hash());
}

method create-quote(WWW::SilverGoldBull::Quote $quote) returns WWW::SilverGoldBull::Response {
  return self!request(method => 'POST', uri => self!build-uri('orders/quote'), params => $quote.to-hash());
}
