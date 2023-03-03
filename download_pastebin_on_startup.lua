local git_location = ""
local file_name = "program.lua"

local args = {...}

if args[1] then
    if args[1] == '-r' then
        shell.execute("pastebin", "get", "dVyxfzsV", "_startup")
        shell.execute("rm","startup")
        shell.execute("mv", "_startup" , "startup")
    end
    return
end

local git_url = "https://raw.githubusercontent.com/JorisAlbers/computercraft/main/"

sleep(1) -- to prevent server startup bug
shell.execute("rm",file_name)
shell.execute("wget", git_url..git_location, file_name)
shell.execute("shell",file_name)
