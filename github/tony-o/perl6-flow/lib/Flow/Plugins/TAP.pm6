use Flow::Roles;

class Flow::Plugins::TAP does Flow::Roles::output-parser {
  has $.template = "perl6 -Ilib \$FILE 2>&1";
  has $!hardfail = False;

  method parse(Str $output) {
    my $last-seq = 0;
    my $failure = 0; # 0 = no plans, 1 = test after planned XOR test before planned, 2 = plan found between tests
    for $output.lines -> $lines {
      $lines ~~ /^ [ $<fail>='not '? ] ** 0..1 'ok ' $<seq>=\d* ['-'] ** 0..1 $<text>=.*? [ '# TODO ' $<todo>=.* ] ** 0..1 $ /;
      $.check($/, $last-seq) if $/;
      $failure++ if ($!passed + $!failed) > 0 && $!planned && $!planned == 0;
      if $lines ~~ /^ $<begin>=\d+ '..' $<end>=\d+ $/ {
        $.problem('More than one plan found in test output.') if $!planned != 0;
        $!planned = $/<end>.Int * ($!passed || $!failed ?? -1 !! 1);
        $failure++;
      }
    }
    CATCH { default { .perl.say; } }


    $.problem("Ran {$!passed+$!failed} tests but planned $!planned.") 
      if    ($!passed + $!failed != $!planned) 
         && $!planned > 0;
    $.problem("Plan found in between tests.  Plan must come prior to or after all tests are completed.") 
      if $failure > 1;
    $!hardfail = True if $failure > 1;
  }

  method run(Str $file) {
    my $output  = run($*EXECUTABLE, '-Ilib', $file, :out, :err);

    try { 
      $.parse($output.out.lines.join("\n"));
      $output.out.close;
      $output.err.close;
      CATCH { default { 
        $.problems.append(.Str); 
        $.problems.append($output.err.lines.join("\n"));
      } }
    };
    $!hardfail  = True unless $output.exitcode == 0;
    CATCH { default { .say; } }
  }

  method check($match, $last-seq is rw) {
    CATCH { default { .perl.say; } }
    $.problem("Received tests out of sequence, expected <{$last-seq+1}> received <{$match<seq>.Int}>") 
      if $match && $match<seq>.Int != $last-seq+1;
    my $test-str = ($match<seq> // '').Str.trim
                   ~ " {($match<text> // '-').Str.trim}"
                   ~ "{$match<todo> ?? " # TODO {$match<todo>}" !! ""}";
    $.ok($test-str), $!passed++ 
      unless $match<fail> eq 'not ' && $match<todo> eq '';
    $.nok($test-str), $!failed++
      if $match<fail> eq 'not ' && $match<todo> eq '';
    $last-seq++;
  }

  method pass {
    CATCH { default { .perl.say; } }
    !$.fail;
  }

  method fail {
    CATCH { default { .perl.say; } }
    return True 
      if    $!hardfail
         && not ($.passed > 0 && $.failed == 0 && ($.planned == $.passed || $.planned == 0));
    False;
  }
}
