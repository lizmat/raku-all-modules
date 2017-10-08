unit class Concurrent::Progress;

class Report {
    has Int $.value is required;
    has Int $.target;
    method percent(--> Int) {
        $.target
            ?? (100 * $.value / $.target).Int
            !! Int
    }
}

# Set at construction time and then immutable, so safe.
has Real $.min-interval;
has Bool $.auto-done = True;
has Supplier $!update-sender;
has Supply $!publish-reports;

# Only ever written from inside a per-instance `supply` block, so safe.
has Int $!current-value = 0;
has Int $!current-target;

submethod TWEAK() {
    $!update-sender = Supplier.new;
    $!publish-reports = supply {
        whenever $!update-sender -> $update {
            given $update.key {
                when 'increment' {
                    $!current-value++;
                }
                my $value = $update.value;
                when 'add' {
                    $!current-value += $value;
                }
                when 'value' {
                    $!current-value = $value;
                }
                when 'target' {
                    $!current-target = $value;
                }
            }
            emit Report.new(
                value => $!current-value,
                target => $!current-target
            );
        }
    }.share;
}

method increment(--> Nil) {
    self && $!update-sender.emit('increment' => 1);
}

method add(Int:D $amount --> Nil) {
    self && $!update-sender.emit('add' => $amount);
}

method set-value(Int:D $value --> Nil) {
    self && $!update-sender.emit('value' => $value);
}

method set-target(Int $target --> Nil) {
    self && $!update-sender.emit('target' => $target);
}

method Supply(Real :$min-interval = $!min-interval, Bool :$auto-done = $!auto-done --> Supply) {
    my $result = $!publish-reports;
    if $auto-done {
        $result = add-auto-done($result);
    }
    with $min-interval {
        $result = add-throttle($result, $min-interval);
    }
    return $result;
}

sub add-auto-done($in) {
    supply {
        whenever $in {
            .emit;
            if .target.defined {
                if .target == .value {
                    done;
                }
            }
        }
    }
}

sub add-throttle($in, $interval) {
    supply {
        my $emit-allowed = True;
        my $emit-outstanding;

        whenever $in {
            if .target.defined && .value == .target {
                .emit;
                $emit-allowed = False;
                $emit-outstanding = Nil;
            }
            elsif $emit-allowed {
                .emit;
                $emit-allowed = False;
            }
            else {
                $emit-outstanding = $_;
            }
        }
        whenever Supply.interval($interval) {
            with $emit-outstanding {
                emit $emit-outstanding;
                $emit-outstanding = Nil;
            }
            else {
                $emit-allowed = True;
            }
        }
    }
}
