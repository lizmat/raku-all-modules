use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Fiji does DateTime::TimeZone::Zone;
has %.rules = ( 
 Fiji => [{"time" => "2:00", "letter" => "S", "adjust" => "1:00", "month" => 11, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 1998..1999}, {"time" => "3:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 2, "years" => 1999..2000}, {"time" => "2:00", "letter" => "S", "adjust" => "1:00", "month" => 11, "years" => 2009..2009, "date" => "29"}, {"time" => "3:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 3, "years" => 2010..2010}, {"time" => "2:00", "letter" => "S", "adjust" => "1:00", "month" => 10, "dow" => {"mindate" => "21", "dow" => 7}, "years" => 2010..Inf}, {"time" => "3:00", "letter" => "-", "adjust" => "0", "month" => 3, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 2011..2011}, {"time" => "3:00", "letter" => "-", "adjust" => "0", "month" => 1, "dow" => {"mindate" => "18", "dow" => 7}, "years" => 2012..Inf}],
);
has @.zonedata = Array.new({"baseoffset" => "11:55:44", "rules" => "", "until" => -1709942400}, {"baseoffset" => "12:00", "rules" => "Fiji", "until" => Inf});
