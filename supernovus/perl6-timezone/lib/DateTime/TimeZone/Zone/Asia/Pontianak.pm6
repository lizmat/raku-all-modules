use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Pontianak does DateTime::TimeZone::Zone;
has %.rules = ( 
);
has @.zonedata = [{:baseoffset("7:17:20"), :rules(""), :until(-1956614400)}, {:baseoffset("7:17:20"), :rules(""), :until(-1199232000)}, {:baseoffset("7:30"), :rules(""), :until(-881193600)}, {:baseoffset("9:00"), :rules(""), :until(-766022400)}, {:baseoffset("7:30"), :rules(""), :until(-694310400)}, {:baseoffset("8:00"), :rules(""), :until(-631152000)}, {:baseoffset("7:30"), :rules(""), :until(-189388800)}, {:baseoffset("8:00"), :rules(""), :until(567993600)}, {:baseoffset("7:00"), :rules(""), :until(Inf)}]<>;
