set PATH=%PATH%;"C:\Program Files\nodejs"

set VSINSTALLDIR=[% VSINSTALLDIR %]
set MSBUILDDIR=[% MSBUILDDIR %]
set MakePriExeFullPath=[% MakePriExeFullPath %]

npm run cordova -- prepare windows
