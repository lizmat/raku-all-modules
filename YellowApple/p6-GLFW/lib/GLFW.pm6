unit module GLFW;

use NativeCall;

########################################################################
# Native C API                                                         #
########################################################################

our sub init(
) returns int32 is native('glfw') is symbol('glfwInit') {*}

our sub terminate(
) is native('glfw') is symbol('glfwTerminate') {*}

our sub set-error-callback(
    &callback (int32, Str)
) is native('glfw') is symbol('glfwSetErrorCallback') {*}

our sub get-version(
    int32 $major is rw,
    int32 $minor is rw,
    int32 $rev is rw
) is native('glfw') is symbol('glfwGetVersion') {*}

our sub get-version-string(
) returns Str is native('glfw') is symbol('glfwGetVersionString') {*}

our sub poll-events(
) is native('glfw') is symbol('glfwPollEvents') {*}

our sub wait-events(
) is native('glfw') is symbol('glfwWaitEvents') {*}

our sub wait-events-timeout(
    num64 $timeout
) is native('glfw') is symbol('glfwWaitEventsTimeout') {*}

our sub post-empty-event(
) is native('glfw') is symbol('glfwPostEmptyEvent') {*}

our sub get-key-name(
    int32 $key,
    int32 $scancode
) returns Str is native('glfw') is symbol('glfwGetKeyName') {*}

our sub joystick-present(
    int32 $joystick
) returns int32(Bool) is native('glfw') is symbol('glfwJoystickPresent') {*}

our sub get-joystick-axes(
    int32 $joystick,
    int32 $count is rw
) returns CArray[num32] is native('glfw') is symbol('glfwGetJoystickAxes') {*}

our sub get-joystick-buttons(
    int32 $joystick,
    int32 $count is rw
) returns Str is native('glfw') is symbol('glfwGetJoystickButtons') {*}

our sub get-joystick-name(
    int32 $joystick
) returns Str is native('glfw') is symbol('glfwGetJoystickName') {*}

our sub set-joystick-callback(
    &callback (int32, int32)
) is native('glfw') is symbol('glfwSetJoystickCallback') {*}

our sub get-time(
) returns num64 is native('glfw') is symbol('glfwGetTime') {*}

our sub set-time(
    num64 $time
) is native('glfw') is symbol('glfwSetTime') {*}

our sub get-timer-value(
) returns uint64 is native('glfw') is symbol('glfwGetTimerValue') {*}

our sub get-timer-frequency(
) returns uint64 is native('glfw') is symbol('glfwGetTimerFrequency') {*}

our sub swap-interval(
    int32 $interval
) is native('glfw') is symbol('glfwSwapInterval') {*}

our sub extension-supported(
    Str $extension
) is native('glfw') is symbol('glfwExtensionSupported') {*}

# FIXME: this is probably broken
our sub get-proc-address(
    Str $proc-name
) returns Pointer is native('glfw') is symbol('glfwGetProcAddress') {*}

our sub vulkan-supported(
) returns int32(Bool) is native('glfw') is symbol('glfwGetProcAddress') {*}

our sub get-required-instance-extensions(
    int32 $count is rw
) returns CArray[Str] is native('glfw') is symbol('glfwGetRequiredInstanceExtensions') {*}

# TODO: get some Vulkan stuff defined.  We need a Vulkan package with
# Vulkan::Instance, Vulkan::PhysicalDevice, Vulkan::SurfaceKHR, and
# possibly Vulkan::AllocationCallbacks and Vulkan::Result classes (for
# VkInstance, VkPhysicalDevice, VkSurfaceKHR, and
# VkAllocationCallbacks, respectively)

# our sub get-instance-proc-address(
#     Vulkan::Instance $instance,
#     Str $proc-name
# ) returns Pointer is native('glfw') is symbol('glfwGetInstanceProcAddress') {*}

# our sub get-physical-device-presentation-support(
#     Vulkan::Instance $instance,
#     Vulkan::PhysicalDevice $device,
#     uint32 $queue-family
# ) returns int32(Bool) is native('glfw') is symbol('glfwGetPhysicalDevicePresentationSupport') {*}

# our sub create-window-surface(
#     Vulkan::Instance $instance,
#     Window $window,
#     Vulkan::AllocationCallbacks $allocator,
#     Vulkan::SurfaceKHR $surface
# ) returns Vulkan::Result is native('glfw') is symbol('glfwCreateWindowSurface') {*}


## OpenGL (TODO: consider moving this stuff out to a separate
## module, with or without going through GLFW)

our enum PrimitiveMode(
    GL_POINTS         => 0x0000,
    GL_LINES          => 0x0001,
    GL_LINE_LOOP      => 0x0002,
    GL_LINE_STRIP     => 0x0003,
    GL_TRIANGLES      => 0x0004,
    GL_TRIANGLE_STRIP => 0x0005,
    GL_TRIANGLE_FAN   => 0x0006,
    GL_QUADS          => 0x0007,
    GL_QUAD_STRIP     => 0x0008,
    GL_POLYGON        => 0x0009
);

our enum MatrixMode(
    GL_MATRIX_MODE => 0x0BA0,
    GL_MODELVIEW   => 0x1700,
    GL_PROJECTION  => 0x1701,
    GL_TEXTURE     => 0x1702
);

our sub gl-viewport(int32, int32, int32, int32)
is native('glfw') is symbol('glViewport') {*}

our sub gl-clear(int32)
is native('glfw') is symbol('glClear') {*}

our sub gl-matrix-mode(int32)
is native('glfw') is symbol('glMatrixMode') {*}

our sub gl-load-identity()
is native('glfw') is symbol('glLoadIdentity') {*}

our sub gl-ortho(num64, num64, num64, num64, num64, num64)
is native('glfw') is symbol('glOrtho') {*}

our sub gl-rotatef(num32, num32, num32, num32)
is native('glfw') is symbol('glRotatef') {*}

our sub gl-begin(int32)
is native('glfw') is symbol('glBegin') {*}

our sub gl-color3f(num32, num32, num32)
is native('glfw') is symbol('glColor3f') {*}

our sub gl-vertex3f(num32, num32, num32)
is native('glfw') is symbol('glVertex3f') {*}

our sub gl-end()
is native('glfw') is symbol('glEnd') {*}

our constant GL_COLOR_BUFFER_BIT = 0x00004000;
