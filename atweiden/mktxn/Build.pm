use v6;

# for zef
# tests require cloning atweiden/txn-examples into t/data
class Build
{
    method build($)
    {
        run qw<git clone https://github.com/atweiden/txn-examples t/data>;
        chdir 't/data';
        run qw<git checkout ff3b16b206267b312ddd44ef6e3710917b5e9999>;
    }
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
