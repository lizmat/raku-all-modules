use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Hovd does DateTime::TimeZone::Zone;
has %.rules = ( 
 Mongol => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 1983..1984, "date" => "1"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 10, "years" => 1983..1983, "date" => "1"}, {"time" => "0:00", "lastdow" => 7, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 1985..1998}, {"time" => "0:00", "lastdow" => 7, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 1984..1998}, {"time" => "2:00", "lastdow" => 6, "letter" => "S", "adjust" => "1:00", "month" => 4, "years" => 2001..2001}, {"time" => "2:00", "lastdow" => 6, "letter" => "-", "adjust" => "0", "month" => 9, "years" => 2001..2006}, {"time" => "2:00", "lastdow" => 6, "letter" => "S", "adjust" => "1:00", "month" => 3, "years" => 2002..2006}],
);
has @.zonedata = Array.new({"baseoffset" => "6:06:36", "rules" => "", "until" => -2051222400}, {"baseoffset" => "6:00", "rules" => "", "until" => 252460800}, {"baseoffset" => "7:00", "rules" => "Mongol", "until" => Inf});
