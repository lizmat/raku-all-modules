use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Christmas does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("7:02:52"), :rules(""), :until(-2366755200)}, {:baseoffset("7:00"), :rules(""), :until(Inf)}]<>;
