unit module Flow::Roles;

role output-parser is export {
  has Int $.passed  = 0;
  has Int $.failed  = 0;
  has Int $.planned = 0;

  has @.oks;
  has @.noks;
  has @.problems;

  has Supplier $!result-supplier;
  has Supply   $!result-supply;

  method BUILD {
    $!result-supplier .= new;
    $!result-supply = $!result-supplier.Supply;
  }

  method supply { $!result-supply; }

  method parse(Str $data) {*}
  method fail {*}
  method pass {*}
  method problem(Str $problem) {
    CATCH { default { .perl.say; } }
    @.problems.append($problem);
  }
  method ok(Str $test) {
    CATCH { default { .perl.say; } }
    @.oks.append($test);
    $!result-supplier.emit({
      msg => 'test',
      test => $test,
      result => 'ok',
    });
  }
  method nok(Str $test) {
    CATCH { default { .perl.say; } }
    @.noks.append($test);
    $!result-supplier.emit({
      msg => 'test',
      test => $test,
      result => 'not-ok',
    });
  }
}
