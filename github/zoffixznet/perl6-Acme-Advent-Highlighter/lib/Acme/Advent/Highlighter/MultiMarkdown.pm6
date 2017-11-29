# P6M Merging GLOBAL symbols failed: duplicate definition of symbol Markdown
# if used directly in original sauce

unit class Acme::Advent::Highlighter::MultiMarkdown;
method render (Str:D $markdown) {
    'use Text::MultiMarkdown:from<Perl5> <markdown>; &markdown'.EVAL.(
        $markdown
    )
}
