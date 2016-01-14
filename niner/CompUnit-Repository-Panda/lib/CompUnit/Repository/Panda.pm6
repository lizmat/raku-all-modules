unit class CompUnit::Repository::Panda does CompUnit::Repository;

my $prev-repo = $*REPO.repo-chain[*-1];
$prev-repo.next-repo = CompUnit::Repository::Panda.new;

method id() {
    'panda'
}

method need(CompUnit::DependencySpecification $spec, CompUnit::PrecompilationRepository $precomp) {
    run('panda', 'install', $spec.short-name);
    $prev-repo.next-repo = CompUnit::Repository;
    LEAVE {
        $prev-repo.next-repo = self;
    }
    $*REPO.need($spec)
}

method loaded() {
    []
}

method path-spec() {
    'panda#'
}
