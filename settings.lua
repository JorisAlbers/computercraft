-- settings 
function newSettingsManager(file_path)
	local self = 
	{
		settings = {},
		file_name = file_path
	}
	
	local function file_exists(file)
	  local f = io.open(file, "rb")
	  if f then f:close() end
	  return f ~= nil
	end
	
	local function lines_from(file)
	  if not file_exists(file) then return {} end
	  local lines = {}
	  for line in io.lines(file) do 
		lines[#lines + 1] = line
	  end
	  return lines
	 end
	 
	local function split(s, separator)
		local fields = {}      
		local pattern = string.format("([^%s]+)", separator)
		string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
		return fields
	end
		
	local function set(name,value)
		self.settings[name] = value
	end
	
	local function get(name)
		return self.settings[name]
	end
	
	local function save()
		print("Settings: saving settings")
		local file = io.open(self.file_name, "w")
		
		for key,value in pairs(self.settings) do
			file:write(key)
			file:write(";")		
			if type(value) == "boolean" then
				if value then
					file:write("true")
				else
					file:write("false")
				end
			else
				file:write(value)
			end		
			file:write("\n")
		end	
		io.close(file)
	end
	
	local function load()
		print("Settings: loading")
		if not file_exists(self.file_name) then
			print("Settings : settings file does not exist. Creating a new one")
			save(self.file_name)
			return
		end
	
		text = lines_from(self.file_name)
		for index, line in ipairs(text) do
			array = split(line,";")
			key = array[1]
			value = array[2]

			if not key then
				print("failed to load setting: empty line at index "..index)
			elseif self.settings[key] == nil then
				print("Settings: can not deserialize unregisted setting with key "..key)
			elseif type(self.settings[key]) == "boolean" then
				self.settings[key] = value == "true"
			elseif type(self.settings[key]) == "number" then
				self.settings[key] = tonumber(value)
			else
				self.settings[key] = value
			end	
		end
	end


	return 
	{
		set = set,
		get = get,
		load = load,
		save = save
	}
end