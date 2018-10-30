# TITLE

Grammar::Highlighter

# SYNOPSIS

```
    use Grammar::Highlighter;
    use Whatever::Grammar::You::Like;

    my $highlighter = Grammar::Highlighter.new;
    my $parser = Whatever::Grammar::You::Like.new;
    say $parser.parse($string, :actions($highlighter)).ast.Str;
```

# DESCRIPTION

Get automatic syntax highlighting for any grammar you provide.

Grammar::Highlighter is a generic syntax highlighter. You use it as an actions
object for a grammar's parse method. It will assign a different color to all
the grammar's tokens, rules and regexes. The generated parse tree stringifies
to the original string with colors applied.

# AUTHOR

Stefan Seifert <nine@detonation.org>
