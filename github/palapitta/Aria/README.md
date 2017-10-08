# Aria
Install aria2 to use this module

apt-get install aria2 , yum --enablerepo=rpmforge install aria2 -y

### Usage
Each function returns one of the three values OK, ERR, INPR. OK for sucessful download
 ERR for error downloading INPR for in-progess download. if INPR encounterd call the
 same function with same parameters to resume download.

### Usage Example

```perl6
use Aria;

my $x = Aria.new();
my $proc = start {
  my $res = $x.get(".", "https://st.pimg.net/perlweb/images/camel_head.v25e738a.png");
  say "Download Complete" if $res eq "OK";
}
say "Do other work";
await $proc; # download in separate process to do other work while downloading

###  functions
$x.get($dir, $link) # downloads http(s), ftp, magnet, torrent, metalink to $dir directory
$x.get-limit($dir, $link, $speed) # downloads at limited speed, give speed in string format eq: "200k"
$x.get-multi($dir,$link1,$link2, $link3, $link4);
#get-multi is to download the same file from different servers, pass 2 or more links
$x.get-concurrent($dir, $link, $num); # downloads $link using $num connections to host

# Example_________________________
my $link1 = "http://mirror.is.co.za/mirrors/linuxmint.com/iso//stable/17.3/linuxmint-17.3-cinnamon-64bit.iso";
my $link2 = "http://mirror.nus.edu.sg/LinuxMint-ISO//stable/17.3/linuxmint-17.3-cinnamon-64bit.iso";
my $link3 = "http://mirrors.psu.ac.th/linuxmint-iso//stable/17.3/linuxmint-17.3-cinnamon-64bit.iso";
my $res = $x.get-multi("./Mint", $link1, $link2, $link3);
say "Download Complete" if $res eq "OK";

# _______________
my res = $x.get-limit("./mint","http://torrents.linuxmint.com/torrents/linuxmint-17.3-cinnamon-64bit.iso.torrent","250k");
say "Download Complete" if $res eq "OK";
