use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Africa::Sao_Tome does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("0:26:56"), :rules(""), :until(-2713910400)}, {:baseoffset("-0:36:32"), :rules(""), :until(-1830384000)}, {:baseoffset("0:00"), :rules(""), :until(Inf)}]<>;
