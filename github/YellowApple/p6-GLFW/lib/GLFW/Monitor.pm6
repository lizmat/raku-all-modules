#| Object-oriented GLFW monitor interface
unit class GLFW::Monitor is Any is repr('CPointer');

use NativeCall;

need GLFW;
need GLFW::VidMode;
need GLFW::GammaRamp;

#| Returns the "primary" monitor
method primary() {
    GLFW::get-primary-monitor();
}

#| Returns the monitor's x/y coordinates in "screen units" (which may
#| or may not map 1:1 with pixels).
method position() {
    my int32 $x;
    my int32 $y;
    GLFW::get-monitor-pos(self, $x, $y);
    ($x, $y);
}

#| Returns the monitor's physical size in millimeters (or an
#| estimation thereof)
method physical-size() {
    my int32 $w;
    my int32 $h;
    GLFW::get-monitor-physical-size(self, $w, $h);
    ($w, $h);
}

#| Returns the monitor's human-readable name.
method name() {
    GLFW::get-monitor-name(self);
}

#| Sets the monitor callback function, which is run whenever a monitor
#| is connected or disconnected.  The function should accept two
#| arguments: a Monitor object and an integer equal to either
#| 0x00040001 (GLFW::Monitor::Connected) or 0x00040002
#| (GLFW::Monitor::Disconnected).
method callback() is rw {
    return Proxy.new(
        FETCH => sub ($) {}, # TODO: do something reasonable here
        STORE => sub ($, &callback) {
            GLFW::set-monitor-callback(self, &callback);
        });
}

#| Returns an array of the monitor's possible video modes (in the form
#| of GLFW::VidMode objects).
method get-video-modes() {
    my int32 $count;
    my $result = GLFW::get-video-modes(self, $count);
    my @retval;
    @retval[$_] = $result[$_] for ^$count;  # I hope this works
    @retval;
}

#| Returns the monitor's current video mode (GLFW::VidMode).
method get-video-mode() {
    GLFW::get-video-mode(self);
}

#| Sets the monitor's gamma ramp based on a single gamma exponent.
method gamma() is rw {
    return Proxy.new(
        FETCH => sub ($) {},  # FIXME: GLFW doesn't have an equivalent
        STORE => sub ($, $gamma) {
            GLFW::set-gamma(self, $gamma);
        });
}

#| Sets the monitor's gamma ramp directly (using a GLFW::GammaRamp
#| object)
method gamma-ramp() is rw {
    return Proxy.new(
        FETCH => sub ($) {
            GLFW::get-gamma-ramp(self);
        },
        STORE => sub ($, $ramp) {
            GLFW::set-gamma-ramp(self, $ramp);
        });
}



########################################################################
# Native C API                                                         #
########################################################################

our sub get-monitors(
    int32 $count is rw
) returns CArray[GLFW::Monitor] is native('glfw') is symbol('glfwGetMonitors') {*}

our sub get-primary-monitor(
    --> GLFW::Monitor
) is native('glfw') is symbol('glfwGetPrimaryMonitor') {*}

our sub get-monitor-pos(
    GLFW::Monitor $monitor,
    int32 $xpos is rw,
    int32 $ypos is rw
) is native('glfw') is symbol('glfwGetMonitorPos') {*}

our sub get-monitor-physical-size(
    GLFW::Monitor $monitor,
    int32 $width-mm is rw,
    int32 $height-mm is rw
) is native('glfw') is symbol('glfwGetMonitorPhysicalSize') {*}

our sub get-monitor-name(
    GLFW::Monitor $monitor
) returns Str is native('glfw') is symbol('glfwGetMonitorName') {*}

our sub set-monitor-callback(
    &callback (GLFW::Monitor, int32)
) is native('glfw') is symbol('glfwSetMonitorCallback') {*}

our sub get-video-modes(
    GLFW::Monitor $monitor,
    int32 $count is rw
) returns CArray[GLFW::VidMode] is native('glfw') is symbol('glfwGetVideoModes') {*}

our sub get-video-mode(
    GLFW::Monitor $monitor
) returns GLFW::VidMode is native('glfw') is symbol('glfwGetVideoMode'){*}

our sub set-gamma(
    GLFW::Monitor $monitor,
    num32 $gamma
) is native('glfw') is symbol('glfwSetGamma') {*}

our sub get-gamma-ramp(
    GLFW::Monitor $monitor
) returns GLFW::GammaRamp is native('glfw') is symbol('glfwGetGammaRamp') {*}

our sub set-gamma-ramp(
    GLFW::Monitor $monitor,
    GLFW::GammaRamp $ramp
) is native('glfw') is symbol('glfwSetGammaRamp') {*}
