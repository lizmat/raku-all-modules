use v6;

use Test;

use Supply::Timeout;

sub sup-test($emit-time, $timeout, $pass) {
    my $supplier = Supplier.new;
    my $sup-timeout = Supply::Timeout.new($supplier.Supply, $emit-time);

    react {
        whenever $sup-timeout.Supply -> $bool {
            ok($bool, "Timeout not happened");
            done;

            QUIT {
                when X::Supply::Timeout {
                    ok(True, "Timeout happened");
                    done;
                }
            }
        }
        whenever Promise.in($timeout) {
            $supplier.emit($pass);
        }
    }
}

# Timeout happens earlier
sup-test(1, 2, False);
# Emit happens earlier
sup-test(2, 1, True);

done-testing;

# vim: ft=perl6
