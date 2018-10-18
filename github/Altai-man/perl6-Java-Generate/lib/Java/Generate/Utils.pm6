unit module Java::Generate::Utils;

subset AccessLevel is export of Str where 'public'|'protected'|'private'|'';

subset Modifier is export of Str where 'static'|'final'|'abstract'|'synchronized';

subset Base is export of Str where 'dec'|'hex'|'oct'|'bin';

constant %boolean-ops is export := set '<', '>', '==', '!=', '&&', '||';
