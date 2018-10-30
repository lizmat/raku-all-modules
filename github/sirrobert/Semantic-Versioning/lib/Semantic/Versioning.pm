role Semantic::Versioning {

  has Str $.version is rw;
  has Int $.major-version is rw =0;
  has Int $.minor-version is rw =0;
  has Int $.patch-version is rw =0; 


  method !get_version (  ) { $!version      }
  method !set_version ($v) { $!version = $v }
  multi method version is rw {
    my $self := self;

    Proxy.new:
      FETCH => method {
        ($self.major-version, $self.minor-version, $self.patch-version).join('.');
      },
      STORE => method ($v) {
        my @parts = $v.split: '.';

        $self.major-version = @parts.shift.Int if @parts.elems;
        $self.minor-version = @parts.shift.Int if @parts.elems;
        $self.patch-version = @parts.shift.Int if @parts.elems;
      },
    ;
  }
}

class Semantic::Version does Semantic::Versioning {};


