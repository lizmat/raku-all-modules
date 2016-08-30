# Real sequences

unit module Math::Sequences::Real;

class Reals is Range is export {
    method new(
            :$min = -Inf,
            :$max = Inf,
            :$excludes-min = False,
            :$excludes-max = False) {
        nextwith :$min, :$max, :$excludes-min, :$excludes-max
    }

    method gist {
        if self.min == -Inf and self.max == Inf and
            !self.excludes-min and ! self.excludes-max {
            "ℝ"
        } else {
            "Reals({self.min}..{self.max})"
        }
    }

    method !params {
        <min max excludes-min excludes-max>.map: -> $param {
            ":{$param}(" ~ self."$param"() ~ ')'
        }
    }

    method perl {
        "Reals.new(" ~ self!params.join(",") ~ ")"
    }

    # An iterator based on the current range (full of fail)
    method iterator {
        my &failer = { fail "Reals are uncountable" };
        failer if self.excludes-min;
        my $seq = (self.excludes-max ??
            (self.min, &failer ...^ self.max) !!
            (self.min, &failer ... self.max));
        $seq.iterator
    }

    # All of the reals >= $n
    method from($n=self.min) {
        my $min = $n;
        my $max = self.max;
        my $excludes-min = self.excludes-min;
        my $excludes-max = self.excludes-max;

        Reals.new(:$min, :$max, :$excludes-min, :$excludes-max);
    }

    method Str { self.gist }
    method of { ::Real }
    method Numeric { Inf }
    method is-int { False }
    method infinite { True }
    method elems { Inf }
}

my constant \ℝ is export = Reals.new;

# vim: sw=4 softtabstop=4 expandtab ai ft=perl6
