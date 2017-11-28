# DESCRIPTION

Preprocessor for Perl 6 Advent Articles, with syntax highlighter. Saves the
trouble of not having to deal with broken escapes in code blocks in Wordpress
and provides syntax-highlights, as a cherry on top.

# GIST TOKEN

To get the best syntax highlights, the module uses GitHub's Gists for
highlighting. You'll need to
[obtain a GitHub API token](https://github.com/settings/tokens/new). Only
`gist   Create gists` permission is needed.

# USAGE

1. Install this module:

    ```bash
    zef install Acme::Advent::Highlighter
    ```

2. Write your article in basic
    [Markdown](https://daringfireball.net/projects/markdown/syntax) and save
    it to a file

3. Run:

    ```bash
    advent-highligher.p6 Your-Article Your-Gist-Token > out.html
    ```

    The token can alternatively be given via
    `ACME_ADVENT_HIGHLIGHTER_TOKEN` environmental variable. The STDOUT of
    the script will output the rendered content while STDERR will output
    some info on what the script is doing.

4. Go to Wordpress and copy-paste contents of `out.html` (or wherever you
    saved the output) into Wordpress's editor, ensuring you're editing in
    "HTML" and not "Visual" mode.

5. Preview or Publish

6. Celebrate with an appropriate amount of fun

## `--wrap` option

If you'd like to have a rough idea of how the thing will look like on Wordpress,
you can pass `--wrap` option to the script. It'll wrap the output into a bit
of markup to make the width of the article to be approximately what it is on
Perl 6 Advent articles right now (might wanna check your codeblocks don't
overflow if you don't want readers scrolling).

## Alternative Content Options

The script does some heuristics for the value of the content argument:

1. If it starts with `http://` or `https://`, assumes it's a URL and will fetch
    the actual content from it
2. If a readable file exists with such a name, assumes the content is in that
    file and will read it from it
3. Otherwise, assume the given value is literally the content

----

#### REPOSITORY

Fork this module on GitHub:
https://github.com/zoffixznet/perl6-Acme-Advent-Highlighter

#### BUGS

To report bugs or request features, please use
https://github.com/zoffixznet/perl6-Acme-Advent-Highlighter/issues

#### AUTHOR

Zoffix Znet (http://perl6.party/)

#### LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

Syntax highlighting CSS code is based on GitHub Light v0.4.1,
Copyright (c) 2012 - 2017 GitHub, Inc. Licensed under MIT
https://github.com/primer/github-syntax-theme-generator/blob/master/LICENSE

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
