use v6;

module SCGI::Constants;

constant CRLF is export = "\x0D\x0A";
constant SEP  is export = "\0";

constant SCGI_E_LENGTH is export = 
  "Malformed netstring, length is incorrect.";
constant SCGI_E_COMMA is export = 
  "Malformed netstring, expecting terminating comma, found \"%s\".";
constant SCGI_E_CONTENT is export =
  "Malformed or missing CONTENT_LENGTH header.";
constant SCGI_E_SCGI is export =
  "Missing or invalid SCGI header.";
constant SCGI_E_INVALID is export =
  "Invalid request, expected a netstring, got: %s";

constant SCGI_M_SHUTDOWN is export =
  "Server shutdown (by request)";
constant SCGI_M_QUIT is export =
  "Server shutdown (explicit command send)";

constant SCGI_ERROR_CODE is export =
  "Status: 500 SCGI Protocol Error";

