use Cro::HTTP::Auth;

my class FakeLiteralParameter is Parameter {
    has Str $.literal-value is required;
    method type() { Str }
    method named() { False }
    method slurpy() { False }
    method optional() { False }
    method constraints() { all($!literal-value) }
}

my class AdaptedSignature is export {
    has Signature $.real-signature is required;
    has @.significant-segments;
    has @!params;

    method TWEAK(:@template-segments! --> Nil) {
        my @orig-parameters = $!real-signature.params;
        my $cur-sig-seg = 0;
        if @orig-parameters[0].?type ~~ Cro::HTTP::Auth {
            @!params.push(@orig-parameters.shift);
            @!significant-segments.push($cur-sig-seg++);
        }
        for @template-segments {
            if /^'{'.+'}'$/ {
                @!params.push(@orig-parameters.shift);
                @!significant-segments.push($cur-sig-seg);
            }
            else {
                @!params.push(FakeLiteralParameter.new(literal-value => $_));
            }
            $cur-sig-seg++;
        }
        @!params.append(@orig-parameters);
    }

    method params() { @!params }

    method ACCEPTS(Capture $c) {
        $!real-signature.ACCEPTS(self.filter-arguments($c))
    }

    method filter-arguments(Capture $c) {
        \(|$c.list[@!significant-segments], |$c.hash)
    }
}
