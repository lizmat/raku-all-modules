# App::MoarVM::Debug

The MoarVM Debugger allows you to connect to a local MoarVM instance - if it was started with the --debug-port argument passed to MoarVM itself - and control execution of threads, introspect the stack and individual objects.

MoarVM also takes the --debug-suspend commandline argument, which causes MoarVM to immediately pause execution at the start.

Start the moar-remote script and pass the port you used for --debug-port and it should connect.

Type "help" in the debugger's CLI to see what commands are available to you.
