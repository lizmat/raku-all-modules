# Web::RF #

See https://github.com/retupmoca/egeler.us for a more comprehensive example.

Web::RF is a simple routing web framework designed to work with Crust. It attempts
to decouple your controller code from the URL's used to access them.

Note that this framework doesn't handle data storage or templating - it simply
gets program flow into one of your controllers and lets you do whatever is needed.

```
# Site/Root.pm6
use Web::RF;

use Page::Home;
# etc

unit class Site::Root is Web::RF::Router;

# the route strings here are passed to Path::Router, so any of the variable
# features in that package can be used here
method routes {
    $.route('', Page::Home); # Web::RF::Controller class
    $.route('login', Page::Login);
    $.route('blog/', Site::Blog); # can include other Web::RF::Routers to create trees
    $.route('redirect', Web::RF::Redirect.new(301, '/blog/'));
}

# gets called before every request is routed
method before(:$request) {
    return Web::RF::Redirect.go(301, 'https://my-site.com'~$request.request-uri) unless $request.secure; # force https
}

method error(:$request, :$exception) {
    given $exception {
        when X::NotFound {  # will return an empty 404 response if not handled
            return Page::NotFound.handle(:$request);
        }
        when X::BadRequest { # will return an empty 400 response if not handled
            return Page::BadRequest.handle(:$request);
        }
        default {   # will rethrow the exception if not handled
            return Page::ShowError.handle(:$request, :$exception);
        }
    }
}
```

```
# Page/Home.pm6
use Web::RF;

unit class Page::Home is Web::RF::Controller;

# %mapping is the mapping created by Path::Router (for variables in the URL)
method handle(:$request, :%mapping) {
    return [200, [ Content-Type => 'text/html' ], [ $content-here ]];
}
```

```
# bin/app.p6sgi
use Web::RF;
use Site::Root;

my $webrf = Web::RF.new(:root(Site::Root.new));

my $app = sub (%env) { $webrf.handle(%env) };
```
