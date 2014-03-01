--[[
Program name: Lolmer's EZ-NUKE reactor control system
Version: v0.3.3
Programmer: Lolmer
Last update: 2014-02-28
Pastebin: http://pastebin.com/fguScPBQ

Description:
This program controls a Big Reactors nuclear reactor
in Minecraft with a Computercraft computer, using Computercraft's
own wired modem connected to the reactors computer control port.

This program was designed to work with the mods and versions installed on Never Stop Toasting (NST) Diet
http://www.technicpack.net/modpack/details/never-stop-toasting-diet.254882
Endeavour: Never Stop Toasting: Diet official Minecraft server http://forums.somethingawful.com/showthread.php?threadid=3603757

To simplify the code and guesswork, I assume the following monitor layout:
1) One Advanced Monitor for overall status display plus
	one or more Reactors plus
	none or more Turbines.
2) One Advanced Monitor for overall status display plus (first found monitor)
	one Advanced Monitor for each connected Reactor plus (subsequent found monitors)
	one Advanced Monitor for each connected Turbine (last group of monitors found).
If you enable debug mode, add one additional Advanced Monitor for #1 or #2.

Notes:
	Only one reactor and one, two, and three turbines have been tested with the above, but IN THEORY any number is supported.
	Devices are found in the reverse order they are plugged in, so monitor_10 will be found before monitor_9.

When using actively cooled reactors with turbines, keep the following in mind:
	- 1 mB steam carries up to 10RF of potential energy to extract in a turbine.
	- Actively cooled reactors produce steam, not power.
	- You will need about 10 mB of water for each 1 mB of steam that you want to create in a 7^3 reactor.

Features:
	Configurable min/max energy buffer and min/max temperature via ReactorOptions file.
	ReactorOptions is read on start and then current values are saved every program cycle.
	Rod Control value in ReactorOptions is only useful for initial start, after that the program saves the current Rod Control average over all Fuel Rods for next boot.
	Auto-adjusts control rods per reactor to maintain temperature.
	Will display reactor data to all attached monitors of correct dimensions.
		For multiple monitors, the first monitor (often last plugged in) is the overall status monitor.
		Dynamically detect and add/remove monitors as they are connected to the network (not recommended).
	For multiple monitors, the first monitor (often last plugged in) is the overall status monitor.

GUI Usage:
	The "<" and ">" buttons, when right-clicked with the mouse, will decrease and increase, respectively, the values assigned to the monitor:
		"Rod (%)" will lower/raise the Reactor Control Rods for that Reactor
		"Flow mB/t" will lower/raise the Turbine Flow Rate maximum for that Turbine
	Right-clicking between the "<" and ">" (not on them) will disable auto-adjust of that value for attached device.
		Right-clicking on the "Enabled" or "Disabled" text for auto-adjust will do the same.
	Right-clicking on "ONLINE" or "OFFLINE" at the top-right will toggle the state of attached device.

Default values:
	Rod Control: 90% (Let's start off safe and then power up as we can)
	Minimum Energy Buffer: 15% (will power on below this value)
	Maximum Energy Buffer: 85% (will power off above this value)
	Minimum Temperature: 850^C (will raise control rods below this value)
	Maximum Temperature: 950^C (will lower control rods above this value)
	Optimal Turbine RPM: 900 or 1,800

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
	http://pastebin.com/tFkhQLYn (IronClaymore, only for Big Reactors 0.2 or passively cooled Big Reactors in 0.3)
	http://pastebin.com/FaccdayZ (IronClaymore's script updated by mechaet for actively cooled Big Ractors)

Reactor Computer Port API: http://wiki.technicpack.net/Reactor_Computer_Port
Computercraft API: http://computercraft.info/wiki/Category:APIs
Big Reactors Efficiency, Speculation and Questions! http://www.reddit.com/r/feedthebeast/comments/1vzds0/big_reactors_efficiency_speculation_and_questions/
Big Reactors API code: https://github.com/erogenousbeef/BigReactors/blob/master/erogenousbeef/bigreactors/common/multiblock/tileentity/TileEntityReactorComputerPort.java
Big Reactors API: http://big-reactors.com/cc_api.html

ChangeLog:
0.3.3 - Add Big Reactor Turbine support
	First found monitor (appears to be last connected monitor) is used to display status of all found devices (if more than one valid monitor is found)
	Display monitor number on top left of each monitor as "M#" to help find which monitor is which.
	Enabling debug will use the last monitor found, if more than one, to print out debug info (also written to file)
	Add monitor layout requirements to simplify code
	Only clear monitors when we're about to use them (e.g. turbine monitors no longer clear, then wait for all reactors to update)
	Fix getDeviceStoredEnergyBufferPercent(), was off by a decimal place
	Just use first Control Rod level for entire reactor, they are no longer treated individually in BR 0.3
	Allow for one monitor for n number of reactors and m number of turbines
	Auto-adjust turbine flow rate by 25 mB to keep rotor speed at 900 or 1,800 RPM.
	Clicks on monitors relate to what the monitor is showing (e.g. clicking on reactor 1's display won't modify turbine 1's nor reactor 2's values)
	Print monitor name and device (reactor|turbine) name in blue to monitor associated for easier design by users.
	Remove version number from monitors to free up space for monitor names.
	Add option of right-clicking on "Enabled"/"Disabled" of auto-adjust to toggle it.
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
- Save parameters per reactor instead of one global set for all reactors
- Add min/max RF/t output and have it override temperature concerns (maybe?)
- Add support for wireless modems, see http://computercraft.info/wiki/Modem_%28API%29, will not be secure (anyone can send/listen to your channels)!
- Add support for any sized monitor (minimum 3x3), dynamic allocation/alignment
- Lookup using pcall for better error handling http://www.computercraft.info/forums2/index.php?/topic/10992-using-pcall/

]]--


