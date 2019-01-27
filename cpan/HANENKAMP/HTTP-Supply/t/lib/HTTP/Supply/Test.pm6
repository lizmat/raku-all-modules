use v6;

unit class HTTP::Supply::Test;

use Test;

has @.tests;
has Bool $.debug = ?%*ENV<HTTP_SUPPLY_TEST_DEBUG> // False;

# Test to see that:
# 1. Every header in @got is in @exp.
# 2. Every header in @exp is in @got.
# 3. Every header in @got with a given name that repeats multiple times repeats
#    identical values in the same order in @exp.
# All key comparisons are case-insensitive. All value comparisons are
# case-sensntive.
method headers-equivalent(@got, @exp, :test($headers) = 'headers') {
    if @exp.elems == 0 {
        if @got.elems != 0 {
            flunk "got @got.elems() $headers, but expected none";
        }
        return;
    }

    # We use this to count which header we are looking for from @got in the
    # @exp header list. It is also used to make sure that all @exp headers are
    # seen while looking for @got matches.
    my %repeats;

    # Iterate through the got headers
    for @got -> $got {

        # If we haven't gotten this name yet, note the number of repeats as 0
        %repeats{ $got.key.fc } //= 0;

        # Counter to let us skip past repeats
        my $counter = 0;

        # Marker to let us know we found the match we were looking for.
        my $found = False;

        # Iterate through the expected headers
        for @exp -> $exp {

            # If the keys don't match, keep searching
            next unless $exp.key.fc eq $got.key.fc;

            # Found a match, but is it the nth match we want to compare with?
            next if $counter++ < %repeats{ $got.key.fc };

            # Matches name and count, do the comparison
            is $got.value, $exp.value, "$got.key() in $headers matches expected value";

            # We found a match, whether it was correct or not
            $found++;

            # We need to bump the repeat counter in case this column comes
            # up again.
            %repeats{ $got.key.fc }++;
        }

        # We didn't find a @got header in @exp?
        flunk "got unexpected $got.key() in $headers"
            unless $found;
    }

    # Iterate through expected again and make sure the number of repeats
    # exactly matches the expected number to make sure every expected
    # header was found in got.
    for @exp».key -> $exp-key {
        my $got-count = +%repeats{ $exp-key.fc };
        my $exp-count = +@exp.grep({ .key.fc eq $exp-key });

        is $got-count, $exp-count, "$exp-key expected $exp-count times in $headers and seen $got-count times";
    }
}

multi method await-or-timeout(Promise:D $p, Int :$seconds = 5, :$message) {
    await Promise.anyof($p, Promise.in($seconds));
    if $p {
        $p.result;
    }
    else {
        die "operation timed out after $seconds seconds"
            ~ ($message ?? ": $message" !! "");
    }
}

multi method await-or-timeout(@p, Int :$seconds = 5, :$message) {
    self.await-or-timeout(Promise.allof(@p), :$seconds, :$message);
}

method file-reader($test-file, :$size) {
    $test-file.open(:r, :bin).Supply(:$size)
}

method socket-reader($test-file, :$size) {
    my Int $port = (rand * 1000 + 10000).Int;

    my $listener = do {
        # note "# new listener";
        my $listener = IO::Socket::Async.listen('127.0.0.1', $port);

        my $promised-tap = Promise.new;
        sub close-tap {
            self.await-or-timeout(
                $promised-tap.then({ .result.close }),
                :message<connection close>,
            );
        }

        $promised-tap.keep($listener.act: {
            CATCH {
                default { .note; .rethrow }
            }

            # note "# accepted $*THREAD.id()";
            my $input = $test-file.open(:r, :bin);
            while $input.read($size) -> $chunk {
                # note "# write ", $chunk;
                self.await-or-timeout(.write($chunk), :message<writing chunk>);
            }
            # note "# closing";
            .close;
            # note "# closed";
            close-tap;
            # note "# not listening";
        });

        # note "# ready to connect";
        $listener;
    }

    # When we get here, we should be ready to connect to ourself on the other
    # thread.
    my $conn = self.await-or-timeout(
        IO::Socket::Async.connect('127.0.0.1', $port),
        :message<client connnection>,
    );
    # note "# connected  $*THREAD.id()";
    $conn.Supply(:bin);
}

multi method setup-reader('file', :$test-file, :$size --> Supply:D) {
    self.file-reader($test-file, :$size);
}

multi method setup-reader('socket', :$test-file, :$size --> Supply:D) {
    self.socket-reader($test-file, :$size);
}

constant @chunk-sizes = 1, 3, 11, 101, 1009;

method run-tests(:$reader = 'file') is export {
    unless @!tests {
        flunk "no tests!";
        return;
    }

    for @!tests -> %test {

        # Run the tests at various chunk sizes
        for @chunk-sizes -> $chunk-size {
            # note "chunk size $chunk-size";
            my $test-file = "t/data/%test<source>".IO;
            my $gots = self.test-class.parse-http(
                self.setup-reader($reader, :$test-file, :size($chunk-size)),
                :$!debug,
            );

            my @expected := %test<expected>;
            my %quits    = %test<quits> // %();

            self.run-test($gots, @expected, :%quits);

            CATCH {
                default {
                    .note;
                    flunk "Because: " ~ $_;
                }
            }
        }
    }
}
