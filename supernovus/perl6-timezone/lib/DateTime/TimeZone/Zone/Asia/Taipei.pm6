use v6;
use DateTime::TimeZone::Zone;
unit class DateTime::TimeZone::Zone::Asia::Taipei does DateTime::TimeZone::Zone;
has %.rules = ( 
 Taiwan => [{:adjust("1:00"), :date("1"), :letter("D"), :month(5), :time("0:00"), :years(1945..1951)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("0:00"), :years(1945..1951)}, {:adjust("1:00"), :date("1"), :letter("D"), :month(3), :time("0:00"), :years(1952..1952)}, {:adjust("0"), :date("1"), :letter("S"), :month(11), :time("0:00"), :years(1952..1954)}, {:adjust("1:00"), :date("1"), :letter("D"), :month(4), :time("0:00"), :years(1953..1959)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("0:00"), :years(1955..1961)}, {:adjust("1:00"), :date("1"), :letter("D"), :month(6), :time("0:00"), :years(1960..1961)}, {:adjust("1:00"), :date("1"), :letter("D"), :month(4), :time("0:00"), :years(1974..1975)}, {:adjust("0"), :date("1"), :letter("S"), :month(10), :time("0:00"), :years(1974..1975)}, {:adjust("1:00"), :date("30"), :letter("D"), :month(6), :time("0:00"), :years(1979..1979)}, {:adjust("0"), :date("30"), :letter("S"), :month(9), :time("0:00"), :years(1979..1979)}],
);
has @.zonedata = [{:baseoffset("8:06:00"), :rules(""), :until(-2335219200)}, {:baseoffset("8:00"), :rules("Taiwan"), :until(Inf)}]<>;
