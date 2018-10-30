use v6;

role WebService::GitHub::Role::CustomUserAgent {
    method prepare_request($request) {
        $request.header.field(User-Agent => %.role_data<custom_useragent>) if %.role_data<custom_useragent>:exists;
        nextsame;
    }

    method set-custom-useragent($ua) {
        %.role_data<custom_useragent> = $ua;
    }
}