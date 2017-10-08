Rakudo::Perl6::Format
==============


Format Perl6 code. 

Known limitations: if there is a `BEGIN`, there will not be any formatting.
Also, if classes are imported from nqp.


## Usage

    use Rakudo::Perl6::Format;


    my $f = Rakudo::Perl6::Format.new(); # create a new object
    say $f.format({indentsize=>4},$content); # format using indentsize 4.

Only identation size can be set now.

## Command line access:


    $ perl6 format.p6 -h

    $ perl6 format.p6 -is 4 \<Dagrammar.p6 \>formatted.p6
