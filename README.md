# Build Scripts

A couple of scripts I wrote in powershell to make compilation easier. Best with the text editor [4Coder](http://4coder.net/).
Includes:
- builder.ps1: creates a basic build script + some folders for management for c/c++. Just run it in an empty directory that you've made of the project.
	> In a folder, say "Hello World", run the build script by executing in the terminal ..\builder.ps1. check the `Usage` for more info.
- opengl_builder.ps1: same as builder.ps1, the only difference is listed in `Usage`
- sdl_builder.ps1: same as builder.ps1, you don't even have to do anything for this one, it'll just work. :P

## Usage:
### builder.ps1:
> Run it, you'll be prompted for **source name** either put filename.c or filename.cpp and in the executable name put, executable_name.exe

### opengl_builder.ps1
> Run it, you'll be prompted for glad link, generate it by going to http://glad.dav1d.de/ (will prolly make this simpler in the near future). And the rest is as same as builder.ps1. 
		p.s. You won't have to setup anything, just double click and run.

### sdl_builder.ps1
> Run it, and it'll automatically download the [SDL2](https://www.libsdl.org/download-2.0.php) lib for MSVC.


### build.ps1
> The actual build script, the other scripts generate build.ps1 and you can just run the script from a developer powershell that's been setup for x64. A guide will be added later on how to do that.

Will add more scripts for other libraries I'll use in the near future.

**NOTE: THIS ONLY WORKS FOR MSVC. Support for other compilers i.e. clang/clang++ and gcc/g++ will be added later.**
