use v6;

unit class WWW::DuckDuckGo::Link;

use WWW::DuckDuckGo::Icon;
use URI;

has $.result;
has $.first_url;
has $.icon;
has $.text;

method has-icon() {
    so $!icon.url;
}

method new($link_result) {
    my $result = $link_result<Result>;
    my $first_url = URI.new($link_result<FirstURL>) if so $link_result<FirstURL>;
    my $icon = WWW::DuckDuckGo::Icon.new($link_result<Icon>) if so $link_result;
    my $text = $link_result<Text>;
    self.bless(:$result, :$first_url, :$icon, :$text);
}
