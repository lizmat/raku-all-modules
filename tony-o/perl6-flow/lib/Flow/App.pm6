use Flow::Config;
use Flow::Plugins::TAP;

our $*CONFIG = FLOW-CONFIG;

class Flow::App {
  has Flow::Roles::output-parser $.output-parser;
  has Channel                        $!result-receiver;
  has Supplier                       $!result-supplier;
  has Supply                         $!result-supply;

  has @.results;
  has @!ongoing;

  submethod BUILD (:$!output-parser = ::('Flow::Plugins::TAP')) {
    $!result-supplier .=new;
    $!result-supply = $!result-supplier.Supply;
    self!results;
  }

  method wait {
    for @!ongoing {
      .result;
      await $_;
    }
  }

  multi method test-dir(*@paths, :$DIR-RECURSION) {
    self!perform-test($_.IO.abspath, :DIR-RECURSION($DIR-RECURSION // 1)) for @paths; 
  }

  method supply { 
    $!result-supply;
  }

  method !perform-test(Str $dir, @extensions = ['t', 'pm6', 'pm'], :$DIR-RECURSION) {
    return if $DIR-RECURSION < 0;
    if $dir.IO.e && $dir.IO.f && $dir.IO.abspath ~~ /'.' $<ext>=\w+? $/ {
      next unless $/<ext> eq any @extensions;
      @!ongoing.append: start { 
        my $path = $dir.IO.abspath;
        my $data = self!test-file($path);
        $!result-receiver.send({
          msg  => 'tested',
          data => $data,
          path => $path,
        });
        CATCH { default { .say; } };
      };
    } elsif $dir.IO.e {
      self.test-dir($dir.IO.dir, :DIR-RECURSION($DIR-RECURSION - 1));
    } else {
      $!result-receiver.send: %(
        msg    => 'failure',
        reason => "$dir.IO.abspath not found",
        path   => $dir.IO.abspath,
      );
    } 
  }

  method !results {
    $!result-receiver .=new;
    start {
      loop {
        my $result = $!result-receiver.receive;
        $!result-supplier.emit($result);
        @.results.append($result);
        CATCH { default { .say; } };
      };
    }
  }

  method !test-file(Str $file) {
    CATCH { default { .say; } }
    my $parser = $.output-parser.new;
    $parser.supply.tap(-> $a {
      $!result-receiver.send: %(
        file => $file,
        |$a
      );
    });
    $parser.run($file);
    $parser;
  }

};
