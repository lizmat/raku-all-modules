use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Efate does DateTime::TimeZone::Zone;
has %.rules = ( 
 Vanuatu => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 9, "years" => 1983..1983, "date" => "25"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 3, "dow" => {"mindate" => "23", "dow" => 7}, "years" => 1984..1991}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 10, "years" => 1984..1984, "date" => "23"}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 9, "dow" => {"mindate" => "23", "dow" => 7}, "years" => 1985..1991}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 1, "dow" => {"mindate" => "23", "dow" => 7}, "years" => 1992..1993}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 10, "dow" => {"mindate" => "23", "dow" => 7}, "years" => 1992..1992}],
);
has @.zonedata = Array.new({"baseoffset" => "11:13:16", "rules" => "", "until" => -1829347200}, {"baseoffset" => "11:00", "rules" => "Vanuatu", "until" => Inf});
