use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Pacific::Saipan does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-14:17:00"), :rules(""), :until(-3944678400)}, {:baseoffset("9:43:00"), :rules(""), :until(-2177452800)}, {:baseoffset("9:00"), :rules(""), :until(-31536000)}, {:baseoffset("10:00"), :rules(""), :until(977529600)}, {:baseoffset("10:00"), :rules(""), :until(Inf)}]<>;
