use DateTime::Format;

## A Parent Class for Format objects.
unit class DateTime::Format::Factory does Callable;

#use DateTime::Format;

method FORMAT { ... }

## Return a DateTime object representing a string.
method from-string (Str $timestamp, *%opts) {
  strptime($timestamp, $.FORMAT, :formatter(self), |%opts);
}

## Return a string representing a DateTime object.
method to-string (DateTime $datetime, *%opts) {
  strftime($.FORMAT, $datetime, |%opts);
}

## For use as the formatter for a DateTime object.
method postcircumfix:<( )> ($args) {
  $.to-string(|$args);
}

