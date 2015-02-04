use IoC::Service;
class IoC::BlockInjection does IoC::Service {
    has Callable $.block;

    method get {
        if $.lifecycle eq 'Singleton' {
            return (
                $.instance || self.initialize($!block.())
            );
        }

        return $!block.();
    }
};
