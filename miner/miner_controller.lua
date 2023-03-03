-- load libraries
shell.run("rm","settings_manager.lua")
shell.run("pastebin","get","XcqAQVWu","settings_manager.lua")
require "settings_manager"

sm = newSettingsManager("settings.txt")
sm.set("modem_side","right")
sm.set("redstone_hallsensor_side","bottom")
sm.set("redstone_lock_movement_side","top")
sm.set("redstone_lock_movement_active_when",true)
sm.set("redstone_direction_side","left")
sm.set("redstone_direction_forwards_when",true)
sm.set("y_controller_id",19)


sm.load()

local y_controller_connected = false;
local char_buffer = ""
local y = 0
local x = 0
local isMovingForwards = true;


function main()
	print("Starting miner controller for x axis")	
	rednet.open(sm.get("modem_side"))

    initialize()
	
	draw_ui()
	while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		
        if event == "key_up" and keys.getName(a1) == "enter" then           
            print()
            parse_console_message(char_buffer)
            char_buffer = ""
        elseif event == "char" then
            char_buffer  = char_buffer..a1
            term.write(a1)
        end

		if event == "redstone" then
			if redstone.getInput(sm.get("redstone_hallsensor_side")) then
				print("x == 0")
                x = 0;
			end
		end

        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content,a1)
        end
	end	
end

function initialize()
    print("initalizing")
    stop_moving_along_x_axis()
    rotate_backwards()

    print("waiting till other controllers connect...")
    while not y_controller_connected do        
        rednet.send(sm.get("y_controller_id"),"init;request")
        local event, a1, a2, a3, a4, a5 = os.pullEvent()
        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content, a1)
        end
    end

    stop_moving_along_y_axis()
    
    if redstone.getInput(sm.get("redstone_hallsensor_side")) then
        x = 0
    end
end

function draw_ui()
    print("R = return to start position")
    print("y:<number> = move to y position <number>")
    print("x:<number> = move to x position <number>")
end

function parse_rednet_message(message_type,message_content, sender_id)
    if message_type == "request" then
        if sender_id == sm.get("y_controller_id") then
            y_controller_connected = true
        end
    elseif message_type == "at_y" then
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
    stop_moving_along_y_axis()
    start_moving_along_x_axis()
end

function return_to_start()
    print("returning to start")
    move_to_y(0)
    move_to_x(0)
end

function rotate_forwards()
    redstone.setOutput(sm.get("redstone_direction_side"),sm.get("redstone_direction_forwards_when"))
end

function rotate_backwards()
    redstone.setOutput(sm.get("redstone_direction_side"),not sm.get("redstone_direction_forwards_when"))
end

function start_moving_along_x_axis()
    redstone.setOutput(sm.get("redstone_lock_movement_side"),sm.get("redstone_lock_movement_active_when"))
end

function stop_moving_along_x_axis()
    redstone.setOutput(sm.get("redstone_lock_movement_side"), not sm.get("redstone_lock_movement_active_when"))
end

function start_moving_along_y_axis()
    rednet.send(sm.get("y_controller_id"),"movement;start")
end

function stop_moving_along_y_axis()
    rednet.send(sm.get("y_controller_id"),"movement;stop")
end

function read_message(message)
    local split = split(message,";")
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