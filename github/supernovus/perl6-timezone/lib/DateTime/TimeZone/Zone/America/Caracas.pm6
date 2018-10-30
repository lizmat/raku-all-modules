use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::America::Caracas does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("-4:27:44"), :rules(""), :until(-2524521600)}, {:baseoffset("-4:27:40"), :rules(""), :until(-1826755200)}, {:baseoffset("-4:30"), :rules(""), :until(-157766400)}, {:baseoffset("-4:00"), :rules(""), :until(1197169200)}, {:baseoffset("-4:30"), :rules(""), :until(Inf)}]<>;
