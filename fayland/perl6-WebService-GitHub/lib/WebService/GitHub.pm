use v6;

use WebService::GitHub::Role;
use WebService::GitHub::OAuth;

class WebService::GitHub does WebService::GitHub::Role {
    # does WebService::GitHub::Role::Debug if %*ENV<DEBUG_GITHUB>;

}