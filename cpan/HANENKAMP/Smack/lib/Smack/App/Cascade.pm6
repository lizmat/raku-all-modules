use v6;

use Smack::Component;

unit class Smack::App::Cascade
does Smack::Component;

has Callable @.apps is rw;
has %.catch is rw = set(404);

sub cascade-app($p, :%env, :%catch, :@remaining-apps) {
    my (Int() $code) = $p.result;

    # Previous app failed, try the next
    if %catch{ $code } {
        my &next-app = shift @remaining-apps;

        # Only one left? Just run it as the final.
        if @remaining-apps == 0 {
            next-app(%env);
        }

        # More than one left, try it
        else {
            next-app(%env).then(-> $p {
                cascade-app($p, :%env, :%catch, :@remaining-apps);
            });
        }
    }

    # Previous app succeeded, return the result
    else {
        |$p.result;
    }
}

method configure(%config) {
    @.apps .= map({
        .returns ~~ Callable ?? .(%config) !! $_
    });
}

method call(%env) {

    # No apps to cascade, just return the 404
    unless @.apps {
        return start {
            404, [ Content-Type => 'text/plain' ], [ '404 Not Found' ];
        }
    }

    # Run the initial app and let cascade-app handle the outcome
    my @remaining-apps = @.apps;
    my &initial-app = shift @remaining-apps;
    initial-app(%env).then(
        &cascade-app.assuming(:%env, :%.catch, :@remaining-apps)
    );
}
