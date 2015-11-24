use Config::Simple::Role;
use Data::Dump;

class Config::Simple does Config::Simple::Role {

  method read($filename, Str :$f) {
    my $this;
    if ($f) {
      my $module = "Config::Simple::$f";
      require ::($module);
      $this = ::($module).new();
      $this.read($filename);
    } else {
      my $text = slurp($filename);
      $this = self.bless(:filename($filename), :hash(EVAL($text)));
    }
    return $this;
  }

  method new(Str :$f) {
    if ($f) {
      my $module = "Config::Simple::$f";
      require ::($module);
      return ::($module).new();
    }
    return self.bless();
  }

  method write($filename = Any) {
    $.filename = $filename if $filename.defined;
    my $fh = open $.filename, :w;
    $fh.print(Dump(%(%!hash), :color(False)));
    $fh.print("\n");
    $fh.close;
  }

}