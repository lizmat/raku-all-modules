use v6;
use Test;
use POFile;

my ($PO, $result);

$PO = q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr ""

#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr ""

#: finddialog.cpp:40
msgid "Planetary Nebulae"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'msgid, msgstr with source reference comment';
ok $result[0].reference eq 'finddialog.cpp:38', 'First comment is set';
ok $result{'Planetary Nebulae'}.reference eq 'finddialog.cpp:40', 'Third comment is set';
is ~$result, $PO, 'Serialization is done';

$PO = q:to/END/;
#: finddialog.cpp:38
msgid "Globular Clusters"
msgstr "Globularna jata"

#: finddialog.cpp:39
msgid "Gaseous Nebulae"
msgstr "Gasne magline"

#: finddialog.cpp:40
msgid "Planetary Nebulae"
msgstr "Planetarne magline"
END

lives-ok { $result = POFile.parse($PO) }, 'msgid, msgstr with source reference comment';
ok $result[0].msgstr eq 'Globularna jata', 'First msgstr is set';
ok $result{'Planetary Nebulae'}.msgstr eq 'Planetarne magline', 'Third msgstr is set';
is ~$result, $PO, 'Serialization is done';

$PO = q:to/END/;
#: indimenu.cpp:96
msgid ""
"No INDI devices currently running. To run devices, please select devices "
"from the Device Manager in the devices menu."
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Multi-line msgid';
ok $result[0].msgid eq 'No INDI devices currently running. To run devices, please select devices from the Device Manager in the devices menu.', 'Multi-line un-quoted correctly';

$PO = q:to/END/;
#. TRANSLATORS: A test phrase with all letters of the English alphabet.
#. Replace it with a sample text in your language, such that it is
#. representative of language's writing system.
#: kdeui/fonts/kfontchooser.cpp:382
msgid "The Quick Brown Fox Jumps Over The Lazy Dog"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Extracted comments';
ok $result[0].extracted eq 'TRANSLATORS: A test phrase with all letters of the English alphabet.Replace it with a sample text in your language, such that it isrepresentative of language\'s writing system.', 'Extracted comment is set';

$PO = q:to/END/;
#: tools/observinglist.cpp:700
msgctxt "First letter in 'Scope'"
msgid "S"
msgstr ""

#: skycomponents/horizoncomponent.cpp:429
msgctxt "South"
msgid "S"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Message context';
ok $result[0].msgctxt eq "First letter in 'Scope'", 'First msgctxt is set';
ok $result[1].msgctxt eq "South", 'Second msgctxt is set';

$PO = q:to/END/;
# Wikipedia says that ‘etrurski’ is our name for this script.
#: viewpart/UnicodeBlocks.h:151
msgid "Old Italic"
msgstr "etrurski"
END

lives-ok { $result = POFile.parse($PO) }, 'Translator comments';
ok $result[0].comment eq 'Wikipedia says that ‘etrurski’ is our name for this script.', 'Translator comment is set';
ok $result[0].reference eq 'viewpart/UnicodeBlocks.h:151', 'Reference comment is set';

$PO = q:to/END/;
#: skycomponents/constellationlines.cpp:106
#, kde-format
msgid "No star named %1 found."
msgstr "Nema zvezde po imenu %1."
END

lives-ok { $result = POFile.parse($PO) }, 'Format comment is set';
ok $result[0].format-style eq 'kde-format', 'Format comment is set';

$PO = q:to/END/;
#. Tag: title
#: blackbody.docbook:13
msgid "<title>Blackbody Radiation</title>"
msgstr ""

#. Tag: para
#: geocoords.docbook:28
msgid ""
"The Equator is obviously an important part of this coordinate system; "
"it represents the <emphasis>zeropoint</emphasis> of the latitude angle, "
"and the halfway point between the poles. The Equator is the "
"<firstterm>Fundamental Plane</firstterm> of the geographic coordinate "
"system. <link linkend='ai-skycoords'>All Spherical</link> Coordinate "
"Systems define such a Fundamental Plane."
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Markup';

$PO = q:to/END/;
#: kstars_i18n.cpp:3591
msgid "The \"face\" on Mars"
msgstr "\"Lice\" na Marsu"
END

lives-ok { $result = POFile.parse($PO) }, 'Escape - double quote';
ok $result[0].msgid eq 'The "face" on Mars', 'Double quote is unescaped';
ok $result[0].msgid-quoted eq 'The \"face\" on Mars', 'msgid-unquoted returns quoted version';
ok $result[0].msgstr eq '"Lice" na Marsu', 'Double quote is unescaped';
ok $result[0].msgstr-quoted eq '\"Lice\" na Marsu', 'msgstr-unquoted returns quoted version';


$PO = q:to/END/;
#: kstarsinit.cpp:699
msgid ""
"The initial position is below the horizon.\n"
"Would you like to reset to the default position?"
msgstr ""
"Početni položaj je ispod horizonta.\n"
"Želite li da vratite na podrazumevani?"
END

lives-ok { $result = POFile.parse($PO) }, 'Escape - newline';
ok $result[0].msgid eq 'The initial position is below the horizon.\nWould you like to reset to the default position?', 'New line character is escaped';

