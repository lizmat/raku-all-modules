use v6;

unit module Sparrowdo::Core::DSL::User;

use Sparrowdo;

sub user-create ( $user_id ) is export {

    task_run  %(
      task => "create user $user_id",
      plugin => 'user',
      parameters => %(
        name        => $user_id,
        action      => 'create',
      )
    );

}

multi sub user ( $user_id, %args ) is export {

    my $action = %args<action>;

    task_run  %(
      task => "$action user $user_id",
      plugin => 'user',
      parameters => %(
        name        => $user_id,
        action      => $action,
      )
    );

}

multi sub user ( $user_id )  is export { user-create $user_id }

sub user-delete ( $user_id ) is export {

    task_run  %(
      task => "delete user $user_id",
      plugin => 'user',
      parameters => %(
        name        => $user_id,
        action      => 'delete',
      )
    );

}

