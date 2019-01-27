use v6;

use PDF::Function;

#| /FunctionType 4 - PostScript
#| see [PDF 32000 Section 7.10.5 Type 4 (PostScript Transform) Functions]
class PDF::Function::PostScript
    is PDF::Function {

    method parse(Str $decoded = $.decoded) {
	state $actions //= (require ::('PDF::Grammar::Function::Actions')).new;
	(require ::('PDF::Grammar::Function')).parse($decoded, :$actions)
	    or die "unable to parse postscript function: $decoded";
	$/.ast
    }

    class Transform
        is PDF::Function::Transform {
        has $.ast;
        has @.stack;
        method pop($type = Numeric) {
            my $v = @!stack
                ?? @!stack.pop
                !! die "Postscript stack underflow";
            die "typecheck error, expected {$type.perl}, got: {$v.perl}"
                unless $v ~~ $type;
            $v;
        }
        method push($v) {
            @!stack < 100
                ?? @!stack.push($v)
                !! die "Postscript stack overflow"
        }

        multi method run(List :$expr!) {
            self.run(|$_) for $expr.list;
        }
        multi method run(Int :$int! ) {
            self.push($int);
        }
        multi method run(Numeric :$real! ) {
            self.push($real);
        }
        multi method run(Bool :$bool! ) {
            self.push($bool);
        }

        my Routine %Ops = BEGIN %(
            # Arithmetic
            add      => method { self.pop + self.pop },
            sub      => method { self.pop - $_ given self.pop },
            mul      => method { self.pop * self.pop },
            div      => method { self.pop / $_ given self.pop },
            idiv     => method { self.pop(Int) div $_ given self.pop(Int) },
            mod      => method { self.pop(Int) % $_ given self.pop(Int) },
            neg      => method { -self.pop },
            abs      => method { self.pop.abs },
            ceiling  => method { self.pop.ceiling },
            floor    => method { self.pop.floor },
            round    => method { self.pop.round },
            truncate => method { self.pop.Int },
            sqrt     => method { self.pop.sqrt },
            sin      => method { sin(self.pop * pi / 180) },
            cos      => method { cos(self.pop * pi / 180) },
            atan     => method {
                            my $den = self.pop;
                            my $num = self.pop;
                            $den = 0 if $den =~= 0;
                            my $angle = $den
                                ?? atan($num / $den) * 180 / pi
                                !! ($num =~= 0 ?? die "undefined result" !! 90);
                            $angle -= 180 if $den < 0;
                            $angle += 360 if $angle < 0;
                            $angle;
                        },
            exp      => method { self.pop ** $_ given self.pop },
            ln       => method { log self.pop; },
            log      => method { log10 self.pop; },
            cvr      => method { self.pop.Num },
            cvi      => method { self.pop.Int },

            # Relational, Boolean and Bitwise Operators
            eq      => method { self.pop == self.pop },
            ne      => method { self.pop != self.pop },
            gt      => method { self.pop >  $_ given self.pop },
            ge      => method { self.pop >= $_ given self.pop },
            lt      => method { self.pop <  $_ given self.pop },
            le      => method { self.pop <= $_ given self.pop },
            and     => method { self.pop(Int) +& self.pop(Int) },
            or      => method { self.pop(Int) +| self.pop(Int) },
            xor     => method { self.pop(Int) +^ self.pop(Int) },
            not     => method {
                           given self.pop(Int) {
                               $_ ~~ Bool ?? not $_  !! ($_ * -1) -1
                           }
                       },
            bitshift => method { self.pop(Int) +< $_ given self.pop(Int) },
            true    => method { True },
            false   => method { False },

            # Stack Operators
            pop     => method {
                self.pop(Any);
                [];
            },
            exch     => method {
                [$_, self.pop(Any)] given self.pop(Any);
            },
            dup     => method {
                [$_, $_] given self.pop(Any);
            },
            copy    => method {
                my UInt $n = self.pop(Int);
                die "stack underflow"
                    unless @!stack >= $n;
                @!stack.tail($n);
            },
            index    => method {
                my UInt $i = self.pop(Int);
                die "stack underflow"
                    unless @!stack >= $i;
                @!stack[* - ($i + 1)];
            },
            roll    => method {
                my $j = self.pop(Int);
                my UInt $n = self.pop(Int);
                die "stack underflow"
                    unless @!stack >= $n;
                @!stack.splice(* - $n).rotate($j);
            },
           );
        multi method run(Str :$op! ) {
            with %Ops{$op} {
                @!stack.append: .(self);
            }
            else {
                die "unknown postscript operator: $op";
            }
        }
        multi method run(Hash :$cond!) {
            my $branch = $.pop(Bool)
                ?? $cond<if>
                !! $cond<else>;
            $.run(|$_) with $branch;
        }

        method calc(@in where .elems = @.domain.elems) {
            @!stack = (@in Z @.domain).map: { $.clip(.[0], .[1]) };
            $.run( |$!ast );
            (@!stack Z @.range).map: { $.clip(.[0], .[1]) };
        }
    }

    method calculator {
        my $ast = self.parse;
        my Range @domain = $.Domain.map: -> $a, $b { Range.new($a, $b) };
        my Range @range = $.Range.map: -> $a, $b { Range.new($a, $b) };
        Transform.new: :@domain, :@range, :$ast;
    }
    #| run the calculator function
    method calc(@in) {
        $.calculator.calc(@in);
    }

}
