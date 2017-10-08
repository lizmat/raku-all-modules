package POSIX {
  use NativeCall;

  constant uid_t = uint32;
  constant gid_t = uint32;

  constant darwin_time_t = uint64;

  constant group = class :: is repr('CStruct') {
                     has Str         $.name;
                     has Str         $.password;
                     has gid_t       $.gid;
                     has CArray[Str] $.members;
                   };
  
  constant passwd = do given ($*KERNEL) {
                      when 'darwin' {
                          # OS X defines extra fields in the passwd struct.
                          class :: is repr('CStruct') {
                            has Str           $.username;
                            has Str           $.password;
                            has uid_t         $.uid;
                            has gid_t         $.gid;
                            has darwin_time_t $.changed;
                            has Str           $.gecos;
                            has Str           $.homedir;
                            has Str           $.shell;
                            has darwin_time_t $.expiration;
                          }
                        };

                        default {
                          # Default passwd struct for Linux and others.
                          class :: is repr('CStruct') {
                            has Str   $.username;
                            has Str   $.password;
                            has uid_t $.uid;
                            has gid_t $.gid;
                            has Str   $.gecos;
                            has Str   $.homedir;
                            has Str   $.shell;
                          }
                        };
                      }

  our sub getgid()  returns gid_t is native is export { * };
  our sub getuid()  returns uid_t is native is export { * };

  our sub setgid(gid_t)  returns int32 is native is export { * };
  our sub setuid(uid_t)  returns int32 is native is export { * };

  our sub getpwnam(Str) returns passwd is native is export { * };

  our sub getgrnam(Str)   returns group is native is export { * };
  our sub getgrgid(gid_t) returns group is native is export { * };
}
