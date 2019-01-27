use v6.*;
use nqp;
class CompUnit::PrecompilationRepository::Document is CompUnit::PrecompilationRepository::Default {
    method !load-handle-for-path(CompUnit::PrecompilationUnit $unit) {
            my $preserve_global := nqp::ifnull(nqp::gethllsym('perl6', 'GLOBAL'), Mu);
            if $*RAKUDO_MODULE_DEBUG -> $RMD { $RMD("Loading precompiled\n$unit") }
            my $handle := CompUnit::Loader.load-precompilation-file($unit.bytecode-handle);
            $unit.close;
            nqp::bindhllsym('perl6', 'GLOBAL', $preserve_global);
            CATCH {
                default {
                    nqp::bindhllsym('perl6', 'GLOBAL', $preserve_global);
                    .throw;
                }
            }
            $handle
        }
    method !load-file(
            CompUnit::PrecompilationStore @precomp-stores,
            CompUnit::PrecompilationId $id,
            :$repo-id,
        ) {
            my $compiler-id = CompUnit::PrecompilationId.new-without-check($*PERL.compiler.id);
            my $RMD = $*RAKUDO_MODULE_DEBUG;
            for @precomp-stores -> $store {
                $RMD("Trying to load {$id ~ ($repo-id ?? '.repo-id' !! '')} from $store.prefix()") if $RMD;
                my $file = $repo-id
                    ?? $store.load-repo-id($compiler-id, $id)
                    !! $store.load-unit($compiler-id, $id);
                return $file if $file;
            }
            Nil
    }
    multi method load(
        CompUnit::PrecompilationId $id,
        IO::Path :$source,
        Str :$checksum is copy,
        Instant :$since,
        CompUnit::PrecompilationStore :@precomp-stores = Array[CompUnit::PrecompilationStore].new($.store),
    ) {
#        $loaded-lock.protect: {
#            return %loaded{$id} if %loaded{$id}:exists;
#        }
#        my $RMD = $*RAKUDO_MODULE_DEBUG;
        my $compiler-id = CompUnit::PrecompilationId.new-without-check($*PERL.compiler.id);
        my $unit = self!load-file(@precomp-stores, $id);
        if $unit {
#            if (not $since or $unit.modified > $since)
#                and (not $source or ($checksum //= nqp::sha1($source.slurp(:enc<iso-8859-1>))) eq $unit.source-checksum)
#                and self!load-dependencies($unit, @precomp-stores)
#            {
#                my \loaded = ;
#                $loaded-lock.protect: { %loaded{$id} = loaded };
#                return (loaded, $unit.checksum);
                return (self!load-handle-for-path($unit), $unit.checksum);
            }
            else {
#                $RMD("Outdated precompiled {$unit}{$source ?? " for $source" !! ''}\n"
#                     ~ "    mtime: {$unit.modified}{$since ?? ", since: $since" !! ''}\n"
#                     ~ "    checksum: {$unit.source-checksum}, expected: $checksum") if $RMD;
                $unit.close;
#                fail "Outdated precompiled $unit";
#            }
        }
        Nil
    }
}
