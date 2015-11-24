use v6;
use Test;
use NativeCall;


my $got-lib = lives-ok
{
    my $version := cglobal 'libmarkdown', 'markdown_version', Pointer[int8];
    say "# markdown_version: $version";
},
'libmarkdown is installed';


unless $got-lib
{
    diag q:to/HERE/;

        * * * * * * * * * * * * * * * * * * * * * * * * * * *
        Looks like you don't have the Discount library
        (libmarkdown) installed. It's required for this
        module to function. See this module's README.md at:
        https://github.com/hartenfels/Text-Markdown-Discount
        * * * * * * * * * * * * * * * * * * * * * * * * * * *
        HERE
    say 'Bail out! NativeCall to Discount (libmarkdown) not working';
    exit 255;
}


done-testing
