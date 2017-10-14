use v6.c;

my constant nano = 1;
my constant micro = nano * 1000;
my constant milli = micro * 1000;
my constant sec = milli * 1000;
my constant min = sec * 60;
my constant hour = min * 60;
my constant day = hour * 24;

#|[Class for representing a time unit like nanosecond or hour.
#
#You not need to new instances of the class.
#Just use corresponding constant instances like nanos or hours.]
class TimeUnit {
  has Str $.name;
  has Int $.nanos-volume;

  #|Convert specified number from current unit to nanoseconds.
  method to-nanos($d) {
    $d * ($!nanos-volume / nano);
  }

  #|Convert specified number from current unit to microseconds.
  method to-micros($d) {
    $d * ($!nanos-volume / micro);
  }

  #|Convert specified number from current unit to milliseconds.
  method to-millis($d) {
    $d * ($!nanos-volume / milli);
  }

  #|Convert specified number from current unit to seconds.
  method to-seconds($d) {
    $d * ($!nanos-volume / sec);
  }

  #|Convert specified number from current unit to minutes.
  method to-minutes($d) {
    $d * ($!nanos-volume / min);
  }

  #|Convert specified number from current unit to hours.
  method to-hours($d) {
    $d * ($!nanos-volume / hour);
  }

  #|Convert specified number from current unit to days.
  method to-days($d) {
    $d * ($!nanos-volume / day);
  }

  #|Convert specified number from specified unit to current unit.
  multi method from($d, TimeUnit:D $u) {
    $d * ($u.nanos-volume / $!nanos-volume);
  }

  #|Convert specified number from nanos unit to current unit.
  multi method from(:$nanos!) {
    $nanos * (nano / $!nanos-volume);
  }

  #|Convert specified number from micros unit to current unit.
  multi method from(:$micros!) {
    $micros * (micro / $!nanos-volume);
  }

  #|Convert specified number from millis unit to current unit.
  multi method from(:$millis!) {
    $millis * (milli / $!nanos-volume);
  }

  #|Convert specified number from seconds unit to current unit.
  multi method from(:$seconds!) {
    $seconds * (sec / $!nanos-volume);
  }

  #|Convert specified number from minutes unit to current unit.
  multi method from(:$minutes!) {
    $minutes * (min / $!nanos-volume);
  }

  #|Convert specified number from hours unit to current unit.
  multi method from(:$hours!) {
    $hours * (hour / $!nanos-volume);
  }

  #|Convert specified number from days unit to current unit.
  multi method from(:$days!) {
    $days * (day / $!nanos-volume);
  }

  multi method from(|) {
    die 'you can only use from method with named parameters: ' ~
      'nanos, micros, millis, seconds, minutes, hours, days.';
  }
}

constant nanos   = TimeUnit.new: name => 'nanosecond',  nanos-volume => nano;
constant micros  = TimeUnit.new: name => 'microsecond', nanos-volume => micro;
constant millis  = TimeUnit.new: name => 'millisecond', nanos-volume => milli;
constant seconds = TimeUnit.new: name => 'second',      nanos-volume => sec;
constant minutes = TimeUnit.new: name => 'minute',      nanos-volume => min;
constant hours   = TimeUnit.new: name => 'hour',        nanos-volume => hour;
constant days    = TimeUnit.new: name => 'day',         nanos-volume => day;



