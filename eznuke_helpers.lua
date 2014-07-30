--[[

EZ-Nuke helper functions

Any functions that are globally used between routines go here.

]]

-- File needs to exist for append "a" later and zero it out if it already exists
-- Always initalize this file to avoid confusion with old files and the latest run
local logFile = fs.open("reactorcontrol.log", "w")
if logFile then
	logFile.writeLine("Minecraft time: Day "..os.day().." at "..textutils.formatTime(os.time(),true))
	logFile.close()
else
	error("Could not open file reactorcontrol.log for writing.")
end


-- Helper functions


local function printLog(printStr)
	if debugMode then
		-- If multiple monitors, use the last monitor for debugging if debug is enabled
		if #monitorList > 1 then
			term.redirect(monitorList[#monitorList]) -- Redirect to last monitor for debugging
			monitorList[#monitorList].setTextScale(0.5) -- Fit more logs on screen
			write(printStr.."\n")   -- May need to use term.scroll(x) if we output too much, not sure
			term.native()
		end -- if #monitorList > 1 then

		local logFile = fs.open("reactorcontrol.log", "a") -- See http://computercraft.info/wiki/Fs.open
		if logFile then
			logFile.writeLine(printStr)
			logFile.close()
		else
			error("Cannot open file reactorcontrol.log for appending!")
		end -- if logFile then
	end -- if debugMode then
end -- function printLog(printStr)

-- Trim a string
function stringTrim(s)
	assert(s ~= nil, "String can't be nil")
	return(string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

config = {}

-- Save a table into a config file
-- path: path of the file to write
-- tab: table to save
config.save = function(path, tab)
	printLog("Save function called for config for "..path.." EOL")
	assert(path ~= nil, "Path can't be nil")
	assert(type(tab) == "table", "Second parameter must be a table")
	local f = io.open(path, "w")
	local i = 0
	for key, value in pairs(tab) do
		if i ~= 0 then
			f:write("\n")
		end
		f:write("["..key.."]".."\n")
		for key2, value2 in pairs(tab[key]) do
			key2 = stringTrim(key2)
			--doesn't like boolean values
			if (type(value2) ~= "boolean") then
			value2 = stringTrim(value2)
			else
			value2 = tostring(value2)
			end
			key2 = key2:gsub(";", "\\;")
			key2 = key2:gsub("=", "\\=")
			value2 = value2:gsub(";", "\\;")
			value2 = value2:gsub("=", "\\=")	
			f:write(key2.."="..value2.."\n")
		end
		i = i + 1
	end
	f:close()
end --config.save = function(path, tab)

-- Load a config file
-- path: path of the file to read
config.load = function(path)
	printLog("Load function called for config for "..path.." EOL")
	assert(path ~= nil, "Path can't be nil")
	local f = fs.open(path, "r")
	if f ~= nil then
		local tab = {}
		local line = ""
		local newLine
		local i
		local currentTag = nil
		local found = false
		local pos = 0
		while line ~= nil do
			found = false		
			line = line:gsub("\\;", "#_!36!_#") -- to keep \;
			line = line:gsub("\\=", "#_!71!_#") -- to keep \=
			if line ~= "" then
				-- Delete comments
				newLine = line
				line = ""
				for i=1, string.len(newLine) do				
					if string.sub(newLine, i, i) ~= ";" then
						line = line..newLine:sub(i, i)						
					else				
						break
					end
				end
				line = stringTrim(line)
				-- Find tag			
				if line:sub(1, 1) == "[" and line:sub(line:len(), line:len()) == "]" then
					currentTag = stringTrim(line:sub(2, line:len()-1))
					tab[currentTag] = {}
					found = true							
				end
				-- Find key and values
				if not found and line ~= "" then				
					pos = line:find("=")				
					if pos == nil then
						error("Bad INI file structure")
					end
					line = line:gsub("#_!36!_#", ";")
					line = line:gsub("#_!71!_#", "=")
					tab[currentTag][stringTrim(line:sub(1, pos-1))] = stringTrim(line:sub(pos+1, line:len()))
					found = true			
				end			
			end
			line = f.readLine()
		end
		
		f:close()
		
		return tab
	else
		return nil
	end
end --config.load = function(path)



-- round() function from mechaet
local function round(num, places)
	local mult = 10^places
	local addon = nil
	if ((num * mult) < 0) then
		addon = -.5
	else
		addon = .5
	end

	local integer, decimal = math.modf(num*mult+addon)
	newNum = integer/mult
	printLog("Called round(num="..num..",places="..places..") returns \""..newNum.."\".")
	return newNum
end -- function round(num, places)

local function getDevices(deviceType)
	printLog("Called as getDevices(deviceType="..deviceType..")")

	local deviceName = nil
	local deviceIndex = 1
	local deviceList, deviceNames = {}, {} -- Empty array, which grows as we need
	local peripheralList = peripheral.getNames() -- Get table of connected peripherals

	deviceType = deviceType:lower() -- Make sure we're matching case here

	for peripheralIndex = 1, #peripheralList do
		-- Log every device found
		-- printLog("Found "..peripheral.getType(peripheralList[peripheralIndex]).."["..peripheralIndex.."] attached as \""..peripheralList[peripheralIndex].."\".")
		if (string.lower(peripheral.getType(peripheralList[peripheralIndex])) == deviceType) then
			-- Log devices found which match deviceType and which device index we give them
			printLog("Found "..peripheral.getType(peripheralList[peripheralIndex]).."["..peripheralIndex.."] as index \"["..deviceIndex.."]\" attached as \""..peripheralList[peripheralIndex].."\".")
			write("Found "..peripheral.getType(peripheralList[peripheralIndex]).."["..peripheralIndex.."] as index \"["..deviceIndex.."]\" attached as \""..peripheralList[peripheralIndex].."\".\n")
			deviceNames[deviceIndex] = peripheralList[peripheralIndex]
			deviceList[deviceIndex] = peripheral.wrap(peripheralList[peripheralIndex])
			deviceIndex = deviceIndex + 1
		end
	end -- for peripheralIndex = 1, #peripheralList do

	return deviceList, deviceNames
end -- function getDevices(deviceType)

local function eventHandler()
	while not finished do
		-- http://computercraft.info/wiki/Os.pullEvent
		-- http://www.computercraft.info/forums2/index.php?/topic/1516-ospullevent-what-is-it-and-how-is-it-useful/
		event, arg1, arg2, arg3 = os.pullEvent()

		if event == "monitor_touch" then
			sideClick, xClick, yClick = arg1, math.floor(arg2), math.floor(arg3)
			printLog("Side: "..arg1.." Monitor touch X: "..xClick.." Y: "..yClick)
		elseif event == "char" and not inManualMode then
			local ch = string.lower(arg1)
			if ch == "q" then
				finished = true
			elseif ch == "r" then
				finished = true
				os.reboot()
			end -- if ch == "q" then
		end -- if event == "monitor_touch" then
	end -- while not finished do
end -- function eventHandler()
