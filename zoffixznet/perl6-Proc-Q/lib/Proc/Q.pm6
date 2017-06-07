use v6.d.PREVIEW;
use RakudoPrereq v2017.05.347.g.61.ecfd.5,
  'Proc::Q module requires Rakudo v2017.06 or newer';
unit module Proc::Q;

sub proc-q (
    +@commands where .so && .all ~~ List & .so,

            :@tags where .elems == @commands = @commands,
            :@in   where {
                .elems == @commands|0
                and all .map: {$_ ~~ Cool:D|Blob:D|Nil or $_ === Any}
            } = (Nil xx @commands).List,
    Numeric :$timeout where .DEFINITE.not || $_ > 0,
    UInt:D  :$batch   where .so = 8,
            :$out     where Bool:D|'bin' = True,
            :$err     where Bool:D|'bin' = True,
    Bool:D  :$merge   where .not | .so & (
              $out & $err & (
                  ($err eq 'bin' & $out eq 'bin')
                | ($err ne 'bin' & $out ne 'bin'))) = False,

    --> Channel:D
) is export {
    my $c = Channel.new;
    (start await Supply.from-list(@commands Z @tags Z @in).throttle: $batch,
      -> ($command, $tag, $in) {
          with Proc::Async.new: |$command, :w($in.defined) -> $proc {
              CATCH { default { .say } }
              my Stringy $out-res = $out eq 'bin' ?? Buf.new !! '' if $out;
              my Stringy $err-res = $err eq 'bin' ?? Buf.new !! '' if $err;
              my Stringy $mer-res = $out eq 'bin' ?? Buf.new !! '' if $merge;

              $out and $proc.stdout(:bin($out eq 'bin')).tap: $out-res ~= *;
              $err and $proc.stderr(:bin($err eq 'bin')).tap: $err-res ~= *;
              if $merge {
                  $proc.stdout(:bin($out eq 'bin')).tap: $mer-res ~= *;
                  $proc.stderr(:bin($err eq 'bin')).tap: $mer-res ~= *;
              }

              my Promise:D $prom   = $proc.start;
              my Bool:D    $killed = False;
              $timeout.DEFINITE and $proc.ready.then: {
                  Promise.in($timeout).then: {
                      $killed = True;
                      $proc.kill: SIGTERM;
                      Promise.in(1).then: {$prom or $proc.kill: SIGSEGV}
                  }
              }

              with $in {
                  try await $in ~~ Blob ?? $proc.write:  $in
                                        !! $proc.print: ~$in;
                  $proc.close-stdin;
              }

              my $proc-obj = await $prom;

              $c.send: class Res {
                  has Stringy $.out      is required;
                  has Stringy $.err      is required;
                  has Stringy $.merged   is required;
                  has Int:D   $.exitcode is required;
                  has Mu      $.tag      is required;
                  has Bool:D  $.killed   is required;
              }.new: :err($err-res), :out($out-res), :merged($mer-res),
                     :$tag,          :$killed,
                     :exitcode($proc-obj.exitcode)
          }
    }).then: {$c.close};
    $c
}
