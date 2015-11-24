use v6;

BEGIN { @*INC.unshift('lib') };

use Test;
plan 8;

use HTTP::Router::Blind;
ok 1, "'use HTTP::Router::Blind' worked";


my $router = HTTP::Router::Blind.new();
ok 1, "creating new router worked";


my %env;
my $result;

## string route
$router.get('/about', sub (%env) {
    'this-is-get'
});

$result = $router.dispatch('GET', '/about', %env);
if $result ~~ 'this-is-get' {
    ok 1, "basic string route worked";
};


# Regex route with named capture group
$router.get(/\/items\/$<id>=(.*)/, sub (%env, $params) {
    $params<id>;
});

$result = $router.dispatch('GET', '/items/4221', %env);
if $result ~~ '4221' {
    ok 1, "regex with named capture group worked";
};


# Regex route with positional capture group
$router.get(/\/reg\/(.*)\/(.*)/, sub (%env, $params) {
    $params[0], $params[1]
});

$result = $router.dispatch('GET', '/reg/aaa/bbb', %env);
if $result[0] eq 'aaa' &&  $result[1] eq 'bbb' {
    ok 1, "regex with positional capture group worked";
};


# test the not-found behaviour
$result = $router.dispatch('GET', '/nothing', %env);
if $result[0] == 404 {
    ok 1, "not found works";
};


# check how anymethod behaves
$router.anymethod('/somewhere', sub (%env) {
    return True;
});
$result = $router.dispatch('PUT', '/somewhere', %env);
if $result == True {
    ok 1, "any works";
};


# check multi-handlers
sub checker (%env) {
    %env<checked> = True;
    %env;
}
$router.get('/check', &checker, sub (%env) {
    %env;
});
$result = $router.dispatch('GET', '/check', %env);
if $result<checked> == True {
    ok 1, "multi-handlers works";
}
