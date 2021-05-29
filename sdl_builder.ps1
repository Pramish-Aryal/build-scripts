mkdir code, .\code\extern, build, misc | out-null

curl -L "https://www.libsdl.org/release/SDL2-devel-2.0.14-VC.zip" --output SDL2.zip | out-null
tar -zxvf .\SDL2.zip | out-null
del .\SDL2.zip
Rename-Item SDL2-2.0.14 SDL2
copy-item .\SDL2\include\ .\code\extern\SDL2\ -recurse
copy-item .\SDL2\lib\x64\ . -recurse
Rename-Item .\x64\ .\libs
copy-item .\libs\SDL2.dll .\build\
remove-item .\SDL2 -recurse -force | out-null

Pop-Location

$source_file = Read-Host "Name of the main source file?"
$exec_name = Read-Host "Name of the executable?"

ni .\build.ps1, .\code\$source_file, .\project.4Coder | out-null

$main_content =
"
#include <SDL2/SDL.h>
#include <stdio.h>
#include <stdint.h>

typedef int32_t b32;

#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720
int main(int argc, char** argv)
{
    SDL_Init(SDL_INIT_EVERYTHING);
    SDL_Window* window = SDL_CreateWindow(`"Window`", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, 0);
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    b32 is_running = 1;

    while(is_running)
    {
        SDL_Event event;
        while(SDL_PollEvent(&event))
        {
            if(event.type == SDL_QUIT)
                is_running = 0;
            if(event.type == SDL_KEYDOWN)
                if(event.key.keysym.scancode == SDL_SCANCODE_ESCAPE)
                    is_running = 0;
        }

        SDL_SetRenderDrawColor(renderer, 100, 150, 120, 255);
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
    }

    return 0;
}
"

$build_content =
"<#
        Build script
#>
if(!(Test-Path(`".\build\`")))
{
        New-Item -Itemtype Directory `"build`"
}

`$source_name = `"..\code\$source_file`"
`$executable_name = `"$exec_name`" + `".exe`"

`$lib_path = `"..\libs\`"
`$include_path = `"..\code\extern\`"

`$compiler_flags = `"/nologo`", `"/EHsc`", `"/Zi`", `"/FC`"
# `$linker_flags =

`$libraries = `"SDL2.lib`" ,`"SDL2main.lib`",`"user32.lib`" ,`"shell32.lib`", `"gdi32.lib`"

Push-Location .\build

#cl /MD `$source_name /Fe`$executable_name `$compiler_flags /I`$include_path /link /LIBPATH:`$lib_path `$libraries `$linker_flags /SUBSYSTEM:console
cl /MD `$source_name /Fe`$executable_name `$compiler_flags /I`$include_path /link /LIBPATH:`$lib_path `$libraries /SUBSYSTEM:console

Pop-Location
"

$4Coder_project_content =
"version(1);
project_name = $exec_name;
patterns = {
`"*.c`",
`"*.cpp`",
`"*.h`",
`"*.m`",
`"*.bat`",
`"*.sh`",
`"*.4coder`",
`"*.ps1`",
};

blacklist_patterns = {
`".*`",
};

load_paths_base = {
 { `".`", .relative = true, .recursive = true, },
};

load_paths = {
 { load_paths_base, .os = `"win`", },
 { load_paths_base, .os = `"linux`", },
 { load_paths_base, .os = `"mac`", },
};

command_list = {
 { .name = `"build`",
   .out = `"*compilation*`", .footer_panel = true, .save_dirty_files = true,
   .cmd = { { `"pwsh -nop .\build.ps1`" , .os = `"win`"   },
            { `"./build.sh`", .os = `"linux`" },
            { `"./build.sh`", .os = `"mac`"   }, }, },
 { .name = `"run`",
   .out = `"*run*`", .footer_panel = true, .save_dirty_files = false,
   .cmd = { { `"build\\$exec_name`", .os = `"win`"   },
            { `"build/$exec_name`" , .os = `"linux`" },
            { `"build/$exec_name`" , .os = `"mac`"   }, }, },
};

fkey_command[1] = `"build`";
fkey_command[2] = `"run`";
"

Set-Content .\code\$source_file -Value $main_content
Set-Content .\build.ps1 -Value $build_content
Set-Content .\project.4Coder -Value $4Coder_project_content

.\build.ps1