use nqp;

sub EXPORT(|) {

  role MOSDEF::Grammar {
    rule routine_declarator:sym<sub> {
        [ 'sub' | 'lambda' | 'λ' ] <routine_def('sub')>
    }
    rule routine_declarator:sym<method> {
        [ 'def' | 'method' ] <method_def('method')>
    }
  }

  nqp::bindkey(%*LANG,
    'MAIN',
    %*LANG<MAIN>.HOW.mixin(%*LANG<MAIN>,
    MOSDEF::Grammar));

  {}
}