$PO = q:to/END/;
msgid ""
"\t\\\t"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Escape - tab and backslash';
ok $result[0].msgid eq '\t\\t', 'Tabs and backslash symbols are escaped';

$PO = q:to/END/;
#: kstarsinit.cpp:163
msgid "Set Focus &Manually..."
msgstr "フォーカスを手動でセット(&M)..."
END

lives-ok { $result = POFile.parse($PO) }, 'Accelerator';
ok $result[0].msgstr eq 'フォーカスを手動でセット(&M)...', 'msgstr with accelerator is parsed and set';

$PO = q:to/END/;
#: kspopupmenu.cpp:203
msgid "Center && Track"
msgstr ""

#. Tag: phrase
#: config.docbook:137
msgid "<phrase>Configure &kstars; Window</phrase>"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Accelerator 2';

$PO = q:to/END/;
#: mainwindow.cpp:127
#, kde-format
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"

msgid "<phrase>Configure &kstars; Window</phrase>"
msgstr ""
END

lives-ok { $result = POFile.parse($PO) }, 'Plural forms';
ok $result[0].msgid-plural eq 'Time: %1 seconds', 'Plural form of msgid is set';
ok $result[0].msgstr[0] eq 'Czas: %1 sekunda', 'First plural message is set';
ok $result[0].msgstr[2] eq 'Czas: %1 sekund', 'Third plural message is set';

$PO = q:to/END/;
#: src/somwidget_impl.cpp:120
#, fuzzy
#| msgid "Elements with boiling point around this temperature:"
msgid "Elements with melting point around this temperature:"
msgstr "Elementi s tačkom ključanja u blizini ove temperature:"
END

lives-ok { $result = POFile.parse($PO) }, 'Fuzzy';
is $result[0].fuzzy-msgid, '"Elements with boiling point around this temperature:"', 'Fuzzy msgid is set';

$PO = q:to/END/;
#: kstarsinit.cpp:451
#, fuzzy
#| msgctxt "Constellation Line"
#| msgid "Constell. Line"
msgctxt "Toggle Constellation Lines in the display"
msgid "Const. Lines"
msgstr "Linija sazvežđa"
END

lives-ok { $result = POFile.parse($PO) }, 'Fuzzy 2';
is $result[0].fuzzy-msgctxt, '"Constellation Line"', 'Fuzzy msgctxt is set';
is $result[0].fuzzy-msgid, '"Constell. Line"', 'Fuzzy msgid is set';

$PO = q:to/END/;
#~ msgid "Set the telescope longitude and latitude."
#~ msgstr "Postavi geo. dužinu i širinu teleskopa."
END

lives-ok { $result = POFile.parse($PO) }, 'Obsolete messages';
is $result.obsolete-messages.elems, 2, 'Obsolete messages are parsed';

$PO = q:to/END/;
#: mainwindow.cpp:127
#, fuzzy
#| msgctxt "Postavi geo. dužinu i širinu teleskopa."
#| msgid "Set the telescope longitude and latitude."
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"

#~ msgid "Set the telescope longitude and latitude."
#~ msgstr "Postavi geo. dužinu i širinu teleskopa."
END

$result = POFile.parse($PO);
is ~$result, $PO.trim, 'Serialization is done';

$PO = q:to/END/;
#: mainwindow.cpp:127
#, fuzzy
#| msgctxt "Postavi geo. dužinu i širinu teleskopa."
#| msgid "Set the telescope longitude and latitude."
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"
END

my $item;
lives-ok { $item = POFile::Entry.parse($PO) }, 'Can parse single item';

$result.push($item);
$result.push($item);

my $three-messages = q:to/END/;
#: mainwindow.cpp:127
#, fuzzy
#| msgctxt "Postavi geo. dužinu i širinu teleskopa."
#| msgid "Set the telescope longitude and latitude."
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"


#: mainwindow.cpp:127
#, fuzzy
#| msgctxt "Postavi geo. dužinu i širinu teleskopa."
#| msgid "Set the telescope longitude and latitude."
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"


#: mainwindow.cpp:127
#, fuzzy
#| msgctxt "Postavi geo. dužinu i širinu teleskopa."
#| msgid "Set the telescope longitude and latitude."
msgid "Time: %1 second"
msgid_plural "Time: %1 seconds"
msgstr[0] "Czas: %1 sekunda"
msgstr[1] "Czas: %1 sekundy"
msgstr[2] "Czas: %1 sekund"

#~ msgid "Set the telescope longitude and latitude."
#~ msgstr "Postavi geo. dužinu i širinu teleskopa."
END

is $three-messages.trim, ~$result, 'New entries are correctly pushed';

lives-ok { $result = POFile.load('t/example.po') }, 'Test loading from file';

is $result.elems, 3, 'Loaded correct numbers of elements from file';

my $i = 0;
for @$result -> $item {
    $i++;
}

is $i, 3, 'List-based iteration works';

$PO = "I will not be parsed!";

throws-like { POFile.parse($PO) },
    POFile::CannotParse, 'Has typed exception on parsing failure';

done-testing;
