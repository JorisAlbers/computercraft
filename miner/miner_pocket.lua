-- load libraries
shell.run("rm","settings_manager.lua")
shell.run("pastebin","get","XcqAQVWu","settings_manager.lua")
require "settings_manager"

sm = newSettingsManager("settings.txt")
sm.set("server_id",18)

function main()
	print("Starting miner pocket control")	
    peripheral.find("modem", rednet.open)

    initialize()
    	
	draw_ui()
	while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		
        if event == "key_up" and keys.getName(a1) == "enter" then           
            print()
            rednet.send(sm.get("server_id"),"pocket_command;"..char_buffer)
            char_buffer = ""
        elseif event == "char" then
            char_buffer  = char_buffer..a1
            term.write(a1)
        end

        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content,a1)
        end
	end	
end

function parse_rednet_message(message_type,message_content, sender_id)
    if message_type == "pocket_init" then
        if sender_id == sm.get("server_id") then
            server_connected = true
        end
    elseif message_type == "pocket_print" then
        print("server: "..message_content)
    end
end

function initialize()
    print("connecting to main miner server...")
    while not server_connected do        
        rednet.send(sm.get("server_id"),"pocket_init;request")
        local event, a1, a2, a3, a4, a5 = os.pullEvent()
        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content, a1)
        end
    end

    
    if redstone.getInput(sm.get("redstone_hallsensor_side")) then
        x = 0
    end
end

function read_message(message)
    local split = split(message,";")
    if not split[2] then
         split[2] = ""
    end
    return split[1], split[2]
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