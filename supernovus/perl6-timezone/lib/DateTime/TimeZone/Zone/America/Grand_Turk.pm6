use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Grand_Turk does DateTime::TimeZone::Zone;
has %.rules = ( 
 TC => [{"time" => "2:00", "lastdow" => 7, "letter" => "D", "adjust" => "1:00", "month" => 4, "years" => 1979..1986}, {"time" => "2:00", "lastdow" => 7, "letter" => "S", "adjust" => "0", "month" => 10, "years" => 1979..2006}, {"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1987..2006}, {"time" => "2:00", "letter" => "D", "adjust" => "1:00", "month" => 3, "dow" => {"mindate" => "8", "dow" => 7}, "years" => 2007..Inf}, {"time" => "2:00", "letter" => "S", "adjust" => "0", "month" => 11, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 2007..Inf}],
);
has @.zonedata = Array.new({"baseoffset" => "-4:44:32", "rules" => "", "until" => -2524521600}, {"baseoffset" => "-5:07:11", "rules" => "", "until" => -1830384000}, {"baseoffset" => "-5:00", "rules" => "TC", "until" => Inf});
