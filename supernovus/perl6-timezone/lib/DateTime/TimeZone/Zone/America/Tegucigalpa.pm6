use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Tegucigalpa does DateTime::TimeZone::Zone;
has %.rules = ( 
 Hond => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1987..1988}, {"time" => "0:00", "lastdow" => 7, "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1987..1988}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 2006..2006}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 8, "dow" => {"mindate" => "1", "dow" => 1}, "years" => 2006..2006}],
);
has @.zonedata = Array.new({"baseoffset" => "-5:48:52", "rules" => "", "until" => -1546300800}, {"baseoffset" => "-6:00", "rules" => "Hond", "until" => Inf});
