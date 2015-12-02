use v6;
use Test;
use JavaScript::SpiderMonkey;


sub no-error()
{
    try JavaScript::SpiderMonkey::js-context.error;
    return defined $!;
}


ok no-error, 'no error happened yet';


lives-ok { js-eval('') }, 'empty code lives';
ok no-error, 'no error happened';


throws-like { js-eval('syntax error') }, X::JavaScript::SpiderMonkey,
            'syntax error dies';
ok no-error, 'error was cleared';


try { js-eval('throw "error";') };
ok   $!.defined, 'uncaught exception propagates';
like $!.message, /uncaught/, 'correct exception thrown';


lives-ok { js-eval('try { throw "catch me"; } catch (e) { }') },
         'catching exception lives';
ok no-error, 'error is not set';


done-testing
