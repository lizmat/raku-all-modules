use v6;
use Shell::Command;

class Math::ThreeD::Operation {
    has Str $.function;
    has Str $.mutator;
    has Str $.operator;
    has Bool $.postfix = False;
    has Bool $.selfarg = True;

    has Positional @.args = []; # Str:D where any <num obj>
    has $.return = 'obj';

    has Str $.intro;
    has Str $.body;
    has Stringy $.expression;
    has @.expressions;

    method build (:$lib!) {
        my $return = '';
        
        for @.args {
            if self.function {
                $return ~= self.build_routine('sub', 'new', $_, :$lib);
                $return ~= self.build_routine('method', 'new', $_, :$lib);
                unless self.body { # TODO?
                    $return ~= self.build_routine('sub', 'rw', $_, :$lib);
                    $return ~= self.build_routine('method', 'rw', $_, :$lib);
                }
            }
            if self.mutator {
                $return ~= self.build_routine('sub', 'mutator', $_, :$lib);
                $return ~= self.build_routine('method', 'mutator', $_, :$lib);
            }
            if self.operator {
                $return ~= self.build_routine('operator', 'new', $_, :$lib);
                if @$_ == 1 && $_[0] eq 'num' {
                    $return ~= self.build_routine('operator', 'new', $_,
                        :$lib, :argfirst);
                }
            }
        }

        $return;
    }
    
    method build_routine (
        Str:D $routine where {any <sub method operator>},
        Str:D $result where {any <new rw mutator>},
        @args,
        :$lib!,
        Bool :$clear-line = True,
        Bool :$argfirst = False,
    ) {
        my $name;
        if $routine eq 'operator' {
            die "Symbolic operators cannot be used as a $result routine"
                unless $result eq 'new';
            
            $name =
                @args ?? "infix:<$.operator>" !!
                $.postfix ?? "postfix:<$.operator>" !!
                "prefix:<$.operator>";
        } else {
            $name = $result eq 'mutator' ?? $.mutator !! $.function;
        }

        my @params;
        @params.push: "$lib.name():D \$" if $.selfarg;
        if @args {
            for @args {
                my $argtype = {
                    when 'num' { 'Numeric' }
                    when 'obj' { $lib.name }
                    default { $_ }
                }();
                @params.push: "$argtype\:D \$";
            }
        }
        @params.unshift: @params.splice(1,1) if $argfirst;

        my $params = '';
        my $var = 'a';
        my $is_method = ($routine eq 'method');
        my $selfarg = $is_method && $.selfarg;
        for @params {
            if $params {
                $params ~= ',' unless $var eq 'b' && $selfarg;
                $params ~= ' ';
            }
            $params ~= $_ ~ $var++;
            $params ~= ':' if $var eq 'b' && $selfarg;
        }

        if $.return {
            my $return =
                $.return eq 'obj' ?? "{$lib.name}:D" !!
                $.return eq 'num' ?? 'Numeric:D' !!
                $.return;

            if $result eq 'rw' {
                if $params {
                    $params ~= ',' unless $var eq 'b' && $selfarg;
                    $params ~= ' ' if $params;
                }
                $params ~= "$return \$r is rw";
            }
            $params ~= ' ' if $params;
            $params ~= "--> $return";
        } else {
            #$params ~= " --> Nil";
        }

        my $beginning = "multi {$routine eq 'method' ?? 'method' !! 'sub'} $name ($params) ";
        $beginning ~= 'is pure ' if $result eq 'new';
        $beginning ~= 'is export ' if $routine ne 'method';
        $beginning ~= '{';
        
        my $build = "$beginning\n{
            self.build_routine_body($routine, $result, @args, :$lib, :$argfirst)\
                .indent(4)
        }\n\}";
        $build ~= "\n\n" if $clear-line;
        
        $build;
    }

    method build_routine_body (
        Str:D $routine,
        Str:D $result,
        @args,
        :$lib!,
        Bool :$argfirst = False,
    ) {
        my $return = '';
        $return ~= "$.intro\n\n" if $.intro;

        return "$return$.body" if $.body;
        
        my $expression = self.build_routine_expression(@args, :$lib, :$argfirst);
        
        if $.return eq 'obj' {
            $expression .= indent(4);
            if $result eq 'new' {
                $return ~= "{$lib.name}.new(\n$expression\n);";
            } else {
                my $r = $result eq 'rw' ?? '$r' !! $argfirst ?? '$b' !! '$a';
                my $i = 0;
                $return ~= '(';
                $return ~= $lib.indices.map({ "$r$_" }).join(',');
                $return ~= ") =\n$expression;\n$r;";
            }
        } elsif $.return eq 'num' {
            if $result eq 'new' {
                $return ~= $expression;
            } elsif $result eq 'rw' {
                $return ~= "\$r = $expression;";
            } else {
                die "Cannot autogenerate $result routine for this operation:\n{self.perl}";
            }
        }

        $return;
    }
    
    method build_routine_expression (@args, :$lib!, Bool :$argfirst = False) {
        return $.expression if $.expression;

        my $return;

        if $.return eq 'obj' {
            $return = self.build_routine_expressions(@args, :$lib, :$argfirst).join(",\n");
        } elsif $.return eq 'num' {
            die "Cannot autogenerate this operation:\n{self.perl}"
                unless $.operator && (!@args || @args == 1 && @args[0] eq 'num');

            my $op = $.operator;
            
            if @args {
                $return = "\$a $op \$b";
            } else {
                $return = "$op\$a";
            }
        } else {
            die "Cannot autogenerate this operation:\n{self.perl}";
        }
        
        $return;
    }

    method build_routine_expressions (@args, :$lib!, Bool :$argfirst) {
        return @.expressions if @.expressions;

        die "Cannot autogenerate this operation:\n{self.perl}"
            unless $.operator && @args <= 1;

        my $op = $.operator;
        my @expressions;
        
        if @args {
            my $map_expr = $argfirst ??
                {   "\$a $op \$b$_" } !!
                { "\$a$_ $op \$b"   };
            @expressions = $lib.indices.map: $map_expr;

            if @args[0] eq 'obj' {
                my @i = $lib.indices;
                @expressions .= map: { "$_@i.shift()" };
            }
        } else {
            @expressions = $lib.indices.map: {"$op \$a$_"};
        }

        @expressions;
    }
}

