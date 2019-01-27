use FINALIZER <class-only>;

class Frobnicate {
    has &.code;
    has &!unregister;

    method TWEAK() {
        &!unregister = FINALIZER.register: {
            .finalize with self
        }
    }
    method finalize(\SELF:) {
        &!unregister();
        &!code();
    }
}

sub dbiconnect(&code) is export { Frobnicate.new( :&code ) }

# vim: ft=perl6 expandtab sw=4
