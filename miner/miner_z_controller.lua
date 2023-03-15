-- load libraries
-- this controller will restart often.
-- only load new settings manager when no lib exists yet

local z = -1
local heartbeat_timer = nil
local heartbeat_timespan = 20

function main()
    local settings_lib = "settings_manager.lua"
    if not file_exists(settings_lib) then
        download_settings_lib()
    end
    require "settings_manager" 
    init_settings()
    send_heartbeat(0)
    start_heartbeat(heartbeat_timespan)

    while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()

		if event == "redstone" then
			if redstone.getInput(sm.get("redstone_hallsensor_side")) then
				log("z == 0")
                rednet.send(sm.get("controller_id"),"at_z;0")
			end
		end

        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			log("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content,a1)
        elseif event == "timer" then
            if a1 == heartbeat_timer then
                send_heartbeat(heartbeat_timespan)
            end
        end	
    end
end

function start_heartbeat(seconds)
    heartbeat_timer = os.startTimer(seconds)
end

function send_heartbeat(seconds)
    rednet.send(sm.get("controller_id"),"z_heartbeat;"..seconds)
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