use v6;
use strict;

use Crypt::Argon2;



sub MAIN (int :$t_cost = 2, int :$m_cost = 1 +< 16, int :$parallelism = 2, int :$hashlen = 16) {
    say "Running 10 iterations of argon2-verify() with the following settings:";
    say "\tIterations: "~$t_cost;
    printf "\tMemory cost: %d KiB\n", $m_cost;
    printf "\tParallelism: %d threads\n", $parallelism;
    printf "\tHash length: %d bytes\n", $hashlen;

    my $hash = argon2-hash("", :t_cost($t_cost), :m_cost($m_cost),
                           :parallelism($parallelism), :hashlen($hashlen));

    my $start = now;
    for 1..10 {
        argon2-verify($hash, "");
    }
    my $stop = now;

    printf "Time per verification: %.2f ms\n", ($stop - $start) * 100;
}
