# EXTRA FEATURES (TODO)

## Exporting aliases

Can be usefull to use more consise routines :

```perl6
use Log::Any( :subs );

log-adapt( Adapter.new );

warning( 'missing some configuration' );
critical( 'a big problem occured' );
```

## Wrapping

### STDOUT, STDERR

Often, applications or libraries are already available, and prints their logs to STDOUT and/or STDERR. Log::Any could captures these logs and manage them.

### EXCEPTIONS

Catches all unhandled exceptions to log them (can be dangerous).

## Stacktrace

Dump a stacktrace with the log. This could be usefull to find a problem.
	Is it necessary?
	Is it possible to do in an Adapter or some Proxy ?

## log-on-error

keep in cache logs in streams (all, from trace to error)
	- if an error occurs (how to detect, using a level?), log the stacktrace ;
	- if nothing special occurs, log cached logs as specified in the filters.

```perl6
Log::Any.trace('entering method with parameters ...'); # nothing logged
Log::Any.noticej('currently working');                 # nothing logged
Log::Any.error( 'oops' );                              # Trigger previous logs
```

Would prints something like:
```
oops
Log::Any: Triggered by an error:
  currently working
  entering method with parameters ...
```

- how to determine that logs are in the same stacktrace?
- use a proxy ?
- something easily parseable

## PROXYs

A proxy is a class used to intercept messages before they are relly sent to the log subroutine. They can be usefull to log more than strings, or to analyse the message. They can also add some data in the message like tags.
	todo: is a filter, a proxy?

## TAGS

Where?
	- in place of category ?
	- as extended informations ? +1
How?
	- tags: [ tag1, tag2 ]
	- how to log them (array) ?

### Replace category with a tag, and add read-only *source*

## Die when not handled

Returns an error (logging, exception?) if a log is not handled.

## Does not log duplicate messages

Check if a log message already been logged during the last <timespec>.

Will call the proxy before logging the message.
	- if the message already been seen n times during the last 1s, increment a counter and return false (meaning the log will not be logged).
		- a timer executing every n s will print a message like '$msg has been seen n times during the last n s' ;
			- empty the stack
	- if not, log basically the message.

```perl6
Log::Any.add( $adapter, :proxy( Log::Any::Proxy::CacheUnpoisonning.new( :stack-size( 10 ), :time-interval( '1s' ) );
```

Prints something like:
```
Wow an error in an infinite loop...
* Log::Any : previous message reapeated n times during last 1s.
```

## Load Log configuration from a file

- YAML, JSON, XML, ?
- watch a file to detect changes
- in the standard distribution, or in a "plugin" ?
- pause dispatching during the reload ;

With Config::Any :
```perl6
use Config::Any;
use Log::Any;

Config::Any.load-from-file( :name('/path/to/file.conf') ).on-change( -> $config { Log::Any.load-from( $config ) } );
```

## Adapter exporting prefered formatter

An adapter could define a prefered formatter which will be used if no formatter are specified.

## Severities

Matching all but a list of severities:

```perl6
filter => [ 'severity' => [ * - 'warning' ] ] # All but 'warning'
```
