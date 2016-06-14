# Bencode
To encode and decode bencoding strings used in bittorrent applications

## Usage Example
```perl6
use Bencode;
my $b = Bencode.new();
say $b.bencode({"announce" => "http://torrents.linuxmint.com/announce.php","created by" => "Transmission/2.82 (14160)","creation date" => "1449261537","encoding"=> "UTF-8","info" => {"length" => "1581383680","name" => "linuxmint-17.3-cinnamon-64bit.iso"}});

say $b.bdecode('d8:announce42:http://torrents.linuxmint.com/announce.php10:created by25:Transmission/2.82 (14160)13:creation datei1449261537e8:encoding5:UTF-84:infod6:lengthi1581383680e4:name33:linuxmint-17.3-cinnamon-64bit.isoee');
