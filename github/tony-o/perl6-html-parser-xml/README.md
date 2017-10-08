#Perl 6: HTML::Parser::XML;

This module will read HTML and attempt to build an XML::Document (https://github.com/supernovus/exemel/#xmldocument-xmlnode) 
##Features:
* Automatically closes certain tags if certain other tags are encountered
* Parses dirty HTML fairly well (AFAIK), submit a bug if it doesn't
* Perl6 Magicness

##Status:
Bugs/feature requests
Maintenance mode

###Usage:
```perl6
my $html   = LWP::Simple.get('http://some-non-https-site.com/');
my $parser = HTML::Parser::XML.new;
$parser.parse($html);
$parser.xmldoc; # XML::Document
```

>or

```perl6
my $html   = LWP::Simple.get('http://some-non-https-site.com/');
my $parser = HTML::Parser::XML.new;
my $xmldoc = $parser.parse($html);
```


Contact me, segomos on irc.freenode #perl6 (segomos)

License: Artistic 2.0
