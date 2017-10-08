unit class HTTP::Router::Blind;

has %!routes = GET => @[],
               POST => @[],
               PUT => @[],
               DELETE => @[],
               ANY => @[];
has &!on-not-found = sub (%env) {
    [404, ['Content-Type' => 'text/plain'], 'Not found']
};

method get ($path, **@handlers) {
    %!routes<GET>.push(@($path, @handlers));
}

method post ($path, **@handlers) {
    %!routes<POST>.push(@($path, @handlers));
}

method put ($path, **@handlers) {
    %!routes<PUT>.push(@($path, @handlers));
}

method delete ($path, **@handlers) {
    %!routes<DELETE>.push(@($path, @handlers));
}

method anymethod ($path, **@handlers) {
    %!routes<ANY>.push(@($path, @handlers));
}

method !keyword-match ($path, $uri) {
    my @p = $path.split('/');
    my @u =  $uri.split('/');
    if @p.elems != @u.elems {
        return;
    }
    my @pairs = zip(@p, @u);
    my %params;
    for @pairs -> @pair {
        my $p = @pair[0];
        my $u = @pair[1];
        if $p ne $u && !$p.starts-with(":") {
            return;
        }
        if $p ne "" && $u ne "" {
            %params{$p.substr(1)} = $u;
        }
    }
    return %params;
}

method !apply-handlers (%env, @handlers) {
    my $result = %env;
    for @handlers -> &handler {
        $result = &handler($result);
    }
    $result;
}
method !apply-handlers-with-params (%env, @handlers, $params) {
    my $result = %env;
    for @handlers -> &handler {
        $result = &handler($result, $params);
    }
    $result;
}

method dispatch ($method, $uri, %env) {
    my @potential-matches;
    @potential-matches.append(@( %!routes<ANY> ));
    @potential-matches.append(@( %!routes{$method} ));
    for @potential-matches -> ($path, @funcs) {
        if $path ~~ Str {
            if $uri eq $path {
                return self!apply-handlers(%env, @funcs);
            }
            if $path.contains(':') {
                my $params = self!keyword-match($path, $uri);
                if $params {
                    return self!apply-handlers-with-params(%env, @funcs, $params);
                }
            }
        }
        if $path ~~ Regex {
            my $match = $uri.match: $path;
            if $match {
                return self!apply-handlers-with-params(%env, @funcs, $match);
            }
        }
    }
    return &!on-not-found(%env);
}
