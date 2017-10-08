use v6;

use WebService::GitHub::Role;

class WebService::GitHub::OAuth does WebService::GitHub::Role {
    method authorizations {
        self.request('/authorizations')
    }

    method authorization($id) {
        self.request('/authorizations/' ~ $id);
    }

    method create_authorization(%data) {
        self.request('/authorizations', 'POST', :data(%data));
    }

    method create_app_authorization($client_id, %data, :$fingerprint) {
        my $url = '/authorizations/clients/' ~ $client_id;
        $url = $url ~ '/' ~ $fingerprint if $fingerprint.defined;
        self.request($url, 'PUT', :data(%data));
    }

    method update_authorization($id, %data) {
        self.request('/authorizations/' ~ $id, 'PATCH', :data(%data));
    }

    method delete_authorization($id) {
        self.request('/authorizations/' ~ $id, 'DELETE');
    }
}