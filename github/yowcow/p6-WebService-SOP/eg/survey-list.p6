use v6;
use lib 'lib';
use HTTP::UserAgent;
use JSON::Fast;
use WebService::SOP::V1_1;

my WebService::SOP::V1_1 $sop .= new(
    app-id     => +%*ENV<APP_ID> // 1,
    app-secret => ~%*ENV<APP_SECRET> // '',
);

my HTTP::UserAgent $ua .= new;

my HTTP::Request $req = $sop.get-req(
    'https://partners.surveyon.com/api/v1_1/surveys/json',
    { app_mid => 1234 },
);

say ~$req;

my HTTP::Response $res = $ua.request($req);

say ~$res;

say from-json(~$res.content).perl;
