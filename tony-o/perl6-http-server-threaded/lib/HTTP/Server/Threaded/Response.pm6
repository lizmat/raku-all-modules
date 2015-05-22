class HTTP::Server::Threaded::Response {
  has Int  $.status   is rw = 200;
  has Bool $!buffered       = True;
  has Bool $!senthead       = False;
  has %.headers is rw = 
    Content-Type => 'text/html',
    Connection   => 'keep-alive',
  ;
  has @!buffer;
  has $.connection;

  method !sendheaders (Bool $lastcall? = False) {
    return if $!senthead || (! $lastcall && $!buffered);
    try {
      $!senthead = True;
      my @pairs = %.headers.keys.map({ 
        "$_: {$.headers{$_}}"
      });
      await $.connection.send("HTTP/1.1 $.status {%!statuscodes{$.status}}\r\n");
      await $.connection.send(@pairs.join("\r\n") ~ "\r\n\r\n");
    };
  }

  method unbuffer {
    return True unless $!buffered;
    return try {
      CATCH { default { return False; } }
      $!buffered = False;
      $.flush;
      return True;
    };
  }

  method rebuffer {
    return False if $!buffered || $!senthead;
    $!buffered = True;
  }

  method flush {
    self!sendheaders(True);
    for @!buffer -> $buff {
      $.connection.write($buff);
    }
    @!buffer = Array.new;
  }

  method write($data) {
    try {
      self!sendheaders;
      my $d = $data.^can('encode') ?? $data.encode !! $data;
      return if $d.elems == 0;
      @!buffer.push($d) if $!buffered;
      $.connection.write($d) unless $!buffered;
    };
  }

  method close($data?, :$force? = False) {
    try {
      if Any !~~ $data { 
        $.write($data);
      }
    };
#set content-length
    my $cl = 0;
    for @!buffer -> $buf {
      $cl += $buf.elems;
    }
    %.headers<Content-Length> = $cl;
    $.flush;
    try {
      $.connection.close if %.headers<Connection>.index('keep-alive') > -1 || $force;
    };
  }

  has %!statuscodes = (
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',
    208 => 'Already Reported',
    226 => 'IM Used',
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    306 => '(Unused)',
    307 => 'Temporary Redirect',
    308 => 'Permanent Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Payload Too Large',
    414 => 'URI Too Long',
    415 => 'Unsupported Media Type',
    416 => 'Requested Range Not Satisfiable',
    417 => 'Expectation Failed',
    422 => 'Unprocessable Entity',
    423 => 'Locked',
    424 => 'Failed Dependency',
    426 => 'Upgrade Required',
    428 => 'Precondition Required',
    429 => 'Too Many Requests',
    431 => 'Request Header Fields Too Large',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
  );
};
