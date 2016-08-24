use v6;
use Panda::Builder;
use Panda::Common;

# for panda only
# tests require cloning atweiden/txn-examples into t/data
class Build is Panda::Builder
{
    method build($workdir)
    {
        run qw<git clone https://github.com/atweiden/txn-examples t/data>;
    }
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
