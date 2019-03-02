use v6;

use Smack::Client::Request;

my constant DEFAULT-CONFIG =
    'p6w.version'          => v0.7.Draft,
    'p6w.errors'           => Supplier.new,
    'p6w.multithread'      => False,
    'p6w.multiprocess'     => False,
    'p6w.run-once'         => True,
    'p6w.protocol.support' => set('request-response'),
    'p6w.protocol.enabled' => SetHash.new('request-response'),
    ;

class Smack::Test { ... }

class Smack::TestFactory {

    our $DEFAULT_IMPL_NAME = %*ENV<SMACK_TEST_IMPL> // "MockHTTP";

    has $.class;
    has %.config = DEFAULT-CONFIG;

    submethod BUILD(:$name = $DEFAULT_IMPL_NAME, :$!class) {
        without $!class {
            my $DEFAULT_IMPL_CLASS = "Smack::Test::$name";
            require ::($DEFAULT_IMPL_CLASS);
            $!class = ::($DEFAULT_IMPL_CLASS);
        }
    }

    method create(&app, *%args --> Smack::Test:D) {
        $.class.new(:&app, |%args);
    }

}

class Smack::Test {
    our $DEFAULT_TEST_FACTORY;

    has &.app;
    has %.config = DEFAULT-CONFIG;

    method run-config(:&app = &!app, :%config = %!config) {
        if &app.returns ~~ Callable {
            # cache the result so we only configure once
            &!app = app(%config);
            &!app;
        }
        else {
            &app;
        }
    }

    method run-app(%env, :&app = &!app, :%config = %!config) {
        my &the-app := self.run-config(:&app, :%config);
        the-app(%env);
    }

    multi method request(Smack::Client::Request $request --> Promise:D) {
        self.request($request, %.config);
    }

    multi method request(Smack::Client::Request $request, %config --> Promise:D) { ... }

    my sub test-factory { $*TEST_FACTORY // ($DEFAULT_TEST_FACTORY //= Smack::TestFactory.new) }

    proto test-p6wapi(|) is export { * };

    multi test-p6wapi($app where { .^can('to-app') }, &client) {
        samewith($app.to-app, &client);
    }

    multi test-p6wapi(&app, &client) {
        samewith(:&app, :&client);
    }

    multi test-p6wapi(:&app, :&client, *%args) {
        my $tester = test-factory.create(&app, |%args);
        client($tester);
    }
}
