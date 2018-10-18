# DESCRIPTION

Preprocessor for Perl 6 Advent Articles, with syntax highlighter. Saves the
trouble of not having to deal with broken escapes in code blocks in Wordpress
and provides syntax-highlights, as a cherry on top.

# GIST TOKEN

To get the best syntax highlights, the module uses GitHub's Gists for
highlighting. You'll need to
[obtain a GitHub API token](https://github.com/settings/tokens/new). Only
`gist   Create gists` permission is needed. After creating the gist, the
script grabs syntax highlighted code from it, and then *deletes it*.

# USAGE

1. Install this module:

    ```bash
    zef install Acme::Advent::Highlighter
    ```

    If you're using `rakudobrew`, then [don't](http://rakudo.org/how-to-get-rakudo/#Discouraged-Tools-Rakudobrew),
    but if you insist, be sure to run `rakudobrew rehash` after installation,
    to update script shims.

    If you want to run extra tests, set `ONLINE_TESTING=1` env var.

2. Write your article in basic
    [Markdown](https://daringfireball.net/projects/markdown/syntax) and save
    it to a file

3. Run:

    ```bash
    advent-highlighter.p6 Your-Article Your-Gist-Token > out.html
    ```

    The [gist token](https://github.com/settings/tokens/new) can alternatively be given via
    `ACME_ADVENT_HIGHLIGHTER_TOKEN` environmental variable. The STDOUT of
    the script will output the rendered content while STDERR will output
    some info on what the script is doing.

4. Go to Wordpress and copy-paste contents of `out.html` (or wherever you
    saved the output) into Wordpress's editor, ensuring you're editing in
    "HTML" and not "Visual" mode.

5. Preview or Publish

6. Celebrate with an appropriate amount of fun

## `--wrap` option

    advent-highlighter.p6 --wrap Your-Article Your-Gist-Token > out.html

If you'd like to have a rough idea of how the thing will look like on Wordpress,
you can pass `--wrap` option to the script. It'll wrap the output into a bit
of markup to make the width of the article to be approximately what it is on
Perl 6 Advent articles right now (might wanna check your codeblocks don't
overflow if you don't want readers scrolling).

## `--multi` option for Multi Markdown

    advent-highlighter.p6 --multi Your-Article Your-Gist-Token > out.html

I found `Text::Markdown` to be a bit of a weak sauce and it failed to render
some things I thought it would. If you
[install `Inline::Perl5`](https://github.com/zoffixznet/r/blob/master/README.md#inlineperl5-with-latest-perl) along with [`Text::MultiMarkdown` Perl 5 module](https://metacpan.org/pod/Text::MultiMarkdown) (just run `cpanm -v Text::MultiMarkdown` or `cpan Text::MultiMarkdown` if you don't have `cpanm`),
then you can add `--multi` command line option to make the script use *that* as Markdown renderer.

## Alternative Content Options

The script does some heuristics for the value of the content argument:

1. If it starts with `http://` or `https://`, assumes it's a URL and will fetch
    the actual content from it
2. If a readable file exists with such a name, assumes the content is in that
    file and will read it from it
3. Otherwise, assume the given value is literally the content

## Notes on Editing/Content

* Wordpress is a finicky beast (or at least the installation on our Advent is). For paragraphs: ensure they're all on one line in your Markdown, otherwise, there'll be weird line breaks in the final article.

* Also, there's a way to mess up code blocks on the article even after using this script. It looks like it happens
  if you save your article (or have autosave feature trigger) when using "Visual" mode. So be sure to keep around your originals and keep an eye out on messed up code blocks if you edit your articles on Wordpress

* If you copy-paste code from the article, the paste will have a ton of blank newlines. I'm not bothered by this enough
   to do anything about it, but will take a patch that removes those, without risk of damaging intended content.

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
