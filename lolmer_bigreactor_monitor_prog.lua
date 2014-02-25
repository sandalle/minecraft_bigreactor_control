--[[
	Program name: Lolmer's EZ-NUKE reactor control system
	Version: v0.3.2
	Programmer: Lolmer
	Last update: 2014-02-24
	Pastebin: http://pastebin.com/fguScPBQ

	Description:
	This program controls a Big Reactors nuclear reactor
	in Minecraft with a Computercraft computer, using Computercraft's
	own wired modem connected to the reactors computer control port.

	This program was designed to work with the mods and versions installed on Never Stop Toasting (NST) Diet
	http://www.technicpack.net/modpack/details/never-stop-toasting-diet.254882
	Endeavour: Never Stop Toasting: Diet official Minecraft server http://forums.somethingawful.com/showthread.php?threadid=3603757

	Features:
		Configurable min/max energy buffer and min/max temperature via ReactorOptions file.
		ReactorOptions is read on start and then current values are saved every program cycle.
		Rod Control value in ReactorOptions is only useful for initial start, after that the program saves the current Rod Control average over all Fuel Rods for next boot.
		Auto-adjusts control rods per reactor to maintain temperature.
		Will display reactor data to all attached monitors of correct dimensions.
		Dynamically detect and add/remove monitors as they are connected to the network (not recommended).
		Disable rod auto-adjust by right-clicking between the rod control buttons "<" and ">"

	Default values:
		Rod Control: 90% (Let's start off safe and then power up as we can)
		Minimum Energy Buffer: 15% (will power on below this value)
		Maximum Energy Buffer: 85% (will power off above this value)
		Minimum Temperature: 850^C (will raise control rods below this value)
		Maximum Temperature: 950^C (will lower control rods above this value)

	Requirements:
		Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
		Computer or Advanced Computer
		Modems (not wireless) connecting each of the Computer to both the Advanced Monitor and Reactor Computer Port.
		Big Reactors (http://www.big-reactors.com/) 0.3
		Computercraft (http://computercraft.info/) 1.57+

	Resources:
	This script is available from:
		http://pastebin.com/fguScPBQ
		https://github.com/sandalle/minecraft_bigreactor_control
	Start-up script is available from:
		http://pastebin.com/ZTMzRLez
		https://github.com/sandalle/minecraft_bigreactor_control
	Other reactor control program which I based my program on:
		http://pastebin.com/aMAu4X5J (ScatmanJohn)
		http://pastebin.com/HjUVNDau (version ScatmanJohn based his on)
	A simpler Big Reactor control program is available from:
		http://pastebin.com/tFkhQLYn (IronClaymore)

	Reactor Computer Port API: http://wiki.technicpack.net/Reactor_Computer_Port
	Computercraft API: http://computercraft.info/wiki/Category:APIs
	Big Reactors Efficiency, Speculation and Questions! http://www.reddit.com/r/feedthebeast/comments/1vzds0/big_reactors_efficiency_speculation_and_questions/
	Big Reactors API code: https://github.com/erogenousbeef/BigReactors/blob/master/erogenousbeef/bigreactors/common/multiblock/tileentity/TileEntityReactorComputerPort.java
	Big Reactors API: http://big-reactors.com/cc_api.html

	ChangeLog:
	0.3.2 - Allow for rod control to override (disable) auto-adjust via UI (Rhonyn)
	0.3.1 - Add fuel consumption per tick to display
	0.3.0 - Add multi-monitor support! Sends one reactor's data to all monitors.
		print function now takes table to support optional specified monitor
		Set "numRods" every cycle for some people (mechaet)
		Don't redirect terminal output with multiple monitor support
		Log troubleshooting data to reactorcontrol.log
		FC_API no longer used (copied and modified what I needed)
		Multi-reactor support is theoretically implemented, but it is UNTESTED!
		Updated for Big Reactor 0.3 (no longer works with 0.2)
		BR getFuelTemperature() now returns many significant digits, just use math.ceil()
		BR 0.3 removed individual rod temperatures, now it's only reactor-level temperature
	0.2.4 - Simplify math, don't divide by a simple large number and then multiply by 100 (#/10000000*100)
		Fix direct-connected (no modem) devices. getDeviceSide -> FC_API.getDeviceSide (simple as that :))
	0.2.3 - Check bounds on reactor.setRodControlLevel(#,#), Big Reactor doesn't check for us.
	0.2.2 - Do not auto-start the reactor if it was manually powered off (autoStart=false)
	0.2.1 - Lower/raise only the hottest/coldest Control Rod while trying to control the reactor temperature.
		"<" Rod Control buttons was off by one (to the left)
	0.2.0 - Lolmer Edition :)
		Add min/max stored energy percentage (default is 15%/85%), configurable via ReactorOptions file.
		No reason to keep burning fuel if our power output is going nowhere. :)
		Use variables variable for the title and version.
		Try to keep the temperature between configured values (default is 850^C-950^C)
		Add Waste and number of Control/Fuel Rods to displayBards()

	TODO:
		Support multiple reactors
		- If multiple reactors, require a monitor for each reactor and display only that reactor on a monitor
		- Save parameters per reactor instead of one global set for all reactors
		- Allow for a monitor (first monitor would be good) to display compressed info from all reactors (Rhonyn)
		Add min/max RF/t output and have it override temperature concerns (maybe?)
		Add support for wireless modems, see http://computercraft.info/wiki/Modem_%28API%29, will not be secure (anyone can send/listen to your channels)!
		Add support for any sized monitor (minimum 3x3), dynamic allocation/alignment
		Add BR 0.3 active-cooled Turbine control support (see https://twitter.com/ErogenousBeef/status/437663302403891200/photo/1/large)

]]--


-- Some global variables
local progVer = "0.3.2"
local progName = "EZ-NUKE ".. progVer
local xClick, yClick = 0,0
local loopTime = 1
local adjustAmount = 5
local debugMode = false
-- These need to be updated for multiple reactors
local baseControlRodLevel = nil
local reactorRodOverride = false -- Empty rod override for reactors
-- End multi-reactor cleanup section
local minStoredEnergyPercent = nil -- Max energy % to store before activate
local maxStoredEnergyPercent = nil -- Max energy % to store before shutdown
local minReactorTemp = nil -- Minimum reactor temperature (^C) to maintain
local maxReactorTemp = nil -- Maximum reactor temperature (^C) to maintain
local autoStart = {} -- Array for automatically starting reactors
local rodLastUpdate = {} -- Last timestamp update for rod control level update per reactor
local monitorList = {} -- Empty monitor array
local reactorList = {} -- Empty reactor array

term.clear()
term.setCursorPos(2,1)
term.write("Initializing program...")


-- File needs to exist for append "a" later and zero it out if it already exists
-- Always initalize this file to avoid confusion with old files and the latest run
local logFile = fs.open("reactorcontrol.log", "w")
if logFile then
	logFile.writeLine("Minecraft time: Day "..os.day().." at "..textutils.formatTime(os.time(),true))
	logFile.close()
else
	error("Could not open file reactorcontrol.log for writing")
end


-- Helper functions


-- round() function from
-- http://www.computercraft.info/forums2/index.php?/topic/4023-lua-printformat-with-floating-point-numbers/page__view__findpost__p__31037
local function round(num, places)
	num = tostring(num)
	local inc = false

	-- Make sure decimal is a valid integer for later arithmetic
	local decimal = string.find(num, "%.") or 0

	if (num:len() - decimal) <= places then
		return tonumber(num)
	end --already rounded, nothing to do.

	local digit = tonumber(num:sub(decimal + places + 1))
	num = num:sub(1, decimal + places)

	if digit <= 4 then
		return tonumber(num)
	end --no incrementation needed, return truncated number

	local newNum = ""
	for i=num:len(), 1, -1 do
			digit = tonumber(num:sub(i))
			if digit == 9 then
					if i > 1 then
							newNum = "0"..newNum
					else
							newNum = "10"..newNum
					end
			elseif digit == nil then
					newNum = "."..newNum
			else
					if i > 1 then
							newNum = num:sub(1,i-1)..(digit + 1)..newNum
					else
							newNum = (digit + 1)..newNum
					end
					return tonumber(newNum) --No more 9s found, so we are done incrementing. Copy remaining digits, then return number.
			end
	end
	return tonumber(newNum)
end


local function printLog(printStr)
	if debugMode then
		local logFile = fs.open("reactorcontrol.log", "a") -- See http://computercraft.info/wiki/Fs.open
		if logFile then
			logFile.writeLine(printStr)
			logFile.close()
		else
			error("Cannot open file reactorcontrol.log for appending!")
		end
	end
end


local function print(printParams)
	-- Default to xPos=1, yPos=1, and first monitor
	setmetatable(printParams,{__index={xPos=1, yPos=1, monitorIndex=1}})
	local printString, xPos, yPos, monitorIndex =
		printParams[1], -- Required parameter
		printParams[2] or printParams.xPos,
		printParams[3] or printParams.yPos,
		printParams[4] or printParams.monitorIndex

	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in print() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	monitor.setCursorPos(xPos, yPos)
	monitor.write(printString)
end


-- Replaces the one from FC_API (http://pastebin.com/A9hcbZWe) and adding multi-monitor support
local function printCentered(printString, yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in printCentered() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	local width, height = monitor.getSize()
	monitor.setCursorPos(math.floor(width/2) - math.ceil(printString:len()/2) , yPos)
	monitor.clearLine()
	monitor.write(printString)
end


-- Replaces the one from FC_API (http://pastebin.com/A9hcbZWe) and adding multi-monitor support
local function clearMonitor(printString, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in clearMonitor() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	local gap = 2
	monitor.clear()
	local width, height = monitor.getSize()

	printCentered(printString, 1, monitorIndex)

	for i=1, width do
		monitor.setCursorPos(i, gap)
		monitor.write("-")
	end

	monitor.setCursorPos(1, gap+1)
end


-- Return a list of all connected (including via wired modems) devices of "deviceType"
local function getDevices(deviceType)
	local deviceName = nil
	local deviceIndex = 1
	local deviceList = {} -- Empty array, which grows as we need
	local peripheralList = peripheral.getNames() -- Get table of connected peripherals

	deviceType = deviceType:lower() -- Make sure we're matching case here

	for peripheralIndex = 1, #peripheralList do
		-- Log every device found
		-- printLog("Found "..peripheral.getType(peripheralList[peripheralIndex]).."["..peripheralIndex.."] attached as \""..peripheralList[peripheralIndex].."\".")
		if (string.lower(peripheral.getType(peripheralList[peripheralIndex])) == deviceType) then
			-- Log devices found which match deviceType and which device index we give them
			printLog("Found "..peripheral.getType(peripheralList[peripheralIndex]).."["..peripheralIndex.."] as index \"["..deviceIndex.."]\" attached as \""..peripheralList[peripheralIndex].."\".")
			deviceList[deviceIndex] = peripheral.wrap(peripheralList[peripheralIndex])
			deviceIndex = deviceIndex + 1
		end
	end

	return deviceList
end


-- End helper functions


-- Then initialize the monitors
local function findMonitors()
	-- Empty out old list of monitors
	monitorList = {}

	printLog("Finding monitors...")
	monitorList = getDevices("monitor")

	if #monitorList == 0 then
		printLog("No monitors found!")
		error("Can't find any monitors!")
	else
		for monitorIndex = 1, #monitorList do
			local monitor = nil
			monitor = monitorList[monitorIndex]

			if not monitor then
				printLog("monitorList["..monitorIndex.."] in findMonitors() was not a valid monitor")
				break -- Invalid monitorIndex
			end

			local monitorX, monitorY = monitor.getSize()
			printLog("Verifying monitor["..monitorIndex.."] is of size x:"..monitorX.." by y:"..monitorY)

			if monitorX ~= 29 or monitorY ~= 12 then
				term.redirect(monitor)
				monitor.clear()
				printLog("Removing monitor "..monitorIndex.." for incorrect size")
				monitor.setCursorPos(1,2)
				write("Monitor is the wrong size!\n")
				write("Needs to be 3x2.")
				term.restore()

				table.remove(monitorList, monitorIndex) -- Remove invalid monitor from list
				if monitorIndex == #monitorList then	-- If we're at the end already, break from loop
					break
				else
					monitorIndex = monitorIndex - 1 -- We just removed an element
				end

			end
		end
	end
end


-- Initialize all Big Reactors
local function findReactors()
	-- Empty out old list of reactors
	newReactorList = {}

	printLog("Finding reactors...")
	newReactorList = getDevices("BigReactors-Reactor")

	if #newReactorList == 0 then
		printLog("No reactors found!")
		error("Can't find any reactors!")
	else  -- Placeholder
		for reactorIndex = 1, #newReactorList do
			local reactor = nil
			reactor = newReactorList[reactorIndex]

			if not reactor then
				printLog("reactorList["..reactorIndex.."] in findReactors() was not a valid Big Reactor")
				return -- Invalid reactorIndex
			end

			-- If number of found reactors changed, re-initialize them all for now
			-- For now, initialize reactors to the same baseControlRodLevel
			if #newReactorList ~= #reactorList then
				reactor.setAllControlRodLevels(baseControlRodLevel)
			end

			-- Initialize rod update timestamp if number of reactors has changed or initial startup
			if #newReactorList ~= #reactorList then
				rodLastUpdate[reactorIndex] = os.time()
			end

			-- Auto-start reactor when needed (e.g. program startup) by default, or use existing value
			if #newReactorList ~= #reactorList then
				autoStart[reactorIndex] = true
			end
		end
	end

	-- Overwrite old reactor list with the now updated list
	reactorList = newReactorList
end


-- This function gets the average control rod percentage for a given reactor
local function getControlRodPercentage(reactorIndex)
	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in getControlRodPercentage() was not a valid Big Reactor")
		return nil -- Invalid reactorIndex
	end

    local numRods = reactor.getNumberOfControlRods() - 1 -- Call every time as some people modify their reactor without rebooting the computer

	local rodTotal = 0
	for i=0, numRods do
		rodTotal = rodTotal + reactor.getControlRodLevel(i)
	end
 
	local rodPercentage = 0
	return (math.ceil(rodTotal/(numRods+1)))
end


-- Return current energy buffer in a specific reactor by %
local function getReactorStoredEnergyBufferPercent(reactorIndex)
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in getReactorStoredEnergyBufferPercent() was not a valid Big Reactor")
		return -- Invalid reactorIndex
	end

	local energyBufferStorage = reactor.getEnergyStored()
	return (math.floor(energyBufferStorage/100000)) -- 10000000*100
end


-- Modify reactor control rod levels to keep temperature with defined parameters, but
-- wait an in-game half-hour for the temperature to stabalize before modifying again
local function temperatureControl(reactorIndex)
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in temperatureControl() was not a valid Big Reactor")
		return -- Invalid reactorIndex
	end

	local rodPercentage = getControlRodPercentage(reactorIndex)
	local rodTimeDiff = 0
	local reactorTemp = math.ceil(reactor.getFuelTemperature())

	-- No point modifying control rod levels for temperature if the reactor is offline
	if reactor.getActive() then
		rodTimeDiff = math.abs(os.time() - rodLastUpdate[reactorIndex]) -- Difference in rod control level update timestamp and now

		-- Don't bring us to 100, that's effectively a shutdown
		if (reactorTemp > maxReactorTemp) and (rodPercentage < 99) and (rodTimeDiff > 0.2) then
			-- If more than double our maximum temperature, increase rodPercentage faster
			if reactorTemp > (2 * maxReactorTemp) then
				-- Check bounds, Big Reactor doesn't do this for us. :)
				if (rodPercentage + 10) > 99 then
					reactor.setAllControlRodLevels(99)
				else
					reactor.setAllControlRodLevels(rodPercentage + 10)
				end
			else
				-- Check bounds, Big Reactor doesn't do this for us. :)
				if (rodPercentage + 1) > 99 then
					reactor.setAllControlRodLevels(99)
				else
					reactor.setAllControlRodLevels(rodPercentage + 1)
				end
			end

			rodLastUpdate[reactorIndex] = os.time() -- Last rod control update is now :)
		elseif (reactorTemp < minReactorTemp) and (rodTimeDiff > 0.2) then
			-- If less than half our minimum temperature, decrease rodPercentage faster
			if reactorTemp < (minReactorTemp / 2) then
				-- Check bounds, Big Reactor doesn't do this for us. :)
				if (rodPercentage - 10) < 0 then
					reactor.setAllControlRodLevels(0)
				else
					reactor.setAllControlRodLevels(rodPercentage - 10)
				end
			else
				-- Check bounds, Big Reactor doesn't do this for us. :)
				if (rodPercentage - 1) < 0 then
					reactor.setAllControlRodLevels(0)
				else
					reactor.setAllControlRodLevels(rodPercentage - 1)
				end
			end

			rodLastUpdate[reactorIndex] = os.time() -- Last rod control update is now :)
			baseControlRodLevel = rodPercentage
		end
	end
end


-- Load saved reactor parameters if ReactorOptions file exists
local function loadReactorOptions()
	local reactorOptions = fs.open("ReactorOptions", "r") -- See http://computercraft.info/wiki/Fs.open

	if reactorOptions then
		baseControlRodLevel = reactorOptions.readLine()
		-- The following values were added by Lolmer
		minStoredEnergyPercent = reactorOptions.readLine()
		maxStoredEnergyPercent = reactorOptions.readLine()
		minReactorTemp = reactorOptions.readLine()
		maxReactorTemp = reactorOptions.readLine()
		reactorRodOverride = reactorOptions.readLine() -- Should be string "true" or "false"

		-- If we succeeded in reading a string, convert it to a number
		if baseControlRodLevel ~= nil then
			baseControlRodLevel = tonumber(baseControlRodLevel)
		end

		if minStoredEnergyPercent ~= nil then
			minStoredEnergyPercent = tonumber(minStoredEnergyPercent)
		end

		if maxStoredEnergyPercent ~= nil then
			maxStoredEnergyPercent = tonumber(maxStoredEnergyPercent)
		end

		if minReactorTemp ~= nil then
			minReactorTemp = tonumber(minReactorTemp)
		end

		if maxReactorTemp ~= nil then
			maxReactorTemp = tonumber(maxReactorTemp)
		end

		if reactorRodOverride == "true" then
			reactorRodOverride = true
		else
			reactorRodOverride = false
		end

		reactorOptions.close()
	end

	-- Set default values if we failed to read any of the above
	if baseControlRodLevel == nil then
		baseControlRodLevel = 90
	end

	if minStoredEnergyPercent == nil then
		minStoredEnergyPercent = 15
	end

	if maxStoredEnergyPercent == nil then
		maxStoredEnergyPercent = 85
	end

	if minReactorTemp == nil then
		minReactorTemp = 850
	end

	if maxReactorTemp == nil then
		maxReactorTemp = 950
	end
end


-- Save our reactor parameters
local function saveReactorOptions()
	local reactorOptions = fs.open("ReactorOptions", "w") -- See http://computercraft.info/wiki/Fs.open

	-- If we can save the files, save them
	if reactorOptions then
		local reactorIndex = 1
		reactorOptions.writeLine(getControlRodPercentage(reactorIndex)) -- Store just the first reactor for now
		-- The following values were added by Lolmer
		reactorOptions.writeLine(minStoredEnergyPercent)
		reactorOptions.writeLine(maxStoredEnergyPercent)
		reactorOptions.writeLine(minReactorTemp)
		reactorOptions.writeLine(maxReactorTemp)
		reactorOptions.writeLine(reactorRodOverride)
		reactorOptions.close()
	else
		printLog("Failed to open file ReactorOptions for writing!")
	end
end


local function displayBars(barParams)
	-- Default to first reactor and first monitor
	setmetatable(barParams,{__index={reactorIndex=1, monitorIndex=1}})
	local reactorIndex, monitorIndex =
		barParams[1] or barParams.reactorIndex,
		barParams[2] or barParams.monitorIndex

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitorList["..monitorIndex.."] in displayBars() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in displayBars() was not a valid Big Reactor")
		return -- Invalid reactorIndex
	end

    local numRods = reactor.getNumberOfControlRods() - 1 -- Call every time as some people modify their reactor without rebooting the computer

	-- Draw some cool lines
	monitor.setBackgroundColor(colors.black)
	local width, height = monitor.getSize()

	for i=3, 5 do
		monitor.setCursorPos(22, i)
		monitor.write("|")
	end

	for i=1, width do
		monitor.setCursorPos(i, 2)
		monitor.write("-")
	end

	for i=1, width do
		monitor.setCursorPos(i, 6)
		monitor.write("-")
	end

	-- Draw some text

	local fuelString = "Fuel: "
	local tempString = "Temp: "
	local energyBufferString = "Producing: "

	local padding = math.max(string.len(fuelString), string.len(tempString),string.len(energyBufferString))

	local fuelPercentage = math.ceil(reactor.getFuelAmount()/reactor.getFuelAmountMax()*100)
	print{fuelString,2,3,monitorIndex}
	print{fuelPercentage.." %",padding+2,3,monitorIndex}

	local energyBuffer = reactor.getEnergyProducedLastTick()
	print{energyBufferString,2,4,monitorIndex}
	print{math.ceil(energyBuffer).."RF/t",padding+2,4,monitorIndex}

	local reactorTemp = math.ceil(reactor.getFuelTemperature())
	print{tempString,2,5,monitorIndex}
	print{reactorTemp.." C",padding+2,5,monitorIndex}

	-- Decrease rod button: 22X, 4Y
	-- Increase rod button: 28X, 4Y

	local rodTotal = 0
	for i=0, numRods do
		rodTotal = rodTotal + reactor.getControlRodLevel(i)
	end
	local rodPercentage = getControlRodPercentage(reactorIndex)

	if (xClick == 23  and yClick == 4) then
		--Decrease rod level by amount
		newRodPercentage = rodPercentage - adjustAmount
		if newRodPercentage < 0 then
			newRodPercentage = 0
		end

		xClick, yClick = 0,0
		reactor.setAllControlRodLevels(newRodPercentage)
		baseControlRodLevel = newRodPercentage
	end


	if (xClick == 28  and yClick == 4) then
		--Increase rod level by amount
		newRodPercentage = rodPercentage + adjustAmount
		if newRodPercentage > 100 then
			newRodPercentage = 100
		end
		xClick, yClick = 0,0
		reactor.setAllControlRodLevels(newRodPercentage)
		baseControlRodLevel = newRodPercentage
	end

	print{"Control",23,3,monitorIndex}
	print{"<     >",23,4,monitorIndex}
	print{rodPercentage,25,4,monitorIndex}
	print{"percent",23,5,monitorIndex}

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/
	term.redirect(monitor)
	-- Draw stored energy buffer bar
	paintutils.drawLine(2, 8, 28, 8, colors.gray)

	local curStoredEnergyPercent = getReactorStoredEnergyBufferPercent(reactorIndex)

	if curStoredEnergyPercent > 4 then
		paintutils.drawLine(2, 8, math.floor(26*curStoredEnergyPercent/100)+2, 8, colors.yellow)
	elseif curStoredEnergyPercent > 0 then
		paintutils.drawPixel(2,8,colors.yellow)
	end
	term.restore()

	monitor.setBackgroundColor(colors.black)
	print{"Energy Buffer",2,7,monitorIndex}
	print{curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+3),7,monitorIndex}
	print{"%",28,7,monitorIndex}
	monitor.setBackgroundColor(colors.black)

	-- Print rod override status
	local reactorRodOverrideStatus = ""

	if not reactorRodOverride then
		reactorRodOverrideStatus = "Enabled"
		monitor.setTextColor(colors.green)
	else
		reactorRodOverrideStatus = "Disabled"
		monitor.setTextColor(colors.red)
	end
	print{"Rod Auto-adjust: "..reactorRodOverrideStatus,2,10,monitorIndex}
	monitor.setTextColor(colors.white)

	print{"Fuel consumption: "..round(reactor.getFuelConsumedLastTick(),3).." mB/t",2,11,monitorIndex}
	print{"Fuel Rods: "..(numRods + 1),2,12,monitorIndex} -- numRods index starts at 0
	print{"Waste: "..reactor.getWasteAmount().." mB",width-(string.len(reactor.getWasteAmount())+10),12,monitorIndex}
end


local function reactorStatus(statusParams)
	-- Default to first reactor and first monitor
	setmetatable(statusParams,{__index={reactorIndex=1, monitorIndex=1}})
	local reactorIndex, monitorIndex =
		statusParams[1] or statusParams.reactorIndex,
		statusParams[2] or statusParams.monitorIndex

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitorList["..monitorIndex.."] in reactorStatus() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in reactorStatus() was not a valid Big Reactor")
		return -- Invalid reactorIndex
	end

	local width, height = monitor.getSize()
	local reactorStatus = ""

    local numRods = reactor.getNumberOfControlRods() - 1 -- Call every time as some people modify their reactor without rebooting the computer

	if reactor.getConnected() then
		if reactor.getActive() then
			reactorStatus = "ONLINE"
			monitor.setTextColor(colors.green)
		else
			reactorStatus = "OFFLINE"
			monitor.setTextColor(colors.red)
		end

		if(xClick >= (width - string.len(reactorStatus) - 1) and xClick <= (width-1)) then
			if yClick == 1 then
				reactor.setActive(not reactor.getActive()) -- Toggle reactor status
				xClick, yClick = 0,0 -- Reset click after we register it

				-- If someone offlines the reactor (offline after a status click was detected), then disable autoStart
				if not reactor.getActive() then
					autoStart[reactorIndex] = false
				end
			end
		end

		-- Allow disabling rod level auto-adjust and only manual rod level control
		if (xClick > 23 and xClick < 28) and yClick == 4 then
			reactorRodOverride = not reactorRodOverride -- Toggle reactor rod override status
			xClick, yClick = 0,0 -- Reset click after we register it
		end

	else
		reactorStatus = "DISCONNECTED"
		monitor.setTextColor(colors.red)
	end

	print{reactorStatus, width - string.len(reactorStatus) - 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)
end


function main()
	-- Load reactor parameters and initialize systems
	loadReactorOptions()

	while not finished do
		local reactor = nil
		-- Get our initial list of connected monitors and reactors
		-- and initialize every cycle in case the connected devices change
		findMonitors()
		findReactors()

		for monitorIndex = 1, #monitorList do
			clearMonitor(progName, monitorIndex) -- Clear monitor and draw borders

			-- This code needs refactoring once we actually work with multiple reactors
			for reactorIndex = 1, #reactorList do
				printCentered(progName, 1, monitorIndex)
				reactorStatus{reactorIndex, monitorIndex}

				reactor = reactorList[reactorIndex]
				if not reactor then
					printLog("reactorList["..reactorIndex.."] in main() was not a valid Big Reactor")
					break -- Invalid reactorIndex
				end

				if reactor.getConnected() then
					local curStoredEnergyPercent = getReactorStoredEnergyBufferPercent(reactorIndex)

					-- Shutdown reactor if current stored energy % is >= desired level, otherwise activate
					-- First pass will have curStoredEnergyPercent=0 until displayBars() is run once
					if curStoredEnergyPercent >= maxStoredEnergyPercent then
						reactor.setActive(false)
					-- Do not auto-start the reactor if it was manually powered off (autoStart=false)
					elseif (curStoredEnergyPercent <= minStoredEnergyPercent) and (autoStart[reactorIndex] == true) then
						reactor.setActive(true)
					end

					-- Don't try to auto-adjust control rods if manual control is requested
					if not reactorRodOverride then
						temperatureControl(reactorIndex)
					end

					displayBars{reactorIndex,monitorIndex}
					sleep(loopTime)
					saveReactorOptions()
				end
			end
		end
	end
end


function eventHandler()
	while not finished do
		event, arg1, arg2, arg3 = os.pullEvent()

		for monitorIndex = 1, #monitorList do
			if event == "monitor_touch" then
				xClick, yClick = math.floor(arg2), math.floor(arg3)
				-- Draw debug stuff
				--print{"Monitor touch X: "..xClick.." Y: "..yClick, 1, 10, monitorIndex}
			-- What is this even for if we aren't looking for a monitor?
			elseif event == "mouse_click" and not monitorList[monitorIndex] then
				xClick, yClick = math.floor(arg2), math.floor(arg3)
				--print{"Mouse click X: "..xClick.." Y: "..yClick, 1, 11, monitorIndex}
			elseif event == "char" and not inManualMode then
				local ch = string.lower(arg1)
				if ch == "q" then
					finished = true
				elseif ch == "r" then
					finished = true
					os.reboot()
				end
			end
		end
	end
end


while not finished do
	parallel.waitForAny(eventHandler, main)
	sleep(loopTime)
end


-- Clear up after an exit
term.clear()
term.setCursorPos(1,1)
