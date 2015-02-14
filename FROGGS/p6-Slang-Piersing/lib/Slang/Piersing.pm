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
    nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, Piersing));

    {}
}
