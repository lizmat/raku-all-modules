This is a module for iterating over directory trees, and filtering out entries of interest. It is inspired by Perl 5's Path::Iterator::Rule, in particular it tries to iterate as lazy as possible and offers a fluent interface. For example, to lazily perl 6 scripts, while skipping over versioning files in a certain set of directories one could do:

```
for Path::Iterator.skip-vcs.ext(rx/ 'pl' 6? $ /).shebang(rx/ ^ '#!' .* 'perl6' /).in(@dirs) -> $file {
	do-something($file);
}
```

It also offers a functional interface, like this:

```
for find(@dirs, :ext(rx/ 'pl' 6? $ /), :shebang(rx/ ^ '#!' .* 'perl6' /), :skip-vcs) -> $file {
	do-something($file);
}
```
