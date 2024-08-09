@echo off

:: Default global variables
set CONFIGURATION=DEBUG
set BUILD_DIR=build
set APP_NAME=app
set NEXT_DEST=eof
set ASSET_DIR=assets
set DEFAULT_FLAGS=/GS /analyze- /W3 /Zc:wchar_t /Zi /Zc:inline  /fp:precise /WX- /Zc:forScope /Gd /Oy- /EHsc /errorReport:prompt
set DEFAULT_DEFINES=/D "WIN32" /D "_CONSOLE" /D "_UNICODE" /D "UNICODE"
set RELEASE_FLAGS=/GL /Gy /Gm- /O2 /Oi /MD 
SET DEBUG_FLAGS=/Od /RTC1 /MDd 
:: Allow the caller to pass additional flags
set MORE_FLAGS= 

:: Set libs if not defined
if "%LIBS%" == "" set LIBS= user32.lib Gdi32.lib

:: Check first arg value and goto the appropriate task
if "%1" == "debug" goto :build
if "%1" == "release" goto :build
if "%1" == "clean" goto :clean
if "%1" == "shell" goto :shell
goto :usage

:: Build task
:build

:: Check if "cl"is a known command, if not, load the x64 tools
@WHERE /q cl
IF %ERRORLEVEL% NEQ 0 (
    :: Set the next destination to come back to after the shell
    set NEXT_DEST=after_cl 
    goto :shell
)

:after_cl
:: Reset to the original destination
set NEXT_DEST=eof 

if "%1" == "release" (
    set CONFIGURATION=RELEASE
    set FLAGS=%RELEASE_FLAGS%
    set BUILD_DIR=%BUILD_DIR%\release
) else if "%1" == "debug" (
    set CONFIGURATION=DEBUG
    set FLAGS=%DEBUG_FLAGS%
    set BUILD_DIR=%BUILD_DIR%\debug
)

:: Set input file paths
set RESOURCE_IN=%ASSET_DIR%\%APP_NAME%.rc
set RESOURCE_OUT=%BUILD_DIR%\%APP_NAME%.res
set MANIFEST_IN=%ASSET_DIR%\%APP_NAME%.manifest
SET APP_EXE=%BUILD_DIR%\%APP_NAME%.exe

echo.
echo ********************************************************************************
echo ** Building in "%CONFIGURATION%" mode
echo ** Flags: "%FLAGS%"
echo ** Libraries: "%LIBS%"
echo ** Build directory: "%BUILD_DIR%"
echo ** Resource file: "%RESOURCE_IN%
echo ** Target executable: "%APP_EXE%"
echo ********************************************************************************
echo.

echo Creating build directory (if not exists).
if not exist %BUILD_DIR% mkdir %BUILD_DIR%

echo Compiling resource file "%RESOURCE_IN%" to "%RESOURCE_OUT%"
rc /D%CONFIGURATION% /nologo /fo%RESOURCE_OUT% %RESOURCE_IN%
IF %ERRORLEVEL% NEQ 0 goto :compile_failed

echo Compiling the application in "%CONFIGURATION%" mode.
cl /nologo /source-charset:utf-8  /Fe:%APP_EXE% /Fo:%BUILD_DIR%\ /Fd:%BUILD_DIR%\vc140.pdb^
 %DEFAULT_DEFINES% %DEFAULT_FLAGS% %FLAGS% %MORE_FLAGS%^
 /D%CONFIGURATION%^
 .\%APP_NAME%.c %LIBS% %RESOURCE_OUT%^
 /link /incremental:no
IF %ERRORLEVEL% NEQ 0 goto :compile_failed

echo Applying manifest "%MANIFEST_IN%" to "%APP_EXE%".
mt.exe /nologo /manifest %MANIFEST_IN% /outputresource:%APP_EXE%;1
IF %ERRORLEVEL% NEQ 0 goto :compile_failed

:compile_done
echo.
echo Compilation Done!
goto :%NEXT_DEST%

:compile_failed
echo.
echo Compilation Failed!
goto :%NEXT_DEST%

:: vcvarsall.bat loading task
:shell
:: Load x64 tools to our PATH
:: We look inside every possible version of visual studio 2022
set SEARCH_DIR="C:\Program Files\Microsoft Visual Studio\2022"
set TARGET_SUBPATH="VC\Auxiliary\Build\vcvarsall.bat"
for /f "delims=|" %%f in ('dir /b %SEARCH_DIR%') do (
    @call "%SEARCH_DIR%\%f%\%TARGET_SUBPATH%" x64
    IF %ERRORLEVEL% EQU 0 goto :%NEXT_DEST%
)

echo.
echo Couldn't find a suitable version of "vcvarsall.bat"
echo Please install Visual Studio Build Tools (https://visualstudio.microsoft.com/fr/downloads/?q=build+tools)
echo Aborting compilation...
EXIT /B 1

:: Cleanup task (deletes build directory)
:clean
del /q %BUILD_DIR%
rmdir /q /s %BUILD_DIR%
echo Build directory cleaned.
goto :%NEXT_DEST%

:usage
echo Usage: build [release^|debug] [clean] [shell]
echo.
echo   release - build release version
echo   debug   - build debug version
echo   clean   - clean build directory
echo   shell   - load x64 tools
echo.
echo Example: build release
echo Example: build debug
echo Example: build clean
echo Example: build shell
goto :%NEXT_DEST%

:%NEXT_DEST%
EXIT /B 0