sub EXPORT(|) {
    sub atkeyish(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    my role Tuxic {
        token term:sym<identifier> {
            :my $pos;
            <!before [sub|if|elsif|while|until|for] \s* '('>
            <identifier> <!{ $*W.is_type([atkeyish($/, 'identifier').Str]) }> <?before <.unsp>|\s*'('> \s* <![:]>
            { $pos := $/.CURSOR.pos }
            <args>
            { self.add_mystery(atkeyish($/, 'identifier'), atkeyish($/, 'args').from, nqp::substr(atkeyish($/, 'args').Str, 0, 1)) }
        }
        token methodop {
            [
            | <longname>
            | <?[$@&]> <variable> { self.check_variable(atkeyish($/, 'variable')) }
            | <?['"]>
                [ <!{$*QSIGIL}> || <!before '"' <-["]>*? [\s|$] > ] # dwim on "$foo."
                <quote>
                [ <?before '(' | '.(' | '\\'> || <.panic: "Quoted method name requires parenthesized arguments. If you meant to concatenate two strings, use '~'."> ]
            ] \s* <.unsp>?
            [
                [
                |  <?before  \s*'('>  \s* <args>
                | ':' <?before \s | '{'> <!{ $*QSIGIL }> <args=.arglist>
                ]
                || <!{ $*QSIGIL }> <?>
                || <?{ $*QSIGIL }> <?[.]> <?>
            ] <.unsp>?
        }
    }
    nqp::bindkey(%*LANG, 'MAIN', %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>, Tuxic));

    {}
}
