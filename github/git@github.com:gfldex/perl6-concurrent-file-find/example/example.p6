use v6;
use lib 'lib';
use Concurrent::File::Find;

find(%*ENV<HOME>
    , :extension('txt', {.contains('~')})
    , :exclude('covers')
    , :exclude-dir('.')
    , :file
    , :!directory
    , :symlink
    , :recursive
    , :max-depth(5)
    , :follow-symlink
    , :keep-going
    , :quiet).elems.say;

sleep 10;

my @l := find-simple(%*ENV<HOME>, :keep-going, :!no-thread);

for @l {
    @l.channel.close if $++ > 5000;
    .say
}
