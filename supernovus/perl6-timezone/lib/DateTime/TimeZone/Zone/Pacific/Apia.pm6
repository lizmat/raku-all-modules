use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Apia does DateTime::TimeZone::Zone;
has %.rules = ( 
 WS => [{"time" => "3:00", "lastdow" => 7, "letter" => "D", "adjust" => "1", "month" => 9, "years" => 2012..Inf}, {"time" => "4:00", "letter" => "-", "adjust" => "0", "month" => 4, "dow" => {"mindate" => "1", "dow" => 7}, "years" => 2012..Inf}],
);
has @.zonedata = Array.new({"baseoffset" => "12:33:04", "rules" => "", "until" => -2855692800}, {"baseoffset" => "-11:26:56", "rules" => "", "until" => -1861920000}, {"baseoffset" => "-11:30", "rules" => "", "until" => -631152000}, {"baseoffset" => "-11:00", "rules" => "", "until" => 1285459200}, {"baseoffset" => "-10:00", "rules" => "", "until" => 1301716800}, {"baseoffset" => "-11:00", "rules" => "", "until" => 1316833200}, {"baseoffset" => "-10:00", "rules" => "", "until" => 1325203200}, {"baseoffset" => "14:00", "rules" => "", "until" => 1325376000}, {"baseoffset" => "13:00", "rules" => "WS", "until" => Inf});
