use v6;
use lib 'lib';
use Test;
use Powerline::Prompt::Segment::Path;
use Powerline::Prompt::Segment::Readonly;

plan 1;

subtest 'Powerline::Prompt::Segment::Path', {
    plan 12;
    sub to-path($seg) {
        my @parts;
        for $seg.parts -> $part {
            @parts.push: $part.text;
        };
        @parts.join('/');
    }

    my $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users/myaccount/Git/a/b/c/d');
    is to-path($seg), '~/Git/a/…/c/d', 'got ~/Git/a/…/c/d';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users/myaccount/Git/a/b/c');
    is to-path($seg), '~/Git/a/b/c', 'got ~/Git/a/b/c';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users/myaccount/Git/a/b');
    is to-path($seg), '~/Git/a/b', 'got ~/Git/a/b';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users/myaccount/Git/a');
    is to-path($seg), '~/Git/a', 'got ~/Git/a';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users/myaccount/Git');
    is to-path($seg), '~/Git', 'got ~/Git';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users/myaccount');
    is to-path($seg), '~', 'got ~';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/Users');
    is to-path($seg), 'Users', 'got Users';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/');
    is to-path($seg), '/', 'got /';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/usr/share');
    is to-path($seg), 'usr/share', 'got usr/share';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/usr/local/share/perl6/sources');
    is to-path($seg), 'usr/local/…/perl6/sources', 'got usr/local/…/perl6/sources';

    $seg = Powerline::Prompt::Segment::Path.new(homedir => '/Users/myaccount', cwd => '/usr/local');
    is to-path($seg), 'usr/local', 'got usr/local';

    my Str $temp = $seg.draw(Powerline::Prompt::Segment::Readonly.new(cwd => '/usr/local'));
    is $temp.substr(33, 20), 'usr \[\e[38;5;244m\]', 'foreground color'
};

