use v6;
use C::AST;
unit module C::AST::Utils;

our sub binop_from_lassoc(@operators, @operands) {
    my $ast = (shift @operands).ast;
    for @operators Z @operands -> $operator, $operand {
        if $operator.WHAT.perl ne 'Match' {
            die "expected operator to be of type `Match`";
        }
        my $op = $operator.ast;
        my @children = ($ast, $operand.ast);
        $ast = C::AST::Op.new(:$op, :@children);
    };
    return $ast;
}

our sub binop_from_rassoc(@operators, @operands) {
    # TODO
    return binop_from_lassoc(@operators, @operands);
}

our sub get_declarator_name(Match $decr --> Str) {
    my Match $ddecr1 = $decr<direct-declarator><direct-declarator-first>;
    my Str $name = $ddecr1<declarator> 
        ?? get_declarator_name($ddecr1<declarator>) 
        !! $ddecr1<ident><name>.Str;
    return $name;
}

our sub synthesize_declarator(
    C::AST::External $declarator,
    C::AST::External $designator --> C::AST::External) {
    
    $designator.children.unshift($declarator);
    my $ast = C::AST::ExternalOp.new(
        op => TyKind::declarator,
        children => $designator);
    return $ast;
}

our sub synthesize_declaration(
    C::AST::External $specifiers,
    C::AST::External $declarator --> C::AST::External) {
    
    our $ast = C::AST::Decl.new(
        type => $specifiers, 
        children => ($declarator,));
    #say $ast.perl;
    return $ast;
}

our sub synthesize_init_declarator(
    $value) {
    return $value;
}

our sub synthesize_init_declaration(
    C::AST::External $specifiers,
    @init_declarators --> C::AST::External) {
    
    my @inits = @init_declarators;
    our $ast = C::AST::Decl.new(
        type => $specifiers, 
        children => @inits);
    #say $ast.perl;
    return $ast;
}

our sub synthesize_struct_declaration(
    C::AST::External $specifiers,
    @struct_declarators --> C::AST::External) {
    
    my @fields = @struct_declarators;
    our $ast = C::AST::Decl.new(
        type => $specifiers, 
        children => @fields);
    #say $ast.perl;
    return $ast;
}
