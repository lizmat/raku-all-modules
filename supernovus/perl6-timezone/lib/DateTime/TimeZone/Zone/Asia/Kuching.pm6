use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Asia::Kuching does DateTime::TimeZone::Zone;
has %.rules = ( 
 NBorneo => [{"time" => "0:00", "letter" => "TS", "adjust" => "0:20", "month" => 9, "years" => 1935..1941, "date" => "14"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 12, "years" => 1935..1941, "date" => "14"}],
);
has @.zonedata = Array.new({"baseoffset" => "7:21:20", "rules" => "", "until" => -1388534400}, {"baseoffset" => "7:30", "rules" => "", "until" => -1167609600}, {"baseoffset" => "8:00", "rules" => "NBorneo", "until" => -879638400}, {"baseoffset" => "9:00", "rules" => "", "until" => -766972800}, {"baseoffset" => "8:00", "rules" => "", "until" => 378691200}, {"baseoffset" => "8:00", "rules" => "", "until" => Inf});
