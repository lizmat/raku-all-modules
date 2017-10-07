use v6;

use WebService::GitHub::Role;
use WebService::GitHub::OAuth;

class WebService::GitHub does WebService::GitHub::Role {
    # does WebService::GitHub::Role::Debug if %*ENV<DEBUG_GITHUB>;

}

sub rate-limit-remaining(--> Str) is export {
    # make a "free" rate-limit request:
    #   GET /rate_limit
    my $c = WebService::GitHub.new;
    my $resp = $c.request('/rate_limit');
    return $resp.x-ratelimit-remaining;
}
