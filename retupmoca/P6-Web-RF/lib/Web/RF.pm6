use v6;
use Crust::Request;
use Path::Router;
use URI::Escape;

class Web::RF::Router { ... };

class Web::RF::Request is Crust::Request {
    method host {
        $.env<HTTP_HOST> // $.env<SERVER_NAME> //  $.env<HOSTNAME> // 'localhost';
    } 
    method user-id {
        $.session.get('user-id');
    }
    method set-user-id($new?) {
        if $new {
            $.session.set('user-id', $new);
            #$.session.change-id = True;
        }
        else {
            $.session.remove('user-id');
        }
    }
}

subset Post of Web::RF::Request is export where { $_.method eq 'POST' };
subset Get of Web::RF::Request is export where { $_.method eq 'GET' };
subset Authed of Web::RF::Request is export where { so $_.user-id }; 
subset Anon of Web::RF::Request is export where { !($_.user-id) }; 

class X::BadRequest is Exception is export { }
class X::NotFound is Exception is export { }
class X::PermissionDenied is Exception is export { }

class Web::RF::Controller is export {
    has Web::RF::Router $.router is rw;
    multi method url-for(Web::RF::Controller $controller, *%params) {
        return $.router.url-for($controller, |%params);
    }
    multi method url-for(Str $controller, *%params) {
        return self.url-for(::($controller), |%params);
    }

    multi method handle {
        die X::BadRequest.new;
    }
}
class Web::RF::Controller::Authed is Web::RF::Controller is export {
    # we do nothing here; the handler code in Web::RF will do the dirty work
}

class Web::RF::Redirect is Web::RF::Controller is export {
    has Int $.code where { !$_.defined || $_ ~~ any(0, 301, 302, 303, 307, 308) };
    has Str $.url where { $_.chars > 0 };

    multi method new($code, $url) { self.new(:$code, :$url) }
    multi method new($url) { self.new(:code(0), :$url) }

    method handle() {
        $.code ?? 
          [ $.code, [ 'Location' => $.url ], []]
        !!
          $.url
        ;
    }

    multi method go(:$code, :$url!) { self.new(:$code, :$url).handle(); }
    multi method go($code, $url) { self.go(:$code, :$url) }
    multi method go($url) { self.go(:code(0), :$url) }
}

class Web::RF::Router::Route is Path::Router::Route {
    has @.query;
    method target-to-url(Web::RF::Controller $controller, *%params) {
        if self.target.WHAT eqv $controller.WHAT {
            my %used;
            my $good = True;
            for self.required-variable-component-names.keys -> $req {
                my $found = False;
                for %params.keys -> $param {
                    if $param eq $req {
                        $found = True;
                        %used{$req} = 1;
                        last;
                    }
                }
                unless $found {
                    $good = False;
                    last;
                }
            }
            unless $good {
                next;
            }

            for self.optional-variable-component-names.keys -> $req {
                my $found = False;
                for %params.keys -> $param {
                    if $param eq $req {
                        $found = True;
                        %used{$req} = 1;
                        last;
                    }
                }
            }

            for self.query -> $req is copy {
                if $req ~~ Bool && $req {
                    $req = 'query';
                }
                if $req ~~ Pair {
                    $req .= key;
                }
                my $found = False;
                for %params.keys -> $param {
                    if $param eq $req {
                        $found = True;
                        %used{$req} = 1;
                        last;
                    }
                }
            }

            for %params.keys {
                unless %used{$_} {
                    $good = False;
                    last;
                }
            }
            unless $good {
                next;
            }

            my $url = '';
            for self.components -> $comp {
                if !self.is-component-variable($comp) {
                    my $name = $comp;
                    $url ~= '/' ~ $name;
                }
                else {
                    my $name = self.get-component-name($comp);
                    if %params{$name}:exists {
                        $url ~= '/' ~ uri-escape(%params{$name});
                    }
                }
            }
            my @query-ret;
            for self.query -> $q {
                if $q ~~ Bool && $q {
                    @query-ret.push(uri-escape(%params<query>)) if %params<query>:exists;
                }
                elsif $q ~~ Pair {
                    @query-ret.push(uri-escape(%params{$q.key})) if %params{$q.key}:exists;
                }
                else {
                    @query-ret.push($q~'='~uri-escape(%params{$q})) if %params{$q}:exists;
                }
            }
            $url ~= '?' ~ @query-ret.join('&') if @query-ret;

            return $url;
        }
    }
}
class Web::RF::Router is export {
    has Path::Router    $.router;
    has Web::RF::Router $.parent is rw;

