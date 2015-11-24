# References ISO/IEC 9899:1990 "Information technology - Programming Language C" (C89 for short)
use v6;
#use Grammar::Tracer;
use C::Parser::Lexer;
use C::Parser::Utils;
unit grammar C::Parser::Grammar is C::Parser::Lexer;

rule TOP {
	^ <.ws> <translation-unit>
    [$ || {
        my $bad = $<translation-unit><external-declaration>[*-1];
        my $lineno = substr($<translation-unit>.orig, 0, $bad.to).lines.elems;
        my $msg = substr($<translation-unit>.orig, $bad.to, min($bad.to + 60, $<translation-unit>.orig.chars));
        my $msg2 = substr($msg, 0, min(60, $msg.chars));
        die("input:" ~ $lineno ~ ": expected declaration, but got: `" ~ $msg2.chomp() ~ "...`")
    }]
}

# subroutines for typedefs

sub push_context(Str $ctx) {
    @*CONTEXTS.push($ctx)
}

sub pop_context(--> Str) {
    @*CONTEXTS.pop()
}

sub context_is(Str $ctx --> Bool) {
    if @*CONTEXTS.elems < 1 {
        return False;
    }
    if @*CONTEXTS[*-1] ne $ctx {
        return False;
    }
    return True;
}

sub get_declarator_name(Match $decr --> Str) {
    my Match $ddecr1 = $decr<direct-declarator><direct-declarator-first>;
    my Str $name = $ddecr1<declarator>
        ?? get_declarator_name($ddecr1<declarator>)
        !! $ddecr1<ident><name>.Str;
    return $name;
}

sub end_declaration(Any $decls, Any $inits) {
    if @*CONTEXTS.elems < 1 {
       return;
    }
    my $context_was = @*CONTEXTS[*-1];
    while context_is('struct') || context_is('union') {
        pop_context();
    }
    my $context = @*CONTEXTS[*-1];
    if !context_is('typedef') {
        return;
    }
    pop_context();

    if $inits && $inits<init-declarator> {
        if !$inits<init-declarator>[0] {
            warn("unknown condition in $context!");
            return;
        }
        if !$inits<init-declarator>[0]<declarator> {
            warn("unknown condition in $context!");
            return;
        }
        
        my Match $decr = $inits<init-declarator>[0]<declarator>;
        my Str $name = get_declarator_name($decr);
        if $name ∈ @*BUILTIN_TYPEDEFS {
            #note("builtin $context '$name'");
        }
        elsif %*TYPEDEFS{$name}:exists {
            warn("redefining $context '$name'!");
        }
        %*TYPEDEFS{$name} = True;
    }
    elsif $inits {
        my Str $name = $inits<name>.Str;
        #note("defining $context '$name'!");
        %*TYPEDEFS{$name} = True;
    }
    elsif $decls && $decls<declaration-specifier> {
        if !$decls<declaration-specifier>[*-1] {
            warn("unknown condition in $context!");
            return;
        }
        if !$decls<declaration-specifier>[*-1]<type-specifier> {
            warn("unknown condition in $context!");
            return;
        }
        if !$decls<declaration-specifier>[*-1]<type-specifier><typedef-name> {
            warn("unknown condition in $context!");
            return;
        }
        if !$decls<declaration-specifier>[*-1]<type-specifier><typedef-name><ident> {
            warn("unknown condition in $context!");
            return;
        }
        
        my Match $ident = $decls<declaration-specifier>[*-1]<type-specifier><typedef-name><ident>;
        my Str $name = $ident<name>.Str;
        if $name ∈ @*BUILTIN_TYPEDEFS {
            #note("builtin $context '$name'");
        }
        elsif %*TYPEDEFS{$name}:exists {
            warn("redefining $context '$name'!");
        }
        %*TYPEDEFS{$name} = True;
    }
    else {
        warn("unknown condition in $context!");
    }

}

sub is_typedef(Match $ident --> Bool) {
    return False if !$ident;
    return False if !$ident<name>;
	%*TYPEDEFS{$ident<name>.Str}:exists
}


############################################################
##
##  Expressions
##

# SS 6.5.1

