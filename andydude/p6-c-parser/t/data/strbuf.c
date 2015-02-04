typedef long size_t;

//typedef struct strbuf {
//	char  *buf;
//	int    len;
//	int    maxlen;
//} strbuf_t;

//extern void exit(int);
//extern int puts(const char *);
//extern size_t strlen(const char *);
//extern void *memcpy(void *restrict s1, const void *restrict s2, size_t n);

void strbuf_setlen(struct strbuf *strbuf, size_t len) {
	if (len > (strbuf->maxlen ? strbuf->maxlen - 1 : 0)) {
		puts("buffer overflow");
        exit(2);
    }
	strbuf->len = len;
	strbuf->buf[len] = '\0';
}

//void strbuf_grow(struct strbuf *strbuf, size_t extra) {
//    size_t len = strbuf->len + extra;
//	if (len > (strbuf->maxlen ? strbuf->maxlen - 1 : 0)) {
//        puts("grow not implemented");
//        exit(2);
//    }
//}
//
//void strbuf_add(struct strbuf *strbuf, const void *str, size_t extra) {
//	strbuf_grow(strbuf, extra);
//	memcpy(strbuf->buf + strbuf->len, str, extra);
//	strbuf_setlen(strbuf, strbuf->len + extra);
//}
//
//void strbuf_addstr(struct strbuf *strbuf, const char *str) {
//    strbuf_add(strbuf, str, strlen(str));
//}
//
//int main(int argc, char *argv[]) {
//    const char *world;
//    char buffer[0x100];
//    strbuf_t strbuf;
//    
//    strbuf.buf = buffer;
//    strbuf.maxlen = sizeof(buf);
//    strbuf_setlen(&strbuf, 0);
//
//    if (argv != 2) {
//        puts("usage: strbuf <world>");
//        return 1;
//    }
//
//    world = argv[1];
//    strbuf_addstr(&strbuf, "Hello, ");
//    strbuf_addstr(&strbuf, world);
//    strbuf_addstr(&strbuf, "!\n");
//    puts(strbuf.buf);
//
//    return 0;
//}
