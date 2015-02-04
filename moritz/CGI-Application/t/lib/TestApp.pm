use v6;
use CGI::Application;

class TestApp is CGI::Application {
    method BUILD {
        $.start-mode = 'basic_test';
        $.mode-param = 'test_rm';
        for <basic_test redirect_test> {
            %.run-modes{$_} = $_;
        }
        %.run-modes<dump_txt> = 'dump';

        %.query<last_orm> = 'teardown';
    }

    method basic_test { 'Hello World: basic_test' }

    method redirect_test {
        $.header-type = 'redirect';
        %.header-props = ( url => 'http://perl6.org/');

        return 'Hello World: redirect_test';
    }
}
