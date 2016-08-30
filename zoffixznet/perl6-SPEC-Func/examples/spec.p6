use lib <lib>;
use SPEC::Func <dir-sep splitdir>;
say join dir-sep, map &flip, splitdir 'foo/bar/ber';

# OUTPUT:
# oof/rab/reb
