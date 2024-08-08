@echo off

@REM Set the flags for the compiler.
set FLAGS=

@REM Define build properties.
set BUILD_DIR=build
set APP_NAME=app
set CONFIGURATION=DEBUG

set LIBS= user32.lib Gdi32.lib

mkdir %BUILD_DIR%

@REM Compile the resource file.
rc /D%CONFIGURATION% /nologo /fo%BUILD_DIR%/%APP_NAME%.res %APP_NAME%.rc  

@REM Compile the application.
cl /nologo /D%CONFIGURATION% /source-charset:utf-8 /Fe:%BUILD_DIR%/%APP_NAME%.exe /Fo:%BUILD_DIR%/ /Fd:%BUILD_DIR%/vc140.pdb /Zi %FLAGS%^
 .\app.c %LIBS% %BUILD_DIR%/%APP_NAME%.res^
 /link /incremental:no /debug:fastlink

@REM Apply the manifest to the executable.
mt.exe /nologo /manifest %APP_NAME%.manifest /outputresource:%BUILD_DIR%/%APP_NAME%.exe;1 