-- load libraries
-- this controller will restart often.
-- only load new settings manager when no lib exists yet

function main()
    local settings_lib = "settings_manager.lua"
    if not file_exists(settings_lib) then
        download_settings_lib()
    end
    require "settings_manager" 
    init_settings()

    send_alive_message()
end


function send_alive_message()
    rednet.send(sm.get("controller_id"),"alive;true")
end

function download_settings_lib()
    local git_url = "https://raw.githubusercontent.com/JorisAlbers/computercraft/main/settings.lua"
    shell.run("rm","settings_manager.lua")
    shell.run("wget",git_url,"settings_manager.lua")
end

function init_settings()
    sm = newSettingsManager("settings.txt")
    sm.set("redstone_hallsensor_side","back")
    sm.set("redstone_lock_movement_side","top")
    sm.set("redstone_lock_movement_active_when",true)
    sm.set("controller_id",18)
    sm.load()
end


function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
  end

main()