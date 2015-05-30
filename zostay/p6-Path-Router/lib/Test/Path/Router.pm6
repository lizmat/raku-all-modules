unit module Test::Path::Router;

use v6;

use Path::Router;

=TITLE Test::Path::Router

=SUBTITLE A testing module for testing routes

use Test;

# TODO Perl 6 does have a tool named Test::Builder, but it doesn't do enought to
# really warrant using it yet. 

sub routes-ok(Path::Router $router, %routes, Str $message = '') is export {
    my ($passed, $reason);

    subtest {

        for %routes.kv -> $path, %mapping {

            my $generated-path = $router.uri-for(|%mapping);

            $generated-path = '' unless defined $generated-path;

            # the path generated from the hash
            # is the same as the path supplied
            if $path ne $generated-path {
                ok(False, 'checking generated path');
                diag("... paths do not match\n" ~
                    "   got:      '" ~ $generated-path ~ "'\n" ~
                    "   expected: '" ~ $path ~ "'");

                last;
            }

            my $match = $router.match($path);
            my %generated-mapping = $match.mapping if $match;

            ok( $match && $match.path eq $path, "matched path (" ~ ($match ?? $match.path !! '<no match>') ~ ") and requested paths ($path) match" );

            # the path supplied produces the
            # same match as the hash supplied

            is_deeply(%generated-mapping, %mapping, 'comparing mapping to expectation');
        }
    }, $message;
}

sub path-ok(Path::Router $router, Str $path, Str $message = '') is export {
    if $router.match($path) {
        ok(True, $message);
    }
    else {
        ok(False, $message);
    }
}

sub path-not-ok(Path::Router $router, Str $path, Str $message = '') is export {
    if (!$router.match($path)) {
        ok(True, $message);
    }
    else {
        ok(False, $message);
    }
}

sub path-is(Path::Router $router, Str $path, %expected, Str $message = '') is export {

    my %generated-mapping = $router.match($path).mapping;

    # the path supplied produces the
    # same match as the hash supplied

    is_deeply(%generated-mapping, %expected, $message);
}

sub mapping-ok(Path::Router $router, %mapping, Str $message = '') is export {
    if $router.uri-for(|%mapping).defined {
        ok(True, $message);
    }
    else {
        ok(False, $message);
    }
}

sub mapping-not-ok(Path::Router $router, %mapping, Str $message = '') is export {
    if !$router.uri-for(|%mapping).defined {
        ok(True, $message);
    }
    else {
        ok(False, $message);
    }
}

sub mapping-is(Path::Router $router, %mapping, Str $expected is copy, Str $message) is export {
    my Str $generated-path = $router.uri-for(|%mapping);

    # the path generated from the hash
    # is the same as the path supplied
    if 
        (defined $generated-path and not defined $expected) or
        (defined $expected       and not defined $generated-path) or
        (defined $generated-path and     defined $expected
            and $generated-path ne $expected)
         {
        for $generated-path, $expected -> Str $v is rw {
            $v = $v.defined ?? qq{'$v'} !! qq{Nil};
        }
        ok(False, $message);
        diag("... paths do not match\n" ~
                   "   got:      $generated-path\n" ~
                   "   expected: $expected");
    }
    else {
        ok(True, $message);
    }
}

=begin pod

=begin SYNOPSIS

  use Test;
  use Test::Path::Router;

  my $router = Path::Router.new;

  # ... define some routes

  path-ok($router, 'admin/remove_user/56', '... this is a valid path');

  path-is($router,
      'admin/edit_user/5',
      {
          controller => 'admin',
          action     => 'edit_user',
          id         => 5,
      },
  '... the path and mapping match');

  mapping-ok($router, {
      controller => 'admin',
      action     => 'edit_user',
      id         => 5,
  }, '... this maps to a valid path');

  mapping-is($router,
      {
          controller => 'admin',
          action     => 'edit_user',
          id         => 5,
      },
      'admin/edit_user/5',
  '... the mapping and path match');

  routes-ok($router, {
      'admin' => {
          controller => 'admin',
          action     => 'index',
      },
      'admin/add_user' => {
          controller => 'admin',
          action     => 'add_user',
      },
      'admin/edit_user/5' => {
          controller => 'admin',
          action     => 'edit_user',
          id         => 5,
      }
  },
  "... our routes are valid");

=end SYNOPSIS

=for DESCRIPTION
This module helps in testing out your path routes, to make sure
they are valid.

=head1 Exported Functions

=head2 method path-ok

    method path-ok(Path::Router $router, Str $path, Str $message?)

=item method path-not-ok

    method path-not-ok(Path::Router $router, Str $path, Str $message?)

=item method path-is

    method path-is(Path::Router $router, Str $path, %mapping, $message?)

=item method mapping-ok

    method mapping-ok(Path::Router $router, %mapping, Str $message?)

=item method mapping-not-ok

    method mapping-not-ok(Path::Router $router, %mapping, Str $message?)

=item method mapping-is

    method mapping-is(Path::Router $router, %mapping, Str $path, Str $message?)

=item method routes-ok

    method routes-ok(Path::Router $router, %test_routes, Str $message?)

This test function will accept a set of C<%test_routes> which
will get checked against your C<$router> instance. This will
check to be sure that all paths in C<%test_routes> procude
the expected mappings, and that all mappings also produce the
expected paths. It basically assures you that your paths
are roundtrippable, so that you can be confident in them.

=for BUG
All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=begin AUTHOR

Andrew Sterling Hanenkamp E<lt>hanenkamp@cpan.orgE<gt>

Based very closely on the original Perl 5 version by
Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=end AUTHOR

=for COPYRIGHT
Copyright 2015 Andrew Sterling Hanenkamp.

=for LICENSE
This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