proto rule primary-expression {*}
rule primary-expression:sym<identifier> {
    <ident>
}
rule primary-expression:sym<constant> {
    <constant>
}
rule primary-expression:sym<string-literal> {
    <string-constant>
}
rule primary-expression:sym<compound-statement> { # GNU
    '(' <compound-statement> ')'
}
rule primary-expression:sym<expression> {
    '(' <expression> ')'
}
rule primary-expression:sym<generic-selection> { # C11
    <generic-selection>
}
rule primary-expression:sym<offsetof-expression> { # GNU
    <offsetof-expression>
}

rule offsetof-expression {
    <offsetof-keyword>
    '('
    <type-name>
	','
	<offsetof-member-designator>        
    ')'
}

rule offsetof-member-designator {
    <offsetof-member-designator-first>
    <offsetof-member-designator-rest>*
}
rule offsetof-member-designator-first {
    <ident>
}
proto rule offsetof-member-designator-rest {*}
rule offsetof-member-designator-rest:sym<struct> {
    '.' <ident>
}
rule offsetof-member-designator-rest:sym<array> {
    "[" <primary-expression> "]"
}

# SS 6.5.1.1
rule generic-selection {
    <generic-keyword>
    '('
    <assignment-expression> ','
    <generic-assoc-list>
    ')'
}

rule generic-assoc-list {
    <generic-association> [',' <generic-association>]*
}

proto rule generic-association {*}
rule generic-association:sym<typename> {
    <type-name> ':' <assignment-expression>
}
rule generic-association:sym<default> {
    <default-keyword> ':' <assignment-expression>
}

# SS 6.5.2
rule postfix-expression {
    <postfix-expression-first>
    <postfix-expression-rest>*
}

proto rule postfix-expression-first {*}
rule postfix-expression-first:sym<primary> {
    <primary-expression>
}
rule postfix-expression-first:sym<initializer> {
    '('
    <type-name>
    ')'
    '{'
    <initializer-list> ','?
    '}'
}

proto rule postfix-expression-rest {*}
rule postfix-expression-rest:sym<[ ]> {
    '['
    <expression>
    ']'
}
rule postfix-expression-rest:sym<( )> {
    '('
    <argument-expression-list>?
    ')'
}
rule postfix-expression-rest:sym<.>   { <sym> <ident> }
rule postfix-expression-rest:sym«->»  { <sym> <ident> }
rule postfix-expression-rest:sym<++>  { <sym> }
rule postfix-expression-rest:sym<-->  { <sym> }

rule argument-expression-list {
    <assignment-expression> [',' <assignment-expression>]*
}

# SS 6.5.3
proto rule unary-expression {*}
rule unary-expression:sym<postfix> { <postfix-expression> }
rule unary-expression:sym<++> { <sym> <unary-expression> }
rule unary-expression:sym<--> { <sym> <unary-expression> }
rule unary-expression:sym<unary-cast> {
    <unary-operator> <cast-expression>
}
rule unary-expression:sym<size-of-expr> {
    <sizeof-keyword> <unary-expression>
}
rule unary-expression:sym<size-of-type> {
    <sizeof-keyword> '(' <type-name> ')'
}
rule unary-expression:sym<align-of-type> {
    <alignof-keyword> '(' <type-name> ')'
}

proto rule unary-operator {*}
rule unary-operator:sym<&> { <sym> }
rule unary-operator:sym<*> { <sym> }
rule unary-operator:sym<+> { <sym> }
rule unary-operator:sym<-> { <sym> }
rule unary-operator:sym<~> { <sym> }
rule unary-operator:sym<!> { <sym> }

# SS 6.5.4
rule cast-expression {
    <cast-operator>* <unary-expression>
}

# Nonstandard: cast-operator does not exist in C89 grammar
# Rationale: these tokens appear in many rules, and although
# it would simplify the grammar, the semantics would be different
# so we only use it in the place where it's supposed to be.
rule cast-operator { '(' <type-name> ')' }

# SS 6.5.5
rule multiplicative-expression {
    <operands=.cast-expression>
    [<multiplicative-operator> <operands=.cast-expression>]*
}
proto rule multiplicative-operator {*}
rule multiplicative-operator:sym<*> { <sym> }
rule multiplicative-operator:sym</> { <sym> }
rule multiplicative-operator:sym<%> { <sym> }

