@echo off
where /q link || (
  echo ERROR: "link" not found - please run this from the MSVC x64 native tools command prompt.
  exit /b 1
)

REM Check if nasm.exe exists
where nasm.exe >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo nasm.exe not found. Please install NASM and ensure it is in your PATH.
    exit /b 1
)

if "%Platform%" neq "x64" (
    echo ERROR: Platform is not "x64" - please run this from the MSVC x64 native tools command prompt.
    exit /b 1
)

echo Assembling...
nasm.exe -g -f win64 rule110.s -o rule110.o

echo Linking...

link.exe rule110.o Kernel32.lib /DEBUG /OUT:rule110.exe /INCREMENTAL:NO /NOLOGO /SUBSYSTEM:CONSOLE /ENTRY:_start /TIME
