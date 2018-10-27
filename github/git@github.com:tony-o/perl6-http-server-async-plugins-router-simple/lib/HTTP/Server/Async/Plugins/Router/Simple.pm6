class HTTP::Server::Async::Plugins::Router::Simple {
  has @.routes;

  method hook($server) {
    $server.register(-> |args { $.handler(|args); });
  }

  method handler($request,$response,$next) {
    my ($promise, $result);
    my $keeper  = sub (Bool $next? = True) {
      $result = $next;
      $promise.keep;
    };
    for @.routes -> $route {
      next if Any !~~ $route<method>.WHAT && $route<method>.lc ne $request.method.lc;
      given $route<route> {
        when .WHAT ~~ Regex {
          next unless $request.uri ~~ $route<route>; 
        };
        default {
          next unless $request.uri eq $route<route>;
        }
      };
      $promise = Promise.new;
      $route<sub>($request,$response,$keeper);
      await Promise.anyof($promise, $response.promise);
      last if $response.promise.status ~~ Kept;
      last if !$result;
    }
    $promise.break(False) if !$result && $response.promise.status ~~ Kept;
    $next(True) if !$result || $response.promise.status !~~ Kept;
  }

  method !push($method, $route, $sub) {
    @.routes.push({
      method   => $method,
      route    => $route,
      sub      => $sub,
    });
  }

  method all(*@routes) {
    for @routes -> $route {
      self!push(Nil, $route.key, $route.value);
    }
  }

  method get(*@routes) {
    for @routes -> $route {
      self!push('get', $route.key, $route.value);
    }
  }

  method put(*@routes) {
    for @routes -> $route {
      self!push('put', $route.key, $route.value);
    }
  }

  method post(*@routes) {
    for @routes -> $route {
      self!push('post', $route.key, $route.value);
    }
  }

  method delete(*@routes) {
    for @routes -> $route {
      self!push('delete', $route.key, $route.value);
    }
  }
}
