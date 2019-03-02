use v6;

class X::Smack::Builder is Exception { }

class X::Smack::Builder::NoBuilder is X::Smack::Builder {
    has Str $.sub;

    method message() {
        "$.sub must be called inside a builder \{} block"
    }
}

class X::Smack::Builder::NoApp is X::Smack::Builder {
    method message() {
        'no application to build. Your builder {} block must either use mount() or return an app';
    }
}

# Catching this will result in an app where all the mount() apps are ignored.
# Plack treated this as a warning. I treat it as an error for two reasons:
#   (1) It really implies a mistake that will cause confusion, even with the
#       warning. We might as well stop execution.
#   (2) Exception handling in Perl 6 is amazingly better than Perl 5, so if they
#       really feel like doing this for some reason, let them catch the
#       exception and live with the consequences.
class X::Smack::Builder::UselessMount is X::Smack::Builder {
    method message() {
        "you used mount() in a builder \{} block, but the result of the block is an app, which hides all mounts; if this is deliberate, please catch the $?PACKAGE.perl() exception and .resume"
    }
}

class Smack::Builder {
    use Smack::App::URLMap;

    has Callable @.builder-cbs;
    has Smack::App::URLMap $!urlmap;

    multi method add-middleware(&builder-cb) {
        push @.builder-cbs, &builder-cb;
        return;
    }

    multi method add-middleware($mw-class, |args) {
        self.add-middleware: -> &app {
            $mw-class.wrap-that(&app, |args);
        }
    }

    multi method add-middleware-if(Mu $cond, &builder-cb) {
        use Smack::Middleware::Conditional;

        push @.builder-cbs, -> &app {
            Smack::Middleware::Conditional.wrap-that(&app,
                condition => $cond,
                builder   => &builder-cb,
            );
        }

        return;
    }

    multi method add-middleware-if(Mu $cond, $mw-class, |args) {
        self.add-middleware-if: $cond, -> &app {
            $mw-class.wrap-that(&app, |args);
        }
    }

    multi method mount($location, &app) {
        $!urlmap .= new without $!urlmap;
        $!urlmap.mount($location, &app);
        return;
    }

    multi method mount($location, $app where *.^can('to-app')) {
        self.mount($location, $app.to-app);
    }

    method is-mount-used() { defined $!urlmap }

    # This should work fine if you want to allow mount() and an app in your
    # build block. The consequence is that all mount()s are ignored.
    # CATCH { when X::Smack::Builder::UselessMount { .resume } }
    method to-app($app?) {
        with $app {
            die X::Smack::Builder::UselessMount.new
                if $.is-mount-used;

            self.wrap-that($app);
        }
        elsif $.is-mount-used {
            self.wrap-that($!urlmap.to-app);
        }
        else {
            die X::Smack::Builder::NoApp.new;
        }
    }

    method wrap-that(&app is copy) {
        for @.builder-cbs.reverse -> &builder-cb {
            &app = builder-cb(&app);
        }

        &app;
    }
}

proto enable(|) is export { * }
multi enable(&builder-cb) {
    with $*SMACK-BUILDER {
        .add-middleware(&builder-cb);
    }
    else {
        die X::Smack::Builder::NoBuilder.new(sub => "enable");
    }
}

multi enable($mw-class, |args) {
    with $*SMACK-BUILDER {
        .add-middleware($mw-class, |args);
    }
    else  {
        die X::Smack::Builder::NoBuilder.new(sub => "enable");
    }
}

proto enable-if(|) is export { * }
multi enable-if(Mu $match, &builder-cb) {
    with $*SMACK-BUILDER {
        .add-middleware-if($match, &builder-cb)
    }
    else {
        die X::Smack::Builder::NoBuilder.new(sub => "enable-if");
    }
}

multi enable-if(Mu $match, $mw-class, |args) {
    with $*SMACK-BUILDER {
        .add-middleware-if($match, $mw-class, |args);
    }
    else {
        die X::Smack::Builder::NoBuilder.new(sub => "enable-if");
    }
}

sub mount(Pair $map) is export {
    with $*SMACK-BUILDER {
        .mount($map.key, $map.value);
    }
    else {
        die X::Smack::Builder::NoBuilder.new(sub => "mount");
    }
}

sub builder(&build-block) is export {
    my $*SMACK-BUILDER = Smack::Builder.new;

    my $app = build-block();

    $app = $app.to-app if $app.defined && $app.^can('to-app');

    $*SMACK-BUILDER.to-app($app);
}
