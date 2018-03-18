# perl6-app-findsource

Find your source file easily.

# USAGE

```
$ fs -h                               
Usage:
/home/*/.perl6/bin/fs [add|list|remove] [-l=<array>] [-w=<array>] [-a=<array>] [-i] [-no=<array>] [-only=<string>] [-d|--debug] <directory> 

-l=<array>     load specify config, available config are < perl make cpp cfg >.

-w=<array>     match whole filename.                                           

-a=<array>     addition extension list.                                        

-i             enable ignore case mode.                                        

-no=<array>    exclude file category.                                          

-only=<string> only search given category.                                     

-d|--debug     print debug message.
```

## config

The config use json format, it contain the option will add categories to command line.
In the config, you also can append value to `-w` or `-a`.

### cpp.json

```json
{
	"option" : [
		{
			"short" : "c",
			"value" : [ "c" ],
			"annotation" : "c source file extension list. "
		},
		{
			"short" : "h",
			"value" : [ "h" ],
			"annotation" : "c/c++ header file extension list. "
		}
	]
}
```

`short` is the category option will added.

`value` is the default value of the category, it will append the value to the category if the category exists.

## load the config

Use `-l cpp` to load the config, it will add `-h=<array>` and `-c=<array>` to `fs` command line.

```
$ fs -l cpp -h
Usage:
/home/*/.perl6/bin/fs [add|list|remove] [-l=<array>] [-w=<array>] [-a=<array>] [-i] [-no=<array>] [-only=<string>] [-d|--debug] [-c=<array>] [-cpp=<array>] [-h=<array>] <directory> 

-l=<array>     load specify config, available config are < perl make cpp cfg >. 

-w=<array>     match whole filename.                                            

-a=<array>     addition extension list.                                         

-i             enable ignore case mode.                                         

-no=<array>    exclude file category.                                           

-only=<string> only search given category.                                      

-d|--debug     print debug message.                                             

-c=<array>     c source file extension list. [c]

-h=<array>     c/c++ header file extension list. [h]
```

## do search

Add an argument specify the directory you want searched.

```
$ fs ../rakudo/tmp/rakudo/src/vm -l cpp 
"../rakudo/tmp/rakudo/src/vm/moar/ops/perl6_ops.c"
"../rakudo/tmp/rakudo/src/vm/moar/ops/container.h"
"../rakudo/tmp/rakudo/src/vm/moar/ops/container.c"
```

## add extension to category

You can add additional file extension to category.

```
$ fs ../rakudo/tmp/rakudo/src/vm -l cpp -a java
"../rakudo/tmp/rakudo/src/vm/moar/ops/perl6_ops.c"
"../rakudo/tmp/rakudo/src/vm/moar/ops/container.h"
"../rakudo/tmp/rakudo/src/vm/moar/ops/container.c"
"../rakudo/tmp/rakudo/src/vm/jvm/runtime/org/perl6/rakudo/RakudoContainerSpec.java"
"../rakudo/tmp/rakudo/src/vm/jvm/runtime/org/perl6/rakudo/RakudoContainerConfigurer.java"
"../rakudo/tmp/rakudo/src/vm/jvm/runtime/org/perl6/rakudo/RakOps.java"
"../rakudo/tmp/rakudo/src/vm/jvm/runtime/org/perl6/rakudo/RakudoJavaInterop.java"
"../rakudo/tmp/rakudo/src/vm/jvm/runtime/org/perl6/rakudo/RakudoEvalServer.java"
"../rakudo/tmp/rakudo/src/vm/jvm/runtime/org/perl6/rakudo/Binder.java"
```

## add | remove | list config

You can add your own config to configuration directory.

List current configuration file:

```
$ fs list
cfg.json
perl.json
cpp.json
make.json
```

# Installation

`zef install App::FindSource`

# License

GPL

# Author

araraloren (blackcatoverwall#gmail.com)