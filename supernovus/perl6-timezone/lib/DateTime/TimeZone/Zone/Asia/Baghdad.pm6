use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Baghdad does DateTime::TimeZone::Zone;
has %.rules = ( 
 Iraq => [{"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 5, "years" => 1982..1982, "date" => "1"}, {"time" => "0:00", "letter" => "S", "adjust" => "0", "month" => 10, "years" => 1982..1984, "date" => "1"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 3, "years" => 1983..1983, "date" => "31"}, {"time" => "0:00", "letter" => "D", "adjust" => "1:00", "month" => 4, "years" => 1984..1985, "date" => "1"}, {"time" => "1:00s", "lastdow" => 7, "letter" => "S", "adjust" => "0", "month" => 9, "years" => 1985..1990}, {"time" => "1:00s", "lastdow" => 7, "letter" => "D", "adjust" => "1:00", "month" => 3, "years" => 1986..1990}, {"time" => "3:00s", "letter" => "D", "adjust" => "1:00", "month" => 4, "years" => 1991..2007, "date" => "1"}, {"time" => "3:00s", "letter" => "S", "adjust" => "0", "month" => 10, "years" => 1991..2007, "date" => "1"}],
);
has @.zonedata = Array.new({"baseoffset" => "2:57:40", "rules" => "", "until" => -2524521600}, {"baseoffset" => "2:57:36", "rules" => "", "until" => -1640995200}, {"baseoffset" => "3:00", "rules" => "", "until" => 378691200}, {"baseoffset" => "3:00", "rules" => "Iraq", "until" => Inf});
