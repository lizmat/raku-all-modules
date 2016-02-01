unit module String::Quotemeta:ver<1.001001>;

multi quotemeta (--> Str) is export {
    return quotemeta CALLERS::<$_>;
}

multi quotemeta ($str --> Str) is export {
    unless $str.defined {
        warn "Use of uninitialized value";
        return Str;
    }

    given $str.Str {
        return S:g/
            (
                <[
                    \x[34f]
                    \x[0]..\x[2f]
                    \x[3a]..\x[40]
                    \x[5b]..\x[5e]
                    \x[60]
                    \x[7b]..\x[a7]
                    \x[a9]
                    \x[ab]..\x[ae]
                    \x[b0]..\x[b1]
                    \x[b6]
                    \x[bb]
                    \x[bf]
                    \x[d7]
                    \x[f7]
                    \x[115f]..\x[1160]
                    \x[61c]
                    \x[1680]
                    \x[17b4]..\x[17b5]
                    \x[180b]..\x[180e]
                    \x[2000]..\x[203e]
                    \x[2041]..\x[2053]
                    \x[2055]..\x[206f]
                    \x[2190]..\x[245f]
                    \x[2500]..\x[2775]
                    \x[2794]..\x[2bff]
                    \x[2e00]..\x[2e7f]
                    \x[3000]..\x[3003]
                    \x[3008]..\x[3020]
                    \x[3030]
                    \x[3164]
                    \x[fd3e]..\x[fd3f]
                    \x[fe00]..\x[fe0f]
                    \x[fe45]..\x[fe46]
                    \x[feff]
                    \x[ffa0]
                    \x[fff0]..\x[fff8]
                    \x[1bca0]..\x[1bca3]
                    \x[1d173]..\x[1d17a]
                    \x[e0000]..\x[e0fff]
                    \x[2adc]
                ]>
            )
        /\\$0/;
    }
}