# SS 6.5.6
rule additive-expression {
    <operands=.multiplicative-expression>
    [<additive-operator> <operands=.multiplicative-expression>]*
}
proto rule additive-operator {*}
rule additive-operator:sym<+> { <sym> }
rule additive-operator:sym<-> { <sym> }

# SS 6.5.7
rule shift-expression {
    <operands=.additive-expression>
    [<shift-operator> <operands=.additive-expression>]*
}
proto rule shift-operator {*}
rule shift-operator:sym«<<» { <sym> }
rule shift-operator:sym«>>» { <sym> }

# SS 6.5.8
rule relational-expression {
    <operands=.shift-expression>
    [<relational-operator> <operands=.shift-expression>]*
}
proto rule relational-operator {*}
rule relational-operator:sym«<»  { <sym> }
rule relational-operator:sym«>»  { <sym> }
rule relational-operator:sym«<=» { <sym> }
rule relational-operator:sym«>=» { <sym> }

# SS 6.5.9
rule equality-expression {
    <operands=.relational-expression>
    [<equality-operator> <operands=.relational-expression>]*
}
proto rule equality-operator {*}
rule equality-operator:sym<==> { <sym> }
rule equality-operator:sym<!=> { <sym> }

# SS 6.5.10
rule and-expression {
    <operands=.equality-expression>
    [<and-operator> <operands=.equality-expression>]*
}
proto rule and-operator {*}
rule and-operator:sym<&> { <sym> }

# SS 6.5.11
rule exclusive-or-expression {
    <operands=.and-expression>
    [<exclusive-or-operator> <operands=.and-expression>]*
}

proto rule exclusive-or-operator {*}
rule exclusive-or-operator:sym<^> { <sym> }

# SS 6.5.12
rule inclusive-or-expression {
    <operands=.exclusive-or-expression>
    [<inclusive-or-operator> <operands=.exclusive-or-expression>]*
}
proto rule inclusive-or-operator {*}
rule inclusive-or-operator:sym<|> { <sym> }

# SS 6.5.13
rule logical-and-expression {
    <operands=.inclusive-or-expression>
    [<logical-and-operator> <operands=.inclusive-or-expression>]*
}
proto rule logical-and-operator {*}
rule logical-and-operator:sym<&&> { <sym> }

# SS 6.5.14
rule logical-or-expression {
    <operands=.logical-and-expression>
    [<logical-or-operator> <operands=.logical-and-expression>]*
}
proto rule logical-or-operator {*}
rule logical-or-operator:sym<||> { <sym> }

# SS 6.5.15
rule conditional-expression {
    <operands=.logical-or-expression>
    ['?' <operands=.expression> ':' <operands=.conditional-expression>]?
}

# SS 6.5.16
rule assignment-expression {
    [<operands=.unary-expression> <assignment-operator>]*
    <operands=.conditional-expression>
}
proto rule assignment-operator {*}
rule assignment-operator:sym<=>   { <sym> }
rule assignment-operator:sym<*=>  { <sym> }
rule assignment-operator:sym</=>  { <sym> }
rule assignment-operator:sym<%=>  { <sym> }
rule assignment-operator:sym<+=>  { <sym> }
rule assignment-operator:sym<-=>  { <sym> }
rule assignment-operator:sym«<<=» { <sym> }
rule assignment-operator:sym«>>=» { <sym> }
rule assignment-operator:sym<&=>  { <sym> }
rule assignment-operator:sym<^=>  { <sym> }
rule assignment-operator:sym<|=>  { <sym> }

# SS 6.5.17
rule expression {
    <operands=.assignment-expression>
    [',' <operands=.assignment-expression>]*
}

# SS 6.6
rule constant-expression { <conditional-expression> }


############################################################
##
##  Declarations
##

# SS 6.7
proto rule declaration {*}
rule declaration:sym<direct-typedef> {
    'typedef' {push_context('typedef')} <declaration-specifiers> <ident> ';'
    {end_declaration($<declaration-specifiers>, $<ident>)}
}

rule declaration:sym<declaration> {
    <declaration-specifiers> <init-declarator-list>? ';'
    {end_declaration($<declaration-specifiers>, $<init-declarator-list>)}
}
rule declaration:sym<static_assert> { # C11
    <static-assert-declaration>
}

