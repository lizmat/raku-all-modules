#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>

void (* UP_set_error)(char *);

typedef struct userinfo {
    char	*login;
    uid_t	 uid;
    gid_t	 gid;
    char	*home;
    char	*shell;
} userinfo;

/*    Populates the passed userinfo struct.
 *    Every OS defines their passwd struct differently so we cannot
 *    rely on accessing it using NativeCall, hence this abstraction.
 *    Returns 0 on success, -1 on failure, the calling code should
 *    treat failure as fatal
 */
int
UP_userinfo(char *user, struct userinfo *ui)
{
    struct passwd 	*pw;

    if ((pw = getpwnam(user)) == NULL) {
    	UP_set_error("could not get user info: no such user");
    	return -1;
    }

    ui->login	= pw->pw_name;
    ui->uid		= pw->pw_uid;
    ui->gid		= pw->pw_gid;
    ui->home	= pw->pw_dir;
    ui->shell	= pw->pw_shell;

    return 0;
}

/*
 * Tries to drop permissions by setting the uid/gid and
 * performs various tests that this did actually work.
 * Returns 0 on success, 1 on error and -1 on fatal error.
 * It is up to the calling code to enforce the fatality.
 */
int
UP_drop_privileges(uid_t new_uid, gid_t new_gid)
{
    uid_t old_uid;
    gid_t old_gid;

    old_uid = getuid();
    old_gid = getgid();

    if (setgroups(1, &new_gid) < 0) {
    	UP_set_error(
    		"could not drop privileges: setting groups did not succeed");
    	return 1;
    }

    if (setregid(new_gid, new_gid) < 0) {
    	UP_set_error("could not drop privileges: setting gid did not succeed");
    	return 1;
    }

    if (setreuid(new_uid, new_uid) < 0) {
    	UP_set_error("could not drop privileges: setting uid did not succeed");
    	return 1;
    }

    /*	being able to regain the old permissions/ids is a fatal error */
    if (old_gid != new_gid && setregid(old_gid, old_gid) != -1) {
    	UP_set_error(
    		"was able to regain dropped privileges: restored old gid");
    	return -1;
    }

    if (old_uid != new_uid && setreuid(old_uid, old_uid) != -1) {
    	UP_set_error(
    		"was able to regain dropped privileges: restored old uid");
    	return -1;
    }

    /* 	to get to here the initial setre[ug]id() had to indicate success
    	therefore if the current *ids don't match what should have been
    	set consider this a fatal error 	*/
    if (getuid() != new_uid || geteuid() != new_uid) {
    	UP_set_error("privileges were not dropped: uid/euid is not correct");
    	return -1;
    }

    if (getgid() != new_gid || getegid() != new_gid) {
    	UP_set_error("privileges were not dropped: gid/egid is not correct");
    	return -1;
    }

    return 0;
}

/*    Sets the owner and group of a file.
 *    Returns 0 on success and 1 on error.
 */
int
UP_change_owner(const char *path, uid_t uid, gid_t gid)
{
    int ret;

    /*	chown returns -1 on failure but we don't want this to be fatal 	*/
    if (chown(path, uid, gid) < 0) {
    	UP_set_error("could not change file owner");
    	ret = 1;
    } else {
    	ret = 0;
    }

    return ret;
}

/*    Changes the root directory.
 *    Returns 0 on success and -1 on failure.
 *    The calling code should treat failure as fatal.
 */
int
UP_change_root(const char *dirname)
{
    return chroot(dirname);
}

void
UP_set_error_callback(void (* callback)(char *))
{
    UP_set_error = callback;
}
