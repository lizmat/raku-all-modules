use v6;

unit module WebService::Google::PageRank;

use URI::Escape;
use HTTP::Tinyish;

my sub int_str($str is copy, $integer is copy, $factor) {
    for 0 .. $str.chars - 1 -> $i {
        $integer *= $factor;
        $integer = $integer +& 0xFFFFFFFF;
        $integer += ord( substr($str, $i, 1) );
    }
    return $integer;
}

my sub hash_url($url) {
    my $c1 = int_str($url, 0x1505, 0x21);
    my $c2 = int_str($url, 0, 0x1003F);

    $c1 = $c1 +> 2;
    $c1 = (($c1 +> 4) +& 0x3FFFFC0) +| ($c1 +& 0x3F);
    $c1 = (($c1 +> 4) +& 0x3FFC00) +| ($c1 +& 0x3FF);
    $c1 = (($c1 +> 4) +& 0x3C000) +| ($c1 +& 0x3FFF);

    my $t1 = ($c1 +& 0x3C0) +< 4;
    $t1 = $t1 +| $c1 +& 0x3C;
    $t1 = ($t1 +< 2) +| ($c2 +& 0xF0F);

    my $t2 = ($c1 +& 0xFFFFC000) +< 4;
    $t2 = $t2 +| $c1 +& 0x3C00;
    $t2 = ($t2 +< 0xA) +| ($c2 +& 0xF0F0000);

    return ($t1 +| $t2);
}

my sub check_hash($hash_int) {
    my $hash_str = sprintf('%u', $hash_int);
    my $check_byte = 0;
    my $flag = 0;

    for (0 .. $hash_str.chars - 1).reverse -> $i {
        my $b = substr($hash_str, $i, 1);
        if (1 == ($flag % 2)) {
            $b *= 2;
            $b = ($b / 10).Int + $b % 10;
        }
        $check_byte += $b;
        $flag += 1;
    }

    $check_byte = $check_byte % 10;
    if 0 != $check_byte {
        $check_byte = 10 - $check_byte;
        if 1 == $flag % 2 {
            if 1 == $check_byte % 2 {
                $check_byte += 9;
            }
            $check_byte = $check_byte +> 1;
        }
    }

    return '7' ~ $check_byte ~ $hash_str;
}

class X::WebService::Google::PageRank is Exception {
    has $.status;
    has $.reason;

    method message {
        "Error: '$.status $.reason'";
    }
}

sub get_pagerank($url) is export {
    state $ua = HTTP::Tinyish.new(agent => "Mozilla/4.0 (compatible; GoogleToolbar 2.0.114-big; Windows XP 5.1)");

    my $hsh = check_hash(hash_url($url));
    my $gurl = 'http://toolbarqueries.google.com/tbr?client=navclient-auto&features=Rank:&q=info:' ~ uri-escape($url) ~ '&ch=' ~ $hsh;
    my %res = $ua.get($gurl);
    # say %res.perl;

    if ! %res<success> {
        X::WebService::Google::PageRank.new(status => %res<status>, reason => %res<reason>).throw;
    }

    # :content("Rank_1:1:9\n")
    if %res<content>.starts-with("Rank_") {
        return substr(%res<content>.trim, 9, %res<content>.trim.chars - 9);
    }

    return;
}
