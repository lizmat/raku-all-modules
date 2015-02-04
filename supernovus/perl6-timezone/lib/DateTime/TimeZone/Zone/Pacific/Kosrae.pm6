use v6;
use DateTime::TimeZone::Zone;
class DateTime::TimeZone::Zone::Pacific::Kosrae does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = Array.new({"baseoffset" => "10:51:56", "rules" => "", "until" => -2177452800}, {"baseoffset" => "11:00", "rules" => "", "until" => -31536000}, {"baseoffset" => "12:00", "rules" => "", "until" => 915148800}, {"baseoffset" => "11:00", "rules" => "", "until" => Inf});
