
use Getopt::Advance::Exception;

unit module Getopt::Advance::Utils;

constant MAXPOSSUPPORT is export = 10240;

class Prefix is export {
    enum < LONG SHORT NULL DEFAULT >;
}

class Style is export {
    enum < XOPT LONG SHORT ZIPARG COMB BSD MAIN CMD POS WHATEVERPOS DEFAULT >;
}

#| register info
role Info { ... }
#| publish message
role Message { ... }
#| publisher
role Publisher { ... }
#| subscriber
role Subscriber { ... }

role ContextProcessor { ... }

role RefOptionSet { ... }

class Debug { ... }

class OptionValueSetter { ... }

role Info is export {

    method check(Message $msg --> Bool) { ... }

    method process( $data ) { ... }
}

role Message is export {

    method id(--> Int) { ... }

    method data() { ... }
}

role Publisher is export {
    has Info @.infos;

    method publish(Message $msg) {
        for @!infos -> $info {
            if $info.check($msg) {
                $info.process($msg.data);
            }
        }
    }

    method subscribe(Info $info) {
        @!infos.push($info);
    }

    method clean-subscriber() {
        @!infos = [];
    }
}

role Subscriber is export {
    method subscribe(Publisher $p) { ... }
}

role ContextProcessor does Message is export {
    has $.style;
    has @.contexts;
    has $.handler;
    has $.id;

    method id() { $!id; }

    method data() { self; }

    method matched() {
        $!handler.success;
    }

    method process($o) {
        Debug::debug("== message {$!id}: [{self.style}|{self.contexts>>.gist.join(" + ")}]");
        if self.matched() {
            Debug::debug("- Skip");
        } else {
            Debug::debug("- Match <-> {$o.usage}");
            my ($matched, $skip) = (True, False);
            for @!contexts -> $context {
                if ! $context.success {
                    if $context.match(self, $o) {
                        $context.set(self, $o);
                        $skip ||= $context.?canskip;
                    } else {
                        $matched = False;
                    }
                }
            }
            if $matched {
                if $skip {
                    Debug::debug("  - Call handler to shift argument.");
                    $!handler.skip-next-arg();
                }
                $!handler.set-success();
            }
        }
        Debug::debug("- process end {$!id}");
    }
}

role RefOptionSet is export {
    has $.owner;

    method set-owner($!owner) { }

    method owner() { $!owner; }
}

class Debug is export {
    enum < DEBUG INFO WARN ERROR DIE NOLOG >;

    subset LEVEL of Int where { $_ >= DEBUG.Int && $_ <= ERROR.Int };

    our $g-level = WARN;
    our $g-stderr = $*ERR;

    our sub setLevel(LEVEL $level) {
        $g-level = $level;
    }

    our sub setStderr(IO::Handle $handle) {
        $g-stderr = $handle;
    }

    our sub print(Str $log, LEVEL $level = $g-level) {
        if $level >= $g-level {
            $*ERR.print(sprintf "[%-5s]: %s\n", $level, $log);
        }
    }

    our sub debug(Str $log) {
        Debug::print($log, Debug::DEBUG);
    }

    our sub info(Str $log) {
        Debug::print($log, Debug::INFO);
    }

    our sub warn(Str $log) {
        Debug::print($log, Debug::WARN);
    }

    our sub error(Str $log) {
        Debug::print($log, Debug::ERROR);
    }

    our sub die(Str $log) {
        die $log;
    }
}

class OptionValueSetter is export {
    has $.optref;
    has $.value;

    method set-value() {
        $!optref.set-value($!value, :callback);
    }
}

state @autohv-opt = [ "help", "version" ];

sub set-autohv(Str:D $help, Str:D $version) is export {
    @autohv-opt = ($help, $version);
}

sub get-autohv($optset) is export {
    given @autohv-opt {
        my ($f, $s) = ($optset.has(.[0], 'b'), $optset.has(.[1], 'b'));

        if !$f && !$s {
            &ga-raise-error("Need the boolean option " ~ .[0] ~ " or " ~ .[1] ~ " for autohv");
        }

        Debug::debug("Juage autohv eixsts: {@autohv-opt[0]}: {$f}, @autohv-opt[1]: {$s}");

        my $fs = $f ?? $optset.get(.[0], 'b').value.so !! False;
        my $ss = $s ?? $optset.get(.[1], 'b').value.so !! False;

        Debug::debug("Juage autohv : {@autohv-opt[0]}: {$fs}, @autohv-opt[1]: {$ss}");

        return [ $fs, $ss ];
    }
}

sub check-if-need-autohv($optset) is export {
    [||] &get-autohv($optset);
}
