use v6.d;
use Cro::HTTP::Client;
use Cro::HTTP::Response;
unit class Hastebin:ver<0.0.4>:auth<github:Kaiepi>;

method get(Str $url --> Str) {
    my Str $key = $url.subst: / [ [ https?\:\/\/ ]? hastebin\.com\/ [ raw\/ ]? ]? ( \w+ ) [ \.\w+ ]? /, $0;
    my Cro::HTTP::Response $resp = await Cro::HTTP::Client.get:
        "https://hastebin.com/raw/$key",
        http => '1.1';
    await $resp.body-text
}

method post(Str $content --> Str) {
    my Cro::HTTP::Response $resp = await Cro::HTTP::Client.post:
        'https://hastebin.com/documents',
        http             => '1.1',
        body             => $content,
        content-type     => 'application/json; charset=utf-8',
        body-serializers => [Cro::HTTP::BodySerializer::JSON.new];
    my     %body = await $resp.body;
    my Str $key  = %body<key>;
    "https://hastebin.com/raw/$key"
}

=begin pod

=head1 NAME

Hastebin - Hastebin client API

=head1 SYNOPSIS

  use Hastebin;

  my Str $url = Hastebin.post: 'ayy lmao';
  my Str $res = Hastebin.get:  $url;
  say $res; # ayy lmao

=head1 DESCRIPTION

Hastebin is a Hastebin client API. This can be used to get data from Hastebin
and post data to Hastebin.

=head1 METHODS

=item B<get>(Str I<$url> --> Str)

Fetches the content at the given URL. C<$url> may be the Hastebin key, a
partial URL, or a full URL.

=item B<post>(Str I<$content> --> Str)

Posts the given text to Hastebin and returns the URL for the raw paste.

=head1 AUTHOR

Ben Davies (Kaiepi)

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Ben Davies

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
