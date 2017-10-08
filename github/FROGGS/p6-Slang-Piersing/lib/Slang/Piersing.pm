use v6;
use nqp;

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

    $*LANG.define_slang: 'MAIN', $*LANG.slang_grammar('MAIN').^mixin: Piersing;
    {}
}
