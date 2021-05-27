mkdir code, build, misc | out-null

$source_file = Read-Host "Name of the main source file?"
$exec_name = Read-Host "Name of the executable?"

ni .\build.ps1, .\code\$source_file, .\project.4Coder | out-null

$main_content =
"#include <stdio.h>

int main()
{
	printf(`"%s\n`",`"Hello there!!`");
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
`$executable_name = `"$exec_name`"

# `$lib_path =
# `$include_path =

`$compiler_flags = `"/nologo`", `"/EHsc`", `"/Zi`", `"/FC`"
# `$linker_flags =

# `$libraries = 

Push-Location .\build

#cl /MD `$source_name /Fe`$executable_name `$compiler_flags /I`$include_path /link /LIBPATH:`$lib_path `$libraries `$linker_flags /SUBSYSTEM:console
cl `$source_name /Fe`$executable_name `$compiler_flags

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
