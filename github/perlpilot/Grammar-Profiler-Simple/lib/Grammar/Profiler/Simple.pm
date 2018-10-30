my %timing;

my class ProfiledGrammarHOW is Metamodel::GrammarHOW {

    method find_method($obj, $name) {
        my $meth := callsame;
        return $meth if $meth.^name eq 'NQPRoutine' || $meth !~~ Any || $meth !~~ Regex;
        substr($name, 0, 1) eq '!' ||
        substr($name, 0, 8) eq 'dispatch' || 
        $name eq any(« parse CREATE Bool defined MATCH Stringy Str WHERE orig BUILD DESTROY ») ??
            $meth !!
            -> $c, |args {
                my $grammar = $obj.^name;
                %timing{$grammar} //= {};                   # Vivify grammar hash
                %timing{$grammar}{$meth.name} //= {};       # Vivify method hash
                my %t := %timing{$grammar}{$meth.name};
                my $start = now;
                my $result := $meth($obj, |args);
                %t<time> += now - $start;
                %t<calls>++;
                $result
            }
    }

    method publish_method_cache($obj) {
        # no caching, so we always hit find_method
    }
}

proto sub get-timing (|) is export { * }
multi sub get-timing () { %timing }
multi sub get-timing ($grammar) { %timing{$grammar} }
multi sub get-timing ($grammar, $rule) { %timing{$grammar}{$rule} }

proto sub reset-timing (|) is export { * }
multi sub reset-timing () { %timing = () }
multi sub reset-timing ($grammar) { %timing{$grammar} = () }
multi sub reset-timing ($grammar, $rule) { %timing{$grammar}{$rule} = () }

my module EXPORTHOW { }
EXPORTHOW.WHO.<grammar> = ProfiledGrammarHOW;
