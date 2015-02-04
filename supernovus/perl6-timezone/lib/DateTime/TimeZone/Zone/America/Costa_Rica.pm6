use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Costa_Rica does DateTime::TimeZone::Zone;
has %.rules = ( 
 CR => [{"time" => "0:00", "lastdow" => 7, "letter" => "D", "adjust" => "1:00", "month" => 2, "years" => 1979..1980}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 6, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1979..1980}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 1, "dow" => {"mindate" => "15", "dow" => 6}, "years" => 1991..1992}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 7, "years" => 1991..1991, "date" => "1"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 3, "years" => 1992..1992, "date" => "15"}],
);
has @.zonedata = Array.new({"baseoffset" => "-5:36:13", "rules" => "", "until" => -2524521600}, {"baseoffset" => "-5:36:13", "rules" => "", "until" => -1545091200}, {"baseoffset" => "-6:00", "rules" => "CR", "until" => Inf});
