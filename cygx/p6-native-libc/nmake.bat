@nmake.exe /nologo MKDIR="build\loopify.bat md" RM="build\loopify.bat del" MV="move" INSTALL="build\install.bat" DLLFLAGS="/link /DLL" DLLEXT="dll" CC="cl /nologo" CFLAGS="" OUT="/OUT:" GARBAGE="p6-native-libc.obj p6-native-libc.lib p6-native-libc.exp" %*