rule declaration-specifiers {
    <declaration-specifier>+
}

# Nonstandard: declaration-specifier does not exist in C89 grammar
# Rationale: declaration-specifiers includes itself in every RHS
# so we factor it out as <declaration-specifier>+ which means the same.
proto rule declaration-specifier {*}
rule declaration-specifier:sym<storage-class> {
    <storage-class-specifier>
}
rule declaration-specifier:sym<type-specifier> {
    <type-specifier>
}
rule declaration-specifier:sym<type-qualifier> {
    <type-qualifier>
}
rule declaration-specifier:sym<function> {
    <function-specifier>
}
rule declaration-specifier:sym<alignment> {
    <alignment-specifier>
}
rule declaration-specifier:sym<__attribute__> { # GNU
    <attribute-keyword>
    '(('
    <attribute-specifier-list>
    '))'
}

rule init-declarator-list { <init-declarator> [',' <init-declarator>]* }
rule init-declarator { <declarator> ['=' <initializer>]? }

# SS 6.7.1
proto rule storage-class-specifier {*}
rule storage-class-specifier:sym<typedef>  { <sym> {push_context('typedef')} }
rule storage-class-specifier:sym<extern>   { <sym> {push_context('extern')} }
rule storage-class-specifier:sym<static>   { <sym> }
rule storage-class-specifier:sym<_Thread_local> { <thread-local-keyword> }
rule storage-class-specifier:sym<auto>     { <sym> }
rule storage-class-specifier:sym<register> { <sym> }

# SS 6.7.2
proto rule type-specifier {*}
rule type-specifier:sym<typedef-name>    {
    <typedef-name>
}
rule type-specifier:sym<void>     { <void-keyword> }
rule type-specifier:sym<char>     { <char-keyword> }
rule type-specifier:sym<short>    { <short-keyword> }
rule type-specifier:sym<int>      { <int-keyword> }
rule type-specifier:sym<long>     { <long-keyword> }
rule type-specifier:sym<float>    { <float-keyword> }
rule type-specifier:sym<double>   { <double-keyword> }
rule type-specifier:sym<signed>   { <signed-keyword> }
rule type-specifier:sym<unsigned> { <unsigned-keyword> }
rule type-specifier:sym<_Bool>    { <sym> } # stdbool.h
rule type-specifier:sym<_Complex> { <sym> } # complex.h
rule type-specifier:sym<_Fract>   { <sym> } # stdfix.h
rule type-specifier:sym<_Accum>   { <sym> } # stdfix.h
rule type-specifier:sym<_Sat>     { <sym> } # stdfix.h
rule type-specifier:sym<atomic-type>     {  # stdatomic.h
    <atomic-type-specifier>
}
rule type-specifier:sym<struct-or-union> {
    <struct-or-union-specifier>
}
rule type-specifier:sym<enum-specifier>  {
    <enum-specifier>
}

rule type-specifier:sym<__typeof__> { # GNU
    <typeof-keyword>
    '(' <expression> ')'
}

# SS 6.7.2.1
proto rule struct-or-union-specifier {*}
rule struct-or-union-specifier:sym<decl> {
    :my $ctx;
    <struct-or-union>
    [ <ident>?
    '{'
    <struct-declaration-list>
    '}' || {pop_context()} <!>]
}
rule struct-or-union-specifier:sym<spec> {
    <struct-or-union>
    [ <ident> <!before '{'>
    || {pop_context()} <!>]
    
}

proto rule struct-or-union {*}
rule struct-or-union:sym<struct> {
    <struct-keyword>
    {push_context('struct')}
}
rule struct-or-union:sym<union>  {
    <union-keyword>
    {push_context('union')}
}

rule struct-declaration-list {
    <struct-declaration>+
}

proto rule struct-declaration {*}
rule struct-declaration:sym<struct> {
    <specifier-qualifier-list> <struct-declarator-list>? ';'
}
rule struct-declaration:sym<static_assert> { # C11
    <static-assert-declaration>
}

rule specifier-qualifier-list {
    <specifier-qualifier>+
}

