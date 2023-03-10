-- rail_console
modem_side = "back"
settings_file = "settings.txt"

function main()
	load_settings()
	
	rednet.open(modem_side)
	draw_ui()
	
	while true do
		local event, x = os.pullEvent()
		if event == "char" then
			-- any message will do.
			rednet.broadcast("start!")	
		end	
	end
end

function draw_ui()
	print("Press any key to start the train!")
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
	io.close(file)
end

function split(s, separator)
    local fields = {}      
    local pattern = string.format("([^%s]+)", separator)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

main()

