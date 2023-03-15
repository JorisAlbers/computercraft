-- load libraries
local git_url = "https://raw.githubusercontent.com/JorisAlbers/computercraft/main/settings.lua"
shell.run("rm","settings_manager.lua")
shell.run("wget",git_url,"settings_manager.lua")
require "settings_manager"

sm = newSettingsManager("settings.txt")
sm.set("redstone_hallsensor_side","bottom")
sm.set("redstone_lock_x_movement_side","right")
sm.set("redstone_lock_x_movement_active_when",false)
sm.set("redstone_direction_side","left")
sm.set("redstone_direction_forwards_when",false)
sm.set("redstone_stop_movement_side","top")
sm.set("redstone_stop_movement_active_when",false)
sm.set("y_controller_id",19)
sm.load()

local y_controller_connected = false;
local char_buffer = ""
local y = 0
local x = 0
local z = 0
local isMovingForwards = true;

local pocket_id = nil


function main()
	log("Starting miner controller for x axis")	
    peripheral.find("modem", rednet.open)
    initialize()
	
	draw_ui()
	while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		
        if event == "key_up" and keys.getName(a1) == "enter" then           
            log()
            parse_console_message(char_buffer)
            char_buffer = ""
        elseif event == "char" then
            char_buffer  = char_buffer..a1
            term.write(a1)
        end

		if event == "redstone" then
			if redstone.getInput(sm.get("redstone_hallsensor_side")) then
				log("x == 0")
                x = 0;
			end
		end

        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			log("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content,a1)
        end
	end	
end

function initialize()
    log("initalizing")
    stop_moving()
    disallow_x_movement()
    disallow_y_movement()
    disallow_z_movement()

    log("waiting till other controllers connect...")
    while not y_controller_connected do        
        rednet.send(sm.get("y_controller_id"),"init;request")
        local event, a1, a2, a3, a4, a5 = os.pullEvent()
        if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			log("type: ".. message_type .. " content: " .. message_content)
			parse_rednet_message(message_type,message_content, a1)
        end
    end

    
    if redstone.getInput(sm.get("redstone_hallsensor_side")) then
        x = 0
    end
end

function draw_ui()
    log("R = return to start position")
    log("y:<number> = move to y position <number>")
    log("x:<number> = move to x position <number>")
    log("start = start mining")
    log("stop  = stop  mining")
end

function parse_rednet_message(message_type,message_content, sender_id)
    if message_type == "init" then
        if sender_id == sm.get("y_controller_id") then
            y_controller_connected = true
        end
    elseif message_type == "pocket_init" then
        pocket_id = sender_id;
        rednet.send(pocket_id,"pocket_init;accepted")
    elseif message_type == "pocket_command" then
        parse_console_message(message_content)
    elseif message_type == "at_y" then
        y = math.floor(tonumber(message_content))
        -- todo do stuff
    elseif message_type == "at_z" then
        z = math.floor(tonumber(message_content))
        -- todo do stuff
    elseif message_type == "z_heartbeat" then
        local z_alive_for = math.floor(tonumber(message_content))
        log("z has been alive for seconds: "..z_alive_for)
    end
end

function parse_console_message(message)
    if message == "r" or message == "R" then
        return_to_start()
    elseif message == "start" then 
        move_to_z(9)        
    elseif message == "stop" then
        move_to_z(0) 
    else
        local split = split(message,":")
        if #split == 2 then
            if split[1] == "y" then
                local number = tonumber(split[2])
                if number then                        
                    move_to_y(number)
                end
            elseif split[1] == "x" then
                local number = tonumber(split[2])
                if number then                        
                    move_to_x(number)
                end
            end
        end
    end
end

function move_to_y(to_y)
    log("moving to y: "..to_y)
    stop_moving()
    disallow_x_movement()
    allow_y_movement()

    if y == to_y then
        log("already at y: "..y)
        return
    end
    
    if y > to_y then
        -- we need to go down
        rotate_backwards()
    else
        -- we need to go up
        rotate_forwards()
    end

    start_moving()
    y = to_y
    -- todo: keep track of y
end

function move_to_x(to_x)    
    log("moving to x: "..to_x)
    stop_moving()
    disallow_y_movement()
    allow_x_movement()

    if x == to_x then
        log("already at x: "..x)
        return
    end

    if x > to_x then
        -- we need to go down
        rotate_forwards()
    else
        -- we need to go up        
        rotate_backwards()
    end

    start_moving()
    x = to_x
    -- todo: keep track of x
end

function move_to_z(to_z)
    stop_moving()
    allow_z_movement()

    if z == to_z then
        log("already at z: "..x)
        return
    end

    if z > to_z then
        -- we need to go down
        rotate_backwards()
    else
        -- we need to go up
        rotate_forwards()
    end
    start_moving()
    -- todo actually know where we are on the z axis
    z = to_z 
end

function return_to_start()
    log("returning to start")
    move_to_y(0)
    move_to_x(0)
end

function rotate_forwards()
    redstone.setOutput(sm.get("redstone_direction_side"),sm.get("redstone_direction_forwards_when"))
end

function rotate_backwards()
    redstone.setOutput(sm.get("redstone_direction_side"),not sm.get("redstone_direction_forwards_when"))
end

function allow_x_movement()
    redstone.setOutput(sm.get("redstone_lock_x_movement_side"), not sm.get("redstone_lock_x_movement_active_when"))
end

function disallow_x_movement()
    redstone.setOutput(sm.get("redstone_lock_x_movement_side"),  sm.get("redstone_lock_x_movement_active_when"))
end

function allow_y_movement()
    rednet.send(sm.get("y_controller_id"),"movement;start")
end

function disallow_y_movement()
    rednet.send(sm.get("y_controller_id"),"movement;stop")
end

function allow_z_movement()
    disallow_y_movement()
    disallow_x_movement()
end

function disallow_z_movement()
    -- this is based on allowing x or y. do nothing.
end

function start_moving()
    redstone.setOutput(sm.get("redstone_stop_movement_side"),  sm.get("redstone_stop_movement_active_when"))
end

function stop_moving()
    redstone.setOutput(sm.get("redstone_stop_movement_side"),  not sm.get("redstone_stop_movement_active_when"))
end

function log(message)
    if not message then
        print()
        return
    end

    print(message)
    if pocket_id then
        rednet.send(pocket_id,"pocket_log;"..message)
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