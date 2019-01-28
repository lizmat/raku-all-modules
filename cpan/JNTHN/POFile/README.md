### NAME

POFile - Perl 6 module for manipulating data in PO files.

### SYNOPSIS

    use POFile;
    my $po = POFile.load('foo.po');

    say $po.obsolete-messages; # list of obsolete messages
    say $result[0]; # POFile::Entry object at 0 index
    say $result{'Splash text'}; # POFile::Entry object with msgid `Splash text`
    for @$po -> $item {
        say $item.reference; # 'finddialog.cpp:38'
        say $item.msgstr; # msgstr value
        $item.msgstr = update($item.msgstr); # Do some update
    }
    $po.save('foo-updated.po');

### DESCRIPTION

The `.po` file as a whole is represented by the `POFile` class, which
holds a `POFile::Entry` object per entry in the PO file.

##### POFile::Entry

`POFile::Entry` represents a single record in PO file, and has its
fields as attributes: `msgid`, `msgid-plural`, `msgstr`, `msgctxt`,
`reference` (reference comment), `extracted` (extracted comment),
`comment` (translator comment), `format-style`, `fuzzy-msgid`,
`fuzzy-msgctxt`. All these attributes are set read/write.

You can create a single `POFile::Entry` object from a `Str` using the
`POFile::Entry.parse($str)` method.

The `msgid` and `msgstr` accessors always provided unquoted values;
the methods `msgid-quoted` and `msgstr-quoted` are present to provide
access to the quoted messages.

The value of `msgstr` attribute might be either `Str` or `Array`, and
is based on value of `msgid-plural` attribute:

    with $po.msgid-plural {
        say $po.msgid; # Singular form
        say $_; # Plural form
        for $po.msgstr -> $form {
            say $form; # Every plural form of end language
        }
    }

You can serialize an entry with `Str` method or its `~` shortcut:

    my $po-entry = $po[1]; # Get second entry
    say ~$po-entry;    # Serialized 1
    say $po-entry.Str; # Serialized 2

Note that _no line wrapping_ is done by the module.

##### POFile

`POFile` provides access to `POFile::Entry` objects using either index
(position in original file) or key (msgid value). It must be noted
that this module provides hash-like access by msgid, which might not
be unique. Please consider that _only array access_ is stable in this
case. Use hash access you know _for sure_ there are no items with the
same `msgid`, yet different `msgctxt`.

`POFile` also contains all obsolete messages, which can be accessed using
`obsolete-messages` attribute.

You can create from scratch a new `POFile` object and populate it with
entries, as well as delete entries by id or by key:

    my $po = POFile.new;
    $result.push(POFile::Entry.parse(...));
    $result.push(POFile::Entry.parse(...));
    $po[0]:delete;
    $po{'my msgid'}:delete;

As well as `POFile::Entry`, you can serialize a `POFile` object
calling `Str` method on it.

##### Escaping

Additionally, two routines are available to escape and unescape strings accordingly to
rules described for PO format.

    use POFile :quoting;

    say po-unquote(｢\t\"\\\n｣); # ｢\t"\\n｣      <- unquoting
    say po-quote(｢\t"\\n\｣);    # ｢\t\"\\\n\\｣  <- quoting
