use v6;

use WebService::GitHub::Role;

class WebService::GitHub::Gist does WebService::GitHub::Role {
    method public_gists {
        self.request('/gists/public')
    }

    method user_gists($user?) {
        self.request($user ?? '/users/' ~ $user ~ '/gists' !! '/gists')
    }

    method starred_gists {
        self.request('/gists/starred')
    }

    method gist($id) {
        self.request('/gists/' ~ $id)
    }

    method create_gist(%data) {
        self.request('/gists', 'POST', :data(%data));
    }

    method update_gist($id, %data) {
        self.request('/gists/' ~ $id, 'PATCH', :data(%data));
    }

    method delete_gist($id) {
        self.request('/gists/' ~ $id, 'DELETE');
    }
}