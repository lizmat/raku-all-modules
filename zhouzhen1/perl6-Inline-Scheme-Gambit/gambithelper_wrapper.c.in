#include "gambit.h"

#define SCHEME_LIBRARY_LINKER ____20_gambithelper__

___BEGIN_C_LINKAGE
extern ___mod_or_lnk SCHEME_LIBRARY_LINKER (___global_state);
___END_C_LINKAGE

void gambit_init() {
    ___setup_params_struct setup_params;
    ___setup_params_reset (&setup_params);

    setup_params.version = ___VERSION;
    setup_params.linker  = SCHEME_LIBRARY_LINKER;

    ___setup (&setup_params);
}

void gambit_cleanup() {
    ___cleanup();
}

