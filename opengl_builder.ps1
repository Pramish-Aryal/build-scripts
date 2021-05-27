mkdir code, .\code\extern, build, misc | out-null

curl -L "https://github.com/glfw/glfw/releases/download/3.3.4/glfw-3.3.4.bin.WIN64.zip" --output glfw.zip | out-null
tar -zxvf .\glfw.zip | out-null
del .\glfw.zip
Rename-Item .\glfw-3.3.4.bin.WIN64\ .\glfw
Copy-Item .\glfw\include\GLFW .\code\extern\GLFW -recurse
if(!(Test-Path(".\libs"))){mkdir .\libs}
Copy-Item ".\glfw\lib-vc2019\glfw3.lib" .\libs\
#Copy-Item ".\glfw\lib-vc2019\glfw3.dll" .\build\ 
remove-item .\glfw -recurse -force | out-null

$glad_link = Read-Host "Gimme glad link plox"

mkdir glad_temp | out-null
Push-Location .\glad_temp
curl -L $glad_link --output glad.zip | out-null
tar -zxvf .\glad.zip | out-null
Copy-Item .\include\glad ..\code\extern\ -recurse
Copy-Item .\include\KHR ..\code\extern\ -recurse
Copy-Item .\src\glad.c ..\code\ -recurse
del .\glad.zip
Pop-Location
remove-item .\glad_temp -recurse -force

$source_file = Read-Host "Name of the main source file?"
$exec_name = Read-Host "Name of the executable?"

ni .\build.ps1, .\code\$source_file, .\project.4Coder | out-null

$main_content =
"#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>

#define SCREEN_WIDTH 800
#define SCREEN_HEIGHT 600

void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    glViewport(0, 0, width, height);
}

void processInput(GLFWwindow* window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

int main()
{
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    GLFWwindow* window = glfwCreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, `"Window`", NULL, NULL);
    if(!window)
    {
        std::cout << `"Failed to create GLFW Window`" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    
    if(!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << `"Failed to initialize GLAD`" << std::endl;
        return -1;
    }
    
    glViewport(0, 0, 800, 600);
    
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    
    while(!glfwWindowShouldClose(window))
    {
        //Input
        processInput(window);
        
        //Render
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        //Process
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    //glfwTerminate();
    
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

`$source_name = `"..\code\$source_file`", `"..\code\glad.c`"
`$executable_name = `"$exec_name`" + `".exe`"

`$lib_path = `"..\libs\`"
`$include_path = `"..\code\extern\`"

`$compiler_flags = `"/nologo`", `"/EHsc`", `"/Zi`", `"/FC`"
`$linker_flags = `"/NODEFAULTLIB:MSVCRTD`" #to remove the warning

`$libraries = `"glfw3.lib`" ,`"opengl32.lib`",`"user32.lib`" ,`"shell32.lib`", `"gdi32.lib`"

Push-Location .\build

#cl /MD `$source_name /Fe`$executable_name `$compiler_flags /I`$include_path /link /LIBPATH:`$lib_path `$libraries `$linker_flags /SUBSYSTEM:console
cl /MD `$source_name /Fe`$executable_name `$compiler_flags /I`$include_path /link /LIBPATH:`$lib_path `$libraries `$linker_flags /SUBSYSTEM:console

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