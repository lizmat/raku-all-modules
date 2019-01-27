
use v6;

class wkhtmltopdf {

  method version {
    my $output = qq:x/wkhtmltopdf --version/.chomp;
    if $output ~~ /^wkhtmltopdf\s+(\d+).(\d+).(\d+)/ {
      my ($major, $minor, $patch) = (~$/[0], ~$/[1], ~$/[2]);
      return ($major, $minor, $patch)
    } else {
      die "Failed to get/match wkhtmltopdf version"
    }
  }
}

my ($major, $minor, $patch) = wkhtmltopdf.version;
say "version = $major.$minor.$patch";
