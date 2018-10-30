#include <stdlib.h>
#include <strings.h>
#include <stdio.h>

#ifdef VMS
#  include <file.h>
#else
#  if defined(__GNUC__) && defined(__cplusplus) && defined(WIN32)
#    define _NO_OLDNAMES
#  endif
#  include <fcntl.h>
#  if defined(__GNUC__) && defined(__cplusplus) && defined(WIN32)
#    undef _NO_OLDNAMES
#  endif
#endif

#ifdef I_UNISTD
#  include <unistd.h>
#endif

struct definition_pair {
  char *const_pattern;
  char *const_name;
  long long const_value;
};

extern struct definition_pair definitions[];

char* verify_one_named_value (char* name, long long value) {
  struct definition_pair *one = definitions;

  while (one->const_name != NULL) {
    if (strcmp(one->const_name, name)) {
      one++;
      continue;
    }

    if (one->const_value == value) {
      return "OK";
    } else {
      return "WRONG";
    }
  }

  return "MISSING";
}
