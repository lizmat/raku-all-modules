use v6;
use Crust::Middleware;

unit class Crust::Middleware::Session is Crust::Middleware;

role StoreRole {
    method get($cookie-name) { ... }
    method set($cookie-name, $session) { ... }
    method remove($cookie-name) { ... }
}

class Store::Memory does StoreRole {
    has %.data;
    method get($cookie-name) {
        return %.data{$cookie-name};
    }

    method set($cookie-name, $session) {
        %.data{$cookie-name} = $session;
    }

    method remove($cookie-name) {
        %.data{$cookie-name}:delete;
    }
}

class SimpleSession {
    has $.id is rw is required;
    has Bool $.modified is rw; # True only if data has been modified
    has Bool $.expired is rw; # Mark session as expired
    has Bool $.is-new; # Mark session as being new
    has Bool $.change-id is rw; # Set this True if you want to keep the session, but want to change IDs
    has Bool $.no-store is rw; # Set this True if you don't want this to be stored

    has $.domain is rw;
    has $.expires is rw;
    has $.httponly is rw;
    has $.path is rw;
    has $.max-age is rw;
    has $.secure is rw;

    has %.data;

    method get($key) {
        return %.data{$key};
    }

    method set($key, $value) {
        $.modified = True;
        %.data{$key} = $value;
    }

    method remove($key) {
        $.modified = True;
        %.data{$key}:delete;
    }

    method clear() {
        $.modified = True;
        %.data = ();
    }

    method has-keys() returns Bool {
        return %.data():k.elems > 0;
    }
}

use Cookie::Baker;
use Digest::SHA;

has StoreRole $.store is required;
has Str $.cookie-name = "crust-session";
has Str $.domain;
has Str $.path = "/";
has Bool $.keep-empty = True;
has Bool $.secure = False;
has Bool $.httponly = False;
has Int $.expires;
has $.max-age;
has Callable $.sid-generator = &default-sid-generator;
has Callable $.sid-validator = &default-sid-validator;
has Callable $.serializer;
has Callable $.deserializer;

sub default-sid-generator() returns Str {
    my $buf = sha1(rand ~ $*PID ~ {} ~ now);
    return [~] $buf.list».fmt: "%02x";
}

sub default-sid-validator($sid) returns Bool {
    return !!($sid ~~ /^ <[0..9,a..f]>**40 $/);
}

method CALL-ME(%env) {
    my ($id, $session) = self.get-session(%env);

    if $id.defined && $session.defined {
        $session.modified = False;
        %env<p6sgix.session> = $session;
    } else {
        $id = $.sid-generator.();
        $session = self!make-session($id, {}, :is-new(True));
        %env<p6sgix.session> = $session;
    }

    my @ret = $.app()(%env);
    return self.finalize(%env, @ret, $session);
}

method !make-session ($id, $data, *%options) {
    my %args = %options, 
        :id($id),
        :domain($.domain),
        :path($.path),
        :expires($.expires),
        :secure($.secure),
        :httponly($.httponly),
        :max-age($.max-age),
        :data($data || {}),
    ;
    return SimpleSession.new(|%args);
}

method get-session(%env) {
    my $cookie-hdr = %env<HTTP_COOKIE>;
    if !$cookie-hdr.defined {
        return;
    }
    my %crushed = crush-cookie($cookie-hdr);
    my $cookie = %crushed{$.cookie-name};
    if !$cookie.defined {
        return;
    }
    if !$.sid-validator()($cookie) {
        return;
    }

    my $session = $.store.get($cookie);
    if !$session.defined {
        return;
    }

    if $.serializer.defined {
        $session = $.serializer($session);
    }

    return $cookie, self!make-session($cookie, $session);

}

method finalize(%env, @res, $session) {
    my $need-store = False;

    if ($session.is-new && $.keep-empty && !$session.has-keys) ||
        $session.modified ||
        $session.expired ||
        $session.change-id
    {
        $need-store = True;
    }
        
    if $session.no-store {
        $need-store = False;
    }

    my $set-cookie = False;
    if ($session.is-new && $.keep-empty && !$session.has-keys) ||
        ($session.is-new && $session.modified) ||
        $session.expired ||
        $session.change-id
    {
        $set-cookie = True;
    }

    if $need-store {
        my $id = $session.id;
        if $session.expired {
            $!store.remove($id);
        } else {
            if $session.change-id {
                $!store.remove($id);
                $id = $!sid-generator();
                $session.id = $id;
            }

            my $val = $session.data;
            if $!serializer.defined {
                $val = $!serializer($val);
            }
            $!store.set($id, $val);            
        }
    }

    if $set-cookie {
        if $session.expired {
            $session.expires = 'now';
        }
        self.set-cookie(@res, $session);
    }

    return @res;
}

method set-cookie(@res, $session) {
    my %options;

    if $session.domain.defined {
        %options<domain> = $session.domain;
    }

    %options<path> = $session.path || "/";

    if $session.expires.defined {
        %options<expires> = $session.expires;
    }

    if $session.secure.defined {
        %options<secure> = $session.secure;
    }

    if $session.httponly.defined {
        %options<httponly> = $session.httponly;
    }
    if $session.max-age.defined {
        %options<max-age> = $session.max-age;
    }
    my $cookie = bake-cookie(
        $.cookie-name,
        $session.id,
        |%options,
    );
    my $hdrs = @res[1];
    $hdrs.push("Set-Cookie"=>$cookie);
}

=begin pod

=head1 NAME

Crust::Middleware::Session - Session Middleware for Crust Framework

=head1 SYNOPSIS

  use Crust::Builder;
  use Crust::Middleware::Session;

  # $store can be anything that implements Crust::Middleware:Session::StoreRole.
  # This here is a dummy that stores everything in memory
  my $store = Crust::Middleware::Session::Store.new();
  builder {
    enable 'Session', :store($store);
    &app;
  };

=head1 DESCRIPTION

Crust::Middlewre::Session manages sessions for your Crust app.
This module uses cookies to keep session state and does not support URI based
session state.

A session object will be available under the kye `p6sgix.session` in the
P6SGI environment hash. You can use this to access session data

    my &app = ->%env {
        %env<p6sgi.session>.get("username").say;
        ...
    };

=head1 AUTHOR

Daisuke Maki <lestrrat@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Daisuke Maki

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
