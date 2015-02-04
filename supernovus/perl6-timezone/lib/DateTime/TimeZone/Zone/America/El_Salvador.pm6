use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::El_Salvador does DateTime::TimeZone::Zone;
has %.rules = ( 
 Salv => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1987..1988}, {"time" => "0:00", "lastdow" => 7, "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1987..1988}],
);
has @.zonedata = Array.new({"baseoffset" => "-5:56:48", "rules" => "", "until" => -1546300800}, {"baseoffset" => "-6:00", "rules" => "Salv", "until" => Inf});
