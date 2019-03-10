use v6;

unit role Smack::Component;

method configure(%config) { }

method call(%env) { }

# the to-app method is cached
has $!_app;
method to-app() {
    my $self = self;
    return $!_app if $!_app;
    $!_app = sub (%config --> Callable) {
        $self.configure(%config);
        sub (%env) { $self.call(%env) };
    }
}

# This only works correctly because to-app is cached
method wrap(&middleware) {
    self.to-app.wrap(&middleware);
}

method Callable() returns Callable { self.to-app }
