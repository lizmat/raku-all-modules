use IO::CatHandle::AutoLines;

my constant %valid-opts := set <no-reset>;

sub EXPORT (*@opts) {
    my %opts := set @opts;
    %opts ⊆ %valid-opts
        or die "Unknown option passed to LN module in file"
          ~ " {(try $*W.current_file) // '<unknown file>'}."
          ~ "Valid options are: " ~ %valid-opts.keys.join(", ");

    $*ARGFILES does IO::CatHandle::AutoLines[:reset(not %opts<no-reset>)];
    PROCESS::<$LN> := Proxy.new:
        :FETCH{ $*ARGFILES.ln }, :STORE(-> $, $ln { $*ARGFILES.ln = $ln });

    Map.new: 'IO::CatHandle::AutoLines' => IO::CatHandle::AutoLines
}
