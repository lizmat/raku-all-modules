unit module CompUnit::Util;

# I would like to have .wrap to do this automaticaly but you
# can't call .wrap stuff at compile time apparently.
# also coercion would be nice but that doesn't seem possible.
sub handle($_) {
    when CompUnit::Handle:D { $_ }
    when CompUnit:D { .handle }
    default { find-loaded($_).handle }
}

sub load(Str:D $short-name,*%opts --> CompUnit:D) is export(:load){
    $*REPO.need(CompUnit::DependencySpecification.new(:$short-name,|%opts));
}

sub find-loaded($match --> CompUnit) is export(:find-loaded)  {
    my $repo = $*REPO;
    my $found;

    repeat {
        if my $compunit = $repo.loaded.first($match) {
            $found = $compunit;
            last;
        }
    } while $repo .= next-repo;

    return $found || fail "unable find loaded compunit matching '{$match.gist}'";
}

sub all-loaded is export(:all-loaded){
    my $repo = $*REPO;
    do repeat { |$repo.loaded } while $repo .= next-repo;
}

sub all-repos is export(:all-repos) {
    my $repo = $*REPO;
    do repeat { $repo } while $repo .= next-repo;
}

sub at-unit($handle is copy,Str:D $path) is export(:at-unit){
    use nqp;
    $handle .= &handle;
    my ($key,*@path) = $path.split('::');
    do if nqp::existskey($handle.unit,$key) {
        my $val = nqp::atkey($handle.unit,$key);
        return do if @path {
            descend-WHO($val.WHO,@path.join('::'));
        } else {
            $val;
        }
    } else {
        Nil;
    }
}

sub descend-WHO($WHO is copy,Str:D $path) is export(:descend-WHO){
    my @parts = $path.split('::');
    while @parts.shift -> $part {
        if @parts == 0 {
            return $WHO{$part};
        } else {
            return Nil unless $WHO{$part}:exists;
            $WHO = $WHO{$part}.WHO;
        }
    }
}

sub set-in-WHO($WHO is copy,$path,$value) is export(:set-in-WHO) {
    use nqp;
    my @parts = $path.split('::');
    while @parts.shift -> $part {
        if @parts == 0 {
            # if no decont the goofs may happen
            $WHO.{$part} := nqp::decont($value);
        } else {
            if not $WHO.{$part}:exists {
                # if it doesn't exist create it
                $WHO.package_at_key($part);
            }
            $WHO = $WHO.{$part}.WHO;
        }
    }
}

sub unit-to-hash($handle is copy) is export(:unit-to-hash) {
    use nqp;
    my $unit := $handle.unit;
    my Mu $iter := nqp::iterator($unit);
    my %hash;
    while $iter {
        my $i := nqp::shift($iter);
        %hash{nqp::iterkey_s($i)} = nqp::iterval($i);
    }
    return %hash;
}

sub capture-import($handle is copy, *@pos, *%named --> Hash:D) is export(:capture-import){
    $handle .= &handle;
    my $EXPORT     = $handle.export-package;
    my %sym;

    %named<DEFAULT> = True unless %named or @pos;

    for %named.keys {
        %sym.append($EXPORT{$_}.WHO);
    }

    with $handle.export-sub {
        %sym.append: .(|@pos);
    }

    with $handle.globalish-package {
        %sym.append: .WHO;
    }

    return %sym;
}


multi re-export($handle is copy)  is export(:re-export) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
        $handle .= &handle;
    $*UNIT.symbol('EXPORT')<value>.WHO.merge-symbols($handle.export-package);
}

sub vivify-QBlock-pkg(Mu \qblock is raw,$name) {
    my $existing := qblock.symbol($name);
    do if $existing<value>:exists {
        $existing<value>;
    } else {
        my $new := Metamodel::PackageHOW.new_type(:name($name));
        $*W.install_lexical_symbol(qblock,$name,$new);
        $new;
    }
}

sub set-in-QBlock(Mu \qblock is raw,$path,Mu $value) {
    my ($first,@parts) = $path.split('::');
    my $existing := qblock.symbol($first);
    if @parts {
        my $pkg = vivify-QBlock-pkg(qblock,$first);
        set-in-WHO($pkg.WHO,@parts.join('::'),$value);
    } else {
        $*W.install_lexical_symbol(qblock,$first,$value);
    }
}

sub re-exporthow($handle is copy) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;

    if $handle.export-how-package -> $target-WHO {
        my $my-WHO := vivify-QBlock-pkg($*UNIT,'EXPORTHOW').WHO;
        $my-WHO.merge-symbols($target-WHO);
    }
}

sub steal-export-sub($handle is copy) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    if my $EXPORT  = $handle.export-sub {
        $*W.install_lexical_symbol($*UNIT,'&EXPORT',$EXPORT,:clone);
    }
}

sub steal-globalish($handle is copy) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    my $target = $handle.globalish-package;
    $*UNIT.symbol('GLOBALish')<value>.WHO.merge-symbols($target.WHO);
}

sub re-export-everything($_ is copy) is export(:re-export) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $_ .= &handle;
    .&re-export;
    .&re-exporthow;
    .&steal-export-sub;
    .&steal-globalish;
}

sub set-export(%syms,Str:D $tag = 'DEFAULT') is export(:set-symbols){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    for %syms {
        $*UNIT.symbol('EXPORT').<value>.WHO.package_at_key($tag).WHO.{.key} := .value;
    }
}

sub set-globalish(%syms) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;

    for %syms  {
        set-in-WHO($*GLOBALish.WHO,.key,.value);
    }
}

sub set-unit(%syms) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    for %syms {
        set-in-QBlock($*UNIT,.key,.value);
    }
}

sub set-lexical(%syms) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    for %syms {
        set-in-QBlock($*W.cur_lexpad(),.key,.value);
    }
}

sub mixin_LANG($lang = 'MAIN',:$grammar,:$actions) is export(:mixin_LANG){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;

    if $grammar !=== Any {
        %*LANG{$lang} := %*LANG{$lang}.^mixin($grammar);
    }

    if $actions !=== Any {
        my $actions-key = $lang ~ '-actions';
        %*LANG{$actions-key} := %*LANG{$actions-key}.^mixin($actions);
    }
    # needed so it will work in EVAL
    set-lexical(%('%?LANG' => $*W.p6ize_recursive(%*LANG)));
}

sub get-globalish(Str $path?) is export(:get-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    return $*GLOBALish unless $path;
    descend-WHO($*GLOBALish.WHO,$path);
}

=pod This is just some pod to test at-unit('CompUnit::Util','$=pod');
