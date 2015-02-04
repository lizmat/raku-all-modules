use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::America::Bogota does DateTime::TimeZone::Zone;
has %.rules = ( 
 CO => [{"time" => "0:00", "letter" => "S", "adjust" => "1:00", "month" => 5, "years" => 1992..1992, "date" => "3"}, {"time" => "0:00", "letter" => "-", "adjust" => "0", "month" => 4, "years" => 1993..1993, "date" => "4"}],
);
has @.zonedata = Array.new({"baseoffset" => "-4:56:16", "rules" => "", "until" => -2707689600}, {"baseoffset" => "-4:56:16", "rules" => "", "until" => -1739059200}, {"baseoffset" => "-5:00", "rules" => "CO", "until" => Inf});
