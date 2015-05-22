#HTTP::Server::Threaded

 HTTP server.  

##Currently handles:
* Parsing Headers
* Chunked Transfer
* Hooks for middleware or route handling
* Simple response handling

##Doesn't handle
* Route handling

##Example
```perl6
use HTTP::Server::Threaded;

my $s = HTTP::Server::Threaded.new;

$s.handler(sub ($request, $response) {
  $response.headers<Content-Type> = 'text/plain';
  $response.status = 200;
  $response.write("Hello ");
  $response.close("world!");
});

$s.listen;
```

##Methods

###.new
`:port` - port to listen on
`:host` - ip to listen on

###.handler (Sub ($request, $response))
Any ```Sub``` passed to this method is called in the order it was registered on every incoming request.  Any method/sub registered with the server should ````return False;``` when the server should discontinue processing the request or close the request to discontinue processing.

Callable will receive two parameters from the server, a `HTTP::Server::Threaded::Request` and a `HTTP::Server::Threaded::Response` and a `Sub`.  More about the `Response` and `Request` object below.

If the server runs out of handlers or a handler not explicitly closing the connection and also returning False will leave the connection open.

Note that the server will wait for the request body to be complete before calling ```handler``` subs.

If the .handler returns a ```Promise``` then the server waits for the Promise to be kept with a True or False value before continuing

###.middleware (Sub ($request, $response))

Same as ```.handler``` but is called directly following header's being parsed.

If the middleware sub returns a False value, then the server will stop processing further data and leave the connection open.  This allows a connections to be hijacked by middleware for streaming or whatever you want to do with it.

If the middleware returns a ```Promise``` then the server waits for the Promise to be kept with a True or False value before continuing

###.listen 
Starts the server and does block 

##HTTP::Server::Threaded::Request

This handles the parsing of the incoming request

###Attributes

####$.method 
GET/PUT/POST/etc

####%.headers
Key/value pair containing the header values

####$.resource
Requested resource

####$.version
`HTTP/1.1` or `HTTP/1.0` (or whatever was in the request)

####$.data
String containing the data included with the request

##HTTP::Server::Threaded::Response

Response object, handles writing and closing the socket

###Attributes

####$.buffered (Bool) = True
Whether or not the response object should buffer the response and write on close, or write directly to the socket

####$.status (Int)
Set the status of the response, uses HTTP status codes.  See [here](http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html) for more info

####%.headers
Response headers to be sent, accessed directly.  Modifying these after writing to the socket will have no effect on the response unless the `$.buffered` is set to True

###Methods

####write
Write data to the sucket, will call the appropriate method for the socket (Str = $connection.write, anything else is $connection.send)

####close
Close takes optional parameter of data to send out.  Will call `write` if a parameter is provided.  Closes the socket, writes headers if the response is buffered, etc 
