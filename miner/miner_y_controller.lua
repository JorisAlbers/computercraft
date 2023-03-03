-- load libraries
shell.run("rm","settings_manager.lua")
shell.run("pastebin","get","XcqAQVWu","settings_manager.lua")
require "settings_manager"

sm = newSettingsManager("settings.txt")
sm.set("modem_side","right")
sm.set("redstone_hallsensor_side","front")
sm.set("redstone_lock_movement_side","top")

sm.load()

function main()
	print("Starting miner controller for y axis")	
	peripheral.find("modem", rednet.open)
	
	while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		
		if event == "redstone" then
			if redstone.getInput(sm.get("redstone_hallsensor_side")) then
				print("contraption arrived")
				rednet.broadcast("at_y;"..0)
			end
		end

        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content)
        end
	end	
end

function parse_rednet_message(message_type,message_content)
    if message_type == "lock_movement" then
        redstone.setOutput(sm.get("redstone_lock_movement_side", parse_bool(message_content)))        
    end
end

function read_message(message)
    local split = split(message,";")
    return split[1], split[0]
end

function parse_bool(text)
    return text == "true"
end

function split(s, separator)
    local fields = {}      
    local pattern = string.format("([^%s]+)", separator)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

main()