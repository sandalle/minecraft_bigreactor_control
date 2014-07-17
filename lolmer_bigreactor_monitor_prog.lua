--[[
Program name: Lolmer's EZ-NUKE reactor control system
Version: v0.3.9
Programmer: Lolmer
Minor assistance by Mechaet
Last update: 2014-07-15
Pastebin: http://pastebin.com/fguScPBQ

Description:
This program controls a Big Reactors nuclear reactor in Minecraft with a Computercraft computer, using Computercraft's own wired modem connected to the reactors computer control port.

This program was designed to work with the mods and versions installed on Never Stop Toasting (NST) Diet http://www.technicpack.net/modpack/details/never-stop-toasting-diet.254882 Endeavour: Never Stop Toasting: Diet official Minecraft server http://forums.somethingawful.com/showthread.php?threadid=3603757

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
	Two 15x15x14 Turbines can output 260K RF/t by just one 7^3 (four rods) reactor putting out 4k mB steam.

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
	For multiple monitors, the first monitor (often last plugged in) is the overall status monitor.
	A new cruise mode from mechaet, ONLINE will be "blue" when active, to keep your actively cooled reactors running smoothly.

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
	Minimum Passive Cooling Temperature: 850^C (will raise control rods below this value)
	Maximum Passive Cooling Temperature: 950^C (will lower control rods above this value)
	Minimum Active Cooling Temperature: 300^C (will raise the control rods below this value)
	Maximum Active Cooling Temperature: 420^C (will lower control rods above this value)
	Optimal Turbine RPM:  900, 1,800, or 2,700 (divisible by 900)
	New user-controlled option for target speed of turbines, defaults to 2726RPM, which is high-optimal.

Requirements:
	Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
	Computer or Advanced Computer
	Modems (not wireless) connecting each of the Computer to both the Advanced Monitor and Reactor Computer Port.
	Big Reactors (http://www.big-reactors.com/) 0.3.2A+
	Computercraft (http://computercraft.info/) 1.63+
	Reset the computer any time number of connected devices change.

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
	http://pastebin.com/7S5xCvgL (IronClaymore only for passively cooled reactors)

	Reactor Computer Port API: http://wiki.technicpack.net/Reactor_Computer_Port
	Computercraft API: http://computercraft.info/wiki/Category:APIs
	Big Reactors Efficiency, Speculation and Questions! http://www.reddit.com/r/feedthebeast/comments/1vzds0/big_reactors_efficiency_speculation_and_questions/
	Big Reactors API code: https://github.com/erogenousbeef/BigReactors/blob/master/erogenousbeef/bigreactors/common/multiblock/tileentity/TileEntityReactorComputerPort.java
	Big Reactors API: http://big-reactors.com/cc_api.html

ChangeLog:
0.3.9 - Algorithm pass by Mechaet.
		Additional user config options.
		Fix multiple reactors and none or more turbines with only one status monitor.
		Fix monitor scaling after one was used as debug (or in case of other modifications).
		Fix energy/% displays to match Big Reactors' GUI (Issue #9).
		Cruise mode implemented, defaults off but is saved between boots.
		Always write out found devices on computer terminal.
		Much improved round() function from mechaet (Issue #14).
0.3.8 - Update to ComputerCraft 1.6 API.
0.3.7 - Fix typo when initializing TurbineNames array.
		Fix Issue #1, turbine display is using the Reactor buffer size (10M RF) instead of the Turbine buffer size (1M RF).
0.3.6 - Fix multi-reactors displaying on the correct monitors (thanks HybridFusion).
		Fix rod auto-adjust text position.
		Reactors store 10M RF and Turbines store 1M RF in their buffer.
		Add more colour to displayAllStatus().
		Sleep for only two seconds instead of five.
		Fix getDeviceStoredEnergyBufferPercent() for Reactors storing 10M RF in buffer.
		Keep actively cooled reactors between 0-300^C (non-configurable for now).
0.3.5 - Do not discover connected devices every loop - nicer on servers. Reset computer anytime number of connected devices change.
		Fix multi-reactor setups to display the additional reactors on monitors, rather than the last one found.
		Fix passive reactor display having auto-adjust and energy buffer overwrite each other (removes rod count).
0.3.4 - Fix arithmetic for checking if we have enough monitors for the number of reactors.
		Turbines are optimal at 900, 1800, *and* 2700 RPM
		Increase loop timer from 1 to 5 to be nicer to servers
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
- Save parameters per reactor instead of one global set for all reactors.
- Add min/max RF/t output and have it override temperature concerns (maybe?).
- Add support for wireless modems, see http://computercraft.info/wiki/Modem_%28API%29, will not be secure (anyone can send/listen to your channels)!
- Add support for any sized monitor (minimum 3x3), dynamic allocation/alignment.
- Lookup using pcall for better error handling http://www.computercraft.info/forums2/index.php?/topic/10992-using-pcall/ .
- Update cruise mode to work independently for each actively-cooled reactor.

]]--


-- Some global variables
local progVer = "0.3.9"
local progName = "EZ-NUKE "
local sideClick, xClick, yClick = nil, 0, 0
local loopTime = 2
local controlRodAdjustAmount = 1 -- Default Reactor Rod Control % adjustment amount
local flowRateAdjustAmount = 25 -- Default Turbine Flow Rate in mB adjustment amount
local debugMode = false
-- These need to be updated for multiple reactors
local baseControlRodLevel = nil
local reactorRodOverride = false -- Rod override for Reactors
-- End multi-reactor cleanup section
local minStoredEnergyPercent = nil -- Max energy % to store before activate
local maxStoredEnergyPercent = nil -- Max energy % to store before shutdown
local minReactorTemp = nil -- Minimum reactor temperature (^C) to maintain
local maxReactorTemp = nil -- Maximum reactor temperature (^C) to maintain
local turbineBaseSpeed = nil -- Target (user-configured in ReactorOptions) turbine speed, default 2726RPM
local reactorCruising = false -- Cruise mode for active-cooled reactors, enable/disable switch
local lastTempPoll = 0 -- Cruise mode global temperature comparator
local autoStart = {} -- Array for automatically starting reactors
local monitorList = {} -- Empty monitor array
local monitorNames = {} -- Empty array of monitor names
local reactorList = {} -- Empty reactor array
local reactorNames = {} -- Empty array of reactor names
local turbineList = {} -- Empty turbine array
local turbineNames = {} -- Empty array of turbine names
local turbineFlowRateOverride = {} -- Flow rate override for each Turbine
local turbineMonitorOffset = 0 -- Turbines are assigned monitors after reactors

term.clear()
term.setCursorPos(2,1)
write("Initializing program...\n")


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
		printLog("monitor["..monitorIndex.."] in print() is not a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in printCentered() is not a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in printLeft() is not a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in printRight() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Make sure printString is a string
	printString = tostring(printString)

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

	printLog("Called as clearMonitor(printString="..printString..",monitorIndex="..monitorIndex..").")

	if not monitor then
		printLog("monitor["..monitorIndex.."] in clearMonitor() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	local gap = 2
	monitor.clear()
	local width, height = monitor.getSize()
	monitor.setTextScale(1.0)       -- Make sure scale is correct

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

-- Draw a line across the entire x-axis
local function drawLine(yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	printLog("Called as drawLine(yPos="..yPos..",monitorIndex="..monitorIndex..").")

	if not monitor then
		printLog("monitor["..monitorIndex.."] in drawLine() is not a valid monitor.")
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

	printLog("Called as drawBar(startXPos="..startXPos..",startYPos="..startYPos..",endXPos="..endXPos..",endYPos="..endYPos..",color="..color..",monitorIndex="..monitorIndex..").")

	if not monitor then
		printLog("monitor["..monitorIndex.."] in drawBar() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/
	term.redirect(monitor)
	paintutils.drawLine(startXPos, startYPos, endXPos, endYPos, color)
	monitor.setBackgroundColor(colors.black) -- PaintUtils doesn't restore the color
	term.native()
end -- function drawBar(startXPos, startYPos,endXPos,endYPos,color,monitorIndex)


-- Display single pixel color
local function drawPixel(xPos, yPos, color, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	printLog("Called as drawPixel(xPos="..xPos..",yPos="..yPos..",color="..color..",monitorIndex="..monitorIndex..").")

	if not monitor then
		printLog("monitor["..monitorIndex.."] in drawPixel() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/
	term.redirect(monitor)
	paintutils.drawPixel(xPos, yPos, color)
	monitor.setBackgroundColor(colors.black) -- PaintUtils doesn't restore the color
	term.native()
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
				printLog("monitorList["..monitorIndex.."] in findMonitors() is not a valid monitor.")
				break -- Invalid monitorIndex
			end

			local monitorX, monitorY = monitor.getSize()
			printLog("Verifying monitor["..monitorIndex.."] is of size x:"..monitorX.." by y:"..monitorY..".")

			-- Check for minimum size to allow for monitor.setTextScale(0.5) to work for 3x2 debugging monitor, changes getSize()
			if monitorX < 29 or monitorY < 12 then
				term.redirect(monitor)
				monitor.clear()
				printLog("Removing monitor "..monitorIndex.." for being too small.")
				monitor.setCursorPos(1,2)
				write("Monitor is the wrong size!\n")
				write("Needs to be at least 3x2.")
				term.native()

				table.remove(monitorList, monitorIndex) -- Remove invalid monitor from list
				if monitorIndex == #monitorList then    -- If we're at the end already, break from loop
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
				printLog("reactorList["..reactorIndex.."] in findReactors() is NOT a valid Big Reactor.")
				return -- Invalid reactorIndex
			else
				printLog("reactor["..reactorIndex.."] in findReactors() is a valid Big Reactor.")
				if reactor.getConnected() then
					printLog("reactor["..reactorIndex.."] in findReactors() is connected.")
				else
					printLog("reactor["..reactorIndex.."] in findReactors() is NOT connected.")
					return -- Disconnected reactor
				end
			end

			-- If number of found reactors changed, re-initialize them all for now
			-- For now, initialize reactors to the same baseControlRodLevel
			if #newReactorList ~= #reactorList then
				reactor.setAllControlRodLevels(baseControlRodLevel)

				-- Auto-start reactor when needed (e.g. program startup) by default, or use existing value
				autoStart[reactorIndex] = true
			end -- if #newReactorList ~= #reactorList then
		end -- for reactorIndex = 1, #newReactorList do
	end -- if #newReactorList == 0 then

	-- Overwrite old reactor list with the now updated list
	reactorList = newReactorList

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
				printLog("turbineList["..turbineIndex.."] in findTurbines() is not a valid Big Reactors Turbine.")
				return -- Invalid turbineIndex
			else
				printLog("turbineList["..turbineIndex.."] in findTurbines() is a valid Big Reactors Turbine.")
				if turbine.getConnected() then
					printLog("turbine["..turbineIndex.."] in findTurbines() is connected.")
				else
					printLog("turbine["..turbineIndex.."] in findTurbines() is NOT connected.")
					return -- Disconnected turbine
				end
			end

			-- If number of found turbines changed, re-initialize them all for now
			if #newTurbineList ~= #turbineList then
				-- Default is to allow flow rate auto-adjust
				turbineFlowRateOverride[turbineIndex] = false
			end -- if #newTurbineList ~= #turbineList then
		end -- for turbineIndex = 1, #newTurbineList do

		-- Overwrite old turbine list with the now updated list
		turbineList = newTurbineList
	end -- if #newTurbineList == 0 then
end -- function findTurbines()


-- Return current energy buffer in a specific reactor by %
local function getReactorStoredEnergyBufferPercent(reactor)
	printLog("Called as getReactorStoredEnergyBufferPercent(reactor).")

	if not reactor then
		printLog("getReactorStoredEnergyBufferPercent() did NOT receive a valid Big Reactor Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("getReactorStoredEnergyBufferPercent() did receive a valid Big Reactor Reactor.")
	end

	local energyBufferStorage = reactor.getEnergyStored()
	return round(energyBufferStorage/100000, 1) -- (buffer/10000000 RF)*100%
end -- function getReactorStoredEnergyBufferPercent(reactor)


-- Return current energy buffer in a specific Turbine by %
local function getTurbineStoredEnergyBufferPercent(turbine)
	printLog("Called as getTurbineStoredEnergyBufferPercent(turbine)")

	if not turbine then
		printLog("getTurbineStoredEnergyBufferPercent() did NOT receive a valid Big Reactor Turbine.")
		return -- Invalid reactorIndex
	else
		printLog("getTurbineStoredEnergyBufferPercent() did receive a valid Big Reactor Turbine.")
	end

	local energyBufferStorage = turbine.getEnergyStored()
	return round(energyBufferStorage/10000, 1) -- (buffer/1000000 RF)*100%
end -- function getTurbineStoredEnergyBufferPercent(turbine)

local function reactorCruise(cruiseMaxTemp, cruiseMinTemp, lastPolledTemp, reactorIndex)
	printLog("Called as reactorCruise(cruiseMaxTemp="..cruiseMaxTemp..",cruiseMinTemp="..cruiseMinTemp..",lastPolledTemp="..lastPolledTemp..",reactorIndex="..reactorIndex..").")

	if ((lastPolledTemp < cruiseMaxTemp) and (lastPolledTemp > cruiseMinTemp)) then
		local reactor = nil
		reactor = reactorList[reactorIndex]
		if not reactor then
			printLog("reactor["..reactorIndex.."] in reactorCruise() is NOT a valid Big Reactor.")
			return -- Invalid reactorIndex
		else
			printLog("reactor["..reactorIndex.."] in reactorCruise() is a valid Big Reactor.")
			if reactor.getConnected() then
				printLog("reactor["..reactorIndex.."] in reactorCruise() is connected.")
			else
				printLog("reactor["..reactorIndex.."] in reactorCruise() is NOT connected.")
				return -- Disconnected reactor
			end -- if reactor.getConnected() then
		end -- if not reactor then

		local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
		local reactorTemp = math.ceil(reactor.getFuelTemperature())

		if ((reactorTemp < cruiseMaxTemp) and (reactorTemp > cruiseMinTemp)) then
			if (reactorTemp > lastPolledTemp) then
				rodPercentage = (rodPercentage - 1)
				--Boundary check
				if rodPercentage < 0 then
					reactor.setAllControlRodLevels(0)
				else
					reactor.setAllControlRodLevels(rodPercentage)
				end
			else
				rodPercentage = (rodPercentage + 1)
				--Boundary check
				if rodPercentage > 99 then
					reactor.setAllControlRodLevels(99)
				else
					reactor.setAllControlRodLevels(rodPercentage)
				end
			end -- if (reactorTemp > lastPolledTemp) then
		else
			--disengage cruise, we've fallen out of the ideal temperature range
			reactorCruising = false
		end -- if ((reactorTemp < cruiseMaxTemp) and (reactorTemp > cruiseMinTemp)) then
	else
		--I don't know how we'd get here, but let's turn the cruise mode off
		reactorCruising = false
	end -- if ((lastPolledTemp < cruiseMaxTemp) and (lastPolledTemp > cruiseMinTemp)) then
end -- function reactorCruise(cruiseMaxTemp, cruiseMinTemp, lastPolledTemp, reactorIndex)

-- Modify reactor control rod levels to keep temperature with defined parameters, but
-- wait an in-game half-hour for the temperature to stabalize before modifying again
local function temperatureControl(reactorIndex)
	printLog("Called as temperatureControl(reactorIndex="..reactorIndex..")")

	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactor["..reactorIndex.."] in temperatureControl() is NOT a valid Big Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("reactor["..reactorIndex.."] in temperatureControl() is a valid Big Reactor.")

		if reactor.getConnected() then
			printLog("reactor["..reactorIndex.."] in temperatureControl() is connected.")
		else
			printLog("reactor["..reactorIndex.."] in temperatureControl() is NOT connected.")
			return -- Disconnected reactor
		end -- if reactor.getConnected() then
	end

	local reactorNum = reactorIndex
	local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
	local reactorTemp = math.ceil(reactor.getFuelTemperature())
	local localMinReactorTemp, localMaxReactorTemp = minReactorTemp, maxReactorTemp

	-- No point modifying control rod levels for temperature if the reactor is offline
	if reactor.getActive() then
		-- Actively cooled reactors should range between 0^C-300^C
		-- Actually, active-cooled reactors should range between 300 and 420C (Mechaet)
		-- Accordingly I changed the below lines
		if reactor.isActivelyCooled() then
			-- below was 0
			localMinReactorTemp = 300
			-- below was 300
			localMaxReactorTemp = 420
		end

		if reactorCruising then
			--let's bypass all this math and hit the much-more-subtle cruise feature
			--printLog("min: "..localMinReactorTemp..", max: "..localMaxReactorTemp..", lasttemp: "..lastTempPoll..", ri: "..reactorIndex.."  EOL")
			reactorCruise(localMaxReactorTemp, localMinReactorTemp, lastTempPoll, reactorIndex)
		else
			-- Don't bring us to 100, that's effectively a shutdown
				if (reactorTemp > localMaxReactorTemp) and (rodPercentage ~= 99) then
					--increase the rods, but by how much?
					if (reactorTemp > lastTempPoll) then
						--we're climbing, we need to get this to decrease
						if ((reactorTemp - lastTempPoll) > 100) then
							--we're climbing really fast, arrest it
							if (rodPercentage + (10 * controlRodAdjustAmount)) > 99 then
								reactor.setAllControlRodLevels(99)
							else
								reactor.setAllControlRodLevels(rodPercentage + (10 * controlRodAdjustAmount))
							end
						else
							--we're not climbing by leaps and bounds, let's give it a rod adjustment based on temperature increase
							local diffAmount = reactorTemp - lastTempPoll
							diffAmount = round(diffAmount/10, 0)
							controlRodAdjustAmount = diffAmount
							if (rodPercentage + controlRodAdjustAmount) > 99 then
							    reactor.setAllControlRodLevels(99)
						    else
							    reactor.setAllControlRodLevels(rodPercentage + controlRodAdjustAmount)
						    end
						end --if ((reactorTemp - lastTempPoll) > 100) then
					elseif (reactorTemp = lastTempPoll) then
						--temperature has stangnated, kick it very lightly
						local controlRodAdjustment = 1
						if (rodPercentage + controlRodAdjustment) > 99 then
							reactor.setAllControlRodLevels(99)
						else
							reactor.setAllControlRodLevels(rodPercentage + controlRodAdjustment)
						end
					end --if (reactorTemp > lastTempPoll) then
						--worth noting that if we're above temp but decreasing, we do nothing. let it continue decreasing.

				elseif (reactorTemp < localMinReactorTemp) and (rodPercentage ~=0) then
					--we're too cold. time to warm up, but by how much?
					if (reactorTemp < lastTempPoll) then
						--we're descending, let's stop that.
						if ((lastTempPoll - reactorTemp) > 100) then
							--we're headed for a new ice age, bring the heat
							if (rodPercentage - (10 * controlRodAdjustAmount)) < 0 then
							    reactor.setAllControlRodLevels(0)
						    else
							    reactor.setAllControlRodLevels(rodPercentage - (10 * controlRodAdjustAmount))
						    end
						else
							--we're not descending quickly, let's bump it based on descent rate
							local diffAmount = lastTempPoll - reactorTemp
							diffAmount = round(diffAmount/10, 0)
							controlRodAdjustAmount = diffAmount
							if (rodPercentage - controlRodAdjustAmount) < 0 then
							    reactor.setAllControlRodLevels(0)
						    else
							    reactor.setAllControlRodLevels(rodPercentage - controlRodAdjustAmount)
						    end
						end --if ((lastTempPoll - reactorTemp) > 100) then
					elseif (reactorTemp = lastTempPoll) then
						--temperature has stagnated, kick it very lightly
						local controlRodAdjustment = 1
						if (rodPercentage - controlRodAdjustment) < 0 then
							reactor.setAllControlRodLevels(0)
						else
							reactor.setAllControlRodLevels(rodPercentage - controlRodAdjustment)
						end --if (rodPercentage - controlRodAdjustment) < 0 then

					end --if (reactorTemp < lastTempPoll) then
					--if we're below temp but increasing, do nothing and let it continue to rise.
				end --if (reactorTemp > localMaxReactorTemp) and (rodPercentage ~= 99) then


				--[[
				--the old functions are here for posterity
			if (reactorTemp > localMaxReactorTemp) and (rodPercentage ~= 99) then
						-- If more than double our maximum temperature, increase rodPercentage faster
						if reactorTemp > (2 * localMaxReactorTemp) then
							-- Check bounds, Big Reactor doesn't do this for us. :)
							if (rodPercentage + (10 * controlRodAdjustAmount)) > 99 then
										reactor.setAllControlRodLevels(99)
							else
										reactor.setAllControlRodLevels(rodPercentage + (10 * controlRodAdjustAmount))
							end
						else
							-- Check bounds, Big Reactor doesn't do this for us. :)
							if (rodPercentage + controlRodAdjustAmount) > 99 then
										reactor.setAllControlRodLevels(99)
							else
										reactor.setAllControlRodLevels(rodPercentage + controlRodAdjustAmount)
							end
						end -- if reactorTemp > (2 * localMaxReactorTemp) then
			elseif (reactorTemp < localMinReactorTemp) and (rodPercentage ~= 0) then
						-- If less than half our minimum temperature, decrease rodPercentage faster
						if reactorTemp < (localMinReactorTemp / 2) then
							-- Check bounds, Big Reactor doesn't do this for us. :)
							if (rodPercentage - (10 * controlRodAdjustAmount)) < 0 then
										reactor.setAllControlRodLevels(0)
							else
										reactor.setAllControlRodLevels(rodPercentage - (10 * controlRodAdjustAmount))
							end
						else
							-- Check bounds, Big Reactor doesn't do this for us. :)
							if (rodPercentage - controlRodAdjustAmount) < 0 then
										reactor.setAllControlRodLevels(0)
							else
										reactor.setAllControlRodLevels(rodPercentage - controlRodAdjustAmount)
							end
						end -- if reactorTemp < (localMinReactorTemp / 2) then

						baseControlRodLevel = rodPercentage
			end -- if (reactorTemp > localMaxReactorTemp) and (rodPercentage < 99) then
				]]--
			if ((reactorTemp > localMinReactorTemp) and (reactorTemp < localMaxReactorTemp)) then
						--engage cruise mode
						reactorCruising = true
			end
		end
		--always set this number
		lastTempPoll = reactorTemp
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
		--added by Mechaet
		turbineBaseSpeed = reactorOptions.readLine()
		reactorCruising = reactorOptions.readLine() -- Should be string "true" or "false"
		lastTempPoll = reactorOptions.readLine() -- number as a string

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

		if turbineBaseSpeed ~= nil then
		turbineBaseSpeed = tonumber(turbineBaseSpeed)
		else
		turbineBaseSpeed = 2726
		end

		if reactorCruising == "true" then
			reactorCruising = true
		else
			reactorCruising = false
		end

		if lastTempPoll ~=nil then
			lastTempPoll = tonumber(lastTempPoll)
		else
			lastTempPoll = 0
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
		minReactorTemp = 950
	end

	if maxReactorTemp == nil then
		maxReactorTemp = 1400
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
		reactorOptions.writeLine(turbineBaseSpeed)
		reactorOptions.writeLine(reactorCruising)
		reactorOptions.writeLine(lastTempPoll)
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

	printLog("Called as displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitor["..monitorIndex.."] in displayReactorBars() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactor["..reactorIndex.."] in displayReactorBars() is NOT a valid Big Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("reactor["..reactorIndex.."] in displayReactorBars() is a valid Big Reactor.")
		if reactor.getConnected() then
			printLog("reactor["..reactorIndex.."] in displayReactorBars() is connected.")
		else
			printLog("reactor["..reactorIndex.."] in displayReactorBars() is NOT connected.")
			return -- Disconnected reactor
		end -- if reactor.getConnected() then
	end -- if not reactor then

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

	local fuelPercentage = round(reactor.getFuelAmount()/reactor.getFuelAmountMax()*100,1)
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
		newRodPercentage = rodPercentage - (5 * controlRodAdjustAmount)
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
		newRodPercentage = rodPercentage + (5 * controlRodAdjustAmount)
		if newRodPercentage > 100 then
			newRodPercentage = 100
		end
		sideClick, xClick, yClick = 0, 0, 0

		reactor.setAllControlRodLevels(newRodPercentage)

		-- Save updated rod percentage
		baseControlRodLevel = newRodPercentage
		rodPercentage = round(newRodPercentage,0)
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
	--convert to a whole number for display purposes
	local wholeRodPercentage = nil
	wholeRodPercentage, decimal = math.modf(rodPercentage)
	print{"Rod (%)",23,3,monitorIndex}
	print{"<     >",23,4,monitorIndex}
	print{wholeRodPercentage,25,4,monitorIndex}

	-- getEnergyProducedLastTick() is used for both RF/t (passively cooled) and mB/t (actively cooled)
	local energyBuffer = reactor.getEnergyProducedLastTick()
	print{energyBufferString,2,4,monitorIndex}

	-- Actively cooled reactors do not produce energy, only hot fluid mB/t to be used in a turbine
	-- still uses getEnergyProducedLastTick for mB/t of hot fluid generated
	if not reactor.isActivelyCooled() then
		printLog("reactor["..reactorIndex.."] in displayReactorBars is NOT an actively cooled reactor.")

		-- Draw stored energy buffer bar
		drawBar(2,8,28,8,colors.gray,monitorIndex)

		local curStoredEnergyPercent = getReactorStoredEnergyBufferPercent(reactor)
		if curStoredEnergyPercent > 4 then
			drawBar(2, 8, math.floor(26*curStoredEnergyPercent/100)+2, 8, colors.yellow, monitorIndex)
		elseif curStoredEnergyPercent > 0 then
			drawPixel(2, 8, colors.yellow, monitorIndex)
		end -- if curStoredEnergyPercent > 4 then

		print{"Energy Buffer",2,7,monitorIndex}
		print{curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+2),7,monitorIndex}
		print{"%",28,7,monitorIndex}

		print{math.ceil(energyBuffer).." RF/t",padding+2,4,monitorIndex}
	else
		printLog("reactor["..reactorIndex.."] in displayReactorBars is an actively cooled reactor.")
		print{math.ceil(energyBuffer).." mB/t",padding+2,4,monitorIndex}
	end -- if not reactor.isActivelyCooled() then

	-- Print rod override status
	local reactorRodOverrideStatus = ""

	print{"Rod Auto-adjust:",2,9,monitorIndex}

	if not reactorRodOverride then
		reactorRodOverrideStatus = "Enabled"
		monitor.setTextColor(colors.green)
	else
		reactorRodOverrideStatus = "Disabled"
		monitor.setTextColor(colors.red)
	end -- if not reactorRodOverride then

	print{reactorRodOverrideStatus, width - string.len(reactorRodOverrideStatus) - 1, 9, monitorIndex}
	monitor.setTextColor(colors.white)

	print{"Reactivity: "..math.ceil(reactor.getFuelReactivity()).." %", 2, 10, monitorIndex}
	print{"Fuel: "..round(reactor.getFuelConsumedLastTick(),3).." mB/t", 2, 11, monitorIndex}
	print{"Waste: "..reactor.getWasteAmount().." mB", width-(string.len(reactor.getWasteAmount())+10), 11, monitorIndex}

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

	printLog("Called as reactorStatus(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..")")

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitor["..monitorIndex.."] in reactorStatus() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactor["..reactorIndex.."] in reactorStatus() is NOT a valid Big Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("reactor["..reactorIndex.."] in reactorStatus() is a valid Big Reactor.")
	end

	local width, height = monitor.getSize()
	local reactorStatus = ""

	if reactor.getConnected() then
		printLog("reactor["..reactorIndex.."] in reactorStatus() is connected.")

		if reactor.getActive() then
			reactorStatus = "ONLINE"

			-- Set "ONLINE" to blue if the actively cooled reactor is both in cruise mode and online
			if reactorCruising and reactor.isActivelyCooled() then
				monitor.setTextColor(colors.blue)
			else
				monitor.setTextColor(colors.green)
			end -- if reactorCruising and reactor.isActivelyCooled() then
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
				or (xClick > 20 and xClick < 27 and yClick == 9))
				and (sideClick == monitorNames[monitorIndex]) then
			reactorRodOverride = not reactorRodOverride -- Toggle reactor rod override status
			sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
		end -- if (xClick > 23) and (xClick < 28) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	else
		printLog("reactor["..reactorIndex.."] in reactorStatus() is NOT connected.")
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
	local totalCoolantStored, totalSteamStored, totalEnergy, totalMaxEnergyStored = 0, 0, 0, 0 -- Total turbine and reactor energy buffer and overall capacity
	local maxSteamStored = (2000*#turbineList)+(5000*#reactorList)
	local maxCoolantStored = (2000*#turbineList)+(5000*#reactorList)

	local monitor, monitorIndex = nil, 1
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitor["..monitorIndex.."] in displayAllStatus() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	for reactorIndex = 1, #reactorList do
		reactor = reactorList[reactorIndex]
		if not reactor then
			printLog("reactor["..reactorIndex.."] in displayAllStatus() is NOT a valid Big Reactor.")
			break -- Invalid reactorIndex
		else
			printLog("reactor["..reactorIndex.."] in displayAllStatus() is a valid Big Reactor.")
		end -- if not reactor then

		if reactor.getConnected() then
			printLog("reactor["..reactorIndex.."] in displayAllStatus() is connected.")
			if reactor.getActive() then
				onlineReactor = onlineReactor + 1
				totalReactorFuelConsumed = totalReactorFuelConsumed + reactor.getFuelConsumedLastTick()
			end -- reactor.getActive() then

			-- Actively cooled reactors do not produce or store energy
			if not reactor.isActivelyCooled() then
				totalMaxEnergyStored = totalMaxEnergyStored + 10000000 -- Reactors store 10M RF
				totalEnergy = totalEnergy + reactor.getEnergyStored()
				totalReactorRF = totalReactorRF + reactor.getEnergyProducedLastTick()
			else
				totalReactorSteam = totalReactorSteam + reactor.getEnergyProducedLastTick()
				totalSteamStored = totalSteamStored + reactor.getHotFluidAmount()
				totalCoolantStored = totalCoolantStored + reactor.getCoolantAmount()
			end -- if not reactor.isActivelyCooled() then
		else
			printLog("reactor["..reactorIndex.."] in displayAllStatus() is NOT connected.")
		end -- if reactor.getConnected() then
	end -- for reactorIndex = 1, #reactorList do

	for turbineIndex = 1, #turbineList do
		turbine = turbineList[turbineIndex]
		if not turbine then
			printLog("turbine["..turbineIndex.."] in displayAllStatus() is NOT a valid Turbine.")
			break -- Invalid turbineIndex
		else
			printLog("turbine["..turbineIndex.."] in displayAllStatus() is a valid Turbine.")
		end -- if not turbine then

		if turbine.getConnected() then
			printLog("turbine["..turbineIndex.."] in displayAllStatus() is connected.")
			if turbine.getActive() then
				onlineTurbine = onlineTurbine + 1
			end

			totalMaxEnergyStored = totalMaxEnergyStored + 1000000 -- Turbines store 1M RF
			totalEnergy = totalEnergy + turbine.getEnergyStored()
			totalTurbineRF = totalTurbineRF + turbine.getEnergyProducedLastTick()
			totalSteamStored = totalSteamStored + turbine.getInputAmount()
			totalCoolantStored = totalCoolantStored + turbine.getOutputAmount()
		else
			printLog("turbine["..turbineIndex.."] in displayAllStatus() is NOT connected.")
		end -- if turbine.getConnected() then
	end -- for turbineIndex = 1, #turbineList do

	print{"Reactors online/found: "..onlineReactor.."/"..#reactorList, 2, 3, monitorIndex}
	print{"Turbines online/found: "..onlineTurbine.."/"..#turbineList, 2, 4, monitorIndex}

	if totalReactorRF ~= 0 then
		monitor.setTextColor(colors.blue)
		printRight("Reactor", 9, monitorIndex)
		monitor.setTextColor(colors.white)
		printRight(math.ceil(totalReactorRF).." (RF/t)", 10, monitorIndex)
	end

	if #turbineList then
		-- Display liquids
		monitor.setTextColor(colors.blue)
		printLeft("Steam (mB)", 6, monitorIndex)
		monitor.setTextColor(colors.white)
		printLeft(math.ceil(totalSteamStored).."/"..maxSteamStored, 7, monitorIndex)
		printLeft(math.ceil(totalReactorSteam).." mB/t", 8, monitorIndex)
		monitor.setTextColor(colors.blue)
		printRight("Coolant (mB)", 6, monitorIndex)
		monitor.setTextColor(colors.white)
		printRight(math.ceil(totalCoolantStored).."/"..maxCoolantStored, 7, monitorIndex)

		monitor.setTextColor(colors.blue)
		printLeft("Turbine", 9, monitorIndex)
		monitor.setTextColor(colors.white)
		printLeft(math.ceil(totalTurbineRF).." RF/t", 10, monitorIndex)
	end -- if #turbineList then

	printRight("Fuel: "..round(totalReactorFuelConsumed,3).." mB/t", 11, monitorIndex)
	print{"Buffer: "..math.ceil(totalEnergy,3).."/"..totalMaxEnergyStored.." RF", 2, 12, monitorIndex}
end -- function displayAllStatus()


-- Get turbine status
local function displayTurbineBars(turbineIndex, monitorIndex)
	printLog("Called as displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitor["..monitorIndex.."] in displayTurbineBars() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbine["..turbineIndex.."] in displayTurbineBars() is NOT a valid Big Turbine.")
		return -- Invalid turbineIndex
	else
		printLog("turbine["..turbineIndex.."] in displayTurbineBars() is a valid Big Turbine.")
		if turbine.getConnected() then
			printLog("turbine["..turbineIndex.."] in displayTurbineBars() is connected.")
		else
			printLog("turbine["..turbineIndex.."] in displayTurbineBars() is NOT connected.")
			return -- Disconnected turbine
		end -- if turbine.getConnected() then
	end -- if not turbine then

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
		turbineFlowRate = math.ceil(newTurbineFlowRate)
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
	--convert the number into a whole number for display purposes
	local wholeFlowRate = nil
	wholeFlowRate, decimal = math.modf(turbineFlowRate)

	print{"  Flow",22,3,monitorIndex}
	print{"<      >",22,4,monitorIndex}
	print{wholeFlowRate,23,4,monitorIndex}
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

	local curStoredEnergyPercent = getTurbineStoredEnergyBufferPercent(turbine)
	if curStoredEnergyPercent > 4 then
		drawBar(1, 8, math.floor(26*curStoredEnergyPercent/100)+2, 8, colors.yellow,monitorIndex)
	elseif curStoredEnergyPercent > 0 then
		drawPixel(1, 8, colors.yellow, monitorIndex)
	end -- if curStoredEnergyPercent > 4 then

	print{"Energy Buffer",1,7,monitorIndex}
	print{curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+2),7,monitorIndex}
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

	printLog("Called as turbineStatus(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")

	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitor["..monitorIndex.."] in turbineStatus() is not a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbine["..turbineIndex.."] in turbineStatus() is NOT a valid Big Turbine.")
		return -- Invalid turbineIndex
	else
		printLog("turbine["..turbineIndex.."] in turbineStatus() is a valid Big Turbine.")
	end

	local width, height = monitor.getSize()
	local turbineStatus = ""

	if turbine.getConnected() then
		printLog("turbine["..turbineIndex.."] in turbineStatus() is connected.")
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
		printLog("turbine["..turbineIndex.."] in turbineStatus() is NOT connected.")
		turbineStatus = "DISCONNECTED"
		monitor.setTextColor(colors.red)
	end -- if turbine.getConnected() then

	print{turbineStatus, width - string.len(turbineStatus) - 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)
end -- function function turbineStatus(turbineIndex, monitorIndex)


-- Maintain Turbine flow rate at 900 or 1,800 RPM
local function flowRateControl(turbineIndex)
	printLog("Called as flowRateControl(turbineIndex="..turbineIndex..").")

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbine["..turbineIndex.."] in flowRateControl() is NOT a valid Big Turbine.")
		return -- Invalid turbineIndex
	else
		printLog("turbine["..turbineIndex.."] in flowRateControl() is a valid Big Turbine.")

		if turbine.getConnected() then
			printLog("turbine["..turbineIndex.."] in turbineStatus() is connected.")
		else
			printLog("turbine["..turbineIndex.."] in turbineStatus() is NOT connected.")
		end -- if turbine.getConnected() then
	end -- if not turbine then

	-- No point modifying control rod levels for temperature if the turbine is offline
	if turbine.getActive() then
		printLog("turbine["..turbineIndex.."] in flowRateControl() is active.")

		local flowRate = turbine.getFluidFlowRate()
		local flowRateUserMax = math.ceil(turbine.getFluidFlowRateMax())
		local rotorSpeed = math.ceil(turbine.getRotorSpeed())
		local newFlowRate = 0

		-- If we're not at max flow-rate and an optimal RPM, let's do something
		-- also don't do anything if the current flow rate hasn't caught up to the user defined flow rate maximum
		if (((rotorSpeed % 900) ~= 0) and (flowRate ~= 2000) and (flowRate == flowRateUserMax))
			or (flowRate == 0) then
			-- Make sure we are not going too fast
			--changed by Mechaet
			if rotorSpeed > turbineBaseSpeed then
				newFlowRate = flowRateUserMax - flowRateAdjustAmount
			-- Make sure we're not going too slow
			--changed by Mechaet
			elseif rotorSpeed < turbineBaseSpeed then
				newFlowRate = flowRateUserMax + flowRateAdjustAmount
			-- We're not at optimal RPM or flow-rate and we're not out-of-bounds
			else
				return
			end -- if rotorSpeed > turbineBaseSpeed then

			-- Check bounds [0,2000]
			if newFlowRate > 2000 then
				newFlowRate = 2000
			elseif newFlowRate < 0 then
				newFlowRate = 25 -- Don't go to zero, might as well power off
			end -- if newFlowRate > 2000 then

			turbine.setFluidFlowRateMax(newFlowRate)
		end -- if ((rotorSpeed % 900) ~= 0) and (flowRate ~= 2000) and (flowRate == flowRateUserMax) then
	else
		printLog("turbine["..turbineIndex.."] in flowRateControl() is NOT active.")
	end -- if turbine.getActive() then
end -- function flowRateControl(turbineIndex)


function main()
	-- Load reactor parameters and initialize systems
	loadReactorOptions()

	-- Get our initial list of connected monitors and reactors
	-- and initialize every cycle in case the connected devices change
	findMonitors()
	findReactors()
	findTurbines()

	while not finished do
		local reactor = nil
		local monitorIndex = 1

		-- For multiple reactors/monitors, monitor #1 is reserved for overall status
		-- or for multiple reactors/turbines and only one monitor
		if (((#reactorList + #turbineList) > 1) and (#monitorList >= 1)) then
			local monitor = nil
			monitor = monitorList[monitorIndex]
			if not monitor then
				printLog("monitor["..monitorIndex.."] in main() is not a valid monitor.")
				return -- Invalid monitorIndex
			end

			clearMonitor(progName.." "..progVer, monitorIndex) -- Clear monitor and draw borders
			printCentered(progName.." "..progVer, 1, monitorIndex)
			displayAllStatus()
			monitorIndex = 2 -- Next monitor, #1 is reserved for overall status
		end

		-- Iterate through reactors, continue to run even if not enough monitors are connected
		for reactorIndex = 1, #reactorList do
			local monitor = nil
			local reactorMonitorIndex = monitorIndex + reactorIndex - 1 -- reactorIndex starts at 1

			printLog("Attempting to display reactor["..reactorIndex.."] on monitor["..reactorMonitorIndex.."]...")

			reactor = reactorList[reactorIndex]
			if not reactor then
				printLog("reactor["..reactorIndex.."] in main() is NOT a valid Big Reactor.")
				break -- Invalid reactorIndex
			else
				printLog("reactor["..reactorIndex.."] in main() is a valid Big Reactor.")
			end --  if not reactor then

			-- Only attempt to assign a monitor if we have a monitor for this reactor
			if (#reactorList ~= 1) and (reactorMonitorIndex <= #monitorList) then
				printLog("Displaying reactor["..reactorIndex.."] on monitor["..reactorMonitorIndex.."].")
				monitor = monitorList[reactorMonitorIndex]

				if not monitor then
					printLog("monitor["..reactorMonitorIndex.."] in main() is not a valid monitor.")
				else
					clearMonitor(progName, reactorMonitorIndex) -- Clear monitor and draw borders
					printCentered(progName, 1, reactorMonitorIndex)

					-- Display reactor status, includes "Disconnected" but found reactors
					reactorStatus{reactorIndex, reactorMonitorIndex}

					-- Draw the borders and bars for the current reactor on the current monitor
					displayReactorBars{reactorIndex, reactorMonitorIndex}
				end -- if not monitor
			else
				printLog("You may want "..(#reactorList + #turbineList + 1).." monitors for your "..#reactorList.." connected reactors and "..#turbineList.." connected turbines.")
			end -- if (#reactorList ~= 1) and (reactorMonitorIndex < #monitorList) then

			if reactor.getConnected() then
				printLog("reactor["..reactorIndex.."] is connected.")
				local curStoredEnergyPercent = getReactorStoredEnergyBufferPercent(reactor)

				-- Shutdown reactor if current stored energy % is >= desired level, otherwise activate
				-- First pass will have curStoredEnergyPercent=0 until displayBars() is run once
				if curStoredEnergyPercent >= maxStoredEnergyPercent then
					reactor.setActive(false)
				-- Do not auto-start the reactor if it was manually powered off (autoStart=false)
				elseif (curStoredEnergyPercent <= minStoredEnergyPercent) and (autoStart[reactorIndex] == true) then
					reactor.setActive(true)
				end -- if curStoredEnergyPercent >= maxStoredEnergyPercent then

				-- Don't try to auto-adjust control rods if manual control is requested
				if not reactorRodOverride then
					temperatureControl(reactorIndex)
				end -- if not reactorRodOverride then
			else
				printLog("reactor["..reactorIndex.."] is NOT connected.")
			end -- if reactor.getConnected() then
		end -- for reactorIndex = 1, #reactorList do

		-- Monitors for turbines start after turbineMonitorOffset
		for turbineIndex = 1, #turbineList do
			local monitor = nil
			local turbineMonitorIndex = turbineIndex + turbineMonitorOffset

			printLog("Attempting to display turbine["..turbineIndex.."] on monitor["..turbineMonitorIndex.."]...")

			-- Only attempt to assign a monitor if we found a monitor for this turbine
			if (#reactorList ~= 1) and (turbineMonitorIndex <= #monitorList) then
				printLog("Displaying turbine["..turbineIndex.."] on monitor["..turbineMonitorIndex.."].")
				monitor = monitorList[turbineMonitorIndex]
				if not monitor then
					printLog("monitor["..turbineMonitorIndex.."] in main() is not a valid monitor.")
				else
					clearMonitor(progName, turbineMonitorIndex) -- Clear monitor and draw borders
					printCentered(progName, 1, turbineMonitorIndex)

					-- Display turbine status, includes "Disconnected" but found turbines
					turbineStatus(turbineIndex, turbineMonitorIndex)

					-- Draw the borders and bars for the current turbine on the current monitor
					displayTurbineBars(turbineIndex, turbineMonitorIndex)
				end -- if not monitor
			else
				printLog("You may want "..(#reactorList + #turbineList + 1).." monitors for your "..#reactorList.." connected reactors and "..#turbineList.." connected turbines.")
			end -- if (#reactorList ~= 1) and (turbineMonitorIndex < #monitorList) then

			turbine = turbineList[turbineIndex]
			if not turbine then
				printLog("turbine["..turbineIndex.."] in main() is NOT a valid Big Turbine.")
				break -- Invalid turbineIndex
			else
				printLog("turbine["..turbineIndex.."] in main() is a valid Big Turbine.")
			end -- if not turbine then

			if turbine.getConnected() then
				printLog("turbine["..turbineIndex.."] is connected.")

				if not turbineFlowRateOverride[turbineIndex] then
					flowRateControl(turbineIndex)
				end -- if not turbineFlowRateOverride[turbineIndex] then
			else
				printLog("turbine["..turbineIndex.."] is NOT connected.")
			end -- if turbine.getConnected() then
		end -- for reactorIndex = 1, #reactorList do

		sleep(loopTime) -- Sleep
		saveReactorOptions()
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
