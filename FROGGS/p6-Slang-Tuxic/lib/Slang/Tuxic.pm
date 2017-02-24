use nqp;
use NQPHLL:from<NQP>;

sub EXPORT(|) {
    sub atkeyish(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }
    my role Tuxic {
        token routine_declarator:sym<sub> {
            :my $*LINE_NO := HLL::Compiler.lineof(self.orig(), self.from(), :cache(1));
            <sym> <.end_keyword>? <routine_def('sub')>
        }
        token term:sym<identifier> {
            :my $pos;
            <identifier>
            <!{
                my $ident = atkeyish($/, 'identifier').Str;
                $ident eq 'sub'|'if'|'elsif'|'while'|'until'|'for' || $*W.is_type([$ident])
            }>
            <?before <.unsp>|\s*'('> \s* <![:]>
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
    my Mu $MAIN-grammar := nqp::atkey(%*LANG, 'MAIN');
    my $grammar := $MAIN-grammar.HOW.mixin($MAIN-grammar, Tuxic);


    # old way
    try nqp::bindkey(%*LANG, 'MAIN', $grammar);
    # new way
    try $*LANG.define_slang('MAIN', $grammar, $*LANG.actions);

    {}
}
