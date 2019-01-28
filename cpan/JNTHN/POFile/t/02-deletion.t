use v6;
use Test;
use POFile;

my ($PO, $result);

$PO = q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr ""
END

my $el1 = POFile::Entry.parse($PO);

$PO = q:to/END/;
#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr ""
END

my $el2 = POFile::Entry.parse($PO);

$PO = q:to/END/;
#: finddialog.cpp:40
msgid "Planetary Nebulae"
msgstr ""
END

my $el3 = POFile::Entry.parse($PO);

$result = POFile.new;
is $result.elems, 0, 'POFile is empty by default';

$result.push($el1);
$result.push($el3);

is $result.elems, 2, 'Added two elements';

is ~$result, q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr ""

#: finddialog.cpp:40
msgid "Planetary Nebulae"
msgstr ""
END

$result{'Planetary Nebulae'}:delete;

is $result.elems, 1, 'Deleted an element by key';

$result.push($el2);

is ~$result, q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr ""

#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr ""
END

$result[1]:delete;

is $result.elems, 1, 'Deleted an element by index';

is ~$result, q:to/END/;
#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr ""
END

throws-like { $result[*-10]:delete },
    POFile::IncorrectIndex, 'Negative index has typed exception';
throws-like { $result[10]:delete },
    POFile::IncorrectIndex, 'Too large index has typed exception';
throws-like { $result{'not-a-key'}:delete },
    POFile::IncorrectKey, 'Missing key has typed exception';


done-testing;
