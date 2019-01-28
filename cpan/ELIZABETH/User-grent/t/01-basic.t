use v6.c;
use Test;

plan 16;

{
    use User::grent;
    for <&getgrnam &getgrgid &getgrent &setgrent &endgrent &getgr> -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

{
    use User::grent :FIELDS;
    for <&getgrnam &getgrgid &getgrent &setgrent &endgrent &getgr
         $gr_name $gr_passwd $gr_gid @gr_members> -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

# vim: ft=perl6 expandtab sw=4
