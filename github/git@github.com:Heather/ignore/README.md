Easiest way to ignore junk in your VCS folder
=============================================

``` shell
Currently supported : hg, git

TODO :
 - multiply ignore files

Usage:
  bin/ignore [--debug] [--git] [--hg] [--all] <source>
```

``` perl
sub ignore($ifile, $pattern) {
    my $res = find(:dir<.>, :name($ifile));
    given $res.elems {
        when 1 {
            log $res[0].fmt('found single ignore file at %s');
            if analyze( $res[0], $pattern ) { log 'this file is already in ignore file'; }
            else {
                log 'adding new node to ignore file';
                f $res[0], :a, { .say( $pattern ); }
```
