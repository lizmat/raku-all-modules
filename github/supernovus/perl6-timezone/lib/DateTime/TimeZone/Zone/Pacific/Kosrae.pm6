use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Kosrae does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("10:51:56"), :rules(""), :until(-2177452800)}, {:baseoffset("11:00"), :rules(""), :until(-31536000)}, {:baseoffset("12:00"), :rules(""), :until(915148800)}, {:baseoffset("11:00"), :rules(""), :until(Inf)}]<>;
