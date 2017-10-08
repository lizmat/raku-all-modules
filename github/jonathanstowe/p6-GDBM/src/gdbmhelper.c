#include <gdbm.h>
#include <stdlib.h>
#include <string.h>


/*
 * Wrapper for libgdbm, largely because NC wants to pass pointers to structs
 * and that's not what gdbm wants.  We'll just use this rather than lgdbm.
 *
*/

#define datum_set(um, buf) { um.dptr = buf; um.dsize = strlen(buf); }

GDBM_FILE p_gdbm_open (char *fname, int bs, int flags, int mode, void (*fatal)(const char *)) {
    return gdbm_open(fname, bs, flags, mode, fatal);
}

void p_gdbm_close (GDBM_FILE file) {
    gdbm_close(file);
}

int p_gdbm_store (GDBM_FILE file, char *key, char *value, int flags) {
    datum key_d, value_d;
    datum_set(key_d, key);
    datum_set(value_d, value);
    return gdbm_store(file, key_d, value_d, flags);
}

char *p_gdbm_fetch (GDBM_FILE file, char *key) {
    datum val, key_d;
    char *ret;
    datum_set(key_d, key);
    val = gdbm_fetch(file, key_d);
    if ( val.dptr ) {
        ret = (char *)malloc(val.dsize + 1);
        strncpy(ret,val.dptr, val.dsize);
        ret[val.dsize] = '\0';
    }
    else {
        ret = (char *)NULL;
    }
    return ret;
}

int p_gdbm_delete (GDBM_FILE file, char *key) {
    datum key_d;
    datum_set(key_d, key);
    return gdbm_delete(file, key_d);
}

char *p_gdbm_firstkey (GDBM_FILE file) {
    datum val;
    char *ret;
    val = gdbm_firstkey(file);
    if ( val.dptr ) {
        ret = (char *)malloc(val.dsize + 1);
        strncpy(ret,val.dptr, val.dsize);
        ret[val.dsize] = '\0';
    }
    else {
        ret = (char *)NULL;
    }
    return ret;
}

char *p_gdbm_nextkey (GDBM_FILE file, char *lastkey) {
    datum val, lastkey_d;
    char *ret;
    datum_set(lastkey_d, lastkey);
    val = gdbm_nextkey(file, lastkey_d);
    if ( val.dptr ) {
        ret = (char *)malloc(val.dsize + 1);
        strncpy(ret,val.dptr, val.dsize);
        ret[val.dsize] = '\0';
    }
    else {
        ret = (char *)NULL;
    }
    return ret;
}

int p_gdbm_reorganize (GDBM_FILE file) {
    return gdbm_reorganize(file);
}

void p_gdbm_sync (GDBM_FILE file) {
    gdbm_sync(file);
}

int p_gdbm_exists (GDBM_FILE file, char *key) {
    datum key_d;
    datum_set(key_d, key);
    return gdbm_exists(file, key_d);
}