proto rule specifier-qualifier {*}
rule specifier-qualifier:sym<type-specifier> {
    <type-specifier>
}
rule specifier-qualifier:sym<type-qualifier> {
    <type-qualifier>
}

rule struct-declarator-list {
    <struct-declarator> [',' <struct-declarator>]*
}

proto rule struct-declarator {*}
rule struct-declarator:sym<std> {
    <declarator> [':' <constant-expression>]?
}
rule struct-declarator:sym<bit> {
    ':' <constant-expression> 
}

# SS 6.7.2.2
proto rule enum-specifier {*}
rule enum-specifier:sym<decl> {
    <enum-keyword> <ident>?
    '{'
    {push_context('enum')}
    <enumerator-list> ','?
    {pop_context()}
    '}'
}
rule enum-specifier:sym<spec> {
    <enum-keyword> <ident> <!before '{'> <!before ';'>
}

rule enumerator-list { <enumerator> [',' <enumerator>]* }

rule enumerator {
    <enumeration-constant> ['=' <constant-expression>]?
}

# SS 6.7.2.4
proto rule atomic-type-specifier {*} # C11
rule atomic-type-specifier:sym<_Atomic> {
    <atomic-keyword>
    '(' <type-name> ')'
}

# SS 6.7.3
proto rule type-qualifier {*}
rule type-qualifier:sym<const>    { <sym> }
rule type-qualifier:sym<volatile> { <sym> }
rule type-qualifier:sym<restrict> { <restrict-keyword> }
rule type-qualifier:sym<_Atomic>  { <atomic-keyword> }

# SS 6.7.4
proto rule function-specifier {*}
rule function-specifier:sym<inline>    { <inline-keyword> }
rule function-specifier:sym<_Noreturn> { <noreturn-keyword> }

# SS 6.7.5
proto rule alignment-specifier {*}
rule alignment-specifier:sym<type-name> {
    <alignas-keyword>
    '(' <type-name> ')'
}
rule alignment-specifier:sym<constant> {
    <alignas-keyword>
    '(' <constant-expression> ')'
}

# SS 6.7.6
proto rule declarator {*}

rule declarator:sym<direct> {
    <pointer>* <direct-declarator>
}
rule declarator:sym<pointer> {
    <pointer>+
}

rule direct-declarator {
    <direct-declarator-first>
    <direct-declarator-rest>*
}

proto rule direct-declarator-first {*}

rule direct-declarator-first:sym<identifier> {
    <ident>
}

rule direct-declarator-first:sym<declarator> {
    '(' <declarator> ')'
}

proto rule static-or-type-qualifier {*}
rule static-or-type-qualifier:sym<static> { <sym> }
rule static-or-type-qualifier:sym<type>   { <type-qualifier> }

rule static-or-type-qualifier-list {
    <static-or-type-qualifier>+
}

proto rule direct-declarator-rest {*}
rule direct-declarator-rest:sym<b-assignment-expression> {
    '['
    <static-or-type-qualifier-list>?
    <assignment-expression>?
    ']'
}
rule direct-declarator-rest:sym<b-type-qualifier-list> {
    '['
    <type-qualifier-list>? '*'
    ']'
}
rule direct-declarator-rest:sym<p-parameter-type-list> {
    '('
    <parameter-type-list>
    ')'
}
rule direct-declarator-rest:sym<p-identifier-list> {
    '('
    <identifier-list>?
    ')'
}
rule direct-declarator-rest:sym<__asm__> { # GNU
    <assembly>
}
rule direct-declarator-rest:sym<__attribute__> { # GNU
    <attribute>
}

# Nonstandard extensions:

rule attribute { # GNU
    <attribute-keyword>
    '(('
    <attribute-specifier-list>
    '))'
}

rule attribute-specifier-list { # GNU
    <attribute-specifier> [',' <attribute-specifier>]*
}

rule attribute-specifier { # GNU
    <ident> ['(' <argument-expression-list> ')']?
}

proto rule assembly {*}
rule assembly:sym<std> { # GNU
    <asm-keyword>
    '('
    <string-constant>
    [':' <assembly-operand-list>]*
    ')'
}

rule assembly-operand-list {
    <assembly-operand> [',' <assembly-operand>]*
}

