use v6.c;
use Test;

plan 16;

{
    use Net::servent;
    for <
      &getservbyname &getservbyport &getservent &setservent &endservent
      &getserv
    > -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

{
    use Net::servent :FIELDS;
    for <
      &getservbyname &getservbyport &getservent &setservent &endservent
      &getserv $s_name @s_aliases $s_port $s_proto
    > -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

# vim: ft=perl6 expandtab sw=4
