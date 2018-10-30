# Simple

This is perhaps the simplest possible example.

The liquidsoap script sets on a single request queue called incoming and
a single 'bedding' source that will be played when there is nothing to
be played.

Requests can be made by putting the MP3 files into the specified directory
from which they will be queued.

The ```simple.liq``` should be run before starting the ```simple.pl```.
By default it will stream out to an icecast server with a default
configuration on the localhost but this should be edited to suit your
configuration.
