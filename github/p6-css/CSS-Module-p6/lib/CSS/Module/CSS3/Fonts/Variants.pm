use CSS::Grammar::CSS3;

grammar CSS::Module::CSS3::Fonts::Variants {

    rule feature-value-name  { <identifier> }
    rule feature-value-item  { <feature-value-name> }
    rule feature-value-list  { <feature-value-name> +% ',' }

    rule annotation                {:i ('annotation')'('        [<args=.feature-value-item>  || <any-args>] ')'}
    rule character-variant         {:i ('character-variant')'(' [<args=.feature-value-list>  || <any-args>] ')'}
    rule ornaments                 {:i ('ornaments')'('         [<args=.feature-value-item>  || <any-args>] ')'}
    rule stylistic                 {:i ('stylistic')'('         [<args=.feature-value-item>  || <any-args>] ')'}
    rule styleset                  {:i ('styleset')'('          [<args=.feature-value-list>  || <any-args>] ')'}
    rule swash                     {:i ('swash')'('             [<args=.feature-value-item>  || <any-args>] ')'}

    rule common-lig-values         {:i [ common\-ligatures | no\-common\-ligatures ] & <keyw> }
    rule discretionary-lig-values  {:i [ discretionary\-ligatures | no\-discretionary\-ligatures ] & <keyw> }
    rule historical-lig-values     {:i [ historical\-ligatures | no\-historical\-ligatures ] & <keyw> }
    rule contextual-alt-values     {:i [ contextual | no\-contextual ] & <keyw> }
    rule numeric-figure-values     {:i [ lining\-nums | oldstyle\-nums ] & <keyw> }
    rule numeric-spacing-values    {:i [ proportional\-nums | tabular\-nums ] & <keyw> }
    rule numeric-fraction-values   {:i [ diagonal\-fractions | stacked\-fractions ] & <keyw> }

    rule east-asian-variant-values {:i [ jis78 | jis83 | jis90 | jis04 | simplified | traditional ] & <keyw> }
    rule east-asian-width-values   {:i [ full\-width | proportional\-width ] & <keyw> }

    rule feature-tag-value {:i <string> [ <integer> | [ on | off ] & <keyw> ]? }
    rule urange {:i <unicode-range> }
}

# ----------------------------------------------------------------------

class CSS::Module::CSS3::Fonts::Variants::Actions {

    method feature-value-name($/) { make $<identifier>.ast }
    method feature-value-item($/) { make $.list($/) }
    method feature-value-list($/) { make $.list($/) }

    method annotation($/)        { make $.func( $0.lc, $<args>.ast ) }
    method character-variant($/) { make $.func( $0.lc, $<args>.ast ) }
    method ornaments($/)         { make $.func( $0.lc, $<args>.ast ) }
    method stylistic($/)         { make $.func( $0.lc, $<args>.ast ) }
    method styleset($/)          { make $.func( $0.lc, $<args>.ast ) }
    method swash($/)             { make $.func( $0.lc, $<args>.ast ) }

    method common-lig-values($/) { make $<keyw>.ast }
    method discretionary-lig-values($/) { make $<keyw>.ast }
    method historical-lig-values($/) { make $<keyw>.ast }
    method contextual-alt-values($/) { make $<keyw>.ast }
    method numeric-figure-values($/) { make $<keyw>.ast }
    method numeric-spacing-values($/) { make $<keyw>.ast }
    method numeric-fraction-values($/) { make $<keyw>.ast }
    method east-asian-variant-values($/) { make $<keyw>.ast }
    method east-asian-width-values($/) { make $<keyw>.ast }

    method feature-tag-value($/) { make $.token( $.list($/), :type<expr:feature-tag-value>) }
    method urange($/) { make $<unicode-range>.ast }
}
