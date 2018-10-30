use v6;

unit module HTTP::Status;

## Exports a function get_http_status_msg($code)
## Returns the plain text message that belongs to that code.
## Info from http://en.wikipedia.org/wiki/Http_status_codes

my %HTTPCODES = (
  ## 1xx Informational
  100 => 'Continue',
  101 => 'Switching Protocols',
  102 => 'Processing',
  103 => 'Checkpoint',
  122 => 'Request-URI Too Long',
  ## 2xx Success
  200 => 'OK',
  201 => 'Created',
  202 => 'Accepted',
  203 => 'Non-Authoritative Information',
  204 => 'No Content',
  205 => 'Reset Content',
  206 => 'Partial Content',
  207 => 'Multi-Status',
  226 => 'IM Used',
  ## 3xx Redirection
  300 => 'Multiple Choices',
  301 => 'Moved Permanently',
  302 => 'Found',
  303 => 'See Other',
  304 => 'Not Modified',
  305 => 'Use Proxy',
  306 => 'Switch Proxy',
  307 => 'Temporary Redirect',
  308 => 'Resume Incomplete',
  ## 4xx Client Error
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
  412 => 'Recondition Failed',
  413 => 'Request Entity Too Large',
  414 => 'Request-URI Too Long',
  415 => 'Unsupported Media Type',
  416 => 'Requested Range Not Satisfiable',
  417 => 'Expectation Failed',
  418 => "I'm a teapot",
  422 => 'Unprocessable Entity',
  423 => 'Locked',
  424 => 'Failed Dependency',
  425 => 'Unordered Collection',
  426 => 'Upgrade Required',
  444 => 'No Response',
  449 => 'Retry With',
  450 => 'Blocked by Parental Controls',
  499 => 'Client Closed Request',
  ## 5xx Server Error
  500 => 'Internal Server Error',
  501 => 'Not Implemented',
  502 => 'Bad Gateway',
  503 => 'Service Unavailable',
  504 => 'Gateway Timeout',
  505 => 'HTTP Version Not Supported',
  506 => 'Variant Also Negotiates',
  507 => 'Insufficient Storage',
  509 => 'Bandwidth Limit Exceeded',
  510 => 'Not Extended',
  598 => 'Network Read Timeout Error',
  599 => 'Network Connect Timeout Error',
  ## End of defined codes.
);

our sub get_http_status_msg ($code) is export {
  if %HTTPCODES{~$code}:exists {
    return %HTTPCODES{~$code};
  }
  return 'Unknown';
}

our sub is-info         ($code) is export { 100 <= $code < 200 }
our sub is-success      ($code) is export { 200 <= $code < 300 }
our sub is-redirect     ($code) is export { 300 <= $code < 400 }
our sub is-error        ($code) is export { 400 <= $code < 600 }
our sub is-client-error ($code) is export { 400 <= $code < 500 }
our sub is-server-error ($code) is export { 500 <= $code < 600 }
