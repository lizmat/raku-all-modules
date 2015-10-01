use v6;
unit class Cookie::Baker;

use URI::Encode;

sub bake-cookie(Str $name is copy, Str $value, Str :$domain, Str :$path, :$expires, Str :$max-age, Bool :$secure, Bool :$httponly, int :$time=time) is export {
    if $name ~~ /<-[a..z A..Z \- \. _ ~]>/ {
        $name = uri_encode($name);
    }

    my Str $cookie = "$name=" ~ uri_encode($value) ~ '; ';
    $cookie ~= "domain={$domain}; "                  if $domain.defined;
    $cookie ~= "path={$path}; "                      if $path.defined;
    $cookie ~= "expires={_date($expires, $time)}; "  if $expires.defined;
    $cookie ~= "max-age={$max-age}; "                if $max-age.defined;
    $cookie ~= 'secure; '                            if $secure;
    $cookie ~= 'HttpOnly; '                          if $httponly;
    $cookie = $cookie.substr(0, $cookie.chars-2); # remove trailing "; "
    $cookie;
}

my @WDAY = <Sun Mon Tue Wed Thu Fri Sat Sun>;
my @MON = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;

my %TERM = (
    's' => 1,
    'm' => 60,
    'h' => 3600,
    'd' => 86400,
    'M' => 86400 * 30,
    'y' => 86400 * 365,
);

my sub _date($expires, int $time) {
    my $expires_at;
    if ($expires ~~ /^\d+$/) {
        # all numbers -> epoch date
        $expires_at = $expires.Int;
    } elsif $expires ~~ /^ (<[-+]>?[\d+|\d*\.\d*])(<[smhdMy]>?)/ {
        my int $offset = (%TERM{$/[1].Str} || 1) * $/[0].Int;
        $expires_at = $time + $offset;
    } elsif ( $expires  eq 'now' ) {
        $expires_at = $time;
    } else {
        return $expires;
    }

    my $dt = DateTime.new($expires_at);
    # (cookies use '-' as date separator, HTTP uses ' ')
    return sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
                   @WDAY[$dt.day-of-week], $dt.day-of-month, @MON[$dt.month-1], $dt.year,
                   $dt.hour, $dt.minute, $dt.second);
}

sub crush-cookie(Str $cookie_string) is export {
    return {} unless $cookie_string;

    my %results;
    my @pairs = grep /\=/, split /<[;,]>" "?/, $cookie_string;
    for @pairs ==> map { .trim } -> $pair {
        my ($key, $value) = split( "=", $pair, 2 );
        $key   = uri_decode($key);
        $value = uri_decode($value);

        # Take the first one like CGI.pm or rack do
        %results{$key} = $value unless %results{$key}:exists;
    }
    return %results;
}

=begin pod

=head1 NAME

Cookie::Baker - Cookie string generator / parser

=head1 SYNOPSIS

    use Cookie::Baker;

    $headers.push_header('Set-Cookie' => bake-cookie($key, $val));

    my $cookies_hashref = crush-cookie($headers.header('Cookie'));

=head1 DESCRIPTION

Cookie::Baker provides simple cookie string generator and parser.

=head1 FUNCTIONS

=item bake-cookie

  my $cookie = bake-cookie('foo','val');
  my $cookie = bake-cookie(
      'foo', 'val',
      path => "test",
      domain => '.example.com',
      expires => '+24h'
  );

Generates a cookie string for an HTTP response header.
The first argument is the cookie's name and the second argument is a plain string or hash reference that
can contain keys such as C<value>, C<domain>, C<expires>, C<path>, C<httponly>, C<secure>, C<max-age>.


=item2 value

Cookie's value

=item2 domain

Cookie's domain.

=item2 expires

Cookie's expires date time. Several formats are supported

  expires => time + 24 * 60 * 60 # epoch time
  expires => 'Wed, 03-Nov-2010 20:54:16 GMT' 
  expires => '+30s' # 30 seconds from now
  expires => '+10m' # ten minutes from now
  expires => '+1h'  # one hour from now 
  expires => '-1d'  # yesterday (i.e. "ASAP!")
  expires => '+3M'  # in three months
  expires => '+10y' # in ten years time
  expires => 'now'  #immediately

=item2 path

Cookie's path.

=item2 httponly

If true, sets HttpOnly flag. false by default.

=item2 secure

If true, sets secure flag. false by default.

=item crush-cookie

Parses cookie string and returns a hashref. 

    my %cookies_hashref = crush-cookie($headers.header('Cookie'));
    my $cookie_value = %cookies_hashref<cookie_name>;

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>.

And original perl5 code is written by:

Masahiro Nagano E<lt>kazeburo@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Perl6 port is:

    Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Original Perl5 code is:

    Copyright (C) Masahiro Nagano.

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.

=end pod
