use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Indian::Mahe does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("3:41:48"), :rules(""), :until(-2019686400)}, {:baseoffset("4:00"), :rules(""), :until(Inf)}]<>;
