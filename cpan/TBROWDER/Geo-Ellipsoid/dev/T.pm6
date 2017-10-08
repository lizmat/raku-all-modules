
our %attrs = (a=>1,b=>2,c=>3);

class T;

has $.a is rw;
has $.b is rw;
has $.c is rw;
has $.d is rw;

submethod BUILD(
		# set defaults here
		:$!a = 15,
		:$!b,
		:$!c,
                :$!d = 100,
	       ) {
  self.set_b;
}

method d($arg) {
  say "\$arg is '$arg'";
}

multi method set_b {
  if (self.a < 10) {
    self.b = 1;
  }
  else {
    self.b = 0;
  }
}

multi method set_b($x) {
  self.b = $x;
}

method show {
  for %attrs.kv -> $k, $v {
    my $aval = self."$k"();  # supposed to work for a method name
    say "DEBUG:  For attr '$k', value is '$aval'";
  }
}
