use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Addis_Ababa does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("2:34:48"), :rules(""), :until(-3155673600)}, {:baseoffset("2:35:20"), :rules(""), :until(-1062201600)}, {:baseoffset("3:00"), :rules(""), :until(Inf)}]<>;
