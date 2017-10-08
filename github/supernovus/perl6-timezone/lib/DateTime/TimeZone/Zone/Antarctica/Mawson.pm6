use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Antarctica::Mawson does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0"), :rules(""), :until(-501206400)}, {:baseoffset("6:00"), :rules(""), :until(1255831200)}, {:baseoffset("5:00"), :rules(""), :until(Inf)}]<>;
