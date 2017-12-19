# PDF::Class

PDF::Class maps the internal structure of a PDF of classes and accessors for safe navigation and construction of PDF documents.

This module is a work in progress. It currently many of the more commonly used PDF objects.


```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;
    my PDF::Catalog $catalog = $pdf.Root;
    with $catalog.MarkInfo //= {} {
        .Marked = True;
        .UserProperties = False;
        .Suspects = False;
    }
```


### Page Layout & Viewer Preferences
```
    use PDF::Class;
    use PDF::Catalog;
    my PDF::Class $pdf .= new;

    my PDF::Catalog $doc = $pdf.Root;
    $doc.PageLayout = 'TwoColumnLeft';
    $doc.PageMode   = 'UseThumbs';

    given $doc.ViewerPreferences //= {} {
        .Duplex = 'DuplexFlipShortEdge';
        .NonFullScreenPageMode = 'UseOutlines';
    }
    # ...etc, see PDF::ViewerPreferences
```

### AcroForm Fields

```
use PDF::Class;
use PDF::AcroForm;
use PDF::Field;

my PDF::Class $doc .= open: "t/pdf/samples/OoPdfFormExample.pdf";
with my PDF::AcroForm $acroform = $doc.Root.AcroForm {
    my PDF::Field @fields = $acroform.fields;
    # display field names and values
    for @fields -> $field {
        say "{$field.T // '??'}: {$field.V // ''}";
    }
}

```

## Raw Data Access

In general, PDF provides accessors for safe access and update of PDF objects.

However you may choose to bypass these accessors and dereference hashes and arrays directly, giving raw untyped access to internal data structures:

This will also bypass type coercements, so you may need to be more explicit. In
the following example we cast the PageMode to a name, so it appears as a name
in the out put stream `/UseToes`, rather than a string `(UseToes)`.

```
    use PDF::Class;
    my PDF::Class $pdf .= new;

    my $doc = $pdf.Root;
    try {
        $doc.PageMode   = 'UseToes';
        CATCH { default { say "err, that didn't work: $_" } }
    }

    # same again, bypassing type checking
    $doc<PageMode>  = :name<UseToes>;
```

## Development Status

The PDF::Class module is under construction and not yet functionally complete.

# Bugs and Restrictions

At this stage:
- The classes in the PDF::* name-space represent a common subset of
the objects that can appear in a PDF. It is envisioned that the range of classes
will expand over time to cover most or all types described in the PDF specification.
