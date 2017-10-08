use v6;

unit class WWW::DuckDuckGo::Icon;

use URI;

has $.url;
has $.width;
has $.height;

method new($icon_result) {
    my $url = URI.new($icon_result<URL>) if so $icon_result<URL>;
    my $height = $icon_result<height> if so $icon_result<Height>;
    my $width = $icon_result<width> if $icon_result<Width>;
    self.bless(:$url, :$width, :$height);
}
