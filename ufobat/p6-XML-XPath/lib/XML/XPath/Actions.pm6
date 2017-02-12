use v6.c;
use XML::XPath::Expr;
use XML::XPath::Step;
use XML::XPath::Predicates;
use XML::XPath::FunctionCall;
use Data::Dump;

class XML::XPath::Actions {
    method mymake($/, $made, Int :$level = 1) {
        # my $caller = callframe($level);
        # debug code would be possible here
        $/.make: $made;
    }

    method TOP($/) {
        $/.make: $/<Expr>.made;
    }

    method Expr($/) {
        self.mymake($/, $/<OrExpr>.made);
    }

    method OrExpr($/) {
        my @tokens = $/<AndExpr>;
        my @operators = $/<OrOperator>;
        self!expression(@tokens, $/, @operators);
    }
    method OrOperator($/) { self.mymake($/, 'Or') }

    method AndExpr($/) {
        my @tokens = $/<EqualityExpr>;
        my @operators = $/<AndOperator>;
        self!expression(@tokens, $/, @operators);
    }
    method AndOperator($/) { self.mymake($/, 'And') }

    method EqualityExpr($/) {
        my @tokens = $/<RelationalExpr>;
        my @operators = $/<EqualityOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method EqualityOperator($/) {
        self.mymake($/, $/.Str eq '=' ?? 'Equal' !! 'NotEqual');
    }

    method RelationalExpr($/) {
        my @tokens = $/<AdditiveExpr>;
        my @operators = $/<RelationalOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method AdditiveExpr($/) {
        my @tokens = $/<MultiplicativeExpr>;
        my @operators = $/<AdditiveOperators>;
        self!expression(@tokens, $/, @operators);
    }

    method AdditiveOperators($/) {
        self.mymake($/, $/.Str eq '+' ?? 'Plus' !! 'Minus');
    }

    method MultiplicativeExpr($/) {
        my @tokens = $/<UnaryExpr>;
        my @operators = $/<MultiplicativeOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method MultiplicativeOperator($/) {
        self.mymake($/, $/.Str eq '*' ?? 'Multiply' !! $/.Str.tc);
    }

    method UnionExpr($/) {
        my @tokens = $/<PathExpr>;
        my @operators = $/<UnionOperator>;
        self!expression(@tokens, $/, @operators);
    }

    method UnionOperator($/){
        self.mymake($/, 'Pipe');
    }

    method !expression(@tokens, $/, @operators) {
        die 'at least 1 *Expr required' if @tokens.elems < 1;
        my $last_expression;
        my $expression;
        for @tokens.kv -> $i, $token {
            $expression = $token.made;
            if $expression ~~ XML::XPath::Step {
                # in case a expression is a step wrap it so we can attach
                # <some kind of operator> <Expr>
                $expression = XML::XPath::Expr.new(operand => $expression);
            }
            if ($last_expression) {
                $expression = XML::XPath::Expr.new(
                    operand       => $last_expression,
                    operator      => @operators[$i-1].made,
                    other-operand => $expression,
                );
            }
            $last_expression = $expression;
            #$first_expression = $expression unless $first_expression;
        }
        # wrap it, so someone else can attach with an operator to it
        my $made = XML::XPath::Expr.new(operand => $expression);
        self.mymake($/, $made, level => 2);
    }

    method UnaryExpr($/) {
        my $union-expression = $/<UnionExpr>.made;
        my $operator-prefix = $/<UnaryOperator>.made;
        my $expr;
        if $operator-prefix {
            $expr = XML::XPath::Expr.new(
                operand  => $union-expression,
                operator => $operator-prefix,
            );
        } else {
            $expr = $union-expression;
        }
        self.mymake($/, $expr);
    }

    method UnaryOperator($/) {
        self.mymake($/, $/.Str.chars % 2 ?? 'UnaryMinus' !! '');
    }

    method FilterExpr($/) {
        my $primary-expr = $/<PrimaryExpr>;
        my @predicates   = $/<Predicate>;
        my $expr         = $primary-expr.made;
        $expr.predicates = XML::XPath::Predicates.new( predicates => @predicates>>.made);
        self.mymake($/, $expr);
    }

    method PrimaryExpr($/) {
        my $expression = XML::XPath::Expr.new;
        if $/<VariableReference>:exists {
            X::NYI.new(feature => 'PrimaryExpr - VariableReference').throw;
        } elsif $/<Expr>:exists {
            $expression.operand = $/<Expr>.made;
        } elsif $/<Literal>:exists {
            $expression.operand = $/<Literal>.made;
        } elsif $/<Number>:exists {
            my $value = $/<Number>.Real;
            $expression.operand = $value;
        } else  {
            $expression.operand = $/<FunctionCall>.made;
        }
        self.mymake($/, $expression);
    }
    method Literal($/) {
        my $str = $/.Str;
        self.mymake($/, $str.substr(1,*-1));
    }
    method FunctionCall($/) {
        my @args = $/<Argument>;
        my $func = XML::XPath::FunctionCall.new(
            function => $/<FunctionName>.Str,
            args => @args>>.made,
        );
        self.mymake($/, $func);
    }
    method Argument($/) {
        self.mymake($/, $<Expr>.made);
    }

    method RelativeLocationPath($/) {
        my @tokens = $/<Step>;
        die 'at least 1 *Expr required' if @tokens.elems < 1;
        my $first_step;

        for @tokens.kv -> $i, $token {
            my $step = $token.made;
            if ($first_step) {
                $first_step.add-next($step);
            } else {
                $first_step = $step;
            }
        }
        self.mymake($/, $first_step);
    }
    method LocationPath($/) {
        my $path;
        if $/<RelativeLocationPath>:exists {
            $path = $/<RelativeLocationPath>.made;

            if $/<StepDelim>:exists {
                $path.is-absolute = True;
            }
        } else {
            $path = XML::XPath::Step.new(
                axis        => 'child',
                is-absolute => True
            );
        }
        self.mymake($/, $path);
    }
    method PathExpr($/) {
        my $pathexpr;
        if $/<LocationPath>:exists {
            $pathexpr = $/<LocationPath>.made;
        } else {
            $pathexpr = $/<FilterExpr>.made;
            if $/<StepDelim>:exists {
                my $path = $/<RelativeLocationPath>.made;
                $path.is-absolute = True;

                $pathexpr.operator = '/';
                $pathexpr.other-operand: $path;
            }
        }
        self.mymake($/, $pathexpr);

    }
    # method NodeTest($/) {
    #     if $/<NameTest>:exists {
    #         $nodetest .= new(value => ~$/<NameTest>);
    #         self.mymake($/, $nodetest);
    #     }
    #     elsif $/<NodeType>:exists {
    #         $nodetest .= new(type => ~$/<NodeType>);
    #     }
    #     else {
    #         $nodetest .= new(
    #             type  => 'processing-instruction',
    #             value => ~$<Literal>
    #         );
    #     }
    #     self.mymake($/, $nodetest);
    # }
    method Step($/) {
        my $step;
        if $/<AbbreviatedStep>:exists {
            # . or ..
            $step = XML::XPath::Step.new(
                axis => $/<AbbreviatedStep>.Str eq '..' ?? 'parent' !! 'self',
            );
        }
        else {
            my $nodetest = $/<NodeTest>;
            my $axis;
            if $/<AxisSpecifier> eq '' {
                $axis = $nodetest<NameTest>:exists ?? 'child' !! 'self';
                $axis = 'child';
            } elsif $/<AxisSpecifier> eq '@' {
                $axis = 'attribute';
            } else {
                $axis = $/<AxisSpecifier>.substr(0,*-2);
            }
            $step = XML::XPath::Step.new(:$axis);

            if $nodetest<NameTest>:exists {
                $step.value = ~$nodetest<NameTest>
            }
            elsif $nodetest<NodeType>:exists {
                $step.type = ~$nodetest<NodeType>;
            }
            else {
                $step.type = 'processing-instruction';
                $step.value = ~$<Literal>;
            }

            my @predicates   = $/<Predicate>;
            $step.predicates = XML::XPath::Predicates.new( predicates => @predicates>>.made);

            if $/<StepDelim>:exists {
                $step = XML::XPath::Step.new(axis => 'descendant-or-self', next => $step);
            }
        }
        self.mymake($/, $step);
    }
    method Predicate($/) {
        self.mymake($/, $/<PredicateExpr>.made);
    }
    method PredicateExpr($/) {
        self.mymake($/, $/<Expr>.made);
    }
    method AxisSpecifier($/) {
        self.mymake($/, ~$/);
    }
    method RelationalOperator($/) {
        given $/.Str {
            when '>'  {self.mymake($/, 'GreaterThan', level => 2) }
            when '<'  {self.mymake($/, 'SmallerThan', level => 2) }
            when '>=' {self.mymake($/, 'GreaterEqual', level => 2) }
            when '<=' {self.mymake($/, 'SmallerEqual', level => 2) }
        }
    }
}
