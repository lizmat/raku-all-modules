sub EXPORT(|) {

  role MOSDEF::Grammar {
    rule routine_declarator:sym<sub> {
        [ 'sub' | 'lambda' | 'λ' ] <routine_def('sub')>
    }
    rule routine_declarator:sym<method> {
        [ 'def' | 'method' ] <method_def('method')>
    }
  }

  $*LANG.define_slang: 'MAIN',
    $*LANG.slang_grammar('MAIN').^mixin(MOSDEF::Grammar),
    $*LANG.actions;

  {}
}
