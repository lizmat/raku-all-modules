use v6;

use Path::Util;
use Test;
plan *;


ok Path::Util.new("c:\\g\\b.mp4").getfullfilename() eq "c:\\g\\b.mp4","getfullfilename";

  #say Path::Util.new("c:\\g\\b.mp4").print;
 ok  Path::Util.new("c:\\g\\b.mp4").basename eq "b.mp4","basename1";

  ok Path::Util.new("c:\\g\\c.mp4").getbasename() eq "c.mp4","basename2";
   ok Path::Util.getbasename("c:\\g\\c.mp4") eq "c.mp4" ,"basename3";;

  ok Path::Util.new("c:\\g\\c.mp4").getjustname() eq "c","justname1";
  ok Path::Util.getjustname("c:\\g\\c.mp4") eq "c" ,"justname2";

 ok Path::Util.new("c:\\g\\c.mp4").getext() eq "mp4","extension1";
  ok Path::Util.getext("c:\\g\\c.mp4") eq "mp4","extension2";

 ok Path::Util.new("c:\\g\\c.mp4").getdir() eq "c:\\g", "getdir";
 ok Path::Util.getdir("c:\\g\\c.mp4"), "getdir2";

 ok Path::Util.new("c:\\g\\c.mp4").getnumberofdirlevel() == 2, "getnumberofdirlevel";
 ok Path::Util.getnumberofdirlevel("c:\\g\\c.mp4") == 2, "getnumberofdirlevel2";
 ok Path::Util.new("c:\\g\\c.mp4").getdirlevel(0) eq "c:", "getdirlevel";
 ok Path::Util.getdirlevel(0,"c:\\g\\c.mp4") eq "c:", "getdirlevel2";
 ok Path::Util.new("c:\\g\\c.mp4").getdirlevel(1) eq "c:\\g", "getdirlevel";
 ok Path::Util.getdirlevel(1,"c:\\g\\c.mp4") eq "c:\\g", "getdirlevel2";
 ok Path::Util.new("c:\\g\\c.mp4").getdirlevel(2) eq "c:\\g\\c.mp4", "getdirlevel";
 ok Path::Util.getdirlevel(2,"c:\\g\\c.mp4") eq "c:\\g\\c.mp4" , "getdirlevel2";
 ok  Path::Util.fsseparator ~~ /<[\\/]>/, "fsseparator";
 ok  Path::Util.new("c:\\g\\c.mp4").separator eq "\\", "separator";
 ok  Path::Util.getseparator("c:\\g\\c.mp4") eq "\\", "separator2";
ok  Path::Util.new("c:\\g\\c.mp4").drive eq "c", "drive win";
ok  Path::Util.new("/g/c.mp4").drive eq "", "drive linux";
ok  Path::Util.new("c:\\g\\c.mp4").getdrive eq "c", "get drive win";
ok  Path::Util.new("/g/c.mp4").getdrive eq "", "get drive linux";
ok  Path::Util.getdrive("c:\\g\\c.mp4") eq "c", "direct drive win";
ok  Path::Util.getdrive("/g/c.mp4") eq "", "direct drive linux";
ok   Path::Util.tocygwin("D:\\g\\c.mp4") eq "/cygdrive/d/g/c.mp4", "to cygwin";
ok   Path::Util.tomsys("D:\\g\\c.mp4") eq "/d/g/c.mp4", "to msys";


done-testing;