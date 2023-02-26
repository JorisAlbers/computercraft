git_location = ""
file_name = "program.lua"

git_url = "https://raw.githubusercontent.com/JorisAlbers/computercraft/main/"

shell.execute("rm",file_name)
shell.execute("wget", git_url..git_location, file_name)
shell.execute("shell",file_name)
