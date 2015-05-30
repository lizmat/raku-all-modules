role HTTP::Request {
  has Str $.method;
  has Str $.uri;
  has Str $.version;
  has Buf $.data is rw;

  has %.params;
  has %.headers;

  method header(*@headers) {
    my @r;
    my %h = @headers.map({ $_.lc => $_ });
    %.headers.keys.map(-> $k {
      @r.push(%h{$k.lc} => %.headers{$k}) if $k.lc ~~ any %h.keys;
    });
    return @r;
  }
}
