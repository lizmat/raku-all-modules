unit module Flow::Plugins::Interface;
use Flow::App;
use Flow::Utils::Cursor;

sub s-m($data, $len, :$ltr = True) {
  return $data.Str ~ (' ' x ($len - $data.Str.chars)) if     $ltr;
  return (' ' x ($len - $data.Str.chars)) ~ $data.Str unless $ltr;
}

multi MAIN('test', :$depth = 1) is export {
  MAIN('test', 't', :$depth);
}

multi MAIN('test', *@dirs, :$depth = 1) is export {
  my $app = Flow::App.new;

  my $ending-out = '';
  my $index      = 0;
  my $str-r      = '.'.IO.abspath;

  "    # | Plan // Pass | File Name".say;
  $app.supply.act(-> $test {
    if $test<msg> eq 'tested' {
      $index++;
      "[{ $test<data>.pass ?? '+' !! '-' }] $index | {s-m($test<data>.planned, 5)}//{s-m($test<data>.passed, 5, :!ltr)} | { $test<path>.substr($str-r.chars+1) }".say;
      my $eout = ''; 
      $eout ~= $test<data>.noks.join("\n").lines.map({ .subst(/^^/, '   ') }).join("\n");
      $eout ~= $test<data>.problems.join("\n").lines.map({ .subst(/^^/, '   ') }).join("\n");
      if $eout {
        $ending-out ~= "Test #$index - output\n$eout\n";
      }
    }
  });

  $app.test-dir(@dirs.map({ $_.IO.abspath }), :DIR-RECURSION($depth));

  $app.wait;
  "\n$ending-out".say if $ending-out.trim ne '';
}

