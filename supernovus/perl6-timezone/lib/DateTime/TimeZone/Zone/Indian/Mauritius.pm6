use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Indian::Mauritius does DateTime::TimeZone::Zone;
has %.rules = ( 
 Mauritius => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 10, "years" => 1982..1982, "date" => "10"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 3, "years" => 1983..1983, "date" => "21"}, {"time" => "2:00", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 10, "years" => 2008..2008}, {"time" => "2:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 3, "years" => 2009..2009}],
);
has @.zonedata = Array.new({"baseoffset" => "3:50:00", "rules" => "", "until" => -1988150400}, {"baseoffset" => "4:00", "rules" => "Mauritius", "until" => Inf});
