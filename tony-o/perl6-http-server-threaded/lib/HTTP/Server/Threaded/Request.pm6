class HTTP::Server::Threaded::Request {
  has Str $.method;
  has Str $.resource;
  has Str $.version;
  has Str %.headers;
  has Buf $.data is rw;

  method header(*@headers) {
    my @r;
    my %h = @headers.map({ $_.lc => $_ });
    %.headers.keys.map(-> $k { 
      @r.push(%h{$k.lc} => %.headers{$k}) if $k.lc ~~ any %h.keys;
    });
    @r;
  }
};
