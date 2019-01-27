use IoC::Service;
class IoC::BlockInjection does IoC::Service {
    has Code $.block;
    has %.dependencies;
    has $.container is rw;

    method get {
        if $.lifecycle ~~ 'Singleton' {
            return (
                $.instance || self.initialize(self.build-instance());
            );
        }

        return self.build-instance();
    }

    method build-instance {
        \(self) ~~ $!block.signature # callable with this
            ?? $!block.(self)
            !! $!block.();
    }

    method param(Str:D $service-name) {
        unless %.dependencies{$service-name}:exists {
            die "Dependency '$service-name' was not found"
        }

        my $service = %.dependencies{$service-name};
        return $!container.fetch($service).get();
    }
};
