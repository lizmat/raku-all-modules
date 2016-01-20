use CompUnit::Util :mixin_LANG;
use Test;

plan 2;

{
    use nqp;
    use QAST:from<NQP>;
    use MONKEY-SEE-NO-EVAL;

    BEGIN mixin_LANG(
        grammar => role {
            token term:sym<foo> { <sym> <.tok> }
        },
        actions => role {
            method term:sym<foo>(Mu $/){
                return $/.'!make'(QAST::SVal.new(:value("FOO")));
            }
       }
    );

    is foo,'FOO', 'slang works';
    is EVAL('foo'),'FOO','slang works in eval';
}
