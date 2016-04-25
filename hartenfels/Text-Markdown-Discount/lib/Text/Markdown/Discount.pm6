unit class Text::Markdown::Discount;
use NativeCall;


class X::Text::Markdown::Discount is Exception {}


class X::Text::Markdown::Discount::File is X::Text::Markdown::Discount
{
    has Str   $.op;
    has Cool  $.file;
    has int32 $.errno;

    sub strerror(int32 --> Str) is native(Str) { * }

    method message() { "$.op '$.file'\: {strerror $.errno}" }
}


class X::Text::Markdown::Discount::Flag is X::Text::Markdown::Discount
{
    has Str $.flag;

    multi method new(Str $flag) { self.bless(:$flag) }

    method message() { "Unknown flag: '$.flag'" }
}


class X::Text::Markdown::Discount::Compile is X::Text::Markdown::Discount
{
    has Str $.message;

    multi method new(Str $message) { self.bless(:$message) }
}


my \XFile    := X::Text::Markdown::Discount::File;
my \XFlag    := X::Text::Markdown::Discount::Flag;
my \XCompile := X::Text::Markdown::Discount::Compile;


class FILE is repr('CPointer')
{
    sub fopen(Str, Str --> FILE)
        is native(Str) { * }

    sub fdopen(int32, Str --> FILE)
        is native(Str) { * }

    sub fclose(FILE --> int32)
        is native(Str) { * }

    my $errno := cglobal(Str, 'errno', int32);


    multi method open(Str $file, Str $mode --> FILE)
    {
        fopen($file, $mode) or fail XFile.new(:op("fopen '$mode'"),
                                              :$file, :$errno);
    }

    multi method open(Int $fd, Str $mode --> FILE)
    {
        fdopen($fd, $mode) or fail XFile.new(:op("fdopen '$mode'"),
                                             :file($fd), :$errno);
    }

    method close()
    {
        fclose(self) == 0 or warn XFile.new(:op("fclose"),
                                            :file(~self), :$errno);
    }
}


class MMIOT is repr('CPointer')
{
    sub mkd_string(Str, int32, int32 --> MMIOT)
        is native('markdown') { * }

    sub mkd_in(OpaquePointer, int32 --> MMIOT)
        is native('markdown') { * }

    sub mkd_compile(MMIOT, int32 --> int32)
        is native('markdown') { * }

    # XXX This should take a `char**` to write to, but I can't make `Pointer`
    #     dance that way. It's also scary to just write to a `Str` like that.
    #     I tried `Str is rw`, but that just segfaults.
    sub mkd_document(MMIOT, CArray[Str] --> int32)
        is native('markdown') { * }

    sub mkd_generatehtml(MMIOT, FILE --> int32)
        is native('markdown') { * }

    sub mkd_flags_are(FILE, int32, int32)
        is native('markdown') { * }

    sub mkd_cleanup(MMIOT)
        is native('markdown') { * }


    method from-str(Cool $str, int32 $flags --> MMIOT:D)
    {
        my int32 $bytes = $str.encode('UTF-8').elems;
        return mkd_string(~$str, $bytes, $flags);
    }

    method from-file(Cool $file, int32 $flags --> MMIOT:D)
    {
        my $fh   = FILE.open(~$file, 'r');
        my $self = try mkd_in($fh, $flags);
        $fh.close;
        fail $! without $self;
        return $self;
    }


    method html-to-str(MMIOT:D: int32 $flags --> Str)
    {
        mkd_compile(self, $flags)
            or fail XCompile.new("Can't compile markdown");

        # Need a `char**`.
        my $buf = CArray[Str].new;

        # XXX This writes to `$buf[0]`, which is scary.
        $buf[0] = Str;
        mkd_document(self, $buf);

        return $buf[0];
    }

    method html-to-file(MMIOT:D: Str $file, int32 $flags --> Bool)
    {
        # FIXME
        #
        # mkd_compile(self, 0) or fail "Can't compile markdown";
        # my $fh = FILE.open($file, 'w');
        # mkd_generatehtml(self, $fh);
        # $fh.close;
        #
        # `mkd_generatehtml` is broken for me. If a MMIOT has been
        # compiled to a string before, it throws an excessive '\0'
        # before the newline at the end.

        return spurt $file, self.html-to-str($flags) ~ "\n";
    }


