use v6;
use Test;
use lib '../t/lib';
plan *;

#%*ENV<CGI_APP_RETURN_ONLY> = 1;

# RAKUDO workaround:
# setting ENV variables fails (WTF?), so let's use a dynamic variable instead
my $*CGI_APP_RETURN_ONLY = 1;

use lib <t/lib lib>;

use CGI::Application;


sub response-like($app, Mu $header, Mu $body, $comment,
        :$todo-header, :$todo-body) {
    my $output = $app.run;
    my @hb = $output.split(rx{\r?\n\r?\n});
    todo($todo-header) if $todo-header;
    ok ?(@hb[0] ~~ $header), "$comment (header)" or diag "Got: @hb[0].perl()";
    todo($todo-body) if $todo-body;
    ok ?(@hb[1] ~~ $body),   "$comment (body)"   or diag "Got: @hb[1].perl()";
}

{
    my $app = CGI::Application.new;
    isa-ok $app, CGI::Application;
    # TODO: make that CGI.new
    $app.query = {};
    response-like($app,
        rx{^ 'Content-Type: text/html'},
        rx{ 'Query parameters:' },
        'base class response',
    );
}

use TestApp;
{
    my $app = TestApp.new();
    isa-ok $app, CGI::Application;

    response-like(
        $app,
        rx{^'Content-Type: text/html'},
        rx{'Hello World: basic_test'},
        'TestApp, blank query',
    );
}

{
    dies-ok { TestApp.new(query => [1, 2, 3]) },
            'query is restricted to Associative';
}

{
    my $app = TestApp.new(query => { test_rm => 'redirect_test' });
    response-like(
        $app,
        rx{^'Status: 302'},
        rx{^'Hello World: redirect_test'},
        'TestApp, redirect_test',
    );
}

{
    my $app = TestApp.new;
    $app.query = { test_rm => 'dump_txt' }
    response-like(
        $app,
        rx{^'Content-Type: text/html'},
        rx{'Query parameter'},
        'TestApp, dump_text',
    );
}

skip('Cookies') for ^3;
if 0 {
    my $app = TestApp.new(query => { test_rm => 'cookie_test' });

    response-like(
        $app,
        rx{ ^^'Set-Cookie: c_name=c_value' },
        rx{ 'Hello World: cookie_test' },
        'TestApp, cookie test',
    );
}

# TODO: template tests


{
    my $error_hook_called = 0;
    my $error_mode_called = 0;
    class TestAppWithError is CGI::Application {
        submethod BUILD { self.run-modes<throws_error> = 'throws_error' };
        method throws_error() {
            die "OH NOEZ";
        }
        method error(*@args) {
            $error_hook_called++;
        }
        method my_error_mode(*@args) {
            $error_mode_called++;
        }
    }

    my $app = TestAppWithError.new(query => { rm => 'throws_error' });

    dies-ok { $app.run() },
        'when the run mode dies, the whole execution aborts';
    ok $error_hook_called, 'and the error hook was called';
    nok $error_mode_called, '... but error mode was not set';

    # now test with error mode too
    $error_hook_called = 0;
    $error_mode_called = 0;
    $app.error-mode = 'my_error_mode';
    lives-ok { $app.run() }, 'Lives when run mode dies and error mode is set';
    ok $error_hook_called, 'Error hook was called';
    ok $error_mode_called, 'Error mode was called too';
}

{
    my $tracker = '';
    class WithHook is CGI::Application {
        submethod BUILD   { self.run-modes<doit> = 'doit' }
        method prerun($)  { $tracker ~= 'prerun'    }
        method postrun($) { $tracker ~= ' postrun'  }
        method doit()     { $tracker ~= ' doit'; 42 }
        method teardown() { $tracker ~= ' teardown'; }
    }
    my $app = WithHook.new(query => { rm => 'doit' });
    response-like(
        $app,
        rx{^'Content-Type: text/html'},
        42,
        'WithHook',
    );
    is $tracker, 'prerun doit postrun teardown',
        'all hooks were called in the right order';
}

{
    class CallbackRunMode is CGI::Application {
        submethod BUILD {
            self.start-mode = 'default_mode';
            self.mode-param = {
                my $rm = self.query<go_to_mode>;
                $rm eq 'undef_rm' ?? Any !! $rm;
            };
            self.run-modes = (
                subref_modeparam => { 'Hello World: subref_modeparam OK' },
                ''               => { 'Hello World: blank_mode OK' },
                0                => { 'Hello World: zero_mode OK' },
                default_mode     => { 'Hello World: default_mode OK' },
            );
        }
    }
    response-like(
        CallbackRunMode.new(query => {go_to_mode => 'subref_modeparam'}),
        rx{^'Content-Type: text/html'},
        rx{'Hello World: subref_modeparam OK'},
        'callable mode param',
    );
    response-like(
        CallbackRunMode.new(query => {go_to_mode => '0'}),
        rx{^'Content-Type: text/html'},
        rx{'Hello World: zero_mode OK'},
        '0 as run mode',
    );
    response-like(
        CallbackRunMode.new(query => {go_to_mode => ''}),
        rx{^'Content-Type: text/html'},
        rx{'Hello World: default_mode OK'},
        'empty string as run mode triggers fallback to start_mode',
    );
    response-like(
        CallbackRunMode.new(query => {go_to_mode => 'undef_rm'}),
        rx{^'Content-Type: text/html'},
        rx{'Hello World: default_mode OK'},
        'undefined run mode triggers fallback to start_mode',
    );
}

done-testing;

# vim: ft=perl6
