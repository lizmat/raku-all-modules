
role Config::Simple::Role {
  has %.hash is rw;
  has $.filename is rw;

   method AT-KEY($key) {
    my $self = self;
    Proxy.new(
      FETCH => method ()
      {
        $self.hash{$key};
      },
      STORE => method ($val)
      {
        $self.set($key, $val);
      }
      );
  }
  
  method set($key, $val) {
    %.hash{$key} = $val;
  }

  method read($filename) { ... };
  
  method write($filename = Any) { ... };
}