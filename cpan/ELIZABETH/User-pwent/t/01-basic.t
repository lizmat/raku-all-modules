use v6.c;
use Test;

plan 25;

{
    use User::pwent;
    for <&getpwnam &getpwuid &getpwent &setpwent &endpwent &getpw> -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

{
    use User::pwent :FIELDS;
    for <&getpwnam &getpwuid &getpwent &setpwent &endpwent &getpw
         $pw_name $pw_passwd $pw_uid $pw_gid $pw_change $pw_age
         $pw_quota $pw_comment $pw_class $pw_gecos $pw_dir
         $pw_shell $pw_expire> -> $name {
       ok OUTER::MY::<<$name>>:exists, "is $name imported by default?";
    }
}

# vim: ft=perl6 expandtab sw=4
