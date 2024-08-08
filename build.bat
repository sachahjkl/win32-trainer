@echo off

@REM Default global variables
set BUILD_DIR=build
set APP_NAME=app
set NEXT_DEST=eof
set ASSET_DIR=assets
set DEFAULT_FLAGS=/GS /analyze- /W3 /Zc:wchar_t /Zi /Zc:inline  /fp:precise /WX- /Zc:forScope /Gd /Oy- /EHsc /errorReport:prompt
set DEFAULT_DEFINES=/D "WIN32" /D "_CONSOLE" /D "_UNICODE" /D "UNICODE"
set RELEASE_FLAGS=/GL /Gy /Gm- /O2 /Oi /MD 
SET DEBUG_FLAGS=/Od /RTC1 /MDd 
@REM Allow the caller to pass additional flags
set MORE_FLAGS= 

@REM Set libs if not defined
if "%LIBS%" == "" set LIBS= user32.lib Gdi32.lib

@REM Check first arg value and goto the appropriate task
if "%1" == "debug" goto :build
if "%1" == "release" goto :build
if "%1" == "clean" goto :clean
if "%1" == "shell" goto :shell
goto :usage


@REM Label for the build task
:build

@REM Check if "cl"is a known command, if not, load the x64 tools
@WHERE /q cl
IF %ERRORLEVEL% NEQ 0 (
    @REM Set the next destination to come back to after the shell
    set NEXT_DEST=after_cl 
    goto :shell
)
:after_cl
@REM Reset the normal destination
set NEXT_DEST=eof 

@REM Default build configuration
set CONFIGURATION=DEBUG
if "%1" == "release" (
    set CONFIGURATION=RELEASE
    set FLAGS=%RELEASE_FLAGS%
    set BUILD_DIR=%BUILD_DIR%\release
) else if "%1" == "debug" (
    set CONFIGURATION=DEBUG
    set FLAGS=%DEBUG_FLAGS%
    set BUILD_DIR=%BUILD_DIR%\debug
)
echo.
echo ********************************************************************************
echo ** Building in "%CONFIGURATION%" mode
echo ** Flags: "%FLAGS%"
echo ** Libraries: "%LIBS%"
echo ** Build directory: "%BUILD_DIR%"
echo ** Resource file: "%APP_NAME%.rc"
echo ** Target executable: "%APP_NAME%.exe"
echo ********************************************************************************
echo.

echo Creating build directory (if not exists).
@if not exist %BUILD_DIR% mkdir %BUILD_DIR%

echo Compiling the resource file.
rc /D%CONFIGURATION% /nologo /fo%BUILD_DIR%/%APP_NAME%.res %ASSET_DIR%/%APP_NAME%.rc

echo Compiling the application in "%CONFIGURATION%" mode.
cl /nologo /source-charset:utf-8  /Fe:%BUILD_DIR%/%APP_NAME%.exe /Fo:%BUILD_DIR%/ /Fd:%BUILD_DIR%/vc140.pdb^
 %DEFAULT_DEFINES% %DEFAULT_FLAGS% %FLAGS% %MORE_FLAGS%^
 /D%CONFIGURATION%^
 .\%APP_NAME%.c %LIBS% %BUILD_DIR%/%APP_NAME%.res^
 /link /incremental:no

echo Applying the manifest to the executable.
mt.exe /nologo /manifest %ASSET_DIR%/%APP_NAME%.manifest /outputresource:%BUILD_DIR%/%APP_NAME%.exe;1 

echo.
echo Compilation done!

@REM end of build task
goto :%NEXT_DEST%

:shell
REM Load x64 tools to our PATH
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
goto :%NEXT_DEST%

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