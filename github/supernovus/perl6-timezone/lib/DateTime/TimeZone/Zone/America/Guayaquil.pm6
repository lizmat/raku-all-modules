use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Guayaquil does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-5:19:20"), :rules(""), :until(-2524521600)}, {:baseoffset("-5:14:00"), :rules(""), :until(-1230768000)}, {:baseoffset("-5:00"), :rules(""), :until(Inf)}]<>;
