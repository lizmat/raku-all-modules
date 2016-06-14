
use v6;

use Getopt::Kinoko::Group;
use Getopt::Kinoko::Option;
use Getopt::Kinoko::DeepClone;
use Getopt::Kinoko::Exception;

#| OptionSet can manager a variety of options
class OptionSet does DeepClone {
    has Option @!options;
    has        @!names;
    has        &!callback;

    #| C<&optionset-str> is a option set string such as "a=a;c=i;"
    #| options delimited with semicolon
    #| C<&callback> is NOA process function
    method new(Str $optionset-str = "", :&callback) {
        self.bless(:&callback).append($optionset-str);
    }

    submethod BUILD(:@!options, :&!callback = Block) { }

    method has(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return True if $opt.match-name($name, :$long, :$short);
        }
        False
    }

    method has-value(Str $name, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                return $opt.has-value;
            }
        }
        False
    }

    method get(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return $opt if $opt.match-name($name, :$long, :$short);
        }
        Option;
    }

    method set-value(Str $name, $value, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                $opt.set-value($value);
                last;
            }
        }
    }

    method set-callback(Str $name, &callback, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                $opt.set-callback(&callback);
                last;
            }
        }
    }

    #| can modify value
    method AT-POS(::?CLASS::D: $index) is rw {
        return @!options[$index].value;
        #`[Proxy.new(
            FETCH => method () {
                if @!options[$index].value ~~ Array {
                    return @!options[$index].value.List;
                }
                @!options[$index].value;
            },
            STORE => method ($value) {
                @!options[$index].set-value($value);
            }
        );]
    }

    #| can modify value
    method AT-KEY(::?CLASS::D: $name) is rw {
        for @!options -> $opt {
            if $opt.match-name($name) {
                return $opt.value;
                #| this proxy has problem when access array
                #`[return Proxy.new(
                    FETCH => method () {
                        if $opt.value ~~ Array {
                            return $opt.value.List;
                        }
                        $opt.value;
                    },
                    STORE => method ($value) {
                        $opt.set-value($value);
                    }
                );]
            }
        }
    }

    method EXISTS-KEY($name) {
        return self.has($name);
    }

    method EXISTS-POS(Int $index) {
        $index < self.Numeric();
    }

    method values() {
        return @!options;
    }

    method is-set-noa-callback() {
        &!callback.defined;
    }

    method set-noa-callback(&callback) {
        &!callback = &callback;
    }

    method process-noa($noa) {
        &!callback($noa);
    }

    method Numeric() {
        return +@!options;
    }

    method check-force-value() {
        for @!options -> $opt {
            if $opt.is-force && !$opt.has-value {
                X::Kinoko.new(msg => ($opt.is-short ?? $opt.short-name !! $opt.long-name) ~
                    ": Option value is required.").throw();
            }
        }
    }

    method generate-method(Str $prefix = "") {
        for @!options -> $opt {
            if $opt.is-long {
                self.^add_method($prefix ~ $opt.long-name, my method { $opt; });
                self.^compose();
            }
            if $opt.is-short {
                self.^add_method($prefix ~ $opt.short-name, my method { $opt; });
                self.^compose();
            }
        }
        self;
    }

    #=[ option-string;option-string;... ]
    method append(Str $optionset-str) {
        return self if $optionset-str.trim.chars == 0;
        @!options.push(create-option($_)) for $optionset-str.split(';', :skip-empty);
        self;
    }

    multi method push(*%option) {
        @!options.push: create-option(|%option);
        self;
    }

    multi method push(Str $option, :&callback) {
        @!options.push: create-option($option, cb => &callback);
        self;
    }

    multi method push(Str $option, $value, :&callback, ) {
        @!options.push: create-option($option, cb => &callback, :$value);
        self;
    }

    #=[
        how to convenient forward parameters ?
    ]
    method push-str(Str :$short, Str :$long, Bool :$force, :&callback, Str :$value) {
        self.push(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<s>);
    }

    method push-int(Str :$short, Str :$long, Bool :$force, :&callback, Int :$value) {
        self.push(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<i>);
    }

    method push-arr(Str :$short, Str :$long, Bool :$force, :&callback, :$value) {
        self.push(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<a>);
    }

    method push-hash(Str :$short, Str :$long, Bool :$force, :&callback, :$value) {
        self.push(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<h>);
    }

    method push-bool(Str :$short, Str :$long, Bool :$force, :&callback, Bool :$value) {
        self.push(sn => $short, ln => $long, :$force, cb => &callback, :$value, :mt<b>);
    }

    method usage() {
        my Str $usage;

        for @!options -> $opt {
            $usage ~= ' [';
            $usage ~= $opt.usage;
            $usage ~= '] ';
        }

        $usage;
    }

    multi method deep-clone() {
        self.bless(self.CREATE(),
            callback => &!callback, options => DeepClone.deep-clone(@!options));
    }
}
