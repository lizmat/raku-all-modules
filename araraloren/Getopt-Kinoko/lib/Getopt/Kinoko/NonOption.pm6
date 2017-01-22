
use v6;

use Getopt::Kinoko::Argument;
use Getopt::Kinoko::DeepClone;
use Getopt::Kinoko::Exception;

role NonOption does DeepClone {
    has &.callback;

    submethod BUILD(:&!callback) { }

    method process {
        X::Kinoko.new(msg => "process must be implement!").throw;
    }

    method perl { "" }

    multi method deep-clone() {
        self.bless(callback => &!callback);
    }
}

class NonOption::Front does NonOption {

    method perl {
        "NonOption::Front.new(callback => " ~ (&!callback.defined ?? &!callback.perl !! "Any") ~ ')';
    }

    method process(Argument $arg, $opts) {
        given &!callback.signature.count {
            when 2 {
                &!callback($arg, $opts);
            }
            when 1 {
                &!callback($arg);
            }
            default {
                X::Kinoko.new(msg => "process signature error!").throw;
            }
        }
    }
}

class NonOption::All does NonOption {

    method perl {
        "NonOption::All.new(callback => " ~ (&!callback.defined ?? &!callback.perl !! "Any") ~ ')';
    }

    method process(Argument @arg, $opts) {
        given &!callback.signature.count {
            when 2 {
                &!callback(@arg, $opts);
            }
            when 1 {
                &!callback(@arg);
            }
            default {
                X::Kinoko.new(msg => "process signature error!").throw;
            }
        }
    }
}

class NonOption::Each does NonOption {

    method perl {
        "NonOption::Each.new(callback => " ~ (&!callback.defined ?? &!callback.perl !! "Any") ~ ')';
    }

    method process(Argument $arg, $opts) {
        given &!callback.signature.count {
            when 2 {
                &!callback($arg, $opts);
            }
            when 1 {
                &!callback($arg);
            }
            default {
                X::Kinoko.new(msg => "process signature error!").throw;
            }
        }
    }
}

sub create-non-option(&callback, :$front?, :$all?, :$each?) is export {
    if $front.defined {
        NonOption::Front.new(:&callback);
    }
    elsif $all.defined {
        NonOption::All.new(:&callback);
    }
    elsif $each.defined {
        NonOption::Each.new(:&callback);
    }
    else {
        X::Kinoko.new(msg => "Need NonOption type").throw;
    }
}
