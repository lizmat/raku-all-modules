sub EXPORT(|) {
    my role Piersing {
        token identifier {
            <.ident> [ <.apostrophe> <.ident> ]* <[?!]>?
        }

        token name {
            [
            | <identifier> <morename>*
            | <morename>+
            ]
            <[?!]>?
        }
    }
    my Mu $MAIN-grammar := nqp::atkey(%*LANG, 'MAIN');
    nqp::bindkey(%*LANG, 'MAIN', $MAIN-grammar.HOW.mixin($MAIN-grammar, Piersing));

    {}
}
