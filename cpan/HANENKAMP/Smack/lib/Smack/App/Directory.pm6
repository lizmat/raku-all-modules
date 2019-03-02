use v6;

use Smack::App::File;

unit class Smack::App::Directory is Smack::App::File;

use Smack::Date;
use Smack::Util;
use Smack::Request;
use URI::Escape;

# Stolen from Plack::App::Directory
my $dir-file = q:to/DIR-FILE/;
<tr>
    <td class="name"><a href="%s">%s</a></td>
    <td class="size">%s</td>
    <td class="type">%s</td>
    <td class="mtime">%s</td>
</tr>
DIR-FILE

my $dir-page = q:to/DIR-PAGE/;
<html>
    <head>
        <title>%s</title>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
        <style type="text/css">
table { width: 100%% }
.name { text-align: left }
.size, .mtime { text-align: right }
.type { width: 11em }
.mtime { width: 15em }
        </style>
    </head>
    <body>
        <h1>%s</h1>
        <hr />
        <table>
            <tr>
                <th class="name">Name</th>
                <th class="size">Size</th>
                <th class="type">Type</th>
                <th class="mtime">Last Modified</th>
            </tr>
            %s
        </table>
        <hr />
    </body>
</html>
DIR-PAGE

method should-handle($file) { $file.d || $file.f }

method redirect-to-directory(%env) {
    my $uri = Smack::Request.new(%env).uri;

    301,
    [
        Location       => "$uri/",
        Content-Type   => 'text/plain',
        Content-Lenght => 8,
    ],
    [ 'Redirect' ]
}

method serve-path(%env, $dir) {
    return callsame if $dir.f; # go back up ::File for files

    my $dir-url = %env<SCRIPT_NAME> ~ %env<PATH_INFO>;
    return self.redirect-to-directory(%env)
        unless $dir-url.ends-with('/');

    my @files = [ $( "../", "Parent Directory", '', '', '' ) ];

    my @children = $dir.dir.grep(* ~~ none('.', '..'));
    for @children.sort -> $file {
        my $basename = $file.basename;
        my $url      = $dir-url ~ $basename;

        $url.=split('/').=map(&uri-escape).=join('/');

        if $file.d {
            $basename ~= '/';
            $url      ~= '/';
        }

        my $mime-type = $file.d ?? 'directory' !! (
            Smack::MIME.mime-type($file) // 'text/plain');
        @files.push: ( $url, $basename, $file.s, $mime-type, time2str($file.modified.DateTime) );
    }

    my $path = encode-html("Index of %env<PATH_INFO>");
    my $files = @files.map(-> @f {
        sprintf $dir-file, |@f.map(&encode-html)
    }).join("\n");
    my $page = sprintf $dir-page, $path, $path, $files;

    200,
    [
        Content-type => 'text/html; charset=utf-8'
    ],
    [ $page ]
}
