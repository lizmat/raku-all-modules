use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Manila does DateTime::TimeZone::Zone;
has %.rules = ( 
 Phil => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 11, "years" => 1936..1936, "date" => "1"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 2, "years" => 1937..1937, "date" => "1"}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 1954..1954, "date" => "12"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 7, "years" => 1954..1954, "date" => "1"}, {"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1978..1978, "date" => "22"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1978..1978, "date" => "21"}],
);
has @.zonedata = Array.new({"baseoffset" => "-15:56:00", "rules" => "", "until" => -3944678400}, {"baseoffset" => "8:04:00", "rules" => "", "until" => -2229292800}, {"baseoffset" => "8:00", "rules" => "Phil", "until" => -883612800}, {"baseoffset" => "9:00", "rules" => "", "until" => -820540800}, {"baseoffset" => "8:00", "rules" => "Phil", "until" => Inf});
