enum Time::Crontab::Set::Type<minute hour dom month dow>;

class Time::Crontab::Set {
    has Int $!start;
    has Int $!stop;
    has Bool %!value;

    method new(Time::Crontab::Set::Type :$type!) {
        my ($start, $stop);
        given $type {
            when Time::Crontab::Set::Type::minute {
                ($start, $stop) = (0,59);
            }
            when Time::Crontab::Set::Type::hour {
                ($start, $stop) = (0,23);
            }
            when Time::Crontab::Set::Type::dom  {
                ($start, $stop) = (1,31);
            }
            when Time::Crontab::Set::Type::month {
                ($start, $stop) = (1,12);
            }
            when Time::Crontab::Set::Type::dow {
                ($start, $stop) = (0,6);
            }
        }
        self.bless(:$start, :$stop);
    }

    submethod BUILD(:$!start, :$!stop) {
        self.disable($_) for ($!start .. $!stop);
    };

    method !check-num(Int $num) {
        die "$num must be between $!start and $!stop" unless $!start <= $num <= $!stop;
    }

    method disable (Int $num) {
        self!check-num($num);
        %!value{$num} = False;
    }
    multi method enable(Int $num) {
        self!check-num($num);
        %!value{$num} = True;
    }
    multi method enable(Int $from, Int $to) {
        self.enable($_) for ($from .. $to);
    }
    multi method enable(Int $from, Int $to, Int $step) {
        for ($from .. $to) {
            self.enable($_) if $_ % $step == 0;
        }
    }
    multi method enable-any() {
        self.enable($_) for ($!start .. $!stop);
    }
    multi method enable-any(Int $step) {
        for ($!start .. $!stop) {
            self.enable($_) if $_ % $step == 0;
        }
    }

    method contains(Int $num) {
        self!check-num($num);
        return %!value{$num};
    }

    method hash() {
        return %!value;
    }

    method will-ever-execute() {
        return any( %!value.values ) == True;
    }
    method all-enabled {
        return all( %!value.values ) == True;
    }

    multi method next(Int $offset) {
        my Int $distance = 0;
        my $ret = samewith($offset, $distance);
        return $ret;
    }
    multi method next(Int $offset, Int $distance is rw) {
        $distance = 0;
        for ($offset+1 .. $!stop) {
            $distance++;
            return $_ if %!value{$_};
        }
        for ($!start .. $offset) {
            $distance++;
            return $_ if %!value{$_};
        }
        return Int;
    }
}
