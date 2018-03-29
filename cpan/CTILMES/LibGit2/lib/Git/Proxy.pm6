use NativeCall;

enum Git::Proxy::Type <
    GIT_PROXY_NONE
    GIT_PROXY_AUTO
    GIT_PROXY_SPECIFIED
>;

class Git::Proxy::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has int32 $.type;
    has Str $.url;
    has Pointer $.credentials;
    has Pointer $.certificate-check;
    has Pointer $.payload;
}