    method flags(MMIOT:D: Cool $f, int32 $flags, Bool $to-file)
    {
        my $fh = FILE.open($to-file ?? ~$f !! +$f, 'w');
        mkd_flags_are($fh, $flags, 0);
        $fh.close;
    }


    # FIXME Does this actually get called?
    method DESTROY
    {
        mkd_cleanup(self);
    }
}


# These are #defines in Discount, so they don't get compiled into symbols.
# It's ugly to just hard-code these in here, but I don't know what else to do.
our %discount-flags = (
    NOLINKS          => 0x00000001,
    NOIMAGE          => 0x00000002,
    NOPANTS          => 0x00000004,
    NOHTML           => 0x00000008,
    STRICT           => 0x00000010,
    TAGTEXT          => 0x00000020,
    NOEXT            => 0x00000040,
    CDATA            => 0x00000080,
    NOSUPERSCRIPT    => 0x00000100,
    NORELAXED        => 0x00000200,
    NOTABLES         => 0x00000400,
    NOSTRIKETHROUGH  => 0x00000800,
    TOC              => 0x00001000,
    COMPAT           => 0x00002000,
    AUTOLINK         => 0x00004000,
    SAFELINK         => 0x00008000,
    NOHEADER         => 0x00010000,
    TABSTOP          => 0x00020000,
    NODIVQUOTE       => 0x00040000,
    NOALPHALIST      => 0x00080000,
    NODLIST          => 0x00100000,
    EXTRA_FOOTNOTE   => 0x00200000,
    NOSTYLE          => 0x00400000,
    NODLDISCOUNT     => 0x00800000,
    DLEXTRA          => 0x01000000,
    FENCEDCODE       => 0x02000000,
    IDANCHOR         => 0x04000000,
    GITHUBTAGS       => 0x08000000,
    URLENCODEDANCHOR => 0x10000000,
);

our sub make-flags(%fs --> Int)
{
    [+|] %fs.kv.map: -> $k, $v
    {
        my $key = uc ~$k;
        if    %discount-flags{   $key } -> $flag { $flag if  $v        }
        elsif %discount-flags{"NO$key"} -> $flag { $flag if !$v        }
        else                                     { fail XFlag.new(~$k) }
    }
}


has MMIOT $!mmiot;
has Int   $!flags;

submethod BUILD(:$!mmiot, :$!flags) { * }


method from(Str $meth, Cool $arg, %flags --> Text::Markdown::Discount:D)
{
    my Int   $flags = make-flags(%flags);
    my MMIOT $mmiot.= "$meth"($arg, $flags);
    return $?PACKAGE.new(:$mmiot, :$flags);
}

method from-str(Cool $str, *%flags --> Text::Markdown::Discount:D)
{
    return self.from('from-str', $str, %flags);
}

method from-file(Cool $file, *%flags --> Text::Markdown::Discount:D)
{
    return self.from('from-file', $file, %flags);
}


method to-str(Text::Markdown::Discount:D: --> Str)
{
    return $!mmiot.html-to-str($!flags);
}

method to-file(Text::Markdown::Discount:D: Str $file --> Bool)
{
    return $!mmiot.html-to-file($file, $!flags);
}


multi method dump-flags(Int:D $fd = 1) { $!mmiot.flags($fd,   $!flags, False) }
multi method dump-flags(Str:D $file  ) { $!mmiot.flags($file, $!flags, True ) }


multi sub markdown(Cool:D $str, Cool $to-file?, *%flags --> Cool) is export
{
    my $self = $?PACKAGE.from-str($str, |%flags);
    return $to-file.defined ?? $self.to-file(~$to-file) !! $self.to-str;
}

multi sub markdown(IO::Path:D $file, Cool $to-file?, *%flags --> Cool) is export
{
    my $self = $?PACKAGE.from-file(~$file, |%flags);
    return $to-file.defined ?? $self.to-file(~$to-file) !! $self.to-str;
}


# Compatibility with Text::Markdown
multi method new($text, *%flags)             { self.from-str($text, |%flags) }
method       render()                        { self.to-str                   }
method       to-html()                       { self.to-str                   }
method       to_html()                       { self.to_str                   }

sub parse-markdown($text, *%flags) is export { $?PACKAGE.from-str($text, |%flags) }


=begin pod

=head1 NAME

Text::Markdown::Discount - markdown to HTML using the Discount C library

=head1 VERSION

0.2.5

