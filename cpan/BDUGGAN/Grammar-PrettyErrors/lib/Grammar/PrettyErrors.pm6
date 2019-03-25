
unit module Grammar::PrettyErrors;

use Terminal::ANSIColor;

class PrettyError {
  has $.parsed;
  has $.target;
  has $!report;
  has Bool $.colors = True;

  method !generate-report($msg) {
    my @msg;
    @msg.push: "--errors--";
    unless $.parsed {
      @msg.push: "Rats, unable to parse anything, giving up.";
      @msg.push: $msg;
      return @msg;
    }
    my $line-no = $.parsed.lines.elems;
    my @lines = $.target.lines;
    my $first = ( ($line-no - 3) max 0 );
    my @near = @lines[ $first.. (($line-no + 3) min @lines-1) ];
    my $i = $line-no - 3 max 0;
    my $chars-so-far = @lines[0..^$first].join("\n").chars;
    my $error-position = $.parsed.chars;
    unless self and self.colors {
      &color.wrap(-> | { "" });
    }
    for @near {
      $i++;
      if $i==$line-no {
        @msg.push: color('bold yellow') ~ $i.fmt("%3d") ~ " │▶" ~ "$_" ~ color('reset');
        @msg.push: "     " ~ '^'.indent($error-position - $chars-so-far);
      } else {
        @msg.push: color('green') ~ $i.fmt("%3d") ~ " │ " ~ color('reset') ~ $_;
        $chars-so-far += .chars;
        $chars-so-far++;
      }
    }
    @msg.push: "";
    @msg.push: "Uh oh, something went wrong around line $line-no.\n";
    @msg.push: "Unable to parse $*LASTRULE." if $*LASTRULE;
    return @msg;
  }

  method report($msg = '') {
    $!report //= self!generate-report($msg).join("\n");
    $!report;
  }
}

role Grammar::PrettyErrors {
  has $.error;
  has $.quiet;
  has Bool $.colors = True;

  method new(|c) {
    return callsame unless self.defined;
    unless self.^find_method('ws').^name ~~ / 'Regex' / {
      my regex whitespace { <!ww> \s* }
      self.^add_method('ws', &whitespace );
      self.^compose;
    }
    self.^find_method('ws').wrap: -> $match, |rest {
       my $pos = $match.pos + 1;
       $*HIGHWATER = $pos if $pos > $*HIGHWATER;
       my $rule = callframe(4).code.name;
       $*LASTRULE = $rule unless $rule eq 'enter';
       callsame;
    }
    callsame;
  }

  multi method report-error($msg) {
      self.report-error(self.target,$msg);
  }

  multi method report-error($target,$msg) {
      my $parsed = $target.substr(0, $*HIGHWATER);
      my $colors = so (self.defined and self.colors);
      my $error = PrettyError.new(:$parsed,:$target,:$colors);
      $!error = $error if self.defined;
      say $error.report($msg) unless self.defined && self.quiet;
  }

  method parse( $target, |c) {
      return self.new.parse($target, |c) without self;
      my $*HIGHWATER = 0;
      my $*LASTRULE;
      my $match = callsame;
      self.report-error($target, "Parsing error.") unless $match;
      return $match;
  }
}
