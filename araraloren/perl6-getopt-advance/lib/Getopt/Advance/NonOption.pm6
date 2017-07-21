
use Getopt::Advance::Argument;
use Getopt::Advance::Exception;

constant NOALL  = "all";
constant NOCMD  = "cmd";
constant NOPOS  = "position";

role NonOption {
    has $.success;
    has &.callback;

    method set-callback(&callback) { ... }
    method has-callback of Bool { &!callback.defined; }
    method match-index(Int $total, Int $index) { ... }
    method match-name(Str $name) { ... }
    method reset-success { $!success = False; }
    method CALL-ME(|c) { ... }
    method type of Str { ... }
    method clone(*%_) { ... }
    method usage { ... }
}

class NonOption::All does NonOption {
    submethod TWEAK(:&callback) {
        self.set-callback(&callback);
    }

    method set-callback(
        &callback where .signature ~~ :($, @) | :(@)
    ) {
        &!callback = &callback;
    }

    method match-index(Int $total, Int $index) {
        True;
    }

    method match-name(Str $name) {
        True;
    }

    method CALL-ME(|c) {
        given &!callback.signature {
            when :($, @) {
                &!callback(|c);
            }
            when :(@) {
                &!callback(c.[* - 1]);
            }
        }
        $!success = True;
    }

    method type of Str {
        NOALL;
    }

    method clone(*%_) {
        nextwith(
            callback    => %_<callback> // &!callback.clone,
            |%_
        );
    }

    method usage() {
        "main";
    }
}

class NonOption::Cmd does NonOption {
    has $.name;

    submethod TWEAK(:&callback) {
        self.set-callback(&callback);
    }

    method set-callback(
        &callback where .signature ~~ :($, $) | :($)
    ) {
        &!callback = &callback;
    }

    method match-index(Int $total, Int $index) {
        $index == 0;
    }

    method match-name(Str $name) {
        $!name eq $name;
    }

    method CALL-ME(|c) {
        given &!callback.signature {
            when :($, @) {
                &!callback(|c);
            }
            when :(@) {
                &!callback(c.[* - 1]);
            }
        }
        $!success = True;
    }

    method type of Str {
        NOCMD;
    }

    method clone(*%_) {
        nextwith(
            callback    => %_<callback> // &!callback.clone,
            name        => %_<name> // $!name.clone,
            |%_
        );
    }

    method usage() {
        $!name;
    }
}

class NonOption::Pos does NonOption {
    has $.name;
    has $.index;

    submethod TWEAK(:&callback, :$index) {
        self.set-callback(&callback);
        if $index ~~ Int && $index < 0 {
            &ga-raise-error("Index should be positive number!");
        }
    }

    method set-index(Int:D $index) {
        $!index = $index;
    }

    method set-callback(
        &callback # where .signature ~~ :($, Argument $) | :(Argument $)
    ) {
        &!callback = &callback;
    }

    method match-index(Int $total, Int $index) {
        my $expect-index = $!index ~~ WhateverCode ??
            $!index.($total) !! $!index;
        return $index == $expect-index;
    }

    method match-name(Str $name) {
        $!name eq $name;
    }

    method CALL-ME(|c) {
        given &!callback.signature {
            when :($, $) {
                &!callback(|c);
            }
            when :($) {
                &!callback(c.[* - 1]);
            }
        }
        $!success = True;
    }

    method type of Str {
        NOPOS;
    }

    method clone(*%_) {
        nextwith(
            callback    => %_<callback> // &!callback.clone,
            name        => %_<name> // $!name.clone,
            index       => %_<index> // $!index.clone,
            |%_
        );
    }

    method usage() {
        "{$!name}";
    }

    method new-front(*%_) {
        %_<index>:delete;
        self.new(
            |%_,
            index => 0
        );
    }

    method new-last(*%_) {
        %_<index>:delete;
        self.new(
            |%_,
            index => * - 1
        );
    }
}
