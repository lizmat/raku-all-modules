use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Freetown does DateTime::TimeZone::Zone;
has %.rules = ( 
 SL => [{"time" => "0:00", "letter" => "SLST", "adjust" => "0:40", "month" => 6, "years" => 1935..1942, "date" => "1"}, {"time" => "0:00", "letter" => "WAT", "adjust" => "0", "month" => 10, "years" => 1935..1942, "date" => "1"}, {"time" => "0:00", "letter" => "SLST", "adjust" => "1:00", "month" => 6, "years" => 1957..1962, "date" => "1"}, {"time" => "0:00", "letter" => "GMT", "adjust" => "0", "month" => 9, "years" => 1957..1962, "date" => "1"}],
);
has @.zonedata = Array.new({"baseoffset" => "-0:53:00", "rules" => "", "until" => -2776982400}, {"baseoffset" => "-0:53:00", "rules" => "", "until" => -1798761600}, {"baseoffset" => "-1:00", "rules" => "SL", "until" => -410227200}, {"baseoffset" => "0:00", "rules" => "SL", "until" => Inf});
