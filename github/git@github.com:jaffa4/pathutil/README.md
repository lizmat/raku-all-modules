pathutil
========




Path::Util

Break up a file path into its components.

Usage:


use Path::Util;


my $p = Path::Util.new("d:\\docs\\usage.txt");<br>
It can break-up Unix like or Dos like file paths.<br>

say $p.getdrive; or say $p.drive; # it gets the drive letter, for Windwos only. Otherwise, it returns "".<br>
say $p.getdir; or say $p.directory; or say $p.dir<br>
say $p.getext; or say $p.extension<br>
say $p.getbasename;  # returns the filename without directory<br>
say $p.getjustname;  # returns the filename without directory and extension<br>

Above also work without get.

say $p.print; # prints all components

say $p.separator; # returns the separator found in the path, it can be "\" or "/" or "".

say $p.fsseparator; # returns Windows or Unix-like file separator depending where you run your script

say $p.getnumberofdirlevel; # number of levels in the directory

say $p.getdirlevel(2); # returns directory up to the second level

say $p.tocygwin(); # returns the cygwin format of a Windows path, nothing happens if it is of other kind.<br>
e.g. /cygdrive/d/music/after.mp4

say $p.tomsys(); # returns the  msysformat of a Windows path, nothing happens if it is of other kind.<br>
e.g. /d/music/after.mp4

Also, it is possible to use them non-object oriented way. 

say Path::Util.getbasename("d:\\docs\\usage.txt");

Extension is returned without dot.
Directories are returned without ending separator.


