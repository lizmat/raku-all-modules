use v6;
use Router::Boost;

unit class Router::Boost::Method;

has Router::Boost $!router;

has %!data;

has @!path;
has %!path-seen;

method add(Router::Boost::Method:D: @methods, Str $path, $stuff) {
    $!router = Nil; # clear cache

    unless %!path-seen{$path}++ {
        @!path.push($path);
    }

    %!data{$path}.push([@methods, $stuff]);
}

method routes(Router::Boost::Method:D:) {
    my @routes;

    for @!path -> $path {
        for @(%!data{$path}) -> @route {
            my ($method, $stuff) = @route;
            @routes.push([$method, $path, $stuff]);
        };
    };

    return @routes;
}

method !method-match(Router::Boost::Method:D: Str $request-method, @matcher) {
    if @matcher.elems === 0 {
        return True;
    }

    for @matcher -> $m {
        return True if $m eq $request-method;
    }

    return False;
}

method match(Router::Boost::Method:D: Str $request-method, Str $path) {
    unless $!router.defined {
        $!router = self!build-router;
    }

    if my $matched = $!router.match($path) {
        my @allowed-methods;

        for @($matched<stuff>) -> $pattern {
            if self!method-match($request-method, $pattern[0]) {
                return {
                    stuff              => $pattern[1],
                    captured           => $matched<captured>,
                    is-method-not-allowed => False,
                    allowed-methods    => [],
                };
            }
            @allowed-methods.append(|$pattern[0])
        }
        return {
            stuff              => Nil,
            captured           => {},
            is-method-not-allowed => True,
            allowed-methods    => @allowed-methods,
        };
    }

    return {};
}

method !build-router(Router::Boost::Method:D:) {
    my $router = Router::Boost.new;
    @!path.map(-> $path { $router.add($path, %!data{$path}) });
    return $router;
}

=begin pod

=head1 NAME

Router::Boost::Method - Router::Boost with HTTP method support

=head1 SYNOPSIS

  use Router::Boost::Method;

  my $router = Router::Boost::Method.new();
  $router.add(['GET'],         '/a',                 'g');
  $router.add(['POST'],        '/a',                 'p');
  $router.add([],              '/b',                 'any');
  $router.add(['GET'],         '/c',                 'get only');
  $router.add(['GET', 'HEAD'], '/d',                 'get/head');
  $router.add(['GET'],         '/user/{id:\d ** 3}', 'capture');

  my $dest = $router.match('GET', '/user/123');
  # => {:allowed-methods($[]), :captured(${:id("123")}), :!is-method-not-allowed, :stuff("capture")}

  my $dest = $router.match('/access/to/not/existed/path');
  # => {}

=head1 DESCRIPTION

Router::Boost doesn't care the routing with HTTP method. It's simple and good.
But it makes hard to implement the rule like this:

  get  '/' => { 'get ok'  };
  post '/' => { 'post ok' };

Then, this class helps you to realize such functions.

=head1 METHODS

=head2 C<add(Router::Boost::Method:D: @methods, Str $path, Any $stuff)>

Add a new path to the router.

C<@methods> is a list to represent HTTP method. i.e. ['GET'], ['POST'], ['DELETE'], ['PUT'], etc.
If you want to allow any HTTP methods, please pass C<[]> for this argument (e.g. C<$router.add([], '/any', 'any')>).
You can specify the multiple HTTP methods in list like C<$router.add(['GET', 'HEAD'], '/', 'top')>>.

C<$path> is the path string.

C<$stuff> is the destination path data. Any data is OK.

=head2 C<match(Router::Boost::Method:D: Str $request-method, Str $path)>

Matching with the router.

C<$request-method> is the HTTP request method.

C<$path> is the path string.

Return value is like following;

  return {
      stuff                 => 'foobar',
      captured              => {},
      is-method-not-allowed => False,
      allowed-methods       => [],
  };

If the request is not matching with any path, this method returns empty hash.

If the request is matched well then, return C<stuff>, C<captured>. And C<is-method-not-allowed> is False.

If the request path is matched but the C<$request-method> is not matched, then C<stuff> and C<captured> is Nil. And C<is-method-not-allowed> is True. And then C<allowed-method> suggests allowed HTTP methods.

=head2 C<< my @routes = $router->routes() >>

Get the list of registered routes. Every routes has following schema.

  [List, Str, Any]

For example:

  [['GET','HEAD'], "/foo", \&dispatch-foo]

=head1 AUTHOR

moznion <moznion@gmail.com>

=head1 ORIGINAL AUTHOR

Tokuhiro Matsuno

=end pod

