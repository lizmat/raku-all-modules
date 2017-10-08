# Examples

These are fairly simple examples of using this module.  I've tried
to avoid any external dependencies (apart from this module and
```liquidsoap``` of course,)

Each example includes a liquidsoap script that must be run prior
to running the perl program. By default the liquidsoap will start the
command server on port 1234, if you want to start this on another port
then you can add a line:

    set('server.telnet.port', 5678)

Toward the beginning of the '.liq' file, ( you can of course use any
free port on your system.)

Also all of the liquidscripts output to an icecast server with a default
configuration on localhost as this is the most common usage and the choice
of outputs available is very dependent on the way that the liquidsoap
was built.  If you prefer you can either edit the line  :

    output.icecast(%mp3,host="localhost",port=8000,password="hackme",mount="radio", radio)

to suit your configuration (of course leaving the source radio ( the
last argument,) untouched.)  Or you can replace it with:

    output.prefered(radio)

which will force output to the first mechanism it can find to send the
output to some soundcard.  Of course this may not work either if there
is no soundcard in the system or the liquidsoap wasn't build with the
appropriate support.  If all else fails you can use ```output.dummy```
but this won't actually result in any output.

If you are looking for examples of liquidsoap scripts rather than example
of how you might use this module then you might want to look at
http://savonet.sourceforge.net/doc-svn/documentation.html which has loads
of specific examples and tutorials.

## [Simple](./simple)

This demonstrates a simple player that queues MP3 files that appear in
a directory.

