use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Kuching does DateTime::TimeZone::Zone;
has %.rules = ( 
 NBorneo => [{:adjust("0:20"), :date("14"), :letter("TS"), :month(9), :time("0:00"), :years(1935..1941)}, {:adjust("0"), :date("14"), :letter("-"), :month(12), :time("0:00"), :years(1935..1941)}],
);
has @.zonedata = [{:baseoffset("7:21:20"), :rules(""), :until(-1388534400)}, {:baseoffset("7:30"), :rules(""), :until(-1167609600)}, {:baseoffset("8:00"), :rules("NBorneo"), :until(-879638400)}, {:baseoffset("9:00"), :rules(""), :until(-766972800)}, {:baseoffset("8:00"), :rules(""), :until(378691200)}, {:baseoffset("8:00"), :rules(""), :until(Inf)}]<>;
