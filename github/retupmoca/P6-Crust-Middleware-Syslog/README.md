# Crust::Middleware::Syslog

    use Crust::Builder;
    use Crust::Middleware::Syslog;

    builder {
        enable 'Syslog', ident => 'MyApp';
        $app;
    }

or

    use Crust::Middleware::Syslog;

    $app = Crust::Middleware::Syslog.new($app);

And in your app:

    %env<p6sgix.logger>('debug', 'Things happened!');
