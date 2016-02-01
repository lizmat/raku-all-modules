use v6;
use nqp;

sub EXPORT(|) {
    my role BetterWorld {
        method do_pragma_or_load_module(Mu $/ is raw, $use, $thisname?) {
            my $name;
            my %cp;
            my $arglist;

            my $RMD := self.RAKUDO_MODULE_DEBUG;

            if $thisname {
                $name := $thisname;
            }
            else {
                my $lnd  := self.dissect_longname(nqp::atkey(nqp::atkey($/, 'module_name'), 'longname'));
                $name    := $lnd.name;
                %cp      := $lnd.colonpairs_hash($use ?? 'use' !! 'no');

                # That's why we do all that:
                return if %cp<if>:exists && %cp<if> == False;

                $arglist := self.arglist($/);
            }

            unless %cp {
                if self.do_pragma($/,$name,$use,$arglist) { return }
            }

            if $use {
                $RMD("Attempting to load '$name'") if $RMD;
                my $comp_unit := self.load_module($/, $name, %cp, $*GLOBALish);
                $RMD("Performing imports for '$name'") if $RMD;
                self.do_import($/, $comp_unit.handle, $name, $arglist);
                self.import_EXPORTHOW($/, $comp_unit.handle);
                $RMD("Imports for '$name' done") if $RMD;
            }
            else {
                nqp::die("Don't know how to 'no $name' just yet");
            }
        }
    }

    $*W.HOW.mixin($*W, BetterWorld);

    { }
}
