use Test;
use AttrX::InitArg;

plan 16;

{
    class SecretEnvoy {
        has $!message is init-arg is required;

        method get-secret-message($password){
            $password eq 'opensesame' ?? $!message !! Str;
        }
    }

    throws-like { SecretEnvoy.new },X::Attribute::Required;

    my $envoy = SecretEnvoy.new(message => "TOP SECRET",guy-sending => 'CIA');
    nok $envoy.can("message"),<$! still don't have accessors>;

    is $envoy.get-secret-message('opensesame'),'TOP SECRET','message was set';

    ok $envoy.perl ~~ /'TOP SECRET'/;
    nok $envoy.gist ~~ /'TOP SECRET'/;
}

{
    my class Foo {
        has $.accessor-name is init-arg('constructor-name') is required;
        has $!some-private  is init-arg('wee');

        method wee { $!some-private }
    }

    my $foo = Foo.new(constructor-name => 'foo', wee => 'bar');
    is $foo.accessor-name,'foo';
    ok $foo.perl ~~ /'constructor-name'/;
    is $foo.wee,'bar';

    ok $foo.perl ~~ /'constructor-name'/;
    ok $foo.perl ~~ /'wee'/;
    nok $foo.gist ~~ /'wee'/;
    ok $foo.gist ~~ /'accessor-name'/;

    throws-like { Foo.new(accessor-name => 'foo') }, X::Attribute::Required;
}

{
    my class Foo {
        has $.no-set is init-arg(False) = "foo";
    }
    my $foo = Foo.new(no-set => "bar");
    is $foo.no-set,'foo','init-arg(False) works';
    nok $foo.perl ~~ /'no-set'/;
    ok  $foo.gist ~~ /'no-set'/;
}
