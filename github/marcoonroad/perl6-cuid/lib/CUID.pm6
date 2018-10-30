unit module CUID;

my $base         = 36;
my $counter-lock = Lock.new;
my $maximum      = $base ** 4;

my @text-inputs = @(
        $*CWD.Str,  $*KERNEL.Str, $*DISTRO.Str,
        $*USER.Str, $*PID.Str,    $*HOME.Str
);

sub to-base36($number) { $number.base($base).lc }
sub adjust-by8($text)  { "%08s".sprintf($text) }
sub padding-by4($text) { $text.substr(*-4) }
sub padding-by8($text) { $text.substr(*-8) }

sub timestamp {
        (now.round(0.01) * 100)
        ==> to-base36()
        ==> adjust-by8()
        ==> padding-by8()
}

sub counter {
        state $counter = 0;

        $counter-lock.protect({
                $counter = $counter < $maximum ?? $counter !! 0;

                $counter++;
        })
        ==> to-base36()
        ==> adjust-by8()
        ==> padding-by4();
}

# TODO: must improve that hashing function
sub digest($text) { $text.ords.sum / ($text.chars + 1) }

my $fingerprint = (@text-inputs
        ==> map(&digest)
        ==> sum()
        ==> to-base36()
        ==> adjust-by8()
        ==> padding-by4());

sub fingerprint { $fingerprint }

sub random-block {
        $maximum.rand.Int
        ==> to-base36()
        ==> adjust-by8()
        ==> padding-by4()
}

sub cuid-fields is export(:internals) {
        %(prefix    => 'c',
        timestamp   => timestamp(),
        counter     => counter(),
        fingerprint => fingerprint(),
        random      => random-block() ~ random-block())
}

sub cuid is export {
        'c' ~
        timestamp() ~ counter() ~ fingerprint() ~
        random-block() ~ random-block()
}

sub cuid-slug is export {
        my %fields = cuid-fields();

        %fields<timestamp>.substr(*-2) ~
        %fields<counter>.substr(*-2) ~
        %fields<fingerprint>.substr(0, 1) ~
        %fields<fingerprint>.substr(*-1) ~
        %fields<random>.substr(*-2);
}

# END
