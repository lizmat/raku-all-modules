unit class Proxee;
use MONKEY-GUTS;

class Proxee::X::CannotProxeeStore is Exception {
    method message {
        'A Proxee cannot use :PROXEE and :STORE at the same time'
    }
}

proto method new(|) { * }
multi method new (&block) {
    my $v := block;
    $v =:= Nil
        ?? self.new
        !! nqp::istype($v, List)
            ?? self.new(|$v.Capture)
            !! self.new(|$v)
}
multi method new(\coercer where {.HOW ~~ Metamodel::CoercionHOW}) {
    my \from     = coercer.^constraint_type;
    my \to       = coercer.^target_type;
    my $to-name := to.^name;

    my $STORAGE;
    Proxy.new: :FETCH{ $STORAGE }, STORE => -> $, \v {
        die X::TypeCheck.new: :got(v.WHAT), :expected(from), :operation<Proxee>
            unless nqp::istype(v, from); # on 2017.11 about 13x faster than ~~

        nqp::istype(v, to) ?? ($STORAGE := v)
                           !! ($STORAGE := v."$to-name"());
        $STORAGE
    }
}
multi method new (:&PROXEE, :&STORE, :&FETCH) {
    &PROXEE and &STORE and die Proxee::X::CannotProxeeStore.new;

    my &store := &PROXEE ?? { $*PROXEE = PROXEE $_ }
                         !! (&STORE || { $*PROXEE = $_ });
    my &fetch := &FETCH  || { $*PROXEE };

    my $proxee;
    Proxy.new:         :FETCH{ my $*PROXEE := $proxee; fetch   },
    STORE => -> $, \v is raw { my $*PROXEE := $proxee; store v }
}
