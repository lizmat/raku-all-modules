use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Belize does DateTime::TimeZone::Zone;
has %.rules = ( 
 Belize => [{"time" => "0:00", "letter" => "HD", "adjust" => "0:30", "month" => 10, "dow" => {"mindate" => "2", "dow" => 7}, "years" => 1918..1942}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 2, "dow" => {"mindate" => "9", "dow" => 7}, "years" => 1919..1943}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 12, "years" => 1973..1973, "date" => "5"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 2, "years" => 1974..1974, "date" => "9"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 12, "years" => 1982..1982, "date" => "18"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 2, "years" => 1983..1983, "date" => "12"}],
);
has @.zonedata = Array.new({"baseoffset" => "-5:52:48", "rules" => "", "until" => -1830384000}, {"baseoffset" => "-6:00", "rules" => "Belize", "until" => Inf});
