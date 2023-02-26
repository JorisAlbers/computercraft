-- elevator controller
-- load libraries
shell.run("rm","settings_manager.lua")
shell.run("pastebin","get","XcqAQVWu","settings_manager.lua")
require "settings_manager"

settings_filepath = "settings.txt"
sm = newSettingsManager(settings_filepath)
sm.set("modem_side","back")
sm.set("redstone_direction_side","right")
sm.set("redstone_direction_down_when",false)
sm.set("redstone_activation_side","bottom")
sm.set("redstone_activation_active_when",false)
sm.set("target_level",0)
sm.set("level",-1)
sm.load()

sep=';'
calibration_timer_id = nil

function initialize()
	
end

function turn_off()
	redstone.setOutput(sm.get("redstone_activation_side"), not sm.get("redstone_activation_active_when"))
end

function turn_on()
	redstone.setOutput(sm.get("redstone_activation_side"), sm.get("redstone_activation_active_when"))
end

function move_up()
	redstone.setOutput(sm.get("redstone_direction_side"), not sm.get("redstone_direction_down_when"))
end

function move_down()
	redstone.setOutput(sm.get("redstone_direction_side"), sm.get("redstone_direction_down_when"))
end


function main()
	print("Starting elevator controller")
	
	sm.load()
	
	turn_off()
	
	initialize_elevator()
	
	rednet.open(sm.get("modem_side"))
	
	
	while (true) do 
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		if event == "rednet_message" then
			local message_type, message_content = read_message(a2)
			print("type: ".. message_type .. " content: " .. message_content)
			parse_message(message_type,message_content)
		elseif event == "timer" then
			if a1 == calibration_timer_id then
				if sm.get("level") == -1 then
					-- we are calibrating, and going doing did not help us. go up instead.
					print("Calibrating: going down did not help. Going up now.")
					sm.set("level",999)
					move_to_level(0)
				end
			end
		end	
	end
end

function read_message(message)
	local message_type = ""
	local messsage_content = ""
	i = 0	
	for str in string.gmatch(message, "([^"..sep.."]+)") do
		if i == 0 then
			message_type = str
		elseif i == 1 then
			messsage_content = str
		end
	
		i = i + 1                
    end

	return message_type, messsage_content
end

function parse_message(message_type,message_content)
	if message_type == "at_level" then
		sm.set("level",tonumber(message_content))
		move_to_level(sm.get("target_level"))		
	elseif message_type == "to_level" then
		sm.set("target_level",tonumber(message_content))
		move_to_level(sm.get("target_level"))
	elseif message_type == "reboot" then
		os.reboot()
	end		
end

function move_to_level(l_target_level)
	print("moving towards level "..l_target_level..", current level is "..sm.get("level"))
	
	if sm.get("level") == l_target_level then
			print("reached target level "..l_target_level)
			turn_off()
			return
		elseif sm.get("level") > l_target_level then
			move_up()
			turn_on()
			return
		elseif sm.get("level") < l_target_level then
			move_down()
			turn_on()		
		end	
end

function initialize_elevator()
	print("Calibration: Initializing elevator")
	if sm.get("level") == -1 then
		print("Calibration: Elevator not yet calibrated.")
		calibrate()
	end
	
	if sm.get("level") == sm.get("target_level") then
		print("Calibration: Elavator at target level")
		return;
	end
	
	move_to_level(sm.get("target_level"))	
end

function calibrate()
	print("Calibrating elevator")
	print("trying the down direction first. Trying up in 10 seconds")
	calibration_timer_id = os.startTimer(20)
	move_to_level(999)
end

function split(s, separator)
    local fields = {}      
    local pattern = string.format("([^%s]+)", separator)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    return fields
end
	

main()