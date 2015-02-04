use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Africa::Accra does DateTime::TimeZone::Zone;
has %.rules = ( 
 Ghana => [{"time" => "0:00", "letter" => "GHST", "adjust" => "0:20", "month" => 9, "years" => 1936..1942, "date" => "1"}, {"time" => "0:00", "letter" => "GMT", "adjust" => "0", "month" => 12, "years" => 1936..1942, "date" => "31"}],
);
has @.zonedata = Array.new({"baseoffset" => "-0:00:52", "rules" => "", "until" => -1640995200}, {"baseoffset" => "0:00", "rules" => "Ghana", "until" => Inf});
