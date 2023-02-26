-- monorail rail controller
-- MKx3PLW4
settings_file = "settings.txt"
modem_side = "top"
redstone_cart_activator_side = "right"
redstone_assembler_side  = "left"
redstone_active_state = true

function main()
	print("starting rail controller")
	
	load_settings()
	
	redstone.setOutput(redstone_cart_activator_side, not redstone_active_state)
	redstone.setOutput(redstone_assembler_side, not redstone_active_state)
	
	rednet.open(modem_side)
	
	main_loop()	
end

function main_loop()
	while true do 
		local event, a1, a2, a3, a4, a5  = os.pullEvent()
		if event == "rednet_message" then
			redstone.setOutput(redstone_cart_activator_side,redstone_active_state)
			redstone.setOutput(redstone_assembler_side,redstone_active_state)
			os.startTimer(5)
		elseif event =="timer" then
			redstone.setOutput(redstone_cart_activator_side,not redstone_active_state)
			redstone.setOutput(redstone_assembler_side,not redstone_active_state)
		end
	end
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function load_settings()
	print("loading settings")
	if not file_exists(settings_file) then
		print("settings file does not exist. Creating a new one")
		save_settings()
		return
	end
	
	settings = lines_from(settings_file)
	for index, line in ipairs(settings) do
		print(line)
		array = split(line,";")
		key = array[1]
		value = array[2]	
		
		if key == "modem_side" then
			modem_side = value
		elseif key == "redstone_cart_activator_side" then
			redstone_cart_activator_side = value
		elseif key == "redstone_assembler_side" then
			redstone_assembler_side = value
		elseif key == "redstone_active_state" then
			redstone_active_state = value == "true" 
		else
			if key then
				print("failed to load setting: unknown key: "..key)
			else
				print("failed to load setting: empty line at index "..index)
			end
		

		end
	end
	save_settings()
end

function save_settings()
	print("saving settings")
	local file = io.open(settings_file, "w")
	file:write("modem_side;" .. modem_side .. "\n")
	file:write("redstone_cart_activator_side;" .. redstone_cart_activator_side .. "\n")
	file:write("redstone_assembler_side;" .. redstone_assembler_side .. "\n")
	
	if redstone_active_state then
		file:write("redstone_active_state;true\n")
	else
		file:write("redstone_active_state;false\n")
	end
	io.close(file)
end

function split(s, separator)
    local fields = {}      
    local pattern = string.format("([^%s]+)", separator)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

main()