use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Barbados does DateTime::TimeZone::Zone;
has %.rules = ( 
 Barb => [{"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 6, "years" => 1977..1977, "date" => "12"}, {"time" => "2:00", "letter" => "S", "adjust" => "0", "month" => 10, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1977..1978}, {"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "15", "dow" => 7}, "years" => 1978..1980}, {"time" => "2:00", "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1979..1979, "date" => "30"}, {"time" => "2:00", "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1980..1980, "date" => "25"}],
);
has @.zonedata = Array.new({"baseoffset" => "-3:58:29", "rules" => "", "until" => -1451692800}, {"baseoffset" => "-3:58:29", "rules" => "", "until" => -1199232000}, {"baseoffset" => "-4:00", "rules" => "Barb", "until" => Inf});
