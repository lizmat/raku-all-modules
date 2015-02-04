use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Atlantic::Canary does DateTime::TimeZone::Zone;
has %.rules = ( 
 EU => [{"time" => "1:00u", "letter" => "S", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1977..1980}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1977..1977}, {"time" => "1:00u", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1978..1978, "date" => "1"}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1979..1995}, {"time" => "1:00u", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1981..Inf}, {"time" => "1:00u", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1996..Inf}],
);
has @.zonedata = Array.new({"baseoffset" => "-1:01:36", "rules" => "", "until" => -1514764800}, {"baseoffset" => "-1:00", "rules" => "", "until" => -733878000}, {"baseoffset" => "0:00", "rules" => "", "until" => 323827200}, {"baseoffset" => "1:00", "rules" => "", "until" => 338947200}, {"baseoffset" => "0:00", "rules" => "EU", "until" => Inf});
