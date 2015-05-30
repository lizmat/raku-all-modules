use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Dili does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("8:22:20"), :rules(""), :until(-1830384000)}, {:baseoffset("8:00"), :rules(""), :until(-879123600)}, {:baseoffset("9:00"), :rules(""), :until(-766022400)}, {:baseoffset("9:00"), :rules(""), :until(199929600)}, {:baseoffset("8:00"), :rules(""), :until(969148800)}, {:baseoffset("9:00"), :rules(""), :until(Inf)}]<>;
