module Math::RungeKutta;

# the actual integation loop
sub rk-integrate (
    :$from,
    :$to,
    :@initial,
    :$step = ($from - $to) / 100,
    :&derivative,
    :&do = sub ($parameter, @values) { say "$parameter: @values.join(', ')" },
    :$order = 4,
    :$adaptive,
) is export {
    return adaptive-rk-integrate(:$from, :$to, :@initial, :&derivative, :&do)
                if $adaptive;
    my $parameter = $from;
    my @values = @initial;
    while $parameter < $to {
        @values = runge-kutta(
                :$order,
                :@values,
                :$parameter,
                :&derivative,
                :$step,
        );
        $parameter = @values.shift;
        do($parameter, @values);
    }
}

sub runge-kutta(:@values, :&derivative,
                :$parameter, :$step = 0.01, :$order = 4) is export {
    rk(:values(@values), :&derivative, :$parameter, :$step, :$order);
}

# Euler's algorithm
multi sub rk(:@values, :&derivative, :$parameter, :$step, :$order where 1) {
    my @new_y = @values >>+<< ($step <<*<< derivative($parameter, @values));
    return ($parameter + $step, @new_y);
}

# Heun's method
multi sub rk(:@values, :&derivative, :$parameter, :$step, :$order where 2) {
    my @k1 = $step <<*<< derivative($parameter, @values);
    my @k2 = $step <<*<< derivative($parameter+$step, @values >>+<< @k1);
    my @result = @values >>+<< (1/2) <<*<< (@k1 >>+<< @k2);
    return ($parameter + $step, @result);
}

# classical RK4
multi sub rk(:@values, :&derivative, :$parameter, :$step, :$order where 4) {
    my @k1 = $step <<*<< derivative($parameter, @values);
    my @k2 = $step <<*<< derivative($parameter + $step/2, [@values >>+<< @k1 >>/>> 2]);
    my @k3 = $step <<*<< derivative($parameter + $step/2, [@values >>+<< @k2 >>/>>2]);
    my @k4 = $step <<*<< derivative($parameter + $step,   [@values >>+<< @k3]);
    my @result = @values >>+<< ((1/6) <<*<< (@k1 >>+<< @k4))
                         >>+<< ((1/3) <<*<< (@k2 >>+<< @k3));
    return ($parameter + $step, @result);
}

sub adaptive-rk-integrate(:$from, :$to, :@initial, :&derivative, :&do,
           :$min-stepsize = 1e-7, :$max-stepsize = ($to - $from)/5,
           :$epsilon = 1e-5, :$order = 4, :$quiet) is export {
    # from http://math.cofc.edu/lemesurier/math545-2007/handouts/adaptive-runge-kutta.pdf
    # $t        = t
    # $from     = a
    # $to       = b
    # @values   = y
    # &derivative = f
    # $step     = h
    my $t      = $from;
    my @values = @initial;
    my $step   = $max-stepsize;
    while $t < $to {
        my @y-new  = rk(:@values, :&derivative, :$step, :parameter($t), :$order);
        my $t-new  = @y-new.shift;
        my @y-mid  = rk(:@values, :&derivative, :step($step/2), :parameter($t), :$order);
        my $t-mid  = @y-mid.shift;
        my @y-halfstep = rk(:values(@y-mid), :&derivative, :step($step/2),
                            :parameter($t-mid), :$order);
        my $y-halfstep = @y-halfstep.shift;
        # TODO: scale error with @values somehow?
        my $err     = ([max] (@y-halfstep »-« @y-new)».abs) / $step;
        if $err <= $epsilon || $step == $min-stepsize {
            @values = @y-new;
            $t      = $t-new;
            do($t, @values);
            if $step == $min-stepsize && !$quiet {
                warn "WARNING: Integration step accepted due to lower step size\n"
                ~ "         limitation, but error tolerance not met\n"
           }
        }
        if $err == 0 {
            $step    = $max-stepsize;
        } else {
            $step   *= sqrt(sqrt($epsilon / (2 * $err)));
            $step max= $min-stepsize;
            $step min= $max-stepsize;
        }

        # never go beyond the upper limit of the integration range
        $step    = $to - $t if $t + $step > $to;
    }
}

# vim: ft=perl6