rule assembly-operand {
	['[' <ident> ']']? 
	<string-literal> 
	['(' <expression> ')']?
}

proto rule pointer {*}
rule pointer:sym<pointer> { '*' <type-qualifier-list>? }
rule pointer:sym<block> { '^' <type-qualifier-list>? } # Apple Blocks

rule type-qualifier-list { <type-qualifier>+ }

proto rule parameter-type-list {*}
rule parameter-type-list:sym<std> { <parameter-list> $<ellipsis>=[',' '...']? }

rule parameter-list {
    <parameter-declaration> [',' <parameter-declaration>]*
}

proto rule parameter-declaration {*}
rule parameter-declaration:sym<declarator> { <declaration-specifiers> <declarator> }
rule parameter-declaration:sym<abstract> { <declaration-specifiers> <abstract-declarator>? }

rule identifier-list { <ident> [',' <ident>]* }

# SS 6.7.7
rule type-name { <specifier-qualifier-list> <abstract-declarator>? }
proto rule abstract-declarator {*}
rule abstract-declarator:sym<pointer> { <pointer> }
rule abstract-declarator:sym<direct-abstract> {
    <pointer>* <direct-abstract-declarator>
}

rule direct-abstract-declarator {
    <direct-abstract-declarator-first>?
    <direct-abstract-declarator-rest>*
}
proto rule direct-abstract-declarator-first {*}
rule direct-abstract-declarator-first:sym<abstract> {
    '('
    <abstract-declarator>
    ')'
}

proto rule direct-abstract-declarator-rest {*}
rule direct-abstract-declarator-rest:sym<b-type-qualifier> {
    '['
    <type-qualifier-list>?
    <assignment-expression>?
    ']'
}
rule direct-abstract-declarator-rest:sym<b-static-type-qualifier> {
    '['
    <static-keyword>
    <type-qualifier-list>?
    <assignment-expression>
    ']'
}
rule direct-abstract-declarator-rest:sym<b-type-qualifier-static> {
    '['
    <type-qualifier-list>
    <static-keyword>
    <assignment-expression>
    ']'
}
rule direct-abstract-declarator-rest:sym<b-*> {
    '[' '*' ']'
}
rule direct-abstract-declarator-rest:sym<p-parameter-type-list> {
    '(' <parameter-type-list>? ')'
}

# SS 6.7.8
rule typedef-name {
    <ident> <!before ';'>
    <?{ is_typedef($<ident>) }>
}

# SS 6.7.9
proto rule initializer {*}
rule initializer:sym<assignment> {
    <assignment-expression>
}
rule initializer:sym<initializer-list> {
    '{'
    <initializer-list> ','?
    '}'
}

rule initializer-list {
    <designation-initializer>
    (',' <designation-initializer>)*
}

rule designation-initializer {
    <designation>? <initializer>
}

rule designation { <designator-list> '=' }
rule designator-list { <designator>+ }

proto rule designator {*}
rule designator:sym<.> { <sym> <ident> }
rule designator:sym<[ ]> {
    '[' <constant-expression> ']'
}

# SS 6.7.10
rule static-assert-declaration { # C11
    <static-assert-keyword>
    '('
    <constant-expression>
    ','
    <string-constant>
    ')'
    ';'
}


############################################################
##
##  Statements
##

# SS 6.8
proto rule statement {*}
rule statement:sym<labeled> { <labeled-statement> }
rule statement:sym<compound> { <compound-statement> }
rule statement:sym<expression> { <expression-statement> }
rule statement:sym<selection> { <selection-statement> }
rule statement:sym<iteration> { <iteration-statement> }
rule statement:sym<jump> { <jump-statement> }

# SS 6.8.1
proto rule labeled-statement {*}
rule labeled-statement:sym<identifier> { <ident> ':' <statement> }
rule labeled-statement:sym<case> {
    <case-keyword> <constant-expression> ':' <statement>
}
rule labeled-statement:sym<default> {
    <default-keyword> ':' <statement>
}

# SS 6.8.2
rule compound-statement {
    '{'
    <block-item-list>?
    '}'
}

rule block-item-list { <block-item>+ }

