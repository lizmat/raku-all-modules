#!/usr/bin/env perl6
use v6;
use lib "lib";

use GLFW;
use GLFW::Window;

sub error-callback(int32 $i,
                   Str $desc) {
    note $desc
}

sub key-callback(GLFW::Window $window,
                 int32 $key,
                 int32 $scancode,
                 int32 $action,
                 int32 $mods) {
    if $key == 256 and $action == 1 {
        # MoarVM panics if we use the object-oriented approach here.
        # Until I figure out why, we use the procedural approach
        # instead.
        # $window.should_close = True;
        GLFW::set-window-should-close($window, True);
    }
}

sub start-gui() {
    my num32 $ratio;
    my int32 $width = 640;
    my int32 $height = 480;
    my Str $title = "Stead";
    
    GLFW::set-error-callback(&error-callback);

    die 'Failed to initialize GLFW' unless GLFW::init().so;

    my $window = GLFW::Window.new($width, $height, $title, Nil, Nil);

    $window.make-context-current();
    GLFW::swap-interval(1);

    $window.key-callback = &key-callback;

    until $window.should-close {
        ($width, $height) = $window.framebuffer-size;
        $ratio = ($width / $height).Num;

        GLFW::gl-viewport(0, 0, $width, $height);
        GLFW::gl-clear(GLFW::GL_COLOR_BUFFER_BIT);

        GLFW::gl-matrix-mode(GLFW::GL_PROJECTION);
        GLFW::gl-load-identity();
        GLFW::gl-ortho(-$ratio, $ratio, -1e0, 1e0, 1e0, -1e0);
        GLFW::gl-matrix-mode(GLFW::GL_MODELVIEW);

        GLFW::gl-load-identity();
        GLFW::gl-rotatef((now * 50e0) % 360, 0e0, 0e0, 1e0);

        GLFW::gl-begin(GLFW::GL_TRIANGLES);
        GLFW::gl-color3f(1e0, 0e0, 0e0);
        GLFW::gl-vertex3f(-0.6e0, -0.4e0, 0e0);
        GLFW::gl-color3f(0e0, 1e0, 0e0);
        GLFW::gl-vertex3f(0.6e0, -0.4e0, 0e0);
        GLFW::gl-color3f(0e0, 0e0, 1e0);
        GLFW::gl-vertex3f(0e0, 0.6e0, 0e0);
        GLFW::gl-end;

        $window.swap-buffers;
        GLFW::poll-events;
    }

    GLFW::terminate();
}

start-gui();
