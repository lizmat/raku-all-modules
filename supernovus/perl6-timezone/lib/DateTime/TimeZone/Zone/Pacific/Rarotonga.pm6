use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Rarotonga does DateTime::TimeZone::Zone;
has %.rules = ( 
 Cook => [{"time" => "0:00", "letter" => "HS", "adjust" => "0:30", "month" => 11, "years" => 1978..1978, "date" => "12"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 3, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1979..1991}, {"time" => "0:00", "lastdow" => 7, "letter" => "HS", "adjust" => "0:30", "month" => 10, "years" => 1979..1990}],
);
has @.zonedata = Array.new({"baseoffset" => "-10:39:04", "rules" => "", "until" => -2177452800}, {"baseoffset" => "-10:30", "rules" => "", "until" => 279676800}, {"baseoffset" => "-10:00", "rules" => "Cook", "until" => Inf});
