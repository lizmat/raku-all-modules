use DateTime::Format;

class HTTP::Server::Logger {

  has Str $.fmt is rw = '%h %l %u %t "%r" %>s %b';

  has %.custom;

  multi method format(Str $fmt) {
    $.fmt = $fmt;
  }

  multi method pretty-log {
    $.fmt  = '[%s] %{%Y/%m/%d %H:%m}t %U';

    %.custom<s> //= sub ($data) { 
      if $data.chars > 0 && $data.substr(0,1) eq '2' {
        my $s = '';
        try {
          require Term::ANSIColor;
          if $data.substr(0,1) eq '2' {
            $s ~= Term::ANSIColor.color('green');
          } else {
            $s ~= Term::ANSIColor.color('red');
          }
        }
        $s ~= $data;
        try $s ~= Term::ANSIColor.color('reset');
        return $s;
      }
      my $s  = Term::ANSIColor.color('red') if ::(Term::ANSIColor);
         $s ~= $data if ::(Term::ANSIColor);
         $s  = Term::ANSIColor.color('reset') if ::(Term::ANSIColor);
      return $s;
    };
  }

  multi method log(%data) {
    my $str = $.fmt;
    while $.fmt ~~ m:c/ 
                      ( <!after '%'> '%' ) 
                      [
                        $<neg>='!'? 
                        $<status>=[\d+ % ',']+ 
                      ]? 
                      [ 
                        \{ $<param>=.+? \} 
                      ]**0..1 
                      [ '<' | '>']**0..1
                      $<code>=\w 
                     / {
      my $status = $<status> // '';
      my $neg    = ($<neg>//'') eq '!' ?? True !! False;
      my $param  = $<param> // '';
      my $code   = $<code>;
      if $status.can('split') && %data<s> eq any $status.split(',') {
        if $neg {
          $str.subst("{ $/.Str }", '-');
          next;
        }
      }
      my $d = %data{$code};
      if $code eq 't' {
        $d = strftime($param eq '' ?? '%d/%b/%Y:%k:%M:%S %z' !! $param.Str, $d);
      }
      if $d ~~ Hash {
        $d = $d{$param} if     $param ne '';
        $d = '-'        unless $param ne '';
      }
      $str .=subst($/.Str, %.custom{$code} ~~ Sub ?? %.custom{$code}($d) !! $d // '-');
    }
    return $str.trim;
  }

  method logger {
    return sub ($req, $res) {
      my $time = DateTime.new(time, :timezone($*TZ));
      my @mont = qw<Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;
      my $fmt  = $.log({
        'a'  => try { $res.connection.remote_address; } // '-',
        'A'  => try { $res.connection.localhost; } // '-',
        'b'  => $res.bytes // '-',
        'B'  => $res.bytes // '0',
        'C'  => 'NYI',
        'D'  => 'NYI',
        'e'  => %*ENV,
        'f'  => '-',
        'h'  => '-',
        'H'  => '-',
        'i'  => try { $req.headers } // {},
        'k'  => 1,
        'l'  => '-',
        'm'  => $req.method // '-',
        'n'  => '-',
        'o'  => try { $res.headers } // {},
        'p'  => try { $res.connection.localport; } // '-',
        'P'  => $*PID,
        'q'  => '-',
        'r'  => "{$req.method // 'ERR'} {$req.uri // ''} {$req.version // ''}",
        'R'  => '-',
        's'  => $res.status // '-1',
        't'  => $time,
        'T'  => '-',
        'u'  => '-',
        'U'  => try { $req.uri; } // '-',
        'v'  => '-',
        'V'  => '-',
        'X'  => try { $res.headers<Content-Type>.index('close') > -1 ?? '-' !! '+'; } // '-',
        'I'  => '-',
        'O'  => '-',
      });
      return $fmt;
    };
  };
}
