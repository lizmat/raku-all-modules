@echo off
setlocal enableextensions

set DEST=%1
set DEST=%DEST:/=\%
shift

:LOOP
if "%~1"=="" goto EXIT
set FILE=%1
set FILE=%FILE:/=\%
copy /Y %FILE% %DEST% >NUL
shift
goto LOOP

:EXIT
endlocal
