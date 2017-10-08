use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Vientiane does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("6:50:24"), :rules(""), :until(-2005948800)}, {:baseoffset("7:06:20"), :rules(""), :until(-1855958340)}, {:baseoffset("7:00"), :rules(""), :until(-1830384000)}, {:baseoffset("8:00"), :rules(""), :until(-1230768000)}, {:baseoffset("7:00"), :rules(""), :until(Inf)}]<>;
