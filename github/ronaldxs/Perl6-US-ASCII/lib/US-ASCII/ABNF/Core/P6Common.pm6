# digit is used by both ABNF and p6
# blank and cntrl are p6 classes with different names in ABNF (CTL and WSP)
# hexdig and vchar are from ABNF but are nice to have in p6 for ASCII

# internal use - you probably don't want to use this directly

role US-ASCII::ABNF::Core::P6Common:ver<0.1.2>:auth<R Schmidt (ronaldxs@software-path.com)> {

token digit     { <[0..9]> }
token blank     { <[\t\ ]> }
token cntrl     { <[\x[0]..\x[1f]]+[\x[7f]]> }
token hexdig    { <[0..9A..F]> }
token vchar     { <[\x[21]..\x[7E]]> }

}

# extending grammars with "(is|does) ...::P6Common" overrides
# default p6 character classes so use grammar below to avoid leakage
# instead of is|does - use package qualifier
# like use ...::P6Common_g; /<...P6Common-g::alpha>/
grammar US-ASCII::ABNF::Core::P6Common-g:ver<0.1.2>:auth<R Schmidt (ronaldxs@software-path.com)> does US-ASCII::ABNF::Core::P6Common {}
