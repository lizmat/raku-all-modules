
use Getopt::Advance::Utils;
use Getopt::Advance::Exception;

unit module Getopt::Advance::Option;

constant BOOLEAN  = "boolean";
constant INTEGER  = "integer";
constant STRING   = "string";
constant FLOAT    = "float";
constant ARRAY    = "array";
constant HASH     = "hash";

class OptionInfo does Info {
    has $.optname;
    has &.check;
    has $.opt;

    method name() { $!optname; }

    method check(Message $msg) {
        &!check($msg.style);
    }

    method process($data) { $data.process($!opt); }
}

role Option does RefOptionSet does Subscriber {
    has $.long              = "";
    has $.short             = "";
    has &.callback          = Callable;
    has Bool $.optional     = True;
    has Str $.annotation    = "";
    has $.value             = Any;
    has $.default-value     = Any;
    has Supplier $.supplier = Supplier.new;

    method init() { }

    method value {
        $!value;
    }

    method long( --> Str) {
        $!long;
    }

    method short( --> Str) {
        $!short;
    }

    method callback {
        &!callback;
    }

    method optional( --> Bool) {
        $!optional;
    }

    method annotation( --> Str) {
        $!annotation;
    }

    method default-value {
        $!default-value;
    }

    method Supply { $!supplier.Supply; }

    method set-value(Any $value, Bool :$callback) {
        if $callback.so {
            &!callback(self, $value) if self.has-callback();
            $!supplier.emit([self.owner(), self, $value]);
        }
        $!value = $value;
    }

    method set-long(Str:D $!long) { }

    method set-short(Str:D $!short) { }

    method set-callback( &callback where .signature ~~ :($, $) | :($) ) {
        &!callback = &callback;
    }

    method set-optional(Bool $!optional) { }

    method set-annotation(Str:D $!annotation) { }

    method set-default-value($!default-value) { }

    method has-value( --> Bool) {
        $!value.defined;
    }

    method has-long( --> Bool) {
        self.long() ne "";
    }

    method has-short( --> Bool) {
        self.short() ne "";
    }

    method has-callback( --> Bool) {
        &!callback.defined;
    }

    method has-annotation( --> Bool) {
        $!annotation ne "";
    }

    method has-default-value( --> Bool) {
        $!default-value.defined;
    }

    method reset-long {
        self.set-long("");
    }

    method reset-short {
        self.set-short("");
    }

    method reset-value {
        self.set-value(self.default-value());
    }

    method reset-callback {
        &!callback = Callable;
    }

    method reset-annotation {
        self.set-annotation("");
    }

    method type( --> Str) { ... }

    method check() {
        if !(self.optional() || self.has-value()) {
            &ga-option-error("{self.usage()}: option need an value!");
        }
    }

    method match-name(Str:D $name) {
        $name eq self.long || $name eq self.short;
    }

    method match-value(Any) { ... }

    method lprefix { '--' }

    method sprefix { '-' }

    method need-argument( --> Bool) { True; }

    method usage( --> Str) {
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

    method clone() {
        nextwith(
            long        => %_<long> // $!long.clone,
            short       => %_<short> // $!short.clone,
            callback    => %_<callback> // &!callback.clone,
            optional    => %_<optional> // $!optional.clone,
            annotation  => %_<annotation> // $!annotation.clone,
            value       => %_<value> // $!value.clone,
            default-value=> %_<default-value> // $!default-value.clone,
            supplier    => Supplier.new,
            |%_
        );
    }
}

class Option::Boolean does Option {
    has $!deactivate;

    submethod TWEAK(:$value, :$deactivate) {
        $!deactivate = $deactivate;
        if $deactivate {
            if $value.defined && !$value {
                ga-invalid-value("{self.usage()}: default value must be True in deactivate-style.");
            }
            self.set-default-value(True);
            self.set-value(True, :!callback);
        } else {
            if $value.defined {
                self.set-default-value($value);
                self.set-value($value, :!callback);
            }
        }
    }

    method set-value(Any $value, Bool :$callback) {
        self.Option::set-value($value.so, :$callback);
    }

    method subscribe(Publisher $p) {
        $p.subscribe(
            OptionInfo.new(
                optname  => self.usage(),
                check   => sub (\style) {
                    set(
                        Style::XOPT, Style::LONG, Style::SHORT, Style::ZIPARG, Style::COMB, Style::BSD
                    ){style};
                },
                opt => self,
            )
        );
    }

    method type() {
        BOOLEAN;
    }

    method lprefix(--> Str) {
        my $lprefix = self.Option::lprefix();
        $!deactivate ?? "{$lprefix}/" !! $lprefix;
    }

    method sprefix(--> Str) {
        my $sprefix = self.Option::sprefix();
        $!deactivate ?? "{$sprefix}/" !! $sprefix;
    }

    method need-argument(--> Bool) { False; }

    method match-value(Any:D $value) {
        return ! ( $!deactivate && $value.so );
    }

    method clone() {
        nextwith(
            deactivate => %_<deactivate> // $!deactivate,
            |%_,
        );
    }
}

class Option::Integer does Option {
    submethod TWEAK(:$value) {
        if $value.defined {
            self.set-default-value($value);
            self.set-value($value, :!callback);
        }
    }

    method set-value(Any:D $value, Bool :$callback) {
        if $value ~~ Int {
            self.Option::set-value($value, :$callback);
        } elsif so +$value {
            self.Option::set-value(+$value, :$callback);
        } else {
            &ga-invalid-value("{self.usage()}: option need an integer.");
        }
    }

    method subscribe(Publisher $p) {
        $p.subscribe(
            OptionInfo.new(
                optname  => self.usage,
                check   => sub (\style) {
                    set(
                        Style::XOPT, Style::LONG, Style::SHORT, Style::ZIPARG, Style::COMB
                    ){style};
                },
                opt => self,
            )
        );
    }

    method type() {
        INTEGER;
    }

    method match-value(Any:D $value) {
        $value ~~ Int || so +$value;
    }
}

class Option::Float does Option {
    submethod TWEAK(:$value) {
        if $value.defined {
            self.set-default-value($value);
            self.set-value($value, :!callback);
        }
    }

    method set-value(Any:D $value, Bool :$callback) {
        if $value ~~ FatRat {
            self.Option::set-value($value, :$callback);
        } elsif so $value.FatRat {
            self.Option::set-value($value.FatRat, :$callback);
        } else {
            &ga-invalid-value("{self.usage()}: option need a float.");
        }
    }

    method subscribe(Publisher $p) {
        $p.subscribe(
            OptionInfo.new(
                optname  => self.usage,
                check   => sub (\style) {
                    set(
                        Style::XOPT, Style::LONG, Style::SHORT, Style::ZIPARG, Style::COMB
                    ){style};
                },
                opt => self,
            )
        );
    }

    method type() {
        FLOAT;
    }

    method match-value(Any:D $value) {
        $value ~~ FatRat || so $value.FatRat;
    }
}

class Option::String does Option {
    submethod TWEAK(:$value) {
        if $value.defined {
            self.set-default-value($value);
            self.set-value($value, :!callback);
        }
    }

    method set-value(Any:D $value, Bool :$callback) {
        if $value ~~ Str {
            self.Option::set-value($value, :$callback);
        } elsif so ~$value {
            self.Option::set-value(~$value, :$callback);
        } else {
            &ga-invalid-value("{self.usage()}: option need a string.");
        }
    }

    method subscribe(Publisher $p) {
        $p.subscribe(
            OptionInfo.new(
                optname  => self.usage,
                check   => sub (\style) {
                    set(
                        Style::XOPT, Style::LONG, Style::SHORT, Style::ZIPARG, Style::COMB
                    ){style};
                },
                opt => self,
            )
        );
    }

    method type() {
        STRING;
    }

    method match-value(Any:D $value) {
        $value ~~ Str || so ~$value;
    }
}

class Option::Array does Option {
    submethod TWEAK(:$value) {
        if $value.defined {
            unless $value ~~ Positional {
                &ga-invalid-value("{self.usage()}: option need an Positional value.");
            }
            $!value = $!default-value = Array.new(|$value);
        }
    }

    method value {
        self.has-value() ?? @$!value !! Array;
    }

    # This actually is a push-value
    method set-value($value, Bool :$callback) {
        my $array = self.has-value() ?? $!value !! Array.new;
        $array.push($value);
        self.Option::set-value($array);
        if $callback.so {
            self.callback.(self, $value) if self.has-callback();
            self.supplier.emit([self.owner(), self, $value]);
        }
    }

    method subscribe(Publisher $p) {
        $p.subscribe(
            OptionInfo.new(
                optname  => self.usage,
                check   => sub (\style) {
                    set(
                        Style::XOPT, Style::LONG, Style::SHORT, Style::ZIPARG, Style::COMB
                    ){style};
                },
                opt => self,
            )
        );
    }

    method type() {
        ARRAY;
    }

    method match-value(Any:D $value) {
        True;
    }
}

class Option::Hash does Option {
    submethod TWEAK(:$value) {
        if $value.defined {
            unless $value ~~ Hash {
                &ga-invalid-value("{self.usage()}: option need a Hash.");
            }
            $!value = $!default-value = $value;
        }
    }

    method value {
        self.has-value() ?? %$!value !! Hash;
    }

    # This actually is a push-value
    method set-value(Any:D $value, Bool :$callback) {
        my $hash = self.has-value() ?? $!value !! Hash.new;
        my $realvalue;
        if $value ~~ Pair {
            $realvalue = $value;
        } elsif try so $value.pairup {
            $realvalue = $value.pairup;
        } elsif (my $evalue = self!parse-as-pair($value)) {
            $realvalue = $evalue;
        } else {
            &ga-invalid-value("{self.usage()}: option need an Pair.");
        }
        $hash.push($realvalue);
        self.Option::set-value($hash);
        if $callback.so {
            self.callback.(self, $realvalue) if self.has-callback();
            self.supplier.emit([self.owner(), self, $realvalue]);
        }
    }

    method subscribe(Publisher $p) {
        $p.subscribe(
            OptionInfo.new(
                optname  => self.usage,
                check   => sub (\style) {
                    set(
                        Style::XOPT, Style::LONG, Style::SHORT, Style::ZIPARG, Style::COMB
                    ){style};
                },
                opt => self,
            )
        );
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
        HASH;
    }

    method match-value(Any:D $value) {
        $value ~~ Pair || (try so $value.pairup) || Pair::Grammar.parse($value).so;
    }
}