=head1 SYNOPSIS

    use Text::Markdown::Discount;
    my $raw-md = '# Hello `World`!'

    # render HTML into string...
    say markdown($raw-md       ); # from a string
    say markdown('README.md'.IO); # from a file, note the `.IO`

    # ...or directly into files
    markdown($raw-md,        'sample.html');
    markdown('README.md'.IO, 'README.html');

You can also use the various L<#Flags> in Discount:

    say markdown($raw-md, :autolink, :!image ); # MKD_AUTOLINK | MKD_NOIMAGE
    say markdown($raw-md, :AUTOLINK, :NOIMAGE); # same thing

The API from L<Text::Markdown|https://github.com/retupmoca/p6-markdown/> is
also supported:

    my $md = Text::Markdown::Discount.new($raw-md);
    say $md.render;

    $md = parse-markdown($raw-md);
    say $md.to-html;
    say $md.to_html; # same thing

=head1 DESCRIPTION

=head2 libmarkdown

This library provides bindings to the L<Discount
library|https://github.com/Orc/discount> via L<NativeCall>.  You need to
have it installed as the C<libmarkdown> shared library.

On Ubuntu 15.04, it's available via C<apt-get> as the
C<libmarkdown2-dev> package, the same goes for several Debians.  If it's
not available as a binary for your system, you can compile it L<from
source|https://github.com/Orc/discount>.

=head2 Simple API

=head3 markdown

    sub markdown(    Cool:D $str,  Cool $to-file?, *%flags --> Cool) is export
    sub markdown(IO::Path:D $file, Cool $to-file?, *%flags --> Cool) is export

This function is probably enough for most cases. It will either take the
markdown from the given C<$str> or C<$file> and convert it to HTML. If
C<$to-file> is given, the result will be written to the file at that path
and returns C<True>. Otherwise returns a C<Str> with the HTML in it.

Will throw an exception if there's a problem reading or writing files, or if
the markdown can't be converted for some reason.

See L<#Flags> about the C<*%flags> parameter.

=head2 Object API

=head3 from-str

    method from-str(Cool $str, *%flags --> Text::Markdown::Discount:D)

Parses the given C<$str> as markdown and returns an object you can call HTML
conversion methods on.

You can call this method on both a class and an object instance.

See L<#Flags> about the C<*%flags> parameter.

=head3 from-file

    method from-file(Cool $file, *%flags --> Text::Markdown::Discount:D)

As L<#from-str>, except will read the markdown from the given C<$file>.

Will C<fail> with an L<#X::Text::Markdown::Discount::File> if it can't C<fopen>
the given C<$file> and C<warn> if it can't C<fclose> it.

=head3 to-str

    method to-str(Text::Markdown::Discount:D: --> Str)

Converts the markdown in the caller into HTML and returns the result.

Will C<fail> with a L<#X::Text::Markdown::Discount::File> if Discount can't
compile the markdown for some reason.

=head3 to-file

    method to-file(Text::Markdown::Discount:D: Str $file --> Bool)

Converts the markdown in the caller into HTML and writes the result to the
given C<$file>. Returns C<True> or an appropriate C<Failure>.

=head3 dump-flags

    multi method dump-flags(Int:D $fd = 1)
    multi method dump-flags(Str:D $file)

Dumps all flag options applied to the caller. Either to the given C<$file>
path, or to the file descriptor C<$fd>. Defaults to dumping to file descriptor
1 (stderr).

This function may be useful in figuring out if the Discount library you're
linked to actually has the flags you need.

=head2 Text::Markdown Compatibility

These functions exist so that you can use C<Text::Markdown::Discount> as a
drop-in replacement for
L<Text::Markdown|https://github.com/retupmoca/p6-markdown/>. They just dispatch
to existing functions:

=head3 new
=head3 parse-markdown

    multi method new($text, *%flags)
    sub parse-markdown($text *%flags) is export

Dispatch to L<#from-str>.

=head3 render
=head3 to-html
=head3 to_html

    method render()
    method to-html()
    method to_html()

Dispatch to L<#to-str>.

=head2 Exceptions

=head3 X::Text::Markdown::Discount

    class X::Text::Markdown::Discount is Exception

The base exception class for this module. All other exception types inherit from
this. Not actually thrown directly.

=head3 X::Text::Markdown::Discount::File

    class X::Text::Markdown::Discount::File is X::Text::Markdown:Discount

Thrown when an C<fopen>, C<fdopen> or C<fclose> fails. The latter will only be
a warning.

