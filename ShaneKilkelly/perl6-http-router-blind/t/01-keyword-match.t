use v6;

use lib 'lib';

use Test;
plan 5;

use HTTP::Router::Blind;

my %env;
my $result;
my $router = HTTP::Router::Blind.new();

# simple, one keyword
$router.get: '/one/:name', -> %env, %params {
    %params<name>;
};

$result = $router.dispatch: 'GET', '/one/jim', %env;
ok $result eq 'jim', 'basic keyword match works';


# multi-keyword route
$router.get: "/stuff/:id/thing/:foo", -> %env, %params {
    %params;
};

$result = $router.dispatch: 'GET', "/stuff/422/thing/wat", %env;
ok $result<id> eq '422' && $result<foo> eq 'wat', "keyword match works";

$result = $router.dispatch: 'GET', "/no/423/not/wait", %env;
ok $result[0] == 404, "keyword match should not work on wrong path";


# multi-handlers with keyword params
sub checker (%env, %params) {
    if %params<thing> eq "yes" {
        %env<checked> = True;
    }
    %env;
}
$router.get: '/othercheck/:thing', &checker, -> %env, %params {
    %env;
};

$result = $router.dispatch('GET', '/othercheck/yes', %env);
ok $result<checked> == True, 'multi-handler with keyword params works';


# realistic example
$router.get(
    '/project/:projectId/document/:docId/attachment/:attachmentId',
    -> %env, %params {
        my $project-id = %params<projectId>;
        my $doc-id = %params<docId>;
        my $attachment-id = %params<attachmentId>;
        my $content = "$project-id - $doc-id - $attachment-id";
        [200, ['Content-Type' => 'text/plain'], [$content]];
    }
);

$result = $router.dispatch: 'GET', '/project/2/document/8/attachment/ba4e5d', %env;
ok $result[2] == ['2 - 8 - ba4e5d'], 'realistic example works';
