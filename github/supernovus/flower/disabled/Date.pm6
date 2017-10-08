class Flower::TAL::TALES::Date;

use DateTime::Format;
use DateTime::TimeZone;

has $.flower is rw;
has $.tales  is rw;

has %.handlers = 
  'date'     => 'date_string',
  'dateof'   => 'date_new',
  'time'     => 'date_time',
  'strftime' => 'date_format',
  'rfc'      => 'date_format_rfc',
  'now'      => 'date_format_now';

## dateof: modifier, Creates a DateTime object with the given spec.
## Usage:  dateof: year [month] [day] [hour] [minute] [second] :tz(timezone)
## The named paramter 'tz' must be specified in the common ISO offset format,
## '-0800' would represent a timezone that is 8 hours behind UTC.
## '+0430' would represent a timezone that is 4 hours and 30 minutes ahead.

method date_new ($query, *%opts) {
  my ($year, $month, $day, $hour, $minute, $second, %params) =
    $.tales.get-args(
      :query({'.STRING'=>1, 'tz' => 1}), 
      :named, $query, 1, 1, 0, 0, 0
    );
  if defined $year {
    my $timezone = 0;
    if %params.exists('tz') && %params<tz> ~~ Str {
      $timezone = tz-offset(%params<tz>);
    }
    my $dt = DateTime.new(
        :year($year.Int), :month($month.Int), :day(+$day.Int), 
        :hour($hour.Int), :minute($minute.Int), :second($second.Int), 
        :timezone($timezone)
    );
    return $.tales.process-query($dt, |%opts);
  }
}

## date: modifier, Creates a DateTime object based on an ISO datetime stamp.

method date_string ($query, *%opts) {
  my $dtstring = $.tales.query($query);
  my $dt = DateTime.new(~$dtstring);
  return $.tales.process-query($dt, |%opts);
}

## time: modifier, Creates a DateTime object based on an epoch integer/string.

method date_time ($query, *%opts) {
  my $epoch = $.tales.query($query);
  my $dt = DateTime.new($epoch.Int);
  return $.tales.process-query($dt, |%opts);
}

## strftime: modifier, formats a DateTime object.
## Usage:  strftime: format [date] [timezone]
## If date is not specified, it will be right now.
## For now with a specified timezone, use the now:
## modifier extension (see below).
## The date parameter can be a DateTime object, Date object
## or epoch integer/string.
## If you don't specify a timezone, then for Date objects
## or epoch integers, UTC will be used. DateTime objects will
## use their existing timezones.

method date_format ($query, *%opts) {
  my ($format, $date, $timezone) = 
    $.tales.get-args(:query, $query, DateTime.now(), Nil);
  if defined $format && defined $date {
    if defined $timezone {
      $timezone = tz-offset($timezone);
    }
    my $return;
    if $date ~~ DateTime {
      if defined $timezone {
        $date.=in-timezone($timezone);
      }
      $return = strftime($format, $date);
    }
    else {
      if !defined $timezone { $timezone = 0; }
      if $date ~~ Date {    
        $return = strftime($format, DateTime.new(:$date, :$timezone));
      }
      elsif $date ~~ Int {
        $return = strftime($format, DateTime.new($date, :$timezone));
      }
      elsif $date ~~ Str {
        ## We assume in the case of Str, the timezone is in the string.
        $return = strftime($format, DateTime.new($date));
      }
    }
  }
}

## rfc: special modifier extension for strftime.
## The only valid use for this, is in strftime: modifier queries.
## Don't use it on its own, as it assumes it's being parsed by strftime.
## Example:
## <div tal:content="strftime: rfc: {{date: 2010 10 10 :tz('-0800')}}"/>
## Will return <div>Sun, 10 Oct 2010 00:00:00 -0800</div>

method date_format_rfc ($query, *%opts) {
  return '%a, %d %b %Y %T %z';
}

## now: special modifier extension for strftime.
## Returns a datetime object representing 'right now'.

method date_format_now ($query, *%opts) {
  return DateTime.now();
}

