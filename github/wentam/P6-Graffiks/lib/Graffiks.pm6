use v6;
unit class Graffiks;

use NativeCall;

has $!renderer_flag_deferred = 0x01;
has $!renderer_flag_forward = 0x02;
has &.init_cb;
has &.update_cb;
has &.finish_cb;

sub gfks_init_dt(int32,int32,Str,
  &callback_init (int32,int32),
  &callback_update (num32),
  &callback_finish ())

  is native("libgraffiks") { * }

sub gfks_init_renderers(int32) is native("libgraffiks") { * }

method new(:&init, :&update, :&finish,
           :$window_width = 640,
           :$window_height = 480,
           :$window_title = "Graffiks") {

  my $gfks = self.bless(:init_cb(&init), :update_cb(&update), :finish_cb(&finish));

  gfks_init_dt($window_width, $window_height, $window_title,
              -> $w, $h {$gfks.init_cb.($gfks, $w, $h);CATCH { default { say $_; return -1; } }},
              -> $t {$gfks.update_cb.($gfks, $t);CATCH { default { say $_; return -1; } }},
              -> {$gfks.finish_cb.($gfks);CATCH { default { say $_; return -1; } }});

  return $gfks;
}

method enable-renderers(:$forward, :$deferred) {
  my $flag = 0;

  if ($forward) {
    $flag +|= $!renderer_flag_forward;
  }

  if ($deferred) {
    $flag +|= $!renderer_flag_deferred;
  }

  gfks_init_renderers($flag);
}
