
use v6;

use Getopt::Kinoko::Option;
use Getopt::Kinoko::DeepClone;

#| Group has multi options
role Group does DeepClone {
    has @.options;

    method options() {
        @!options;
    }

    method size() {
        +@!options;
    }

    multi method push(Option $option) {
        @!options.push: $option;
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

    method append(Str $options) {
        @!options.push(create-option($_)) for $options.split(';', :skip-empty);
        self;
    }

    method has-option(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return True if $opt.match-name($name, :$long, :$short);
        }
        False
    }

    method has-value(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return $opt.has-value if $opt.match-name($name, :$long, :$short);
        }
        False
    }

    multi method get-option(Int $index) {
        @!options[$index];
    }

    multi method get-option(Str $name, :$long, :$short) {
        for @!options -> $opt {
            return $opt if $opt.match-name($name, :$long, :$short);
        }
    }

    multi method get-option-rw(Int $index) is rw {
        @!options[$index];
    }

    multi method get-option-rw(Str $name, :$long, :$short) is rw {
        for @!options -> $opt {
            return $opt if $opt.match-name($name, :$long, :$short);
        }
    }

    method set-value(Str $name, $value, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                $opt.set-value($value);
                return True;
            }
        }
        False;
    }

    method set-value-callback(Str $name, $value, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                $opt.set-value-callback($value);
                return True;
            }
        }
        False;
    }

    method set-callback(Str $name, &callback, :$long, :$short) {
        for @!options -> $opt {
            if $opt.match-name($name, :$long, :$short) {
                $opt.set-callback(&callback);
                return True;
            }
        }
        False;
    }

    multi method deep-clone() {
        self.bless(options => DeepClone.deep-clone(@!options));
    }

    method !base-perl() {
        my $bp = "[ ";

        for @!options -> $opt {
            $bp ~= $opt.perl ~ ", " ;
        }
        $bp ~= ']';
        $bp;
    }

    method perl { "" }

    method check() { X::Kinoko.new(msg => "Driver class must implement check").throw; }
}

class Group::Normal does Group {

    method perl() { "Group::Normal.new(options => " ~ self!base-perl() ~ ')'; }

    method check() {
        for @!options -> $opt {
            if $opt.is-force && !$opt.has-value {
                X::Kinoko.new(msg => ($opt.is-short ?? $opt.short-name !! $opt.long-name) ~
                    ": Option value is required.").throw();
            }
        }
    }
}

class Group::Radio does Group {
    has $.force;

    method perl() { "Group::Radio.new(force => " ~ $!force ~ ', options => ' ~ self!base-perl() ~ ')'; }

    method !clear-value {
        for @!options {
            .reset if .has-value;
        }
    }

    method set-value(Str $name, $value, :$long, :$short) {
        self!clear-value;
        self.Group::set-value($name, $value, :$long, :$short);
    }

    method set-value-callback(Str $name, $value, :$long, :$short) {
        self!clear-value;
        self.Group::set-value-callback($name, $value, :$long, :$short);
    }

    method check() {
        my @has-value = [];

        for @!options -> $opt {
            if $opt.has-value {
                @has-value.push: $opt.is-short ?? "-{$opt.short-name}" !! "--{$opt.long-name}";
            }
        }

        if +@has-value == 0 && $!force {
            X::Kinoko.new(msg => ": Group value is force required.").throw();
        }

        if +@has-value > 1 {
            my $msg = "";

            $msg ~= $_ ~ " " for @has-value;

            X::Kinoko.new(msg => $msg ~ ": Group value only allow set one.").throw();
        }
    }

    multi method push(Str $option, $value, :&callback) {
        self!clear-value;
        self.Group::push($option, $value, :&callback);
    }

    multi method deep-clone() {
        self.bless(
            options => DeepClone.deep-clone(@!options),
            force => DeepClone.deep-clone($!force)
        );
    }
}

class Group::Multi does Group {

    method perl() { "Group::Multi.new(options => " ~ self!base-perl() ~ ')'; }

    method check() {
        for @!options -> $opt {
            if $opt.is-force && !$opt.has-value {
                X::Kinoko.new(msg => ($opt.is-short ?? $opt.short-name !! $opt.long-name) ~
                    ": Option value is required.").throw();
            }
        }
    }
}

sub create-group(Str $opts, :$force, :$normal, :$radio, :$multi) is export {
    my $group;

    if $normal.defined {
        $group = Group::Normal.new().append($opts);
    }
    elsif $radio.defined {
        $group = Group::Radio.new(:$force).append($opts);
    }
    elsif $multi.defined {
        $group = Group::Multi.new().append($opts);
    }
    else {
        X::Kinoko.new(msg => ": Need Group type.").throw();
    }
    $group;
}
