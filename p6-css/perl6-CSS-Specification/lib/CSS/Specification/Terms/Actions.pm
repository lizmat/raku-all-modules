use v6;

class CSS::Specification::Terms::Actions {

    use CSS::Grammar::AST :CSSValue;

    has @._proforma;

    method decl($/, :@proforma = @._proforma ) {

        my %ast;

        %ast<ident> = $0.trim.lc
            if $0;

        if $<val> {
            my $val = $<val>.ast;

            if $val<usage> {
                my $synopsis := $val<usage>;
                $.warning( ('usage ' ~ $synopsis, @proforma).flat.join: ' | ');
                return Any;
            }
            elsif ! $val<expr> {
                $.warning('dropping declaration', %ast<ident>);
                return Any;
            }

            %ast<expr> = $val<expr>;
        }

        return %ast;
    }

    method val($/) {
        my %ast;

        if $<usage> {
            %ast<usage> = $<usage>.ast;
        }
        elsif $<proforma> {
            my $expr = $<proforma>.ast;
            %ast<expr> = [$expr]
                if $expr;
        }
        else {
            my $m = $<rx><expr>;
            unless $m &&
                ($m.can('caps') && (!$m.caps || $m.caps.grep({! .value.ast.defined}))) {
                    my $expr-ast = $.list($m);

                    %ast<expr> = $expr-ast;
            }
        }

        make %ast;
    }

    method usage($/) {
        make ~ $*USAGE;
    }

    use CSS::Grammar::AST;

    # ---- CSS::Grammar overrides ---- #

    method any-function($/)             {
        return callsame if $.lax;
        $.warning('ignoring function', $<Ident>.ast.lc);
    }

    method declaration($/)  {

        if $<any-declaration> {
            my $ast = $<any-declaration>.ast;
            if $ast.defined {
                my ($key, $value) = $ast.kv;
                if $.lax {
                    make {($key ~ ':unknown') => $value}
                }
                else {
                    $.warning('dropping unknown property',
                              $value<at-keyw> ?? '@'~$value<at-keyw> !! $value<ident>);
                }
            }
            return;
        }
        
        my %ast = %( $.decl( $<decl> ) );
        return Any
            unless +%ast;

        if $<any-arg> {
            return $.warning("extra terms following '{%ast<ident>}' declaration",
                             ~$<any-arg>, 'dropped');
        }

        if (my $prio = $<prio> && $<prio>.ast) {
            %ast<prio> = $prio;
        }
        

        make $.token( %ast, :type(CSSValue::Property) );
    }

    method proforma:sym<inherit>($/) { make (:keyw<inherit>) }
    method proforma:sym<initial>($/) { make (:keyw<initial>) }

    #---- Language Extensions ----#

    method length:sym<zero>($/) {
        make $.token(0, :type(CSSValue::LengthComponent))
    }

    method angle:sym<zero>($/) {
        make $.token(0, :type(CSSValue::AngleComponent))
    }

    has Hash $.colors = %CSS::Grammar::AST::CSS21-Colors;

   method color:sym<named>($/) {
        my $color-name = $<keyw>.ast.value;
        my @rgb = @( $.colors{$color-name} )
            or die "unknown color: " ~ $color-name;

        my $num-type = CSSValue::NumberComponent;
        my @color = @rgb.map: { $num-type.Str => $_ };

        make $.token(@color, :type<rgb>);
    }

    method integer($/)     {
        my $val = $<uint>.ast;
        $val = -$val
            if $<sign> && $<sign> eq '-';
        make $.token($val, :type(CSSValue::IntegerComponent))
    }

    method number($/)      { make $.token($<num>.ast, :type(CSSValue::NumberComponent)) }
    method uri($/)         { make $<url>.ast }
    method keyw($/)        { make $.token($<id>.lc, :type(CSSValue::KeywordComponent)) }
    # case sensitive identifiers
    method identifier($/)  { make $.token($<name>.ast, :type(CSSValue::IdentifierComponent)) }
    # identifiers strung-together, e.g New Century Schoolbook
    method identifiers($/) { make $.token( $<identifier>.map({ .ast.value }).join(' '), :type(CSSValue::IdentifierComponent)) }
}
