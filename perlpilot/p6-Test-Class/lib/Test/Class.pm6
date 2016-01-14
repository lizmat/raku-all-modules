
use Test;

# Re-export Test's exported routines as if they came from us
sub EXPORT {
    %(Test::EXPORT::DEFAULT::);
}

my role Test::Class::Method[$ttype, $tcount] {
    has $.test-type = $ttype;
    has $.test-count = $tcount;
}

multi sub trait_mod:<is>(Method $meth, :$test-startup)  is export { $meth does Test::Class::Method['Startup', $test-startup]    }
multi sub trait_mod:<is>(Method $meth, :$test-shutdown) is export { $meth does Test::Class::Method['Shutdown', $test-shutdown]  }
multi sub trait_mod:<is>(Method $meth, :$test-setup)    is export { $meth does Test::Class::Method['Setup', $test-setup]        }
multi sub trait_mod:<is>(Method $meth, :$test)          is export { $meth does Test::Class::Method['Test', $test]               }
multi sub trait_mod:<is>(Method $meth, :$tests)         is export { $meth does Test::Class::Method['Test',*]                    }
multi sub trait_mod:<is>(Method $meth, :$test-teardown) is export { $meth does Test::Class::Method['Teardown', $test-teardown]  }

role Test::Class is export {
    method run-tests(*@test-objs) {
        my @objs = @test-objs || self;
        for @objs -> $o is copy {
            $o = $o.new unless $o.DEFINITE;
            my @meths = $o.^methods;
            my @counts = @meths.grep({ (.?test-type // '') eq 'Test' || .?test-count !~~ Bool })
                               .map({ .?test-count // 0 });
            plan any(@counts) ~~ Whatever ?? * !! [+] @counts;
            my %h = @meths.classify({ .?test-type // '' });
            %h{%h.keys} = %h.values».sort(*.name);
            for @(%h<Startup> // []) { $o.$_(); }
            for @(%h<Test> // []) -> $m { 
                for @(%h<Setup> // []) { $o.$_(); }
                $o.$m(); 
                for @(%h<Teardown> // []) { $o.$_(); }
            }
            for @(%h<Shutdown> // []) { $o.$_(); }
        }
    }

}
