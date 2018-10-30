
use JSON::Pretty;
use Config::Simple::Role;

class Config::Simple::JSON does Config::Simple::Role {
  method read($filename) {
    $.filename = $filename;
    %!hash = from-json(slurp($.filename));
  }
  
  method write($filename = Any) {
    $.filename = $filename if $filename.defined;
    my $fh = open $.filename, :w;
    $fh.print(to-json(%!hash));
    $fh.print("\n");
    $fh.close();
  }
}