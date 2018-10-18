unit class Hematite::Middleware::Static does Callable;

has Str $.public_dir is required;

method CALL-ME($ctx, $next) {
    my IO::Path $request_path = "{ self.public_dir }/{ $ctx.req.path }".IO;

    # if isn't a directory and the file exists, just serve it
    if (!$request_path.d && $request_path.f) {
        $ctx.serve-file($request_path.absolute);
        return;
    }

    # not a static file, continue to the next middleware
    $next($ctx);
    return;
}
