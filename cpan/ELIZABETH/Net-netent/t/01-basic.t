use v6.c;
use Test;

plan 16;

{
    use Net::netent;
    for <
      &getnetbyname &getnetbyaddr &getnetent &setnetent &endnetent &getnet
    > -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

{
    use Net::netent :FIELDS;
    for <
      &getnetbyname &getnetbyaddr &getnetent &setnetent &endnetent &getnet
      $n_name @n_aliases $n_addrtype $n_net
    > -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

# vim: ft=perl6 expandtab sw=4
