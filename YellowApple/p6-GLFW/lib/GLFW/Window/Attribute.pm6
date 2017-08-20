unit module GLFW::Window::Attribute;

# Window attributes

constant Focused        = 0x00020001;
constant Iconified      = 0x00020002;
constant Resizable      = 0x00020003;
constant Visible        = 0x00020004;
constant Decorated      = 0x00020005;
constant AutoIconify    = 0x00020006;
constant Floating       = 0x00020007;
constant Maximized      = 0x00020008;

# Framebuffer (?) attributes

constant RedBits        = 0x00021001;
constant GreenBits      = 0x00021002;
constant BlueBits       = 0x00021003;
constant AlphaBits      = 0x00021004;
constant DepthBits      = 0x00021005;
constant StencilBits    = 0x00021006;
constant AccumRedBits   = 0x00021007;
constant AccumGreenBits = 0x00021008;
constant AccumBlueBits  = 0x00021009;
constant AccumAlphaBits = 0x0002100a;
constant AuxBuffers     = 0x0002100b;
constant Stereo         = 0x0002100c;
constant Samples        = 0x0002100d;
constant SRGBCapable    = 0x0002100e;
constant RefreshRate    = 0x0002100f;
constant DoubleBuffer   = 0x00021010;

# Context attributes

constant ClientAPI      = 0x00022001;
constant ContextVersionMajor = 0x00022002;
constant ContextVersionMinor = 0x00022003;
constant ContextRevision = 0x00022004;
constant ContextRobustness = 0x00022005;
constant OpenGLForwardCompat = 0x00022006;
constant OpenGLDebugContext = 0x00022007;
constant OpenGLProfile = 0x00022008;
constant ContextReleaseBehavior = 0x00022009;
constant ContextNoError = 0x0002200a;
constant ContextCreationAPI = 0x0002200b;

# Attribute values?

constant NoAPI = 0;
constant OpenGLAPI = 0x00030001;
constant OpenGLESAPI = 0x00030002;

constant NoRobustness = 0;
constant NoResetNotification = 0x00031001;
constant LoseContextOnReset = 0x00031002;

constant OpenGLAnyProfile = 0;
constant OpenGLCoreProfile = 0x00032001;
constant OpenGLCompatProfile = 0x00032002;

# Input modes

constant Cursor = 0x00033001;
constant StickyKeys = 0x00033002;
constant StickyMouseButtons = 0x00033003;

constant CursorNormal = 0x00034001;
constant CursorHidden = 0x00034002;
constant CursorDisabled = 0x00034003;

# No idea; more attribute values?

constant AnyReleaseBehavior = 0;
constant ReleaseBehaviorFlush = 0x00035001;
constant ReleaseBehaviorNone = 0x00035002;

constant NativeContextAPI = 0x00036001;
constant EGLContextAPI = 0x00036002;

constant Connected = 0x00040001;
constant Disconnected = 0x00040002;

constant DontCare = -1;
