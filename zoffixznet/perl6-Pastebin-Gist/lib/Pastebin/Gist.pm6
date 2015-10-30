unit class Pastebin::Gist:version<1.001001>;

use HTTP::Tinyish;

constant API-URL   = 'https://api.github.com/';
constant PASTE-URL = 'https://gist.github.com/';

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

    my $res = HTTP::Tinyish.new.post( API-URL ~ 'gists',
        headers => {
            Authorization => "token $!token",
            Content-Type  => 'application/json',
        },
        content => to-json %content,
    );

    return PASTE-URL ~ from-json( $res.<content> ).<id>;
}

method fetch ($what is copy) returns List {
    $what = $what.split('/').[*-1];

    my $res = from-json
        HTTP::Tinyish.new.get( API-URL ~ "gists/$what" ).<content>;

    my %files;
    for $res.<files>.keys {
        %files{$_} = $res.<files>{$_}<content>;
    }

    return ( %files, $res.<description> );
}
