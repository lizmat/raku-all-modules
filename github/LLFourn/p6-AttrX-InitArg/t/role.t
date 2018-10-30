use Test;
use AttrX::InitArg;
plan 5;

role Foo {
    has $!message is init-arg is required;

    method get-secret-message($password){
        $password eq 'opensesame' ?? $!message !! Str;
    }
}

class SecretEnvoy does Foo { };

throws-like { SecretEnvoy.new },X::Attribute::Required;

my $envoy = SecretEnvoy.new(message => "TOP SECRET",guy-sending => 'CIA');
nok $envoy.can("message"),<$! still don't have accessors>;

is $envoy.get-secret-message('opensesame'),'TOP SECRET','message was set';

ok $envoy.perl ~~ /'TOP SECRET'/;
nok $envoy.gist ~~ /'TOP SECRET'/;
