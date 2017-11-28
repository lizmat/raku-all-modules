unit class Pastebin::Gist;

use WWW :extras;
use JSON::Fast;

class X is Exception { has $.message }

constant API-URL   = 'https://api.github.com/';
constant PASTE-URL = 'https://gist.github.com/';
constant %UA       = :User-Agent('Rakudo Pastebin::Gist');

subset ValidGistToken of Str where /:i <[a..f 0..9]> ** 40/;
has ValidGistToken $.token = %*ENV<PASTEBIN_GIST_TOKEN>;

method paste (
    $paste,
    Str  :$desc     = '',
    Str  :$filename = 'nopaste.txt',
    Bool :$public   = False,
) returns Str {
    my %content = public      => $public,
                  description => $desc,
                  files       => $paste ~~ Hash
                                    ?? $paste
                                    !! { $filename => { content => $paste } };

    my $res = jpost API-URL ~ 'gists', %content.&to-json,
        |%UA, :Authorization("token $!token"), :Content-Type<application/json>
    orelse die X.new: :message(.exception.message);

    return PASTE-URL ~ $res<id>;
}

method fetch ($what) returns List {
    with jget API-URL ~ "gists/$what.split('/').tail()", |%UA -> $res {
        my %files;
        %files{$_} = $res.<files>{$_}<content> for $res<files>:v.keys;
        return %files, $res<description>;
    }
    else -> $_ {
        when *.exception.message.contains: 'Error 404' {
            die X.new: :message('404 paste not found');
        }
        die X.new: :message(.exception.message);
    }
}

method delete ($what) returns Bool {
    with delete API-URL ~ "gists/$what.split('/').tail()", |%UA,
        :Authorization("token $!token"), :Content-Type<application/json>
    {
        return True;
    }
    else -> $_ {
        when *.exception.message.contains: 'Error 404' {
            die X.new: :message('404 paste not found');
        }
        die X.new: :message(.exception.message);
    }
}
