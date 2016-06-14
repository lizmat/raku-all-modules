# Aria
Using aria2c from perl6

Install aria2 to use this module

apt-get install aria2

yum --enablerepo=rpmforge install aria2 -y

### Usage Example

```perl6
use Aria;

my $x = Aria.new();
my $proc = start {
  $x.get(".", "https://st.pimg.net/perlweb/images/camel_head.v25e738a.png");
  say "Download Complete";
}
say "Do other work";
await $proc; # download in separate process to do other work while downloading

###  functions
$x.get($dir, $link) # downloads http(s)/ftp link to $dir directory
$x.get-limit($dir, $link, $speed) # downloads at limited speed, give speed in string format
$x.get-multi($dir, $link1, $link2);
# use get-multi to download the same file from different servers
$x.get-multi($dir,$link1,$link2, $link3, $link4);
# you can pass upto four different links to download same file
$x.get-concurrent($dir, $link, $num); # downloads to the directory $dir using $num connections to host
$x.get-torrent($dir, $pathorlink-to-torrent); # Downloads from a torrent file
$x.get-torrent-limit($dir, $pathorlink-to-torrent, $up-speed, $down-speed);
# limits upload speed and download speed, send arguments in string form eg: "2M" or "150K"
$x.get-metalink($dir, $metalink); # downloads metalink
$x.get-magnet($dir, $magnet); # downloads magnetlink
$x.get-fromfile($dir, $file-path); #downloads all links in a file

#_________________________
my $link1 = "http://mirror.is.co.za/mirrors/linuxmint.com/iso//stable/17.3/linuxmint-17.3-cinnamon-64bit.iso";
my $link2 = "http://mirror.nus.edu.sg/LinuxMint-ISO//stable/17.3/linuxmint-17.3-cinnamon-64bit.iso";
my $link3 = "http://mirrors.psu.ac.th/linuxmint-iso//stable/17.3/linuxmint-17.3-cinnamon-64bit.iso";
$proc = start {
  $x.get-multi("./Mint", $link1, $link2, $link3);
  say "Download Complete";
}
say "Do other work";
await $proc;

# _______________
$x.get-torrent-limit("./mint","http://torrents.linuxmint.com/torrents/linuxmint-17.3-cinnamon-64bit.iso.torrent","250k","1M");
