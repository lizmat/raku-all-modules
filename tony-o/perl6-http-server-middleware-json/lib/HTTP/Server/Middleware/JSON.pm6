use JSON::Fast;
use HTTP::Server;
no precompilation;

module HTTP::Server::Middleware::JSON {
  my $err = sub ($req, $res) {
    $res.close('invalid json');
    False;
  };

  sub json-error (Sub $sub) is export {
    die 'Required sub signature of ($request, $response)'
      unless $sub.signature.params.elems == 2;
    $err = $sub;
  }

  multi sub trait_mod:<is>(Routine $sub, :$json-consumer!) is export {
    $sub.wrap: sub ($req, $res) {
      unless $req.params<stash><body-parsed> {
        return $err($req, $res); 
      }
      callsame;
    };
  }

  sub content-type($req) {
    $req.header('content-type')[0]<content-type> // '';
  }

  sub body-parse-json(HTTP::Server $server) is export {
    $server.handler: sub ($req, $res) {
      $req.params<stash><content-type> = content-type $req;
      my $rval = True;
      if $req.params<stash><content-type> eq 'application/json' {
        $req.params<stash><body-parsed>  = False;
        try {
          $req.params<body> = from-json $req.data.decode.substr(0, *-1);
          $req.params<stash><body-parsed> = True;
          CATCH { default {
            $rval = $err($req,$res); 
          } };
        }; 
      }
      $rval;
    };
  }
};
