use v6;

role Finance::GDAX::API::URL
{    
    has      $.production-url is rw = 'https://api.gdax.com';
    has      $.testing-url    is rw = 'https://api-public.sandbox.gdax.com';
    has Bool $.debug          is rw = True;
    has Bool $.big-debug      is rw = False;

    has Str  $.path is rw = '/';

    has      @!_url-sections;

    method get-url {
	return ($.debug ??
		$.testing-url !! $.production-url) ~ self.get-uri;
    }

    method get-uri {
	my Str $url = '';
	$url = '/' ~ $.path if $.path ne '/';
	$url ~= '/' ~ @!_url-sections.join: '/' if @!_url-sections;
	return $url;
    }

    method add-to-url ($new_section) {
	my $uri = $new_section.subst(/^\/+/, '');
	$uri.=subst(/\/+$/, '');
	@!_url-sections.push($uri);
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::URL - Role doing URL assembly for GDAX REST
API classes

=head1 SYNOPSIS

  =begin code :skip-test
  use Finanace::GDAX::API::URL;

  my $url = Finance::GDAX::API::URL.new(debug => False);
  $url.add-to-url('test_thing');
  say $url.get-url;

  # OUTPUTS: https://api.gdax.com/test_thing
  =end code

=head1 DESCRIPTION

This role builds URLs for Finance::GDAX::API classes

=head1 ATTRIBUTES

=head2 debug Bool

Bool that sets debug mode (will use sandbox). Defaults to true (1).

=head2 production-url

The base URI for production requests, including the https://

=head2 testing-url

The base URI for testing requests to the GDAX sandbox, including the
https://

=head2 path (default: "/")

The root path of the URI, required for all API requests. When given,
never provide the initial "/".

=head1 METHODS

=head2 get-url

Returns a string of the assembled URL

=head2 get-uri

Returns the URI portion of the assembled URL

=head2 add-to-url

Adds to the URL, each will be separated with a '/'. Leading and
trailing slashes are stripped.

  =begin code :skip-test
  $url.add-to-url('products');
  =end code

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
