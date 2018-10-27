# p6-Text-VimColour

Converts language source code into colour syntax HTML using vim.

Idea was shamelessly stolen from the original Perl 5 Text::VimColor

Pull requests welcome.

## Installation

To install this module, you'll need `vim` version at least 7.4. 

An optional step for the best syntax colouring results is to 
also install updated
[Perl 6 vim syntax files](https://github.com/vim-perl/vim-perl)

## Synopsis

```perl6
    use Text::VimColour;
    Text::VimColour.new(
        lang => "perl6",
        in   => "file-to-highlight.p6",
        out  => '/tmp/out.html'
    );
```

## Methods

### new

```perl6
    Text::VimColour.new(
        lang    => 'perl6',
        in      => 'file-to-highlight.p6'
        code    => 'say $foo;',
        out     => '/tmp/out.html',
    );
```

#### in

Specifies the input file with the code to highlight. You **must** specify
either `in` or `code`.

#### code

Specifies the code to highlight. You **must** specify either `in` or `code`.

#### lang

Optional. Specifies the language to use for highlighting. Defaults to `c`

#### out

Optional. Specifies the path to a file to output highlighted HTML into

### html-full-page

```perl6
    say Text::VimColour.new( lang => 'perl6', in => 'file-to-highlight.p6')
        .html-full-page;
```

Takes no arguments. Returns the full HTML page with highlighted code
and styling CSS.

### html

```perl6
    say Text::VimColour.new( lang => 'perl6', in => 'file-to-highlight.p6')
        .html;
```

Same as `html-full-page`, but returns only the highlighted code HTML.

### css

```perl6
    say Text::VimColour.new( lang => 'perl6', in => 'file-to-highlight.p6')
        .css;
```

Same as `html-full-page`, but returns only the styling CSS code.