-- Some global variables
local progVer = "0.3.3"
local progName = "EZ-NUKE "
local sideClick, xClick, yClick = nil, 0, 0
local loopTime = 1
local controlRodAdjustAmount = 5 -- Default Reactor Rod Control % adjustment amount when using UI
local flowRateAdjustAmount = 25 -- Default Turbine Flow Rate in mB adjustment amount when using UI
local debugMode = false
-- These need to be updated for multiple reactors
local baseControlRodLevel = nil
local reactorRodOverride = false -- Rod override for Reactors
-- End multi-reactor cleanup section
local minStoredEnergyPercent = nil -- Max energy % to store before activate
local maxStoredEnergyPercent = nil -- Max energy % to store before shutdown
local minReactorTemp = nil -- Minimum reactor temperature (^C) to maintain
local maxReactorTemp = nil -- Maximum reactor temperature (^C) to maintain
local autoStart = {} -- Array for automatically starting reactors
local rodLastUpdate = {} -- Last timestamp update for rod control level update per reactor
local monitorList = {} -- Empty monitor array
local monitorNames = {} -- Empty array of monitor names
local reactorList = {} -- Empty reactor array
local reactorNames = {} -- Empty array of reactor names
local turbineList = {} -- Empty turbine array
local trubineNames = {} -- Empty array of turbine names
local turbineFlowRateOverride = {} -- Flow rate override for each Turbine
local turbineMonitorOffset = 0 -- Turbines are assigned monitors after reactors
local turbineLastUpdate = {} -- Last timestamp update for turbine flow rate update per turbine

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
			end -- if digit == 9 then
	end -- for i=num:len(), 1, -1 do
	return tonumber(newNum)
