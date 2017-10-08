use v6;

role WebService::GitHub::Role::Debug {
    method prepare_request($request) {
        $*ERR.say(
            map(
                '>>> ' ~  *.subst(/^Authorization: .*$/, 'Authorization: X'),
                $request.Str.chomp.split("\n")
            ).join("\n")
        );
        nextsame;
    }
    method handle_response($response) {
        $*ERR.say( map('<<< ' ~  *, $response.Str.chomp.split("\n")).join("\n") );
        nextsame;
    }
}