proto rule block-item {*}
rule block-item:sym<declaration> { <declaration> }
rule block-item:sym<statement> { <statement> }
rule block-item:sym<function-definition> { <function-definition> } # GNU


# SS 6.8.3
rule expression-statement { <expression>? ';' }

# SS 6.8.4
proto rule selection-statement {*}
rule selection-statement:sym<if> {
    <if-keyword>
    '('
    <expression>
    ')'
    <then_statement=statement>
    ('else' <else_statement=statement>)?
}
rule selection-statement:sym<switch> {
    <switch-keyword>
    '('
    <expression>
    ')'
    <statement>
}

# SS 6.8.5
proto rule iteration-statement {*}
rule iteration-statement:sym<while> {
    <while-keyword>
    '('
    <expression>
    ')'
    <statement>
}
rule iteration-statement:sym<do_while> {
    <do-keyword>
    <statement>
    <while-keyword>
    '('
    <expression>
    ')'
    ';'
}
rule iteration-statement:sym<for> {
    <for-keyword>
    '('
    <init=expression>? ';'
    <test=expression>? ';'
    <step=expression>?
    ')'
    <statement>
}
rule iteration-statement:sym<for_decl> { # C99
    <for-keyword>
    '('
    <init=declaration>
    <test=expression>? ';'
    <step=expression>?
    ')'
    <statement>
}

# SS 6.8.6
proto rule jump-statement {*}
rule jump-statement:sym<goto> {
    <goto-keyword> <ident> ';'
}
rule jump-statement:sym<continue> {
    <continue-keyword> ';'
}
rule jump-statement:sym<break> {
    <break-keyword> ';'
}
rule jump-statement:sym<return> {
    <return-keyword> <expression>? ';'
}

############################################################
##
##  Translation Unit
##

# SS 6.9
rule translation-unit {
    :my %*ENUMS;
    :my %*STRUCTS;
    :my %*TYPEDEFS;
    :my @*CONTEXTS = @();

    # BUILTIN_TYPEDEFS never changes
    # maybe this could be const/final?
    :my @*BUILTIN_TYPEDEFS = C::Parser::Utils::get_builtin_types();
    {
        for @*BUILTIN_TYPEDEFS -> Str $typename {
            #note("new builtin typedef '{$typename}'");
            %*TYPEDEFS{$typename} = True;
        }
    }
    
    <external-declaration>+
}

proto rule external-declaration {*} 
rule external-declaration:sym<function-definition> {
    :my @ctxs = @*CONTEXTS; 
    <function-definition>
    || {@*CONTEXTS = @ctxs} <!>
}
rule external-declaration:sym<declaration> {
    :my @ctxs = @*CONTEXTS; 
    <declaration>
    || {@*CONTEXTS = @ctxs} <!>
}
rule external-declaration:sym<__asm__> {
    <assembly>
}
#rule external-declaration:sym<control-line> { <control-line> }

# SS 6.9.1
proto rule function-definition {*}
rule function-definition:sym<std> {
    <declaration-specifiers>
    <declarator>
    <declaration-list>?
    <compound-statement>
}

rule declaration-list { <declaration>+ }


############################################################
##
##  Preprocessor
##

## SS 6.10
#rule preprocessing-file { <group>? }
#rule group { <group-part>+ }
#proto rule group-part {*}
#rule group-part:sym<if-section> { <if-section> }
#rule group-part:sym<control-line> { <control-line> }
#rule group-part:sym<text-line> { <text-line> }
#rule group-part:sym<non-directive> { '#' <non-directive> }

#proto rule if-section($text) {
#    <if-group($text)>
#    <elif-groups($text)>?
#    <else-group($text)>?
#    <endif-line($text)>
#}
#proto rule if-group($text) {*}
#proto rule elif-groups($text) {*}
#proto rule elif-group($text) {*}
#proto rule else-group($text) {*}
#proto rule endif-line($text) {*}

#proto rule control-line() {*}
#
#rule text-line { <pp-tokens>? <new-line> }
#rule non-directive { <pp-tokens>? <new-line> }
#
## TODO
#token new-line { <?> }
#
#proto rule replacement-list {*}

# SS 6.10.9 Pragma operator

rule pragma-operator {
    '_Pragma' '(' <string-constant> ')'
}
