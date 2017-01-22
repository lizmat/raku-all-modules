# CSS Testing - lightweight harness

module CSS::Grammar::Test {

    use Test;
    use JSON::Fast;

    # allow only json compatible data
    multi sub json-eqv (Hash:D $a, Hash:D $b) {
	if +$a != +$b { return False }
	for $a.kv -> $k, $v {
	    unless $b{$k}:exists && json-eqv($a{$k}, $b{$k}) {
		return False;
	    }
	}
	return True;
    }
    multi sub json-eqv (List:D $a, List:D $b) {
	if +$a != +$b { return Bool::False }
	for (0 .. +$a-1) {
	    return False
		unless (json-eqv($a[$_], $b[$_]));
	}
	return True;
    }
    multi sub json-eqv (Numeric:D $a, Numeric:D $b) { $a == $b }
    multi sub json-eqv (Stringy $a, Stringy $b) { $a eq $b }
    multi sub json-eqv (Bool $a, Bool $b) { $a == $b }
    multi sub json-eqv (Any $a, Any $b) is default {
        return json-eqv( %$a, $b) if $a.isa(Pair);
        return json-eqv( $a, %$b) if $b.isa(Pair);
        return True if !$a.defined && !$b.defined;
	note "data type mismatch";
	note "    - expected: {to-json($b)}";
	note "    - got: {to-json($a)}";
	return False;
    }

    our sub parse-tests($class, $input, :$parse is copy, :$actions,
			:$rule = 'TOP', :$suite = '', :$writer,
                        :%expected) {

        $parse //= do { 
            $actions.reset if $actions.can('reset');
            $class.subparse( $input, :$rule, :$actions)
        };

        my $expected-parse = (%expected<parse> // $input).trim;

        my %todo = $_ with %expected<todo>;

        if $input.defined && $expected-parse.defined {
            my @input-lines = $input.lines;
            my $input-display = @input-lines >= 3
                ?? [~] @input-lines[0], '... ', @input-lines[*-1]
                !! $input;
            my $got = $parse.defined ?? (~$parse).trim !! '';
            # partial matches bit iffy at the moment
            is $got, $expected-parse, "{$suite} $rule parse: " ~ $input-display;
        }

        my @warnings = $actions.warnings.map: *.message
            if $actions.can('warnings');

        if  %expected<warnings>:exists && ! %expected<warnings>.defined {
            diag "untested warnings: " ~ @warnings
                if @warnings;
        }
        else {
	    todo $_ with %todo<warnings>;

            if %expected<warnings>.isa('Regex') {
                my $matched = @warnings.join.match(%expected<warnings>);
                ok $matched, "{$suite} $rule warnings"
                    or diag @warnings;
            }
            else {
                my @expected-warnings = @$_ with %expected<warnings>;
                is @warnings, @expected-warnings, "{$suite} $rule {@expected-warnings??''!!'no '}warnings";
            }
        }

        my $actual-ast = .ast with $parse;

        with %expected<ast> -> $expected-ast {

            todo $_ with %todo<ast>;

            my $ast-ok = ok ($actual-ast.defined && json-eqv($actual-ast, $expected-ast)), "{$suite} $rule ast";
            unless $ast-ok {
                diag "expected: " ~ to-json($expected-ast);
                diag "got: " ~ to-json($actual-ast)
            };

            if $ast-ok && $writer.can('write') {
                # recursive test of reserialized css.
                try {
                    my %writer-opts = $_ with %expected<writer>;
                    my %writer-expected = ast => %writer-opts<ast> // $expected-ast;
                    my $type = $actual-ast.can('type') && $actual-ast.units // $actual-ast.type;
                    my %args = $type ?? ($type => $expected-ast) !! %$expected-ast;

                    my $css-again = $writer.write( |%args );
                    ok $css-again.chars, "ast reserialization";

                    # check that ast reamins identical after reserialization
                    parse-tests($class, $css-again, :$rule, :$actions, :expected(%writer-expected), :suite("  -- $suite reserialized") );

                    CATCH {
                        note "error writing: {$actual-ast.perl}";
                        die $_;
                    }
                }
            }
        }
        elsif $actual-ast.defined {
            note 'untested_ast: ' ~ to-json( $actual-ast )
                unless %expected<ast>:exists;
        }

	return $parse;
    }

}
