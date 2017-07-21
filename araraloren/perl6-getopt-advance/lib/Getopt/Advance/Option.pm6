
use Getopt::Advance::Exception;

constant BOOLEAN is export = "boolean";
constant INTEGER is export = "integer";
constant STRING  is export = "string";
constant FLOAT   is export = "float";
constant ARRAY   is export = "array";
constant HASH    is export = "hash";

role Option {
    method value { ... }
    method long of Str { ... }
    method short of Str { ... }
    method callback { ... }
    method optional of Bool { ... }
    method annotation of Str { ... }
    method default-value { ... }
    method set-value(Mu, Bool :$callback) { ... }
    method set-long(Str:D) { ... }
    method set-short(Str:D) { ... }
    method set-callback(&callback) { ... }
    method set-optional(Mu) { ... }
    method set-annotation(Str:D) { ... }
    method set-default-value(Mu) { ... }
    method has-value of Bool { ... }
    method has-long of Bool { ... }
    method has-short of Bool { ... }
    method has-callback of Bool { ... }
    method has-annotation of Bool { ... }
    method has-default-value of Bool { ... }
    method reset-long { ... }
    method reset-short { ... }
    method reset-value { ... }
    method reset-callback { ... }
    method reset-annotation { ... }
    method type of Str { ... }
    method check() { ... }
    method match-name(Str:D) { ... }
    method match-value(Mu) { ... }
    method lprefix { ... }
    method sprefix { ... }
    method need-argument of Bool { True; }
    method usage() of Str {
        my Str $usage = "";

        $usage ~= "{self.sprefix}{self.short}"
            if self.has-short;
        $usage ~= "|"
            if self.has-long && self.has-short;
        $usage ~= "{self.lprefix}{self.long}"
            if self.has-long;
        $usage ~= "=<{self.type}>"
            if self.type ne BOOLEAN;

        return $usage;
    }
    method clone(*%_) { ... }
}

role Option::Base does Option {
    has $.long  = "";
    has $.short = "";
    has &.callback;
    has $.optional = True;
    has $.annotation = "";
    has $.value;
    has $.default-value;

    method callback {
        &!callback;
    }

    method optional {
        $!optional;
    }

    method annotation {
        $!annotation;
    }

    method value {
        $!value;
    }

    method default-value {
        $!default-value;
    }

    method long {
        $!long;
    }

    method short {
        $!short;
    }

    method set-value(Mu $value, Bool :$callback) {
        if $callback.so && &!callback.defined {
            &!callback(self, $value);
        }
        $!value = $value;
    }

    method set-long(Str:D $name) {
        $!long = $name;
    }

    method set-short(Str:D $name) {
        $!short = $name;
    }

    method set-callback(
        &callback where .signature ~~ :($, $) | :($)
    ) {
        &!callback = &callback;
    }

    method set-optional(Mu $optional) {
        $!optional = $optional.so;
    }

    method set-annotation(Str:D $annotation) {
        $!annotation = $annotation;
    }

    method set-default-value(Mu $value) {
        $!default-value = $value;
    }

    method has-value() of Bool {
        $!value.defined;
    }

    method has-long() of Bool {
        $!long ne "";
    }

    method has-short() of Bool {
        $!short ne "";
    }

    method has-callback() of Bool {
        &!callback.defined;
    }

    method has-annotation() of Bool {
        $!annotation.defined;
    }

    method has-default-value() of Bool {
        $!default-value.defined;
    }

    method reset-long {
        $!long = "";
    }

    method reset-short {
        $!short = "";
    }

    method reset-value {
        $!value = $!default-value;
    }

    method reset-callback {
        &!callback = Callable;
    }

    method reset-annotation {
        $!annotation = Mu;
    }

    method type() {
        die "{$?CLASS} has no type!";
    }

    method check() {
        return $!optional || self.has-value();
    }

    method match-name(Str:D $name) {
        $name eq self.long
            ||
        $name eq self.short;
    }

    method match-value(Mu) {
        False;
    }

    method lprefix { '--' }

    method sprefix { '-' }

    method clone(*%_) {
        nextwith(
            long        => %_<long> // $!long.clone,
            short       => %_<short> // $!short.clone,
            callback    => %_<callback> // &!callback.clone,
            optional    => %_<optional> // $!optional.clone,
            annotation  => %_<annotation> // $!annotation.clone,
            value       => %_<value> // $!value.clone,
            default-value=> %_<default-value> // $!default-value.clone,
            |%_
        );
    }
}

class Option::Boolean does Option::Base {
    submethod TWEAK(:$value, :$deactivate) {
        if $deactivate {
            if $value.defined && !$value {
                ga-invalid-value("{self.usage()}: default value must be True in deactivate-style.");
            }
            $!default-value = True;
            self.set-value(True, :!callback);
        } else {
            if $value.defined {
                $!default-value = $value;
                self.set-value($value, :!callback);
            }
        }
    }

    method set-value(Mu $value, Bool :$callback) {
        self.Option::Base::set-value($value.so, :$callback);
    }

    method type() {
        "boolean";
    }

