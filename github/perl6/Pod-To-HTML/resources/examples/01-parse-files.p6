use v6;
use Pod::To::HTML;

put Pod::To::HTML.render('README.pod6'.IO, head-fields => '<style>a { color: black }</style>', title => 'README.pod6');



