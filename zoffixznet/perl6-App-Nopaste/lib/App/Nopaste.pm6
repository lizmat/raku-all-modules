unit class App::Nopaste:version<1.001001>;

use Pastebin::Gist;
use Pastebin::Shadowcat;

subset ValidPastebins of Str where any <gist shadow>;
method paste ( @files ) returns Str {
    if ( %*ENV<PASTEBIN_GIST_TOKEN> ) {
        my %paste;
        %paste{$_.IO.basename}<content> = $_.IO.slurp for @files;
        return Pastebin::Gist.new.paste(%paste);
    }
    else {
        my $content = @files.elems == 1
            ?? @files[0].IO.slurp
            !! join "\n\n\n", map { "#### File: $_\n" ~ $_.IO.slurp }, @files;

        return Pastebin::Shadowcat.new.paste($content);
    }
}

multi method fetch (Str $url where /gist/ ) returns List {
    my ( $files, $desc ) = Pastebin::Gist.new.fetch($url);
    my Str $paste; $paste ~= "#### File: $_\n$files{$_}" for $files.keys;
    return ( $paste, $desc.chars ?? $desc !! 'N/A' );
}

multi method fetch (Str $url where /fpaste/) returns List {
    my ( $paste, $desc ) = Pastebin::Shadowcat.new.fetch($url);
    return ( $paste, $desc.chars ?? $desc !! 'N/A' );
}
