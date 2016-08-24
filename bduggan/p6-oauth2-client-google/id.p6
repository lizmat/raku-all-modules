#!/usr/bin/env perl6
use HTTP::UserAgent;

my $token = q:to/DONE/;
eyJhbGciOiJSUzI1NiIsImtpZCI6ImQ1ODcyOTE5OGQ4YTRiMDJhYzI5MDI4MTgxNWY0NWE2MjVkMDgzM
TUifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhdF9oYXNoIjoiUHhuNHR5cV9
aakJXWVc5QTFmVnFoUSIsImF1ZCI6IjQ3OTcxNjgxODIxLWdicDR0ZzNjdHQxYTFuMWVvZWpibnZpNmo0
dnFzN2JiLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTAyNTQ1Nzc1MjkyOTEyNjM1O
TgwIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImF6cCI6IjQ3OTcxNjgxODIxLWdicDR0ZzNjdHQxYTFuMW
VvZWpibnZpNmo0dnFzN2JiLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJiZHVnZ2F
uMkBnbWFpbC5jb20iLCJpYXQiOjE0Njk3MzE1NTksImV4cCI6MTQ2OTczNTE1OX0.C0ZB5w6EZ7SHugzf
YSmrto-clGha3Hp9aDRi7b2aJ6kXBYL67nL5xv9y63J9OrNZeklcGao8dmjmOMqhqOxI5lw-VL62jHAD1
aBcmeM5uThvAKov-LR6AsLiOsyyj9sK_mpnFs8yKJ76dKtvvi5wYXOJCCJIgn3dkJAAIYMmF0kVBos0S1
24DWrsTHx3wn0gjYtYYEcxSdrAxgyK6ojmVvz37XPgeuIi1NyP5_VHDHfVkl15F2fyOzec31gjn5cvvX3
_LUvt6Le54gnRN030vJ8v_JoK38F90Jk0R2Z2B8dCsRBFHfq2h0mo2WeBuxH83s9MEBCxv7iKR1Pz3KgT
sA
DONE

$token.=subst(rx'\s','',:g);

my $ua = HTTP::UserAgent.new;
my $res = $ua.get("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=$token");
say $res.content;

# {
#  "iss": "https://accounts.google.com",
#  "at_hash": "Pxn4tyq_ZjBWYW9A1fVqhQ",
#  "aud": "47971681821-gbp4tg3ctt1a1n1eoejbnvi6j4vqs7bb.apps.googleusercontent.com",
#  "sub": "102545775292912635980",
#  "email_verified": "true",
#  "azp": "47971681821-gbp4tg3ctt1a1n1eoejbnvi6j4vqs7bb.apps.googleusercontent.com",
#  "email": "bduggan2@gmail.com",
#  "iat": "1469731559",
#  "exp": "1469735159",
#  "alg": "RS256",
#  "kid": "d58729198d8a4b02ac290281815f45a625d08315"
# }


