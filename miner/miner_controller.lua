-- load libraries
shell.run("rm","settings_manager.lua")
shell.run("pastebin","get","XcqAQVWu","settings_manager.lua")
require "settings_manager"

sm = newSettingsManager("settings.txt")
sm.set("modem_side","right")
sm.set("redstone_hallsensor_side","bottom")
sm.set("redstone_lock_movement_side","top")
sm.set("redstone_direction_side","left")

sm.load()

local char_buffer = ""

function main()
	print("Starting miner controller for x axis")	
	rednet.open(sm.get("modem_side"))
	
	draw_ui()
	while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		
        if event == "key_up" and keys.getName(a1) == "enter" then           
            char_buffer = ""
            print()
        end
        
        if event == "char" then
            char_buffer  = char_buffer..a1
            term.write(a1)
        end

		if event == "redstone" then
			if redstone.getInput(sm.get("redstone_hallsensor_side")) then
				print("contraption arrived")
				-- todo do stuff
			end
		end

        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content)
        end
	end	
end

function draw_ui()
    print("R = return to start position")
    print("y:<number> = move to y position <number>")
    print("x:<number> = move to x position <number>")
end

function parse_rednet_message(message_type,message_content)
    if message_type == "at_y" then
        local y = tonumber(message_content)
        -- todo do stuff
    end
end

function parse_console_message(message)
    if message == "r" or message == "R" then
        return_to_start()
    else
        local split = split(message,":")
        if #split == 2 then
            if split[1] == "y" then
                move_to_y(tonumber(split[2]))
            elseif split[2] == "x" then
                move_to_x(tonumber(split[2]))
            end
        end
    end
end

function move_to_y(y)
    print("moving to y: "..y)
end

function move_to_x(x)
    print("moving to x: "..x)
end

function return_to_start()
    print("returning to start")
    move_to_y(0)
    move_to_x(0)
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