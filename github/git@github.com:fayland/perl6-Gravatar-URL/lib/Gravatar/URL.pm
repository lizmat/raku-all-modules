unit module Gravatar::URL;

use URI::Escape;
use Digest::MD5;

sub gravatar_id($email) is export {
    return Digest::MD5.new.md5_hex($email.trim.lc);
}

sub gravatar_url(:$email!, :$size, :$rating, :$default, :$short_keys=1, :$https) is export {
    my $gravatar_id;
    if $email.chars == 32 and not index($email, '@').defined {
        $gravatar_id = $email;
    } else {
        $gravatar_id = gravatar_id($email);
    }

    my @pairs;
    @pairs.push( join('=', $short_keys ?? 'r' !! 'rating',  $rating.lc ) ) if $rating;
    @pairs.push( join('=', $short_keys ?? 's' !! 'size',    $size ) )   if $size;
    @pairs.push( join('=', $short_keys ?? 'd' !! 'default', uri-escape($default) ) ) if $default;

    my $url = $https ?? 'https://secure.gravatar.com/avatar/' !! 'http://www.gravatar.com/avatar/';
    $url ~= $gravatar_id;
    $url ~= '?' ~ join('&', @pairs) if @pairs.elems;

    return $url;
}

