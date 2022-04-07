@echo off

set compiler_path="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.27.29110\bin\Hostx64\x64"

: call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat"
%compiler_path%\cl /std:c++17 /EHsc /c .\src\*.cpp /I .\include /Fo".\obj\\" 

%compiler_path%\link /DLL /OUT:WinRTBridge.dll .\obj\*.obj
del *.exp