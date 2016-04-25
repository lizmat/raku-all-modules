module Flow::Test {
  my Int $pass  = 0;
  my Int $run   = 0;
  my Int $to-do = 0;
  my Int $plan;
  my %output;
  sub plan($tests) is export {
    $plan = $tests // Int;  
  }

  sub pass($desc = '') is export {
    message(1, $desc);
  }

  sub ok($cond, $desc = '') is export {
    message(?$cond, $desc);
  }

  sub nok($cond, $desc = '') is export {
    message(!$cond, $desc);
  }

  sub is($recv, $expected, $desc = '') is export {
    my $result = ($recv // Failure) === $expected;
    message($result, $desc, $result ??
      ["expected: '{$expected.^name}'", "received: '{$recv.^name}'"] !! 
      @()
    );
  }

  sub isnt($recv, $expected, $desc = '') is export {
    my $result = ($recv // Failure) === $expected;
    message(!$result, $desc, !$result ??
      ["expected: '{$expected.^name}'", "received: '{$recv.^name}'"] !! 
      @()
    );
  }

  multi sub cmp-ok($recv, Callable $comp, $expected, $desc = '') is export {
    $comp = $comp // &infix:<cmp>;
    message($comp($recv, $expected), $desc);
  }

  multi sub cmp-ok($recv, $comp, $expected, $desc = '') is export {
    message(False, $desc, ['Refusing to test an "EVAL"d comparison, please correct your tests']);
  }

  multi sub is-approx(Numeric $recv, Numeric $expected, $desc = '') is export {
    is-approx($recv, $expected, 1e-6, $desc); # 1e-6 from core Test.pm6
  }

  multi sub is-approx(Numeric $recv, Numeric $expected, Numeric $tolerance, $desc = '') is export {
    #emulate Test.pm6
    my $diff = ($recv - $expected).abs;
    my $max  = max($recv.abs, $expected.abs);
    my $rel  = $max == 0 ?? 0 !! $diff/$max;
    message($rel <= $tolerance, $desc, $rel > $tolerance ??
      ["expected: {$expected.abs}", "received: {$recv.abs}"] !!
      []
    );
  }

  multi sub is-approx(Numeric $recv, Numeric $expected, $desc = '', Numeric :$relative-tolerance, Numeric :$absolute-tolerance) is export {
    die 'is-approx(:relative-tolerance - must be a number greater than zero' unless $relative-tolerance > 0;
    die 'is-approx(:absolute-tolerance - must be a number greater than zero' unless $absolute-tolerance > 0;
    my $diff = ($recv - $expected).abs;
    my $test = (($diff <= ($relative-tolerance * $recv).abs) ||
                ($diff <= $absolute-tolerance));
    message(?$test, $desc, !$test ?? 
      ["expected: {$expected.abs}", "received: {$recv.abs}"] !!
      []);
  }

  sub todo($reason, $count = 1) is export {
    $to-do += $count;
  }

  multi sub skip is export {
    message(True, "# SKIP");
  }

  multi sub skip($reason, Int $count = 1) is export {
    die 'Pass a positive integer value to skip' unless $count > 0;
    message(True, "# SKIP $_") for 0..$count;
  }

  sub skip-rest($reason = 'skip-rest requested') is export {
    skip($reason, $plan - $run);
  }

  sub flunk($reason) is export {
    message(False, $reason);
  }

  sub isa-ok($recv, $expected, $desc = "Object is-a '{$expected.^name}'") is export {
    message($recv.isa($expected), $desc, !$recv.isa($expected) ??
      ["'{$recv.^name}' isn't: '{$expected.^name}'"] !!
      []);
  }

  sub does-ok($recv, $expected, $desc = "Object does '{$expected.^name}'") is export {
    message($recv.does($expected), $desc, !$recv.does($expected) ??
      ["'{$recv.^name}' doesn't do '{$expected.^name}'"] !!
      []);
  }

  sub can-ok($recv, $expected, $desc = "Object can '{$expected}'") is export {
    message($recv.^can($expected), $desc, !$recv.^can($expected) ??
      ["'{$recv.^name}' {$recv.defined ?? 'instance' !! 'definition'} cannot .$expected"] !!
      []);
  }

  sub like($recv, $expected, $desc = '') is export {
    message($recv ~~ $expected, $desc, !($recv ~~ $expected) ??
      ["expected: '{$expected.perl}'", "received: '{$recv.perl}'"] !!
      []);
  }

  sub unlike($recv, $expected, $desc = '') is export {
    message(!($recv ~~ $expected), $desc, $recv ~~ $expected ??
      ["expected: '{$expected.perl}'", "received: '{$recv.perl}'"] !!
      []);
  }

  sub use-ok(Str $recv, $msg = "'$recv' module can required()") is export {
    my $pass = False;
    try {
      require $recv;
      $pass = True;
    };
    message($pass, $msg);
  }

  sub dies-ok(Callable $recv, $desc = '') is export {
    my $pass = try { 
      $recv();
      False;
    } // True;
    message($pass, $desc);
  }

  sub lives-ok(Callable $recv, $desc = '') is export {
    my $pass = try {
      $recv();
      True;
    };
    message($pass, $desc);
  }

  sub eval-dies-ok(Str $recv, $desc = '') is export {
    message(False, "Refusing to eval: $desc");
  }

  sub eval-lives-ok(Str $recv, $desc = '') is export {
    message(False, "Refusing to eval: $desc");
  }

  sub is-deeply($recv, $expected, $desc = '') is export {
    my $pass = $recv eqv $expected;
    message($pass, $desc, !$pass ??
      ["expected: {$expected.perl}", "received: {$recv.perl}"] !!
      []);
  }

  sub throws-like(Callable $recv, $exception-type, $desc?, *%match) is export {
    try {
      $recv();
      CATCH {
        my $pass = $_ ~~ $exception-type;
        my @excepts;
        for %match.kv -> $k, $v {
          $pass = $pass && $_{$k}() ~~ $v;
          @excepts.append("Matching '$k'");
          @excepts.append("    expected: '{$v.perl}'");
          @excepts.append("    expected: '{$_{$k}().perl}'");
        }
        message(False, $desc, @excepts);
        return;
      }
    };
    message(False, "Code did not die: {$desc // "throws-like {$exception-type.^name}"}");
  }

  sub putout { 
    my $space = ' ' x 4;
    for %output.keys -> $k { 
      "Test{$k eq '_' && %output.keys.elems == 1 ?? '' !! " $k"}:".say;
      "{$space}{%output{$k}.join("\n$space")}".say;
    }
  }

  sub done-testing {
    putout;
    %output = Hash;
  };

  sub debug-test-data is export { #TODO : only export as debug
    return %(
      output => %output,
    );
  }

  END { putout; };

  sub message($val, $desc, :@diag?) {
    $pass++ if $val;
    $run++;
    %output{$*group // '_'} = []
      unless %output{$*group // '_'}.isa(Array);
    %output{$*group // '_'}.append:
      "{$val ?? '' !! 'not '}ok - {$desc}{@diag.elems ?? "\n    " !! ''}{@diag.join("    \n")}";
  }

}
