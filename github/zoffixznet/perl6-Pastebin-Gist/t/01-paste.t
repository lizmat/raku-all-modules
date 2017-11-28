use lib <lib>;
use Test;
use Pastebin::Gist;

plan 7;

my $p = Pastebin::Gist.new(
    token => '7042d1' # Github revokes tokens if it notices them in source
    ~ '47ec9'
    ~ 'f800ce'
    ~ '835935'
    ~ 'a24e3'
    ~ 'ee30e'
    ~ 'c5872c7',
);

my $paste_url = $p.paste(
    "Perl 6 Module Test<p>\n& <pre>foo",
    desc => 'My Summary <>&',
);
ok $paste_url ~~ /^ 'https://gist.github.com/' <[\w]>+ $/,
    "Paste URL [$paste_url] is sane";


my ($files, $desc) = $p.fetch: $paste_url;
is $desc, 'My Summary <>&', 'Retrieved description is good';
for keys $files {
    is $_, 'nopaste.txt', 'Paste filename is sane';
    is $files.{$_}, "Perl 6 Module Test<p>\n& <pre>foo",
        'Paste content is sane';
}

ok $p.delete($paste_url), 'tried to delete a gist';
throws-like { $p.fetch: $paste_url }, Pastebin::Gist::X,
    :message{ .contains: 'not found' }, 'gist got deleted';

throws-like { $p.delete: $paste_url }, Pastebin::Gist::X,
    :message{ .contains: 'not found' },
    'we get a 404 on deleting non-existent gists';

=finish

GitHub testing account:
Login: per
l6-tes
ter
Pass: tes
ter-p
erl6
Token:
