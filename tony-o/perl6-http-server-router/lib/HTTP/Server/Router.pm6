use HTTP::Server;

class HTTP::Server::Router {
  has @.routes;

  multi method push(Str $path, Sub $method) {
    my @parts = $path.split('/');
    @.routes.push({
      path   => $path,
      method => $method,
      type   => 1,
      delim  => @parts,
    });
  }

  multi method push(Regex $path, Sub $method) {
    @.routes.push({
      path   => $path,
      method => $method,
      type   => 0,
    });
  }

  method serve(HTTP::Server $app) {
    $app.handler(sub ($req, $res) {
      for @.routes -> $r {
        given $r<type> {
          when 0 {
            next unless $r<path> ~~ $req.uri;
          }
          when 1 {
            my @p = $req.uri.split('/');
            my $m = True;
            next if @p.elems != @($r<delim>).elems;
            my %h;
            for @p Z @($r<delim>) -> ($x?, $y?) {
              if $y.chars > 1 && $y.substr(0,1) eq ':' {
                try {
                  %h{$y.substr(1)} = $x;
                  CATCH { default { warn $_; } }
                }
              } elsif $y ne $x {
                $m = False; 
                last; 
              }
            }
            $req.params = %h;
            next unless $m;    
          }
          default {
            next;
          }
        }

        my $p = try { $r<method>($req, $res); } // False;
        if $p ~~ Promise {
          await $p;
          $p = $p.result;
        }
        return False unless $p;
      }
    });
  }
}

my HTTP::Server::Router $r .=new;

multi sub route(Str $path, Sub $method) is export {
  $r.push($path, $method);
}

multi sub route(Regex $path, Sub $method) is export {
  $r.push($path, $method);
}

sub serve(HTTP::Server $app) is export {
 $r.serve($app);
}
