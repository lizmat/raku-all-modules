sub EXPORT(|) {

    role AltTern::Grammar {
        # All of what follows is stolen from the Rakudo grammar - while only half knowing what I'm doing

        token term:sym<No>     { 'No' <?before \s> }  # actual error produced inside infix:<?⁈ No>

        token infix:sym<?⁈ No> {
            :my %conditional = ( :prec<j=> , :assoc<right> , :dba<conditional> , :fiddly<1> , :thunky<.tt> );
            :my $*GOAL := 'No';
            $<sym>='?⁈'
            <.ws> 'Yes' <.ws>
            <EXPR('i=')>
            [  
            || 'No'
            || { self.typed_panic: "X::Syntax::Confused", reason => "Confused: Found ?⁈ without 'No' clause" }
            ]
            <O(|%conditional, :reducecheck<ternary>, :pasttype<if>)>
        }
    }

    my Mu $MAIN-grammar := %*LANG<MAIN> ;
    my $extended-grammar := $MAIN-grammar.^mixin(AltTern::Grammar);
    # my Mu $MAIN-actions := %*LANG<MAIN-actions> ;
    # my $extended-actions := $MAIN-actions;

    $*LANG.define_slang('MAIN', $extended-grammar , %*LANG<MAIN-actions>);

    {}
}
