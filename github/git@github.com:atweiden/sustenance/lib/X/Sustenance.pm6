use v6;

# X::Sustenance::FoodMissing {{{

class X::Sustenance::FoodMissing
{
    also is Exception;

    has Str:D $.name is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message =
            sprintf(Q{Sorry, could not find matching food named %s}, $.name);
    }
}

# end X::Sustenance::FoodMissing }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
