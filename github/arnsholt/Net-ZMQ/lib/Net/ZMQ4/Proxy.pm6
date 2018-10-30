use NativeCall;
unit module Net::ZMQ4::Proxy;

# Message proxing
# ZMQ_EXPORT int zmq_proxy (void *frontend, void *backend, void *capture);
our sub zmq_proxy(Pointer[void], Pointer[void], Pointer[void] --> int32)
    is native('zmq', v5) { * }
# ZMQ_EXPORT int zmq_proxy_steerable (void *frontend, void *backend, void *capture, void *control);
our sub zmq_proxy_steerable(Pointer[void], Pointer[void], Pointer[void], Pointer[void] --> int32)
    is native('zmq', v5) { * }
