# Win32 Demo Application

This is a demo application for learning purposes. 
It is a simple bitmap application that allows you to draw a bitmap on the screen and drag it around. 
The bitmap is loaded from a resource file and can be resized by dragging the bottom right corner.

![screenshot](screenshot.png)

## Features (For now)

- Simple bitmap application
- Bitmap loaded from a resource file
- Bitmap can be resized by dragging and selecting an area inside the window
- Bitmap can be dragged around the screen

## Requirements

- Windows 10 or later (probably works on Windows 7 and earlier, but not tested)
- Visual Studio 2022 or later (probably works on Visual Studio 2019 and earlier, but not tested)

## Usage

To run the application, run the `build.bat` script with the `release` or `debug` argument. 
For example, to build the application in release mode, run `build.bat release`. 
The script will create a `build` directory in the project root, and it will build the application in the `release` directory.

To run the application, double-click on the `app.exe` file in the `build` directory.
