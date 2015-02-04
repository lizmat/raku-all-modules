use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Noumea does DateTime::TimeZone::Zone;
has %.rules = ( 
 NC => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 12, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1977..1978}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 2, "years" => 1978..1979, "date" => "27"}, {"time" => "2:00s", "letter" => "S", "adjust" => "1:00", "month" => 12, "years" => 1996..1996, "date" => "1"}, {"time" => "2:00s", "letter" => "-", "adjust" => "0", "month" => 3, "years" => 1997..1997, "date" => "2"}],
);
has @.zonedata = Array.new({"baseoffset" => "11:05:48", "rules" => "", "until" => -1829347200}, {"baseoffset" => "11:00", "rules" => "NC", "until" => Inf});
