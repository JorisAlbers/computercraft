-- elevator console

-- load libraries
shell.run("rm","settings_manager.lua")
shell.run("pastebin","get","XcqAQVWu","settings_manager.lua")
require "settings_manager"

-- setup settings
settings_filepath = "settings.txt"
sm = newSettingsManager(settings_filepath)
sm.set("level",0)
sm.set("elevator_server_id",1)
sm.set("modem_side","back")
sm.set("redstone_sensor_side","left")
sm.set("redstone_button_side","right")
sm.load()

function main()
	print("starting elevator console")
	term.clear()
	rednet.open(sm.get("modem_side"))
	
	draw_ui()
	while true do
		local event, a1, a2, a3, a4, a5 = os.pullEvent()
		if event == "char" then
			if a1 == 'r' or a1 == "R" then
				rednet.send(sm.get("elevator_server_id"),"reboot;")
			else		
				local number = tonumber(a1)
				if number then
					rednet.send(sm.get("elevator_server_id"),"to_level;"..number)
					draw_ui()
				else 
					print("unknown level : " .. a1)
					os.sleep(2)
				end		
			end
		elseif event == "redstone" then
			if redstone.getInput(sm.get("redstone_sensor_side")) then
				print("elevator arrived")
				rednet.send(sm.get("elevator_server_id"),"at_level;"..sm.get("level"))
			end
			
			if redstone.getInput(sm.get("redstone_button_side")) then
				print("calling elevator...")
				-- it must be the button being pressed.
				rednet.send(sm.get("elevator_server_id"),"to_level;"..sm.get("level"))
			end
		end	
	end
	
end



function draw_ui()
	print("Dit is level " .. sm.get("level"))
	print("waar wilt u heen? 0 is helemaal boven")
	print("Type r to reboot elevator controller")
end

main()