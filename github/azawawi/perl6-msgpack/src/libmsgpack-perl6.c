
#include <msgpack.h>
#include <stdio.h>

#ifdef _WIN32
#define EXTERN_C extern "C" __declspec(dllexport)
#else
#define EXTERN_C extern
#endif

// TODO explain why we are wrapping them

EXTERN_C void wrapped_msgpack_sbuffer_init(msgpack_sbuffer* sbuf)
{
    msgpack_sbuffer_init(sbuf);
}

EXTERN_C void wrapped_msgpack_sbuffer_destroy(msgpack_sbuffer* sbuf)
{
    msgpack_sbuffer_destroy(sbuf);
}

EXTERN_C msgpack_sbuffer* wrapped_msgpack_sbuffer_new(void)
{
    return msgpack_sbuffer_new();
}

EXTERN_C void wrapped_msgpack_sbuffer_free(msgpack_sbuffer* sbuf)
{
    msgpack_sbuffer_free(sbuf);
}

EXTERN_C int wrapped_msgpack_sbuffer_write(void* data, const char* buf, size_t len)
{
    return msgpack_sbuffer_write(data, buf, len);
}

EXTERN_C char* wrapped_msgpack_sbuffer_release(msgpack_sbuffer* sbuf)
{
    return msgpack_sbuffer_release(sbuf);
}

EXTERN_C void wrapped_msgpack_sbuffer_clear(msgpack_sbuffer* sbuf)
{
    msgpack_sbuffer_clear(sbuf);
}

EXTERN_C void wrapped_msgpack_packer_init(msgpack_packer* pk, void* data) {
    msgpack_packer_init(pk, data, msgpack_sbuffer_write);
}

EXTERN_C int wrapped_msgpack_pack_array(msgpack_packer* pk, size_t n) {
    return msgpack_pack_array(pk, n);
}

EXTERN_C int wrapped_msgpack_pack_map(msgpack_packer* pk, size_t n) {
    return msgpack_pack_map(pk, n);
}

EXTERN_C int wrapped_msgpack_pack_bin(msgpack_packer* pk, size_t n) {
#if MSGPACK_VERSION_MAJOR == 0
    return msgpack_pack_raw(pk, n);
#else
    return msgpack_pack_bin(pk, n);
#endif
}

EXTERN_C int wrapped_msgpack_pack_bin_body(msgpack_packer* pk, const void* b, size_t l) {
#if MSGPACK_VERSION_MAJOR == 0
    return msgpack_pack_raw_body(pk, b, l);
#else
    return msgpack_pack_bin_body(pk, b, l);
#endif
}

EXTERN_C int wrapped_msgpack_pack_int(msgpack_packer* pk, int d) {
    return msgpack_pack_int(pk, d);
}

EXTERN_C int wrapped_msgpack_pack_float(msgpack_packer* pk, float d) {
    return msgpack_pack_float(pk, d);
}

EXTERN_C int wrapped_msgpack_pack_double(msgpack_packer* pk, double d) {
    return msgpack_pack_double(pk, d);
}

EXTERN_C int wrapped_msgpack_pack_nil(msgpack_packer* pk) {
    return msgpack_pack_nil(pk);
}

EXTERN_C int wrapped_msgpack_pack_true(msgpack_packer* pk) {
    return msgpack_pack_true(pk);
}

EXTERN_C int wrapped_msgpack_pack_false(msgpack_packer* pk) {
    return msgpack_pack_false(pk);
}

EXTERN_C int wrapped_msgpack_pack_str(msgpack_packer* pk, size_t l) {
#if MSGPACK_VERSION_MAJOR == 0
    return msgpack_pack_raw(pk, l);
#else
    return msgpack_pack_str(pk, l);
#endif
}

EXTERN_C int wrapped_msgpack_pack_str_body(msgpack_packer* pk, const void* b, size_t l) {
#if MSGPACK_VERSION_MAJOR == 0
    return msgpack_pack_raw_body(pk, b, l);
#else
    return msgpack_pack_str_body(pk, b, l);
#endif
}

EXTERN_C int wrapped_msgpack_pack_raw(msgpack_packer* pk, size_t n) {
#if MSGPACK_VERSION_MAJOR == 0
    return msgpack_pack_raw(pk, n);
#else
    return msgpack_pack_v4raw(pk, n);
#endif
}

EXTERN_C int wrapped_msgpack_pack_raw_body(msgpack_packer* pk, const void* b, size_t l) {
#if MSGPACK_VERSION_MAJOR == 0
    return msgpack_pack_raw_body(pk, b, l);
#else
    return msgpack_pack_v4raw_body(pk, b, l);
#endif
}