end -- function round(num, places


local function printLog(printStr)
	if debugMode then
		-- If multiple monitors, use the last monitor for debugging if debug is enabled
		if #monitorList > 1 then
			term.redirect(monitorList[#monitorList]) -- Redirect to last monitor for debugging
			monitorList[#monitorList].setTextScale(0.5) -- Fit more logs on screen
			write(printStr.."\n")	-- May need to use term.scroll(x) if we output too much, not sure
			term.restore()
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
end -- function print(printParams)


-- Replaces the one from FC_API (http://pastebin.com/A9hcbZWe) and adding multi-monitor support
local function printCentered(printString, yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in printCentered() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	local width, height = monitor.getSize()
	local monitorNameLength = 0

	-- Special changes for title bar
	if yPos == 1 then
		-- Add monitor name to first line
		monitorNameLength = monitorNames[monitorIndex]:len()

		-- Leave room for "offline" and "online" on the right except for overall status display
		if (#monitorList ~= 1) and (monitorIndex ~= 1) then
			width = width - 7
		end
	end

	monitor.setCursorPos(math.floor(width/2) - math.ceil(printString:len()/2) +  monitorNameLength/2, yPos)
	monitor.clearLine()
	monitor.write(printString)

	monitor.setTextColor(colors.blue)
	print{monitorNames[monitorIndex], 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)
end -- function printCentered(printString, yPos, monitorIndex)


-- Print text padded from the left side
-- Clear the left side of the screen
local function printLeft(printString, yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in printLeft() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	local gap = 1
	local width = monitor.getSize()

	-- Clear left-half of the monitor

	for curXPos = 1, (width / 2) do
		monitor.setCursorPos(curXPos, yPos)
		monitor.write(" ")
	end

	-- Write our string left-aligned
	monitor.setCursorPos(1+gap, yPos)
	monitor.write(printString)
end


-- Print text padded from the right side
-- Clear the right side of the screen
local function printRight(printString, yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in printRight() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	local gap = 1
	local width = monitor.getSize()

	-- Clear right-half of the monitor
	for curXPos = (width/2), width do
		monitor.setCursorPos(curXPos, yPos)
		monitor.write(" ")
	end

	-- Write our string right-aligned
	monitor.setCursorPos(math.floor(width) - math.ceil(printString:len()+gap), yPos)
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
	monitor.setTextColor(colors.blue)
	print{monitorNames[monitorIndex], 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)

	for i=1, width do
		monitor.setCursorPos(i, gap)
		monitor.write("-")
	end

	monitor.setCursorPos(1, gap+1)
end -- function clearMonitor(printString, monitorIndex)


-- Return a list of all connected (including via wired modems) devices of "deviceType"
local function getDevices(deviceType)
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
			deviceNames[deviceIndex] = peripheralList[peripheralIndex]
			deviceList[deviceIndex] = peripheral.wrap(peripheralList[peripheralIndex])
			deviceIndex = deviceIndex + 1
		end
	end -- for peripheralIndex = 1, #peripheralList do

	return deviceList, deviceNames
end -- function getDevices(deviceType)

-- Draw a line across the entire x-axis
local function drawLine(yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in drawLine() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	local width, height = monitor.getSize()

	for i=1, width do
		monitor.setCursorPos(i, yPos)
		monitor.write("-")
	end
end -- function drawLine(yPos,monitorIndex)


-- Display a solid bar of specified color
local function drawBar(startXPos, startYPos, endXPos, endYPos, color, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in drawBar() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/
	term.redirect(monitor)
	paintutils.drawLine(startXPos, startYPos, endXPos, endYPos, color)
	monitor.setBackgroundColor(colors.black) -- PaintUtils doesn't restore the color
	term.restore()
end -- function drawBar(startXPos, startYPos,endXPos,endYPos,color,monitorIndex)


-- Display single pixel color
local function drawPixel(xPos, yPos, color, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitorList["..monitorIndex.."] in drawPixel() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/
	term.redirect(monitor)
	paintutils.drawPixel(xPos, yPos, color)
	monitor.setBackgroundColor(colors.black) -- PaintUtils doesn't restore the color
	term.restore()
end -- function drawPixel(xPos, yPos, color, monitorIndex)


-- End helper functions


-- Then initialize the monitors
local function findMonitors()
	-- Empty out old list of monitors
	monitorList = {}

	printLog("Finding monitors...")
	monitorList, monitorNames = getDevices("monitor")

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

			-- Check for minimum size to allow for monitor.setTextScale(0.5) to work for 3x2 debugging monitor, changes getSize()
			if monitorX < 29 or monitorY < 12 then
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
				end -- if monitorIndex == #monitorList then

			end -- if monitorX ~= 29 or monitorY ~= 12 then
		end -- for monitorIndex = 1, #monitorList do
	end -- if #monitorList == 0 then
end -- local function findMonitors()


-- Initialize all Big Reactors - Reactors
local function findReactors()
	-- Empty out old list of reactors
	newReactorList = {}

	printLog("Finding reactors...")
	newReactorList, reactorNames = getDevices("BigReactors-Reactor")

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

				-- Initialize rod update timestamp if number of reactors has changed or initial startup
				rodLastUpdate[reactorIndex] = os.time()

				-- Auto-start reactor when needed (e.g. program startup) by default, or use existing value
				autoStart[reactorIndex] = true
			end -- if #newReactorList ~= #reactorList then
		end -- for reactorIndex = 1, #newReactorList do
	end -- if #newReactorList == 0 then

	-- Overwrite old reactor list with the now updated list
	reactorList = newReactorList

	-- Check if we have enough monitors for the number of reactors
	if (#reactorList ~= 1) and ((#turbineList < #reactorList) + 1 < #monitorList) then
		printLog("You need "..(#reactorList + 1).." monitors for your "..#reactorList.." connected reactors")
	end

	-- Start turbine monitor offset after reactors get monitors
	-- This assumes that there is a monitor for each turbine and reactor, plus the overall monitor display
	turbineMonitorOffset = #reactorList + 1 -- #turbineList will start at "1" if turbines found and move us just beyond #reactorList and status monitor range
end -- function findReactors()


-- Initialize all Big Reactors - Turbines
local function findTurbines()
	-- Empty out old list of turbines
	newTurbineList = {}

	printLog("Finding turbines...")
	newTurbineList, turbineNames = getDevices("BigReactors-Turbine")

	if #newTurbineList == 0 then
		printLog("No turbines found") -- Not an error
	else
		for turbineIndex = 1, #newTurbineList do
			local turbine = nil
			turbine = newTurbineList[turbineIndex]

			if not turbine then
				printLog("turbineList["..turbineIndex.."] is not a valid Big Reactors Turbine")
				return -- Invalid turbineIndex
			end

			-- If number of found turbines changed, re-initialize them all for now
			if #newTurbineList ~= #turbineList then
				-- Initialize turbine flow rate timestamp if number of reactors has changed or initial startup
				turbineLastUpdate[turbineIndex] = os.time()

				-- Default is to allow flow rate auto-adjust
				turbineFlowRateOverride[turbineIndex] = false
			end -- if #newTurbineList ~= #turbineList then
		end -- for turbineIndex = 1, #newTurbineList do

		-- Overwrite old turbine list with the now updated list
		turbineList = newTurbineList

		-- Check if we have enough monitors for the number of turbines
		if #monitorList < (#reactorList + #turbineList + 1) then
			printLog("You need "..(#reactorList + #turbineList + 1).." monitors for your "..#reactorList.." connected reactors and "..#turbineList.." connected turbines")
		end
	end -- if #newTurbineList == 0 then
end -- function findTurbines()


-- Return current energy buffer in a specific reactor by %
local function getDeviceStoredEnergyBufferPercent(device)
	if not device then
		printLog("getDeviceStoredEnergyBufferPercent() did not receive a valid Big Reactor device")
		return -- Invalid reactorIndex
	end

	local energyBufferStorage = device.getEnergyStored()
	return (math.floor(energyBufferStorage/10000)) -- (buffer/10000000 RF)*100%
end -- function getDeviceStoredEnergyBufferPercent(reactorIndex)


-- Modify reactor control rod levels to keep temperature with defined parameters, but
-- wait an in-game half-hour for the temperature to stabalize before modifying again
local function temperatureControl(reactorIndex)
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in temperatureControl() was not a valid Big Reactor")
		return -- Invalid reactorIndex
	end

	local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
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
			end -- if reactorTemp > (2 * maxReactorTemp) then

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
			end -- if reactorTemp < (minReactorTemp / 2) then

			rodLastUpdate[reactorIndex] = os.time() -- Last rod control update is now :)
			baseControlRodLevel = rodPercentage
		end -- if (reactorTemp > maxReactorTemp) and (rodPercentage < 99) and (rodTimeDiff > 0.2) then
	end -- if reactor.getActive() then
end -- function temperatureControl(reactorIndex)


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
	end -- if reactorOptions then

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
end -- function loadReactorOptions()


-- Save our reactor parameters
local function saveReactorOptions()
	local reactorOptions = fs.open("ReactorOptions", "w") -- See http://computercraft.info/wiki/Fs.open

	-- If we can save the files, save them
	if reactorOptions then
		local reactorIndex = 1
		reactorOptions.writeLine(math.ceil(reactorList[1].getControlRodLevel(0))) -- Store just the first reactor for now
		-- The following values were added by Lolmer
		reactorOptions.writeLine(minStoredEnergyPercent)
		reactorOptions.writeLine(maxStoredEnergyPercent)
		reactorOptions.writeLine(minReactorTemp)
		reactorOptions.writeLine(maxReactorTemp)
		reactorOptions.writeLine(reactorRodOverride)
		reactorOptions.close()
	else
		printLog("Failed to open file ReactorOptions for writing!")
	end -- if reactorOptions then
end -- function saveReactorOptions()


local function displayReactorBars(barParams)
	-- Default to first reactor and first monitor
	setmetatable(barParams,{__index={reactorIndex=1, monitorIndex=1}})
	local reactorIndex, monitorIndex =
		barParams[1] or barParams.reactorIndex,
		barParams[2] or barParams.monitorIndex

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitorList["..monitorIndex.."] in displayReactorBars() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactorList["..reactorIndex.."] in displayReactorBars() was not a valid Big Reactor")
		return -- Invalid reactorIndex
	end

	-- Draw border lines
	local width, height = monitor.getSize()

	for i=3, 5 do
		monitor.setCursorPos(22, i)
		monitor.write("|")
	end

	drawLine(2, monitorIndex)
	drawLine(6, monitorIndex)

	-- Draw some text
	local fuelString = "Fuel: "
	local tempString = "Temp: "
	local energyBufferString = "Producing: "

	local padding = math.max(string.len(fuelString), string.len(tempString), string.len(energyBufferString))

	local fuelPercentage = math.ceil(reactor.getFuelAmount()/reactor.getFuelAmountMax()*100)
	print{fuelString,2,3,monitorIndex}
	print{fuelPercentage.." %",padding+2,3,monitorIndex}

	local reactorTemp = math.ceil(reactor.getFuelTemperature())
	print{tempString,2,5,monitorIndex}
	print{reactorTemp.." C",padding+2,5,monitorIndex}

	local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
	-- Allow controlling Reactor Control Rod Level from GUI
	-- Decrease rod button: 23X, 4Y
	-- Increase rod button: 28X, 4Y
	if (xClick == 23) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		--Decrease rod level by amount
		newRodPercentage = rodPercentage - controlRodAdjustAmount
		if newRodPercentage < 0 then
			newRodPercentage = 0
		end
		sideClick, xClick, yClick = 0, 0, 0

		reactor.setAllControlRodLevels(newRodPercentage)

		-- Save updated rod percentage
		baseControlRodLevel = newRodPercentage
		rodPercentage = newRodPercentage
	end -- if (xClick == 23) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		--Increase rod level by amount
		newRodPercentage = rodPercentage + controlRodAdjustAmount
		if newRodPercentage > 100 then
			newRodPercentage = 100
		end
		sideClick, xClick, yClick = 0, 0, 0

		reactor.setAllControlRodLevels(newRodPercentage)

		-- Save updated rod percentage
		baseControlRodLevel = newRodPercentage
		rodPercentage = newRodPercentage
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	print{"Rod (%)",23,3,monitorIndex}
	print{"<     >",23,4,monitorIndex}
	print{rodPercentage,25,4,monitorIndex}

	-- getEnergyProducedLastTick() is used for both RF/t (passively cooled) and mB/t (actively cooled)
	local energyBuffer = reactor.getEnergyProducedLastTick()
	print{energyBufferString,2,4,monitorIndex}

	-- Actively cooled reactors do not produce energy, only hot fluid mB/t to be used in a turbine
	-- still uses getEnergyProducedLastTick for mB/t of hot fluid generated
	if not reactor.isActivelyCooled() then
		-- Draw stored energy buffer bar
		drawBar(2,8,28,8,colors.gray,monitorIndex)

		local curStoredEnergyPercent = getDeviceStoredEnergyBufferPercent(reactor)
		if curStoredEnergyPercent > 4 then
			drawBar(2, 8, math.floor(26*curStoredEnergyPercent/100)+2, 8, colors.yellow, monitorIndex)
		elseif curStoredEnergyPercent > 0 then
			drawPixel(2, 8, colors.yellow, monitorIndex)
		end -- if curStoredEnergyPercent > 4 then

		print{"Energy Buffer",2,7,monitorIndex}
		print{curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+3),7,monitorIndex}
		print{"%",28,7,monitorIndex}

		print{math.ceil(energyBuffer).." RF/t",padding+2,4,monitorIndex}
	else
		print{math.ceil(energyBuffer).." mB/t",padding+2,4,monitorIndex}
	end -- if not reactor.isActivelyCooled() then

	-- Print rod override status
	local reactorRodOverrideStatus = ""

	print{"Rod Auto-adjust:",2,8,monitorIndex}

	if not reactorRodOverride then
		reactorRodOverrideStatus = "Enabled"
		monitor.setTextColor(colors.green)
	else
		reactorRodOverrideStatus = "Disabled"
		monitor.setTextColor(colors.red)
	end -- if not reactorRodOverride then

	print{reactorRodOverrideStatus, width - string.len(reactorRodOverrideStatus) - 1, 8, monitorIndex}
	monitor.setTextColor(colors.white)

    local numRods = reactor.getNumberOfControlRods() - 1 -- Call every time as some people modify their reactor without rebooting the computer

	print{"Reactivity: "..math.ceil(reactor.getFuelReactivity()).." %",2,9,monitorIndex}
	print{"Consumption: "..round(reactor.getFuelConsumedLastTick(),3).." mB/t",2,10,monitorIndex}
	print{"Rods: "..(numRods + 1),2,11,monitorIndex} -- numRods index starts at 0
	print{"Waste: "..reactor.getWasteAmount().." mB",width-(string.len(reactor.getWasteAmount())+10),11,monitorIndex}

	monitor.setTextColor(colors.blue)
	printCentered(reactorNames[reactorIndex],12,monitorIndex)
	monitor.setTextColor(colors.white)
end -- function displayReactorBars(barParams)


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

	if reactor.getConnected() then
		if reactor.getActive() then
			reactorStatus = "ONLINE"
			monitor.setTextColor(colors.green)
		else
			reactorStatus = "OFFLINE"
			monitor.setTextColor(colors.red)
		end -- if reactor.getActive() then

		if xClick >= (width - string.len(reactorStatus) - 1) and xClick <= (width-1) and (sideClick == monitorNames[monitorIndex]) then
			if yClick == 1 then
				reactor.setActive(not reactor.getActive()) -- Toggle reactor status
				sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it

				-- If someone offlines the reactor (offline after a status click was detected), then disable autoStart
				if not reactor.getActive() then
					autoStart[reactorIndex] = false
				end
			end -- if yClick == 1 then
		end -- if (xClick >= (width - string.len(reactorStatus) - 1) and xClick <= (width-1)) and (sideClick == monitorNames[monitorIndex]) then

		-- Allow disabling rod level auto-adjust and only manual rod level control
		if ((xClick > 23 and xClick < 28 and yClick == 4)
				or (xClick > 20 and xClick < 27 and yClick == 8))
				and (sideClick == monitorNames[monitorIndex]) then
			reactorRodOverride = not reactorRodOverride -- Toggle reactor rod override status
			sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
		end -- if (xClick > 23) and (xClick < 28) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	else
		reactorStatus = "DISCONNECTED"
		monitor.setTextColor(colors.red)
	end -- if reactor.getConnected() then

	print{reactorStatus, width - string.len(reactorStatus) - 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)
end -- function reactorStatus(statusParams)


-- Display all found reactors' status to monitor 1
-- This is only called if multiple reactors and/or a reactor plus at least one turbine are found
local function displayAllStatus()
	local reactor, turbine = nil, nil
	local onlineReactor, onlineTurbine = 0, 0
	local totalReactorRF, totalReactorSteam, totalTurbineRF = 0, 0, 0
	local totalReactorFuelConsumed = 0
	local totalCoolantStored, totalSteamStored, totalEnergy, totalEnergyStores = 0, 0, 0, 0 -- Total turbine and reactor energy buffer and overall capacity
	local maxSteamStored = (2000*#turbineList)+(5000*#reactorList)
	local maxCoolantStored = (2000*#turbineList)+(5000*#reactorList)

	local monitor, monitorIndex = nil, 1
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitorList["..monitorIndex.."] in reactorStatus() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	for reactorIndex = 1, #reactorList do
		reactor = reactorList[reactorIndex]
		if not reactor then
			printLog("reactorList["..reactorIndex.."] in main() was not a valid Big Reactor")
			break -- Invalid reactorIndex
		end -- if not reactor then

		if reactor.getConnected() then
			if reactor.getActive() then
				onlineReactor = onlineReactor + 1
				totalReactorFuelConsumed = totalReactorFuelConsumed + reactor.getFuelConsumedLastTick()
			end -- reactor.getActive() then

			-- Actively cooled reactors do not produce or store energy
			if not reactor.isActivelyCooled() then
				totalEnergyStores = totalEnergyStores + 1
				totalEnergy = totalEnergy + reactor.getEnergyStored()
				totalReactorRF = totalReactorRF + reactor.getEnergyProducedLastTick()
			else
				totalReactorSteam = totalReactorSteam + reactor.getEnergyProducedLastTick()
				totalSteamStored = totalSteamStored + reactor.getHotFluidAmount()
				totalCoolantStored = totalCoolantStored + reactor.getCoolantAmount()
			end -- if not reactor.isActivelyCooled() then
		end -- if reactor.getConnected() then
	end -- for reactorIndex = 1, #reactorList do

	for turbineIndex = 1, #turbineList do
		turbine = turbineList[turbineIndex]
		if not turbine then
			printLog("turbineList["..turbineIndex.."] in main() was not a valid Big Reactor")
			break -- Invalid turbineIndex
		end -- if not turbine then

		if turbine.getConnected() then
			if turbine.getActive() then
				onlineTurbine = onlineTurbine + 1
			end

			totalEnergyStores = totalEnergyStores + 1
			totalEnergy = totalEnergy + turbine.getEnergyStored()
			totalTurbineRF = totalTurbineRF + turbine.getEnergyProducedLastTick()
			totalSteamStored = totalSteamStored + turbine.getInputAmount()
			totalCoolantStored = totalCoolantStored + turbine.getOutputAmount()
		end -- if turbine.getConnected() then
	end -- for turbineIndex = 1, #turbineList do

	print{"Reactors online/found: "..onlineReactor.."/"..#reactorList, 2, 3, monitorIndex}
	print{"Turbines online/found: "..onlineTurbine.."/"..#turbineList, 2, 4, monitorIndex}

	if totalReactorRF ~= 0 then
		print{"Reactor Output: "..math.ceil(totalReactorRF).." RF/t", 2, 9, monitorIndex}
	end

	if #turbineList then
		-- Display liquids
		printLeft("Steam (mB)", 6, monitorIndex)
		printLeft(math.ceil(totalSteamStored).."/"..maxSteamStored, 7, monitorIndex)
		printLeft(math.ceil(totalReactorSteam).." mB/t", 8, monitorIndex)
		printRight("Coolant (mB)", 6, monitorIndex)
		printRight(math.ceil(totalCoolantStored).."/"..maxCoolantStored, 7, monitorIndex)

		print{"Turbine Output: "..math.ceil(totalTurbineRF).." RF/t", 2, 10, monitorIndex}
	end -- if #turbineList then

	print{"Fuel consumed: "..round(totalReactorFuelConsumed,3).." mB/t", 2, 11, monitorIndex}
	print{"Buffer: "..math.ceil(totalEnergy,3).."/"..(1000000*totalEnergyStores).." RF", 2, 12, monitorIndex}
end -- function displayAllStatus()


-- Get turbine status
local function displayTurbineBars(turbineIndex, monitorIndex)
	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitorList["..monitorIndex.."] in displayTurbineBars() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbineList["..turbineIndex.."] in displayTurbineBars() was not a valid Big Turbine")
		return -- Invalid turbineIndex
	end

	-- Draw border lines
	local width, height = monitor.getSize()

	for i=3, 5 do
		monitor.setCursorPos(21, i)
		monitor.write("|")
	end

	drawLine(2,monitorIndex)
	drawLine(6,monitorIndex)

	-- Allow controlling Turbine Flow Rate from GUI
	-- Decrease flow rate button: 22X, 4Y
	-- Increase flow rate button: 28X, 4Y
	local turbineFlowRate = math.ceil(turbine.getFluidFlowRateMax())
	if (xClick == 22) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		--Decrease rod level by amount
		newTurbineFlowRate = turbineFlowRate - flowRateAdjustAmount
		if newTurbineFlowRate < 0 then
			newTurbineFlowRate = 0
		end
		sideClick, xClick, yClick = 0, 0, 0

		-- Check bounds [0,2000]
		if newTurbineFlowRate > 2000 then
			newTurbineFlowRate = 2000
		elseif newTurbineFlowRate < 0 then
			newTurbineFlowRate = 25 -- Don't go to zero, might as well power off
		end

		turbine.setFluidFlowRateMax(newTurbineFlowRate)

		-- Save updated Turbine Flow Rate
		turbineFlowRate = newTurbineFlowRate
	end -- if (xClick == 22) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		--Increase rod level by amount
		newTurbineFlowRate = turbineFlowRate + flowRateAdjustAmount
		if newTurbineFlowRate > 2000 then
			newTurbineFlowRate = 2000
		end
		sideClick, xClick, yClick = 0, 0, 0

		-- Check bounds [0,2000]
		if newTurbineFlowRate > 2000 then
			newTurbineFlowRate = 2000
		elseif newTurbineFlowRate < 0 then
			newTurbineFlowRate = 25 -- Don't go to zero, might as well power off
		end

		turbine.setFluidFlowRateMax(newTurbineFlowRate)

		-- Save updated Turbine Flow Rate
		turbineFlowRate = newTurbineFlowRate
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	print{"  Flow",22,3,monitorIndex}
	print{"<      >",22,4,monitorIndex}
	print{turbineFlowRate,23,4,monitorIndex}
	print{"  mB/t",22,5,monitorIndex}

	local rotorSpeedString = "Speed: "
	local energyBufferString = "Producing: "

	local padding = math.max(string.len(rotorSpeedString), string.len(energyBufferString))

	local energyBuffer = turbine.getEnergyProducedLastTick()
	print{energyBufferString,1,4,monitorIndex}
	print{math.ceil(energyBuffer).." RF/t",padding+1,4,monitorIndex}

	local rotorSpeed = math.ceil(turbine.getRotorSpeed())
	print{rotorSpeedString,1,5,monitorIndex}
	print{rotorSpeed.." RPM",padding+1,5,monitorIndex}

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/

	-- Draw stored energy buffer bar
	drawBar(1,8,28,8,colors.gray,monitorIndex)
	--paintutils.drawLine(2, 8, 28, 8, colors.gray)

	local curStoredEnergyPercent = getDeviceStoredEnergyBufferPercent(turbine)
	if curStoredEnergyPercent > 4 then
		drawBar(1, 8, math.floor(26*curStoredEnergyPercent/100)+2, 8, colors.yellow,monitorIndex)
	elseif curStoredEnergyPercent > 0 then
		drawPixel(1, 8, colors.yellow, monitorIndex)
	end -- if curStoredEnergyPercent > 4 then

	print{"Energy Buffer",1,7,monitorIndex}
	print{curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+3),7,monitorIndex}
	print{"%",28,7,monitorIndex}

	-- Print rod override status
	local turbineFlowRateOverrideStatus = ""

	print{"Flow Auto-adjust:",2,10,monitorIndex}

	if not turbineFlowRateOverride[turbineIndex] then
		turbineFlowRateOverrideStatus = "Enabled"
		monitor.setTextColor(colors.green)
	else
		turbineFlowRateOverrideStatus = "Disabled"
		monitor.setTextColor(colors.red)
	end -- if not reactorRodOverride then

	print{turbineFlowRateOverrideStatus, width - string.len(turbineFlowRateOverrideStatus) - 1, 10, monitorIndex}
	monitor.setTextColor(colors.white)

	monitor.setTextColor(colors.blue)
	printCentered(turbineNames[turbineIndex],12,monitorIndex)
	monitor.setTextColor(colors.white)

	-- Need equation to figure out rotor efficiency and display
end -- function displayTurbineBars(statusParams)


-- Display turbine status
local function turbineStatus(turbineIndex, monitorIndex)	
	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitorList["..monitorIndex.."] in turbineStatus() was not a valid monitor")
		return -- Invalid monitorIndex
	end

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbineList["..turbineIndex.."] in turbineStatus() was not a valid Big Turbine")
		return -- Invalid turbineIndex
	end

	local width, height = monitor.getSize()
	local turbineStatus = ""

	if turbine.getConnected() then
		if turbine.getActive() then
			turbineStatus = "ONLINE"
			monitor.setTextColor(colors.green)
		else
			turbineStatus = "OFFLINE"
			monitor.setTextColor(colors.red)
		end -- if turbine.getActive() then

		if (xClick >= (width - string.len(turbineStatus) - 1)) and (xClick <= (width-1)) and (sideClick == monitorNames[monitorIndex]) then
			if yClick == 1 then
				turbine.setActive(not turbine.getActive()) -- Toggle turbine status
				sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
			end -- if yClick == 1 then
		end -- if (xClick >= (width - string.len(turbineStatus) - 1)) and (xClick <= (width-1)) and (sideClick == monitorNames[monitorIndex]) then

		-- Allow disabling/enabling flow rate auto-adjust
		if ((xClick > 23 and xClick < 28 and yClick == 4)
				or (xClick > 20 and xClick < 27 and yClick == 10))
				and (sideClick == monitorNames[monitorIndex]) then
			turbineFlowRateOverride[turbineIndex] = not turbineFlowRateOverride[turbineIndex] -- Toggle turbine rod override status
			sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
		end

	else
		turbineStatus = "DISCONNECTED"
		monitor.setTextColor(colors.red)
	end -- if turbine.getConnected() then

	print{turbineStatus, width - string.len(turbineStatus) - 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)
end -- function function turbineStatus(turbineIndex, monitorIndex)


-- Maintain Turbine flow rate at 900 or 1,800 RPM
local function flowRateControl(turbineIndex)
	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbineList["..turbineIndex.."] in flowRateControl() was not a valid Big Turbine")
		return -- Invalid turbineIndex
	end

	-- No point modifying control rod levels for temperature if the turbine is offline
	if turbine.getActive() then
		local flowRate = turbine.getFluidFlowRate()
		local flowRateUserMax = math.ceil(turbine.getFluidFlowRateMax())
		local turbineTimeDiff = 0
		local rotorSpeed = math.ceil(turbine.getRotorSpeed())
		local newFlowRate = 0

		turbineTimeDiff = math.abs(os.time() - turbineLastUpdate[turbineIndex]) -- Difference in turbine flow rate update timestamp and now

		-- If we're outside our optimal rotor speed of 900 RPM or 1800 RPM, do something!
		if (math.fmod(rotorSpeed,900) ~= 0) then
			-- First simple checks if we're above or below optimal
			if ((rotorSpeed < 900) and (flowRate == flowRateUserMax)) or -- Don't increment maximum if flowRate isn't keeping up with our maximum setting
				((rotorSpeed < 1800) and (flowRateUserMax < 2000)) then
				newFlowRate = flowRateUserMax + flowRateAdjustAmount
			-- If we're past max optimal RPM or cannot increase flowRate, downgrade to get to 900 RPM
			elseif (rotorSpeed > 1800) or (rotorSpeed > 900) then
				newFlowRate = flowRateUserMax - flowRateAdjustAmount
			end

			-- Check bounds [0,2000]
			if newFlowRate > 2000 then
				newFlowRate = 2000
			elseif newFlowRate < 0 then
				newFlowRate = 25 -- Don't go to zero, might as well power off
			end

			turbine.setFluidFlowRateMax(newFlowRate)
			turbineLastUpdate[turbineIndex] = os.time() -- Last update is now. :)
		end -- if (rotorSpeed % 900 == 0) and (turbineTimeDiff > 0.1) then
	end -- if turbine.getActive() then
end -- function flowRateControl(turbineIndex)


function main()
	-- Load reactor parameters and initialize systems
	loadReactorOptions()

	while not finished do
		local reactor = nil
		-- Get our initial list of connected monitors and reactors
		-- and initialize every cycle in case the connected devices change
		findMonitors()
		findReactors()
		findTurbines()

		-- Loop through found monitors
		for monitorIndex = 1, #monitorList do
			-- For multiple reactors/monitors, monitor #1 is reserved for overall status
			-- or for multiple reactors/turbines and only one monitor
			if (((#reactorList + #turbineList) > 1) and (#monitorList > 1) and (monitorIndex == 1)) or
				(((#reactorList + #turbineList) > 1) and (#monitorList == 1)) then
				clearMonitor(progName.." "..progVer, monitorIndex) -- Clear monitor and draw borders
				printCentered(progName.." "..progVer, 1, monitorIndex)
				displayAllStatus()
			elseif debugMode and (monitorIndex == #monitorList) then
				break -- We're using this monitor for debug info
			-- Turbines are taken care of below via an offset, so do not loop through those
			-- if no turbines are found, use all monitors for reactors
			-- #turbineMonitorOffset already included #reactorList and +1 for overall status monitor
			elseif #turbineList and (monitorIndex > turbineMonitorOffset) then
				break
			else
				-- This code needs re-factoring once we actually work with multiple reactors
				for reactorIndex = 1, #reactorList do
					clearMonitor(progName, monitorIndex) -- Clear monitor and draw borders
					printCentered(progName, 1, monitorIndex)

					-- Display reactor status, includes "Disconnected" but found reactors
					reactorStatus{reactorIndex, monitorIndex}

					reactor = reactorList[reactorIndex]
					if not reactor then
						printLog("reactorList["..reactorIndex.."] in main() was not a valid Big Reactor")
						break -- Invalid reactorIndex
					end

					if reactor.getConnected() then
						local curStoredEnergyPercent = getDeviceStoredEnergyBufferPercent(reactor)

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

						displayReactorBars{reactorIndex,monitorIndex}
					end	-- if reactor.getConnected() then
				end	-- for reactorIndex = 1, #reactorList do

				-- Monitors for turbines start after turbineMonitorOffset
				for turbineIndex = 1, #turbineList do
					local turbineMonitorIndex = turbineIndex+turbineMonitorOffset
					clearMonitor(progName, turbineMonitorIndex) -- Clear monitor and draw borders
					printCentered(progName, 1, turbineMonitorIndex)

					-- Display turbine status, includes "Disconnected" but found turbines
					turbineStatus(turbineIndex, turbineMonitorIndex)

					turbine = turbineList[turbineIndex]
					if not turbine then
						printLog("turbineList["..turbineIndex.."] in main() was not a valid Big Turbine")
						break -- Invalid turbineIndex
					end

					if turbine.getConnected() then
						if not turbineFlowRateOverride[turbineIndex] then
							flowRateControl(turbineIndex)
						end

						displayTurbineBars(turbineIndex,turbineMonitorIndex)
					end
				end -- for reactorIndex = 1, #reactorList do
			end -- if #reactorList > 1 and monitorIndex == 1 then

			sleep(loopTime)	-- Sleep
			saveReactorOptions()
		end -- for monitorIndex = 1, #monitorList do
	end -- while not finished do
end -- main()


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


while not finished do
	parallel.waitForAny(eventHandler, main)
	sleep(loopTime)
end -- while not finished do


-- Clear up after an exit
term.clear()
term.setCursorPos(1,1)
