unit module CompUnit::Util;
use nqp;
# I would like to have .wrap to do this automaticaly but you
# can't call .wrap stuff at compile time apparently.
# also coercion would be nice but that doesn't seem possible.
sub handle($_) {
    when CompUnit::Handle:D { $_ }
    when CompUnit:D { .handle }
    default { find-loaded($_).handle }
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
    if @parts {
        my $pkg = vivify-QBlock-pkg(qblock,$first);
        set-in-WHO($pkg.WHO,@parts.join('::'),$value);
    } else {
        $*W.install_lexical_symbol(qblock,$first,$value);
    }
}

sub get-in-QBblock(Mu \qblock is raw,$path) {
    my ($first,@parts) = $path.split('::');
    my $top := qblock.symbol($first);
    if $top<value>:exists {
        if @parts {
            return descend-WHO($top<value>.WHO,@parts.join('::'));
        } else {
            return $top<value>;
        }
    } else {
        return Nil;
    }
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

sub descend-WHO($WHO is copy,Str:D $path) is export(:who){
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

sub set-in-WHO($WHO is copy,$path,$value --> Nil) is export(:who) {
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

sub unit-to-hash($handle? is copy) is export(:unit-to-hash) {
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

sub re-export($handle is copy --> Nil)  is export(:re-export) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    get-unit('EXPORT').WHO.merge-symbols($handle.export-package);
    Nil;
}

sub re-exporthow($handle is copy --> Nil) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;

    if $handle.export-how-package -> $target-WHO {
        my $my-WHO := vivify-QBlock-pkg($*UNIT,'EXPORTHOW').WHO;
        $my-WHO.merge-symbols($target-WHO);
    }
    Nil;
}

sub steal-export-sub($handle is copy --> Nil) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    if my $EXPORT  = $handle.export-sub {
        set-unit('&EXPORT',$EXPORT);
    }
    Nil;
}

sub steal-globalish($handle is copy --> Nil) is export(:re-export){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $handle .= &handle;
    my $target = $handle.globalish-package;
    get-unit('GLOBALish').WHO.merge-symbols($target.WHO);
    Nil;
}

sub re-export-everything($_ is copy --> Nil) is export(:re-export) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    $_ .= &handle;
    .&re-export;
    .&re-exporthow;
    .&steal-export-sub;
    .&steal-globalish;
    Nil;
}

sub set-unit(Str:D $path,Mu $value --> Nil) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    set-in-QBlock($*UNIT,$path,$value);
    Nil;
}

sub set-lexpad(Str:D $path,Mu $value --> Nil) is export(:set-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    set-in-QBlock($*W.cur_lexpad,$path,$value);
    Nil;
}


sub push-multi(Routine:D $target where { .is_dispatcher },Routine:D $r --> Nil) {
    $target.add_dispatchee(nqp::decont($r));
    Nil;
}

sub push-QBlock-multi(Mu \qblock,$path,$multi is copy) {
    if get-in-QBblock(qblock,$path) -> $existing {
        if $multi.is_dispatcher {
            die "cannot add dispatcher to '$path' because it already exists";
        } else {
            push-multi($existing,$multi);
        }
    } else {
        $multi .= dispatcher unless $multi.is_dispatcher;
        set-in-QBlock(qblock,$path,$multi);
    }
}

sub push-unit-multi(Str:D $path, $multi where { .multi || .is_dispatcher } --> Nil) is export(:push-multi) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    push-QBlock-multi($*UNIT,$path,$multi);
    Nil;
}

sub push-lexpad-multi(Str:D $path,$multi where { .multi || .is_dispatcher } --> Nil) is export(:push-multi) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    push-QBlock-multi($*W.cur_lexpad,$path,$multi);
    Nil;
}

sub push-lexical-multi(Str:D $path, $multi where { .multi || .is_dispatcher } --> Nil) is export(:push-multi) {
    if get-lexpad($path) -> $existing {
        push-multi($existing,$multi);
    }
    elsif get-lexical($path) -> $existing {
        if $existing.is_dispatcher {
            my $new := $existing.clone().derive_dispatcher();
            push-multi($new,$multi);
            push-lexpad-multi($path,$new);
        }
    }
    else {
        push-lexpad-multi($path,$multi);
    }
    Nil;
}

sub get-unit(Str:D $path) is export(:get-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    return get-in-QBblock($*UNIT,$path);
}

sub get-lexpad(Str:D $path) is export(:get-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    return get-in-QBblock($*W.cur_lexpad(),$path);
}

sub get-lexical(Str:D $path) is export(:get-symbols) {
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;
    die "cannot have '::' in get-lexical lookup (got '$path'). Patch needed!" if $path ~~ /'::'/;
    # this should work with :: but it doesn't
    try {
        return $*W.find_symbol(nqp::split('::',$path));
    }
    Nil;
}

sub mixin_LANG($lang = 'MAIN',:$grammar,:$actions --> Nil) is export(:mixin_LANG){
    die "{&?ROUTINE.name} can only be called at BEGIN time" unless $*W;

    if $grammar !=== Any {
        %*LANG{$lang} := %*LANG{$lang}.^mixin($grammar);
    }

    if $actions !=== Any {
        my $actions-key = $lang ~ '-actions';
        %*LANG{$actions-key} := %*LANG{$actions-key}.^mixin($actions);
    }
    # needed so it will work in EVAL
    set-lexpad('%?LANG',$*W.p6ize_recursive(%*LANG));
    Nil;
}


=pod This is just some pod to test at-unit('CompUnit::Util','$=pod');
