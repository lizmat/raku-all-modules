use Config::Simple;
use Config::INI;
use Config::INI::Writer;

class Config::Simple::ini does Config::Simple::Role {

  method read($filename) {
    $.filename = $filename;
    %!hash = Config::INI::parse_file($.filename);
  }
  
  method write($filename = Any) {
    $.filename = $filename if $filename.defined;
    Config::INI::Writer::dumpfile(%!hash, $.filename);
  }
  
}