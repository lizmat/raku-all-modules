# App::MoarVM::Debug

The MoarVM Debugger allows you to connect to a local MoarVM instance - if it was started with the --debug-port argument passed to MoarVM itself - and control execution of threads, introspect the stack and individual objects.

MoarVM also takes the --debug-suspend commandline argument, which causes MoarVM to immediately pause execution at the start.

Start the moar-remote script and pass the port you used for --debug-port and it should connect.

Type "help" in the debugger's CLI to see what commands are available to you.

### Beta Use Instructions

1. Install the module (you may need to disable tests):
    `zef install --/test App::MoarVM::Debug`
2. Locate `perl6-m` bash script (or `perl6.bat` on Windows): `locate perl6-m`
3. Copy it to some other name: `cp perl6-m perl6-moar-remote-m`
4. Edit it to include `--debug-port=9999` and `--debug-suspend` in `moar` options:
    `[…] install/bin/moar --debug-port=9999 --debug-suspend --execname=[…]`
5. Start the program you want to debug using that new script:
    `perl6-moar-remote-m  my-script.pl`
6. Start the debugger CLI app and have it connect to the same port that's in the
   shell script from step 4: `moar-remote 9999`
7. (Optional) Write `assume thread 1` to assume tracking of first thread
8. Set a breakpoint `breakpoint "my-script.pl" 1234 1 1`
    the string is the filename and `1234` is the line number (`1 1` is the secret ingredient).
    Ensure the line number doesn't point to an empty line.
9. Type `resume` to run your script.
10. The breakpoint will trigger, you can type `all lexicals` to view all lexicals. The numbers
    shown next to them in bold are "handle" numbers.
11. Find the object you want to dump and run `metadata 1234` (`1234` is the handle number).
    - If the features includes `attributes`, you can enter `attributes 1234` for this object.
    - If the features includes `positional`, `positionals 1234` will work.
    - If the features includes `associative`, `associatives 1234` will work.
    - The `metadata` command is only needed if you don't know which of these commands is useful
      for any given type.
12. Type `help` to see all of the available commands.

## Known Issues

The only stepping mode currently available is Step Into.

Backtraces will show incorrect line numbers.