    submethod BUILD {
        $!router = Path::Router.new(:route-class(Web::RF::Router::Route));
        self.routes();
    }

    method match(Str $path) {
        $!router.match($path);
    }
    multi method url-for(Web::RF::Controller $controller, *%params) {
        if $.parent {
            return $.parent.url-for($controller, |%params);
        }

        for $!router.routes {
            my $url = $_.target-to-url($controller, |%params);
            return $url if $url.defined;
        }
        die "No url found.";
    }
    multi method url-for(Str $controller, *%params) {
        return self.url-for(::($controller), |%params);
    }

    multi method route(Str $path, Web::RF::Controller $target, :$query) {
        my @query = $query.list if $query;
        my $t = $target.defined ?? $target !! $target.new;
        $t.router = self;
        $!router.add-route($path, target => $t, :query(@query));
    }
    multi method route(Str $path, Web::RF::Router:D $target) {
        $target.parent = self;
        $!router.include-router($path => $target.router);
    }
    multi method route(Str $path, Web::RF::Router:U $target) {
        self.route($path, $target.new);
    }

    method routes {
        !!!;
    }

    method before(:$request) { }
    method error(:$request, :$exception) { }
}

class Web::RF is export {
    has Web::RF::Router $.root;
    has $.request-class = Web::RF::Request;

    method app(*%params) {
        my $webrf = self.new(|%params);
        return sub (%env) { $webrf.handle(%env); };
    }

    method handle(%env) {
        my $request = $.request-class.new(%env);
        
        my $uri = $request.request-uri.subst(/\?.+$/, '');

        loop {
            my $resp = $.root.before(:$request);
            unless $resp {
                my $page = $.root.match($uri);
                if $page {
                    if $page.target ~~ Web::RF::Controller::Authed && $request ~~ Anon {
                        die X::PermissionDenied.new;
                    }

                    my %mapping = $page.mapping;
                    my $params = $request.query-parameters;
                    for $page.route.query -> $p {
                        if $p ~~ Bool && $p {
                            %mapping<query> = $request.query-string;
                        }
                        elsif $p ~~ Pair {
                            %mapping{$p.key} = $request.query-string;
                        }
                        elsif $p ~~ Str {
                            %mapping{$p} = $params{$p};
                        }
                        else {
                            die "Unknown query option: "~$p;
                        }
                    }

                    if $page.target ~~ Web::RF::Controller {
                        $resp = $page.target.handle(:$request, |%mapping);
                    }
                    elsif $page.target ~~ Callable {
                        $resp = $page.target.(:$request, |%mapping);
                    }
                    else {
                        die "No valid target found.";
                    }
                }
                else {
                    die X::NotFound.new;
                }
            }
            # allow internal redirects
            return $resp unless $resp ~~ Str;
            $uri = $resp;
        }

        CATCH {
            when X::BadRequest {
                return $.root.error(:$request, :exception($_)) || [400, [], []];
            }
            when X::NotFound {
                return $.root.error(:$request, :exception($_)) || [404, [], []];
            }
            when X::PermissionDenied {
                return $.root.error(:$request, :exception($_)) || [403, [], []];
            }
            default {
                return $.root.error(:$request, :exception($_)) || $_.rethrow;
            }
        }
    }
}