class Math::ThreeD::Library {
    has Str:D $.name;
    has Numeric:D @.dims;
    has Str $.intro;
    has Str $.constructor = $!name.lc;
    has Math::ThreeD::Operation:D @.ops;
    has @.use;

    method build () {
        my $build = "class $.name is Array;\n\n";

        if @.use {
            $build ~= "use $_;\n" for @.use;
            $build ~= "\n";
        }

        $build ~= "$.intro\n\n" if $.intro;
        
        $build ~=
            qq[method perl () \{ '{$.name}.new(' ~ join(',', self.list».perl) ~ ')' }\n\n];

        $build ~= 'method dump () { say self.perl }' ~ "\n\n";

        if $.constructor -> $_ {
            $build ~= "sub $_ (|a) is export \{ {$.name}.new(|a) }\n\n";
        }

        $build ~= "multi sub $.name.lc()-zero () is export \{ $.name\.new({ (0 xx [*] @.dims).join: ',' }) };\n\n";

        if @.dims == 1 {
            $build ~= "multi sub $.name.lc()-ident () is export \{ $.name\.new({ (1 xx @.dims[0]).join: ',' }) };\n\n";
        } elsif @.dims == 2 {
            $build ~= "multi sub $.name.lc()-ident () is export \{ $.name\.new(";
            $build ~= (^(@.dims[0]) X ^(@.dims[1])).map( +(* == *) ).join(',');
            $build ~= ") };\n\n";
            
            my $columns = @.dims[1];
            $build ~= 'method at_pos ($i) is rw {' ~ "\n";
            my @expressions;
            for ^$columns {
                my $offset = $_ ?? "+$_" !! "  ";
                @expressions.push: "self.Array::at_pos(\$_$offset)";
            }
            $build ~= @expressions.join(",\n").indent(4) ~ "\n";
            $build ~= "given \$i*$columns;".indent(8);
            $build ~= "\n}\n\n";
        }

        if @.ops {
            for @.ops {
                $build ~= .build(lib => self);
            }
        }

        $build;
    }

    method write (Str:D $filename) {
        print "Writing $filename...";
        chdir $?FILE.IO.dirname;
        my $file = $filename.IO;
        mkpath($file.parent);
        my $out = $file.open(:w);
        $out.print: self.build;
        $out.close;
        say "done";
    }

    method indices () {
        my @return =
            @.dims == 1 ?? (^@.dims[0]).map({"[$_]"}) !!
            @.dims == 2 ?? (^(@.dims[0]) X ^(@.dims[1])).map({ "[$^a][$^b]" }) !!
            die 'Only dimensions 1 and 2 are currently supported';
        return @return;
    }
}

sub op (|a) is export { Math::ThreeD::Operation.new(|a) }

# vim: set expandtab:ft=perl6:ts=4:sw=4