=head3 X::Text::Markdown::Discount::Flag

    class X::Text::Markdown::Discount::Flag is X::Text::Markdown:Discount

Thrown when you try to use a non-existent flag.

=head3 X::Text::Markdown::Discount::Compile

    class X::Text::Markdown::Discount::Compile is X::Text::Markdown:Discount

Thrown when Discount can't compile markdown. I can't tell when this would
happen or where to get the error message from though.

=head2 Flags

Discount provides a variety of flags that change how the conversion behavior.
You can pass flags to all routines that take a C<*%flags> parameter.

The following list of flags is taken from
L<Discount's documentation|http://www.pell.portland.or.us/~orc/Code/discount/>.
Depending on your version of the library, they might not all be available, see
L<#dump-flags>.

All of these flags map to the respective C<MKD_> constants. The keys are
case-insensitive. Constants that originally start with C<NO> can be used without
it and negated. For example, C<:!links> is the same as C<:nolinks>.

=defn C<:!links>, C<:nolinks>

Don't do link processing, block C<< <a> >> tags.

=defn C<:!image>, C<:noimage>

Don't do image processing, block C<< <img> >>.

=defn C<:!pants>, C<:nopants>

Don't run C<smartypants()>

=defn C<:!html>, C<:nohtml>

Don't allow raw html through B<AT ALL>.

=defn C<:strict>

Disable C<SUPERSCRIPT>, C<RELAXED_EMPHASIS>.

=defn C<:tagtext>

Process text inside an html tag; no C<< <em> >>, no C<< <bold> >>, no html or
C<[]> expansion.

=defn C<:!ext>, C<:noext>

Don't allow pseudo-protocols.

=defn C<:cdata>

Generate code for xml C<![CDATA[...]]>.

=defn C<:!superscript>, C<:nosuperscript>

No C<A^B>.

=defn C<:!relaxed>, C<:norelaxed>

Emphasis happens I<everywhere>.

=defn C<:!tables>, C<:notables>

Don't process
L<PHP Markdown Extra|http://michelf.com/projects/php-markdown/extra/> tables.

=defn C<:!strikethrough>, C<:nostrikethrough>

Forbid C<~~strikethrough~~>.

=defn C<:toc>

Do table-of-contents processing.

=defn C<:compat>

Compatability with MarkdownTest_1.0.

=defn C<:autolink>

Make C<http://foo.com> a link even without C<< <> >>s.

=defn C<:safelink>

Paranoid check for link protocol.

=defn C<:!header>, C<:noheader>

Don't process document headers.

=defn C<:tabstop>

Expand tabs to 4 spaces.

=defn C<:!divquote>, C<:nodivquote>

Forbid C<< >%class% >> blocks.

=defn C<:!alphalist>, C<:noalphalist>

Forbid alphabetic lists.

=defn C<:!dlist>, C<:nodlist>

Forbid definition lists.

=defn C<:extra_footnote>

Enable
L<PHP Markdown Extra|http://michelf.com/projects/php-markdown/extra/>-style
footnotes.

=head1 BUGS

There's probably some bugs in the NativeCall handling. I'm not sure if the
types are specified correctly and if the destructor for the native pointers
gets called when it needs to.

There seems to be a bug in Discount's C<mkd_generatehtml> function, where it
adds excessive C<nul>s to the output if it has previously been compiled to a
string. Due to that, the L<#to-file> currently just C<spurt>s the string
output into the file.

Please report bugs
L<on GitHub|https://github.com/hartenfels/Text-Markdown-Discount/issues>.

=head1 TODO

=item Depend on C<Native::LibC> for C<FILE> stuff
=item Make sure that my NativeCall usage is correct
=item Finish this documentation

=head1 AUTHOR

L<Carsten Hartenfels|mailto:carsten.hartenfels@googlemail.com>

=head1 SEE ALSO

L<Text::Markdown|https://github.com/retupmoca/p6-markdown/>,
L<Discount|http://www.pell.portland.or.us/~orc/Code/discount/>,
L<Discount GitHub repository|https://github.com/Orc/discount>,
L<Text::Markdown::Discount for Perl 5|https://metacpan.org/pod/Text::Markdown::Discount>.

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Carsten Hartenfels.

This program is distributed under the terms of the Artistic License 2.0.

For further information, please see LICENSE or visit
<http://www.perlfoundation.org/attachment/legal/artistic-2_0.txt>.

=end pod
