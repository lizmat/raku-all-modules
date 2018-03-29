enum Git::FileMode (
    GIT_FILEMODE_UNREADABLE          => 0o000000,
    GIT_FILEMODE_TREE                => 0o040000,
    GIT_FILEMODE_BLOB                => 0o100644,
    GIT_FILEMODE_BLOB_EXECUTABLE     => 0o100755,
    GIT_FILEMODE_LINK                => 0o120000,
    GIT_FILEMODE_COMMIT              => 0o160000,
);
