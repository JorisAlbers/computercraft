-- load libraries
local git_url = "https://raw.githubusercontent.com/JorisAlbers/computercraft/main/settings.lua"
shell.run("rm","settings_manager.lua")
shell.run("wget",git_url,"settings_manager.lua")
require "settings_manager"

sm = newSettingsManager("settings.txt")
-- redstone hallsensor side 
sm.set("rhs_arm","bottom")
sm.set("rhs_cargo_pod","left")
sm.set("redstone_lock_movement_side","right")
sm.set("redstone_lock_movement_active_when",true)
sm.load()

local arm_at_startposition = false;
local startup_timer_id;
local should_stop_arm = false;

function main()
	print("Starting rotational controller")	
    peripheral.find("modem", rednet.open)
    initialize()

    while true do
        local event, a1, a2, a3, a4, a5 = os.pullEvent()

        if event == "redstone" then
            if not arm_at_startposition and redstone.getInput(sm.get("rhs_arm")) then
                -- switched from false to true
                print("The arm is now at the start position")
                arm_at_startposition = true;
                if should_stop_arm then
                    redstone.setOutput(sm.get("redstone_lock_movement_side"),sm.get("redstone_lock_movement_active_when"));
                end

            elseif arm_at_startposition and not redstone.getInput(sm.get("rhs_arm")) then
                -- switched from true to false
                print("The arm is no longer at the start position")
                arm_at_startposition = false;
            end
        end        

        if event == "rednet_message" then
            local message_type, message_content = read_message(a2)
            print("type: ".. message_type .. " content: " .. message_content)
        end

        if event == "timer" then
            if a1 == startup_timer_id then
                -- the miner has landed and the arm should be moving now. 
                -- stop the arm when it returns
                print("2 seconds passed. Stopping arm when needed")
                should_stop_arm = true;
            end
        end	
    end
end

function initialize()
    startup_timer_id = os.startTimer(2)
end

main()

