# GTK::Scintilla [![Build Status](https://travis-ci.org/azawawi/perl6-gtk-scintilla.svg?branch=master)](https://travis-ci.org/azawawi/perl6-gtk-scintilla) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-gtk-scintilla?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-gtk-scintilla/branch/master)

Scintilla editing GTK widget is here :)

Note: This is an experimental proof of concept at the moment.

## Example

```Perl6
use v6;

use GTK::Simple::App;
use GTK::Simple::Raw;
use GTK::Scintilla;
use GTK::Scintilla::Editor;

my $app = GTK::Simple::App.new(title => "Hello GTK + Scintilla!");

my $editor = GTK::Scintilla::Editor.new;
$editor.size-request(500, 300);
$app.set-content($editor);

$editor.style-clear-all;
$editor.set-lexer(SCLEX_PERL);
$editor.style-set-foreground(SCE_PL_COMMENTLINE, 0x008000);
$editor.style-set-foreground(SCE_PL_POD, 0x008000);
$editor.style-set-foreground(SCE_PL_NUMBER, 0x808000);
$editor.style-set-foreground(SCE_PL_WORD, 0x800000);
$editor.style-set-foreground(SCE_PL_STRING, 0x800080);
$editor.style-set-foreground(SCE_PL_OPERATOR, 1);
$editor.insert-text(0, q{
# A Perl comment
use Modern::Perl;

say "Hello world";
});

$editor.show;
$app.run;
```

For more examples, please see the [examples](examples) folder.

## Documentation

Please see the [GTK::Scintilla](doc/GTK-Scintilla-Editor.md) generated documentation.

## Installation

Please check [GTK::Simple prerequisites](
https://github.com/perl6/gtk-simple/blob/master/README.md#prerequisites) section
for more information.

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install GTK::Scintilla
```

## Testing

To run tests:

```
$ prove -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
