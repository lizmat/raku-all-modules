#Overwatch

Perl6 Overwatch can be used to restart programs when they crash or 
when files are modified.  

##Usage 

```
overwatch [options] <program> [<program arguments>]
```
    
##Required

```
<program>
```
    
A program/script name is required.

##Options

###Executable

```
-e=<executable> | --execute=<executable>
```

Default: ```perl6```

The executable that runs the specified <program>.

###Keep Alive

```
-k | --keep-alive
```

Default: ```True```

Automatically rerun the program.
 

###Exit on error

```
-x | --exit-on-error
```

Default: ```False```

Stop overwatch if the <program> exited with a non-zero code.

###Git

```
-g | --git
```

Default: ```0```

Checks default upstream git repository and pulls if local is behind.

A value of zero or less disables this option.

###Quiet

```
-q | --quiet
```

Default: ```False```

Prevents overwatch from printing informative messages to stdout. 

###Watch

```
-w | --watch
```

Default: ```[]```

Directories/files to watch for changes, when a file is changed the <program> is restarted.

###Filter

```
-f | --filter
```

Default: ```''```

Comma separated list of file extensions to watch for changes.  List applies to all ```watch``` dirs.

##Notes
* Multiple -w switches may be specified
* To negate a [True|False} value you can use -/q (same as -q=False)

##Examples

```
overwatch app.pl6
```

```
overwatch -w=models mvc.pl6
```

```
overwatch -w=/tmp/ -e=/bin/sh shellscript.sh --shellarg=go
```

##License

[Artistic License 2.0](http://www.perlfoundation.org/artistic_license_2_0)

