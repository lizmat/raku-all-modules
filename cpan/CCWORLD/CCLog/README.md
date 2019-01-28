## [CCLog](https://github.com/ccworld1000/CCLog)
    Simple and lightweight cross-platform logs,
    easy-to-use simple learning,
    and support for multiple languages,
    such as C, C++, Perl 6, shell, Objective-C
    support ios, osx, watchos, tvos
    support pod, cocoapods https://cocoapods.org/pods/CCLog

## Perl 6
    There are 2 (CCLog & CCLogFull) ways of binding.

Call CCLog.pm6

![short_perl6](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/short_perl6.png)

Call CCLogFull.pm6

![full_perl6](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/full_perl6.png)

## Shell
    Provide simple commands. fg: 
		ccnormal
		ccwarning
		ccerror
		cctimer
		ccloop
		ccthread
		ccprint
		ccsay
		ccdie
		ccnetwork

    These commands are automatically installed locally and can be called directly.


Call shell

![shell](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/shell.png)

## C && C++ && Objective-C
    You can use C library or C source (CCLog.h CCLog.c) code directly.

Call C && C++ && Objective-C

![c](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/c.png)

## Objective-C
    Objective-C can call C directly, Or follow other ways to import.
    or use pod https://github.com/ccworld1000/CCLog

    pod 'CCLog'


## Local installation and unloading
    zef install .
    zef uninstall CCLog

## Network install
    zef update
    zef install CCLog

## Check if the installation is successful

The installation may be as follows

![check_ok](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/check_ok.png)

Installation failure may be as follows, you can try again

![check_error](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/check_error.png)

## Color display control
  Perl6 CCLog.pm6 call ccshowColor
  Perl6 CCLogFull.pm6 call CCLog_showColor
  C && C++ && Objective-C call CCLog_showColor
  fg:

  ![colorControl](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/colorControl.png)

## Tips display control
  fg:

  ![logTips](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/logTips.png)

## Display log control
  fg:

  ![displayLog](https://raw.githubusercontent.com/ccworld1000/CCLog/master/CCLog/doc/sceenshot/displayLog.png)

