use v6.c;
use Test;
use lib 'lib';

plan 4;

subtest "CUID field specification -" => sub {
        use CUID :internals;

        plan 5;

        my %fields = cuid-fields( );

        is %fields<prefix>.chars,      1, "cuid prefix length";
        is %fields<timestamp>.chars,   8, "cuid timestamp length";
        is %fields<counter>.chars,     4, "cuid counter length";
        is %fields<fingerprint>.chars, 4, "cuid fingerprint length";
        is %fields<random>.chars,      8, "cuid random length";
};

subtest "CUID valid characters -" => sub {
        use CUID;

        plan 2;

        my $cuid = cuid( );

        is $cuid.chars, 25, "cuid length";
        like $cuid, rx:r/^ <[a .. z 0 .. 9]>+ $/, "cuid base-36 characters";
};

subtest "CUID slugs -" => sub {
        use CUID;

        plan 2;

        my $cuid-slug = cuid-slug( );

        is $cuid-slug.chars, 8, "cuid slug length";
        like $cuid-slug, rx:r/^ <[a .. z 0 .. 9]>+ $/, "cuid slug characters";
};

subtest "CUID collisions -" => sub {
        use CUID;

        plan 1;

        my $THREADS    = 3;
        my $ITERATIONS = 20_000;
        my $lock       = Lock.new;
        my $cuids      = ().SetHash;
        my $collision  = False;

        loop (my $index = 1; $index < $ITERATIONS; $index++) {
                my $result = [&&] await((^$THREADS).map: {
                        start {
                                my $cuid = cuid( );

                                $lock.protect: {
                                        if $cuids{$cuid} {
                                                $collision = True;
                                                False; # Things aren't OK
                                        }
                                        else {
                                                $cuids{$cuid} = True;
                                                True; # Things are OK
                                        }
                                };
                        };
                });

                last unless $result;
        }

        nok $collision, "cuid collision detection";
};

done-testing;
