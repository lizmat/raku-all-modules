use v6.c;

use META6::bin :HELPER;

&META6::bin::try-to-fetch-url.wrap({
    say "checking URL: ⟨$_⟩";
    callsame;
});

META6::bin::MAIN(:check);