    method lprefix { $!default-value ?? '--/' !! '--' }

    method need-argument of Bool { False; }

    method match-value(Mu:D) {
        True;
    }
}


class Option::Integer does Option::Base {
    submethod TWEAK(:$value) {
        if $value.defined {
            $!default-value = $value;
            self.set-value($value, :!callback);
        }
    }

    method set-value(Mu:D $value, Bool :$callback) {
        if $value ~~ Int {
            self.Option::Base::set-value($value, :$callback);
        } elsif so +$value {
            self.Option::Base::set-value(+$value, :$callback);
        } else {
            ga-invalid-value("{self.usage()}: Need integer.");
        }
    }

    method type() {
        "integer";
    }

    method match-value(Mu:D $value) {
        $value ~~ Int || so +$value;
    }
}

class Option::Float does Option::Base {
    submethod TWEAK(:$value) {
        if $value.defined {
            $!default-value = $value;
            self.set-value($value, :!callback);
        }
    }

    method set-value(Mu:D $value, Bool :$callback) {
        if $value ~~ FatRat {
            self.Option::Base::set-value($value, :$callback);
        } elsif so $value.FatRat {
            self.Option::Base::set-value($value.FatRat, :$callback);
        } else {
            ga-invalid-value("{self.usage()}: Need float.");
        }
    }

    method type() {
        "float";
    }

    method match-value(Mu:D $value) {
        $value ~~ FatRat || so $value.FatRat;
    }
}

class Option::String does Option::Base {
    submethod TWEAK(:$value) {
        if $value.defined {
            $!default-value = $value;
            self.set-value($value, :!callback);
        }
    }

    method set-value(Mu:D $value, Bool :$callback) {
        if $value ~~ Str {
            self.Option::Base::set-value($value, :$callback);
        } elsif so ~$value {
            self.Option::Base::set-value(~$value, :$callback);
        } else {
            ga-invalid-value("{self.usage()}: Need string.");
        }
    }

    method type() {
        "string";
    }

    method match-value(Mu:D $value) {
        $value ~~ Str || so ~$value;
    }
}

class Option::Hash does Option::Base {
    submethod TWEAK(:$value) {
        if $value.defined {
            unless $value ~~ Hash {
                ga-invalid-value("{self.usage()}: Need a Hash.");
            }
            $!value = $!default-value = $value;
        }
    }

    # This actually is a push-value
    method set-value(Mu:D $value, Bool :$callback) {
        my %hash = $!value.defined ?? %$!value !! Hash.new;
        if $value ~~ Pair {
            %hash.push($value);
        } elsif try so $value.pairup {
            %hash.push($value.pairup);
        } elsif (my $evalue = self!parse-as-pair($value)) {
            %hash.push($evalue);
        } else {
            ga-invalid-value("{self.usage()}: Need a Pair.");
        }
        self.Option::Base::set-value(%hash, :$callback);
    }

    my grammar Pair::Grammar {
        token TOP { ^ <pair> $ }

        proto rule pair {*}

        rule pair:sym<arrow> { <key> '=>' <value> }

        rule pair:sym<colon> { ':' <key> '(' $<value> = (.+ <!before $>) ')' }

    	rule pair:sym<angle> { ':' <key> '<' $<value> = (.+ <!before $>) '>' }

        rule pair:sym<true> { ':' <key> }

        rule pair:sym<false> { ':' '!' <key> }

        token value { .+ }

        token key { <[0..9A..Za..z\-_\'\"]>+ }
    }

    my class Pair::Actions {
        method TOP($/) { $/.make: $<pair>.made; }

        method pair:sym<arrow>($/) {
            $/.make: $<key>.made => $<value>.Str;
        }

        method pair:sym<colon>($/) {
            $/.make: $<key>.made => $<value>.Str;
        }

        method pair:sym<true>($/) {
            $/.make: $<key>.made => True;
        }

        method pair:sym<false>($/) {
            $/.make: $<key>.made => False;
        }

        method pair:sym<angle>($/) {
            $/.make: $<key>.made => $<value>.Str;
        }

        method value($/) {
            $/.make: ~$/;
        }

        method key($/) {
            $/.make: ~$/;
        }
    }

    method !parse-as-pair($value) {
        my $r = Pair::Grammar.parse($value, :actions(Pair::Actions));

        return $r.made if $r;
    }

    method type() {
        "hash";
    }

    method match-value(Mu:D $value) {
        $value ~~ Pair || (try so $value.pairup) || Pair::Grammar.parse($value).so;
    }
}

class Option::Array does Option::Base {
    submethod TWEAK(:$value) {
        if $value.defined {
            unless $value ~~ Positional {
                ga-invalid-value("{self.usage()}: Need an Positional.");
            }
            $!value = $!default-value = Array.new(|$value);
        }
    }

    # This actually is a push-value
    method set-value($value, Bool :$callback) {
        my @array = $!value ?? @$!value !! Array.new;
        @array.push($value);
        self.Option::Base::set-value(@array, :$callback);
    }

    method type() {
        "array";
    }

    method match-value(Mu:D $value) {
        True;
    }
}
