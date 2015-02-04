use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Antarctica::Vostok does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "0", "rules" => "", "until" => -380073600}, {"baseoffset" => "6:00", "rules" => "", "until" => Inf});
