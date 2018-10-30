#include <security/pam_appl.h>
#include <stdlib.h>
#include <string.h>

struct pam_response *reply;
 
int null_conv(int num_msg, const struct pam_message **msg, struct pam_response **resp, void *appdata_ptr) {
 
        *resp = reply;
        return PAM_SUCCESS;
 
}
 
static struct pam_conv conv = { null_conv, NULL };

extern int auth(char *service, char *user, char *pass) {
        char *passcopy;
 
        pam_handle_t *pamh = NULL;
        int retval = pam_start(service, user, &conv, &pamh);
 
        if (retval == PAM_SUCCESS) {
 
                passcopy = malloc(1+strlen(pass));
                strcpy(passcopy, pass);

                reply = (struct pam_response *)malloc(sizeof(struct pam_response));
                reply[0].resp = passcopy;
                reply[0].resp_retcode = 0;
 
                retval = pam_authenticate(pamh, 0);
 
                pam_end(pamh, PAM_SUCCESS);

                return ( retval == PAM_SUCCESS ? 0:1 );
 
        }

        return ( retval == PAM_SUCCESS ? 0:1 );
 
}
