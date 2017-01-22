# perl6-concurrent-file-find
[![Build Status](https://travis-ci.org/gfldex/perl6-concurrent-file-find.svg?branch=master)](https://travis-ci.org/gfldex/perl6-concurrent-file-find)

concurrent File::Find for Perl 6

# SYNOPSIS

```
use v6;
use Concurrent::File::Find;

find(%*ENV<HOME>
    , :extension('txt', {.contains('~')}) # ends in .txt or ends in something that contains a ~
    , :exclude('covers') # exclude any path that contains covers, both for files and directories
    , :exclude-dir('.') # exclude any directory-path that contains a . 
    , :file # return file paths
    , :!directory # don't return directory paths
    , :symlink # return symlink paths
    , :max-depth(5) # but not deeper then 5 directories deep
    , :follow-symlink # follow symlinks (no loop detection yet)
    , :keep-going # on error (no access, stale symlink, etc.), keep going
    , :quiet # don't report errors on STDERR
).elems.say; # count how many files and symlinks we got

sleep 10;

my @l := find-simple(%*ENV<HOME>, :keep-going, :!no-thread); # binding to avoid eagerness

for @l {
    @l.channel.close if $++ > 5000; # hard-close the channel after 5000 found files
    .say if $++ %% 100 # print every 100th file
}
```

# DESCRIPTION

## Routines

### sub find

Return `List` of files, directories and symlinks as `Str` that are fetched by a
background thread. The list got a role mixed in with the sole method `channel`
that can be used to close the channel behind the `List` to abort any still
ongoing fetching. This is a bit wonky and may produce a warning when the
underlying `Promise` is `DESTROY`ed. There are various inclusive and exclusive
filter options as described below. Files are sorted before directories in the
returned list for any directory. Only after items are returned recursion into
sub-directories may occur.

#### Matcher

Some arguments take a matcher or a list of matchers. The `Junction`-type used
when given a list depends on the argument. As matchers `Str`, `Regex`, and
`Callable` are accepted. Unless stated otherwise `Str` matches partially and
case sensitive against the filename or the whole path. `Regexp` smartmatches
against `IO::Path.Str` and `Callable` is called with `IO::Path`.

#### Arguments

`IO(Str) $dir` - directory where to start either as `IO::Path` or `Str`.

`:$file = True` - also return files

`:$directory` - also return directories

`:$symlink` - also return symlinks

`:&return-type = { .IO.Str }` - transform the matched items to `Str` by
default. The block is fed with `IO::Path` objects. The result is returned as is
and not used by `find` itself, you can go wild here.

`:$name` - return any file in any directory that matches provided matcher.
Using `Str` as matcher requires exact, case sensitive match.

`:$include` - return any file where `IO::Path.basename` matches provided
matcher. Using `Str` as matcher requires partial match.

`:$exclude` - do not return any file where `IO::Path.basename` matches provided
matcher. Using `Str` as matcher requires partial match.

`:$include-dir` - do return or decent into directories that match provided
matcher.  Using `Str` as matcher requires partial match.

`:$exclude-dir` - do not return or decent into directories that match provided
matcher. Using `Str` as matcher requires partial match.

`:$extension` - return any item that matches `IO::Path.extension`. Using `Str`
as matcher requires exact, case sensitive match.

`:$recursive = True` - descent into sub-directories.

`Int :$max-depth = ∞` - descent as deep into sub-directories.

`:$follow-symlink = False` - follow symlinks. There is no loop detection yet.

`:$keep-going = True` - on errors (access denied, stale symlinks, etc.) keek
going but output warning on $*ERR.

`:$quiet = False` - in conjunction with $keep-going, do not outout warnings.

`:$no-thread = False` - disable creation of `Promise`. Useful for debugging.

### sub find-simple

Same as `find` but without filter options, always recursive, follows existing
symlinks (no loop detection yet) and no sorting. Faster and may contain less
bugs. It may throw `X::IO::StaleSymlink`.

#### Arguments

`IO(Str) $dir` - `Path` as `IO::Path` or Str at where to start looking for files

`:$keep-going = True` - don't stop at errors

`:$no-thread = False` - don't create a `Promise`, useful for debugging

## Exceptions

### `X::IO::NotADirectory does X::IO`

Try do get the content of a path that is not a directory.

### `X::IO::CanNotAccess does X::IO`

Access to a directroy is denied by the OS.

### `X::IO::StaleSymlink does X::IO`

We where ment to return or follow a symlink that does exists but got no target.

### `X::Paramenter::Exclusive is Exception`

Named arguments where used together that are mutual exclusive.

# CAVEATS

Loop detection is not supported yet. As soon as there are portable versions for
readlink and/or stat, loop detection will be added. Until then avoid
`:follow-symlink` or use `:max-depth`.
