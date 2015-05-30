use HTTP::Server::Threaded::Request;
use HTTP::Server::Threaded::Response;
use HTTP::Server;

class HTTP::Server::Threaded does HTTP::Server {

  has Int              $.port         = 8091;
  has Str              $.ip           = '0.0.0.0';
  has Supply           $!connections .=new; 
  has IO::Socket::INET $.server;     

  has @.mws;
  has @.hws;
  has @.pws;

  method middleware(Callable $sub) {
    @.mws.push($sub);
  }

  method handler(Callable $sub) {
    @.hws.push($sub);
  }

  method after(Callable $sub) {
    @.pws.push($sub);
  }

  method !eor($req, $data is rw) returns Bool {
    if $req.method eq 'GET' || $req.header('Content-Length', 'Transfer-Encoding').elems == 0 {
      return True;
    }
    my %headers = $req.header('Content-Length', 'Transfer-Encoding');
    if %headers.EXISTS-KEY('Content-Length') {
      return True if $data.elems == %headers<Content-Length>;
    }
    if %headers.EXISTS-KEY('Transfer-Encoding') && %headers<Transfer-Encoding>.lc eq 'chunked' {
      #scan from end to find out if it is complete;
      for (-$data.elems)+4 .. -3  -> $a { 
        my $x = -$a;
        last if $x+3 >= $data.elems;
        if $data.subbuf($x, 3) eq Buf.new('0'.ord, 13, 10) {
          #TODO decode transfer-encoding: chunked 
          return True; 
        }
      }
    }
    return False;
  }

  method !conn {
    start {
      $!connections.tap( -> $conn {
        my Buf  $data .=new;
        my Blob $sep   = "\r\n\r\n".encode;
        my ($stop, $buf);
        my $done = 0;
        my $headercomplete = 0;
        my ($res, $req);
        my (%headers, $method, $resource, $version);
        while $buf = $conn.read(1) {
          #CATCH { default { warn $_ ; } }
          $data ~= $buf;
          if ! $headercomplete {
            for $data.elems-$buf.elems-4 .. $data.elems-1 -> $x {
              last if $x < 0;
              if $data.elems >= $x+4 && $data.subbuf($x, 4) eq $sep {
                $headercomplete = 1;
                my $i = 0;
                $data.subbuf(0, $x).decode.split("\r\n").map( -> $l {
                  if $i++ == 0 {
                    $l ~~ / ^^ $<method>=(\w+) \s $<resource>=(.+) \s $<version>=('HTTP/' .+) $$ /;
                    $method   = $<method>.Str;
                    $resource = $<resource>.Str;
                    $version  = $<version>.Str;
                    next; 
                  }
                  my @parse = $l.split(':', 2);
                  %headers{@parse[0].trim} = @parse[1].trim // Any;
                });
                $data .=subbuf($x + 4);
                $req = HTTP::Server::Threaded::Request.new(:$method, uri => $resource, :$version, :%headers);
                $res = HTTP::Server::Threaded::Response.new(:connection($conn));
                for @.mws -> $middle {
                  try { 
                    my $r = $middle($req, $res);
                    if $r ~~ Promise {
                      await $r;
                      $stop = ! $r.status;
                    } else {
                      $stop = ! $r;
                    }
                    CATCH { default { warn $_; $stop = False; } }
                  };
                  last if $stop;
                }
              }
            }
            last if $stop;
          }
          last if $stop;
          if $headercomplete && self!eor($req, $data) {
            $req.data = $data;
            for @.hws -> $handler {
              my $r = $handler($req, $res);
              if $r ~~ Promise {
                await $r;
                if ! $r.status {
                  return;
                }
              }
            }
            try $conn.close;
            for @.pws -> $p {
              $p($req, $res);
            }
            $done = 1;
          }
          last if $done;
        }
      });
      await Promise.new;
    };
  }

  method listen {
    $!server      = IO::Socket::INET.new(:localhost($.ip), :localport($.port), :listen);
    self!conn;
    while (my $conn = $!server.accept) {
      $!connections.emit($conn);
    }
  }
}

