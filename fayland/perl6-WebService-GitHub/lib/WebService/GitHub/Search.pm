use v6;

use WebService::GitHub::Role;

class WebService::GitHub::Search does WebService::GitHub::Role {
    method repositories(%data) {
        self.request('/search/repositories', :data(%data))
    }

    method code(%data) {
        self.request('/search/code', :data(%data))
    }

    method issues(%data) {
        self.request('/search/issues', :data(%data))
    }

    method users(%data) {
        self.request('/search/users', :data(%data))
    }
}