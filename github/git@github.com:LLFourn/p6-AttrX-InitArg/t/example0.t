use Test;
use AttrX::InitArg;

plan 4;

class SecretEnvoy {
    has $!message is init-arg is required;
    has $.steed is init-arg(False) = 'Shadowfax';
    has $.rider is init-arg('messenger') = 'Gandalf';

    method get-message($password){
        $password eq 'opensesame' ?? $!message !! Nil;
    }

}

my $msg = SecretEnvoy.new(
    message => 'TOP SECRET',
    messenger => 'BatMan',
    steed => 'Bat-Mobile'
);

nok $msg.can('message');
is $msg.get-message('opensesame'), 'TOP SECRET';
is $msg.steed, 'Shadowfax';
is $msg.rider, 'BatMan';
