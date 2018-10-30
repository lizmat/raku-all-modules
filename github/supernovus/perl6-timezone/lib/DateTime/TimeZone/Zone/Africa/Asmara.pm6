use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Asmara does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("2:35:32"), :rules(""), :until(-3155673600)}, {:baseoffset("2:35:32"), :rules(""), :until(-2524521600)}, {:baseoffset("2:35:20"), :rules(""), :until(-1062201600)}, {:baseoffset("3:00"), :rules(""), :until(Inf)}]<>;
