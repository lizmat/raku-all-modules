use v6;

use WebService::GitHub::Role;

class WebService::GitHub::Users does WebService::GitHub::Role {

    method show($user?) {
      self.request($user ?? '/users/' ~ $user !! '/user')
    }

    method update(%data) {
      self.request('/user', 'PATCH', :data(%data))
    }

    method add_email(%data) {
      self.request('/user/emails', 'POST', :data(%data));
    }

    method remove_email(%data) {
      self.request('/user/emails', 'DELETE', :data(%data));
    }

    method followers($user?) {
      self.request($user ?? "/users/" ~ $user ~ '/followers' !! '/user/followers');
    }

    method following($user?) {
      self.request($user ?? "/users/" ~ $user ~ '/following' !! '/user/following');
    }

    method emails {
      self.request('/user/emails');
    }

    method is_following($id) {
      self.request('/user/following/' ~ $id);
    }

    method follow($id) {
      self.request('/user/following/' ~ $id, 'PUT');
    }

    method unfollow($id) {
      self.request('/user/following/' ~ $id, 'DELETE');
    }

    method keys {
      self.request('/user/keys')
    }

    method key($id) {
      self.request('/user/keys/' ~ $id)
    }

    method create_key(%data) {
      self.request('/user/keys', 'POST', :data(%data))
    }

    method update_key($id, %data) {
      self.request('/user/keys/' ~ $id, 'PATCH', :data(%data))
    }

    method delete_key($id){
      self.request('/user/keys/' ~ $id, 'DELETE')
    }
}
