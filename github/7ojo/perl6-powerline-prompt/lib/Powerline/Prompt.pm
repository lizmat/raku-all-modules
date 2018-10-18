use v6;

use Powerline::Prompt::Segment;
use Powerline::Prompt::Segment::Git;
use Powerline::Prompt::Segment::Root;
use Powerline::Prompt::Segment::Path;
use Powerline::Prompt::Segment::Readonly;

role Powerline::Prompt {

    has Str $.user;
    has Str $.host;
    has Str $.root;
    has Str $.path = '.';
    has Int $.exit = 0;

    method draw {
        my @segments;

        # Username
        @segments.push( Powerline::Prompt::Segment.new(text => $.user, foreground => 250, background => 240) );

        # Hostname
        @segments.push( Powerline::Prompt::Segment.new(text => $.host, foreground => 250, background => 238) );

        # Path
        @segments.push( Powerline::Prompt::Segment::Path.new(homedir => %*ENV<HOME>, cwd => $.path) );
        @segments.push( Powerline::Prompt::Segment::Readonly.new(cwd => $.path) );

        # Git
        @segments.push( Powerline::Prompt::Segment::Git.new(cwd => $.path) );

        # Root
        @segments.push( Powerline::Prompt::Segment::Root.new(text => $.root, exitcode => $.exit) );

        my Str $prompt = '';
        while my $segment = @segments.shift {
            next if $segment.text.chars == 0;           # skip empty segments

            my $next = @segments[0];
            while ($next && $next.text.chars == 0) {    # find next non empty segment
                @segments.shift;
                $next = @segments[0];
            }

            $prompt ~= $segment.draw($next);
        }

        $prompt;
    }

}
