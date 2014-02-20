--[[
	Program name: Lolmer's EZ-NUKE reactor control system
	Version: v0.2.1
	Programmer: Lolmer
	Last update: 2014-02-18
	Pastebin: http://pastebin.com/fguScPBQ

	Description: 
	This program controls a Big Reactors nuclear reactor
	in Minecraft with a Computercraft computer, using Computercraft's
	own wired modem connected to the reactors computer control port.

	Advanced Monitor size is X: 29, Y: 12 with a 3x2 size

	Resources:
	This script is available from:
		http://pastebin.com/fguScPBQ
		https://github.com/sandalle/minecraft_bigreactor_control
	Startup script is available from:
		http://pastebin.com/ZTMzRLez
		https://github.com/sandalle/minecraft_bigreactor_control
	Other reactor control which I based my program on:
		http://pastebin.com/aMAu4X5J (ScatmanJohn)
		http://pastebin.com/HjUVNDau (version ScatmanJohn based his on)
	FC API, required:
		http://pastebin.com/A9hcbZWe
	A simpler Big Reactor control is available from:
		http://pastebin.com/tFkhQLYn (IronClaymore)

	Reactor Computer Port API: http://wiki.technicpack.net/index.php?title=Reactor_Computer_Port
	Computercraft API: http://computercraft.info/wiki/Category:APIs

	ChangeLog:
	0.2.1 - Lower/raise only the hottest/coldest Control Rod while trying to control the reactor temperature.
		"<" Rod Control buttons was off by one (to the left)
	0.2.0 - Lolmer Edition :)
		Add min/max stored energy percentage (default is 15%/85%), configurable via ReactorOptions file.
		No reason to keep burning fuel if our power output is going nowhere. :)
		Use variables variable for the title and version.
		Try to keep the temperature between configured values (default is 850^C-950^C)
		Add Waste and number of Control/Fuel Rods to displayBards()

	TODO:
		Add Fuel consumption metric to display - No such API. :(
		Support multiple reactors and multiple monitors.
		- If one reactor, display same output to all monitors
		- If multiple reactors, require a monitor for each reactor and display only that reactor on a monitor
		Offline mode needs to override temperature/energy buffer code.
		Add support for wireless modems, see http://computercraft.info/wiki/Modem_%28API%29
]]--

print("Initializing program...");

if not os.loadAPI("FC_API") then
    error("Missing FC_API")
end
--Done loading API

function wrapThis(thing)
        local wrapped, f = nil, 0
        while wrapped == nil and f <= 100 do
                wrapped = peripheral.wrap(thing.."_"..f)
                f = f + 1
        end
 
        if wrapped == nil then
                side = getDeviceSide(thing)
                if side ~= nil then
                        return peripheral.wrap(side)
                else
                        return nil
                end
        else
                return wrapped
        end
end

local function print(str, x, y)
	term.setCursorPos(x, y)
	term.write(str)	
end
-- Done helper functions

-- Then initialize the monitor
local monitor = wrapThis("monitor")
local monitorX, monitorY = monitor.getSize()
if monitorX ~= 29 or monitorY ~= 12 then
	error("Monitor is the wrong size! Needs to be 3x2.")
end

if  monitor then
	--error("No Monitor Attached")
	term.clear()
	term.setCursorPos(1,1)
	term.write("Display redirected to Monitor")
	term.redirect(monitor)
end

-- Let's connect to the reactor peripheral
local reactor = wrapThis("BigReactors-Reactor")
if reactor == nil then
	error("Can't find reactor.")
end

-- Some global variables
local progVer = "0.2.1"
local progName = "EZ-NUKE ".. progVer
local xClick, yClick = 0,0
local loopTime = 1
local adjustAmount = 5
local dataLogging = false
local baseControlRodLevel = nil
local numRods = reactor.getNumberOfControlRods() - 1 -- Call once so that we don't have to keep calling it
local curStoredEnergyPercent = 0 -- Current stored energy in %
local rodPercentage = 0 -- For checking rod control level oustide of Display Bars
local rodLastUpdate = os.time() -- Last timestamp update for rod control level update
local reactorTemp = 0 -- For checking reactor temperature outside of Display Bars
local minStoredEnergyPercent = nil -- Max energy % to store before activate
local maxStoredEnergyPercent = nil -- Max energy % to store before shutdown
local minReactorTemp = nil -- Minimum reactor temperature (^C) to maintain
local maxReactorTemp = nil -- Maximum reactor temperature (^C) to maintain

--Load saved data if file exists
file = fs.open("ReactorOptions", "r") -- See http://computercraft.info/wiki/Fs.open
if file then
	baseControlRodLevel = file.readLine()
	-- The following values were added by Lolmer
	minStoredEnergyPercent = file.readLine()
	maxStoredEnergyPercent = file.readLine()
	minReactorTemp = file.readLine()
	maxReactorTemp = file.readLine()

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

	file.close()
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

--Save some stuff
local function save()
	file = fs.open("ReactorOptions", "w")
	file.writeLine(rodPercentage)
	-- The following values were added by Lolmer
	file.writeLine(minStoredEnergyPercent)
	file.writeLine(maxStoredEnergyPercent)
	file.writeLine(minReactorTemp)
	file.writeLine(maxReactorTemp)
	file.close()
end

reactor.setAllControlRodLevels(baseControlRodLevel)

FC_API.clearMonitor(progName)

--Done initializing

local function displayBars()
	-- Draw some cool lines
	term.setBackgroundColor(colors.black)
	local width, height = term.getSize()

	for i=3, 5 do
		term.setCursorPos(22, i)
		term.write("|")
	end
	
	for i=1, width do
		term.setCursorPos(i, 2)
		term.write("-")
	end
	
	for i=1, width do
		term.setCursorPos(i, 6)
		term.write("-")
	end
	
	-- Draw some text
	
	local fuelString = "Fuel: "
	local tempString = "Temp: "
	local energyBufferString = "Producing: "
	
	local padding = math.max(string.len(fuelString), string.len(tempString),string.len(energyBufferString))
	
	local fuelPercentage = math.ceil(reactor.getFuelAmount()/reactor.getFuelAmountMax()*100)
	print(fuelString,2,3)
	print(fuelPercentage.." %",padding+2,3)
	
	local energyBuffer = reactor.getEnergyProducedLastTick()
	print(energyBufferString,2,4)
	print(math.ceil(energyBuffer).."RF/t",padding+2,4)
	
	local reactorTemp = reactor.getTemperature()
	print(tempString,2,5)
	print(reactorTemp.." C",padding+2,5)
	
	-- Decrease rod button: 22X, 4Y
	-- Increase rod button: 28X, 4Y
	
	local rodTotal = 0
	for i=0, numRods do
		rodTotal = rodTotal + reactor.getControlRodLevel(i)
	end
	rodPercentage = math.ceil(rodTotal/(numRods+1))
	
	print("Control",23,3)
	print("<     >",23,4)
	print(rodPercentage,25,4)
	print("percent",23,5)
	
	if (xClick == 23  and yClick == 4) then
		--Decrease rod level by amount
		newRodPercentage = rodPercentage - adjustAmount
		if newRodPercentage < 0 then
			newRodPercentage = 0
		end

		xClick, yClick = 0,0
		reactor.setAllControlRodLevels(newRodPercentage)
	end
	
	if (xClick == 28  and yClick == 4) then
		--Increase rod level by amount
		newRodPercentage = rodPercentage + adjustAmount
		if newRodPercentage > 100 then
			newRodPercentage = 100
		end
		xClick, yClick = 0,0
		reactor.setAllControlRodLevels(newRodPercentage)
	end

	local energyBufferStorage = reactor.getEnergyStored()
	curStoredEnergyPercent = math.floor(energyBufferStorage/10000000*100)
	paintutils.drawLine(2, 8, 28, 8, colors.gray)
	if curStoredEnergyPercent > 4 then
		paintutils.drawLine(2, 8, math.floor(26*curStoredEnergyPercent/100)+2, 8, colors.yellow)
	elseif curStoredEnergyPercent > 0 then
		paintutils.drawPixel(2,8,colors.yellow)
	end
	term.setBackgroundColor(colors.black)
	print("Energy Buffer",2,7)
	print(curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+3),7)
	print("%",28,7)
	term.setBackgroundColor(colors.black)

	local hottestControlRod = getHottestControlRod()
	local coldestControlRod = getColdestControlRod()
	print("Hottest Rod: "..(hottestControlRod + 1),2,10) -- numRods index starts at 0
	print(reactor.getTemperature(hottestControlRod).."^C".." "..reactor.getControlRodLevel(hottestControlRod).."%",width-(string.len(reactor.getWasteAmount())+8),10)
	print("Coldest Rod: "..(coldestControlRod + 1),2,11) -- numRods index starts at 0
	print(reactor.getTemperature(coldestControlRod).."^C".." "..reactor.getControlRodLevel(coldestControlRod).."%",width-(string.len(reactor.getWasteAmount())+8),11)
	print("Fuel Rods: "..(numRods + 1),2,12) -- numRods index starts at 0
	print("Waste: "..reactor.getWasteAmount().." mB",width-(string.len(reactor.getWasteAmount())+10),12)
end


function reactorStatus()
	local width, height = term.getSize()
	local reactorStatus = ""
	if reactor.getConnected() then
		if reactor.getActive() then
			reactorStatus = "ONLINE"
			term.setTextColor(colors.green)
		else
			if autoStart then
				reactor.setActive(true)
			end
			reactorStatus = "OFFLINE"
			term.setTextColor(colors.red)
		end
		
		if(xClick >= (width - string.len(reactorStatus) - 1) and xClick <= (width-1)) then
			if yClick == 1 and not autoStart then
				reactor.setActive(not reactor.getActive())
				xClick, yClick = 0,0
			end
		end	
		
	else
		reactorStatus = "DISCONNECTED"
		term.setTextColor(colors.red)
	end	
	
	print(reactorStatus, width - string.len(reactorStatus) - 1, 1)
	term.setTextColor(colors.white)
end

-- This function was added by Lolmer
-- Return the index of the hottest Control Rod
function getColdestControlRod()
	local coldestRod = 0

	for rodIndex=0, numRods do
		if reactor.getTemperature(rodIndex) < reactor.getTemperature(coldestRod) then
			coldestRod = rodIndex
		end
	end

	return coldestRod
end

-- This function was added by Lolmer
-- Return the index of the hottest Control Rod
function getHottestControlRod()
	local hottestRod = 0

	for rodIndex=0, numRods do
		if reactor.getTemperature(rodIndex) > reactor.getTemperature(hottestRod) then
			hottestRod = rodIndex
		end
	end

	return hottestRod
end

-- This function was added by Lolmer
-- Modify reactor control rod levels to keep temperature with defined parameters, but
-- wait an in-game half-hour for the temperature to stabalize before modifying again
function temperatureControl()
	local rodTimeDiff = 0

	-- No point modifying control rod levels for temperature if the reactor is offline
	if reactor.getActive() then
		rodTimeDiff = math.abs(os.time() - rodLastUpdate) -- Difference in rod control level update timestamp and now

		-- Don't bring us to 100, that's effectively a shutdown
		if (reactorTemp > maxReactorTemp) and (rodPercentage < 99) and (rodTimeDiff > 0.2) then
			-- If more than double our maximum temperature, incrase rodPercentage faster
			if reactorTemp > (2 * maxReactorTemp) then
				reactor.setControlRodLevel(getHottestControlRod(), rodPercentage + 10)
			else
				reactor.setControlRodLevel(getHottestControlRod(), rodPercentage + 1)
			end

			rodLastUpdate = os.time() -- Last rod control update is now :)
		elseif (reactorTemp < minReactorTemp) and (rodTimeDiff > 0.2) then
			-- If less than half our minimum temperature, decrease rodPercentage faster
			if reactorTemp < (minReactorTemp / 2) then
				reactor.setControlRodLevel(getColdestControlRod(), rodPercentage - 10)
			else
				reactor.setControlRodLevel(getColdestControlRod(), rodPercentage - 1)
			end
			rodLastUpdate = os.time() -- Last rod control update is now :)
		end
	end
end


function main()
	while not finished do
		FC_API.clearMonitor(progName)

		reactorStatus()

		if reactor.getConnected() then
			-- Shutdown reactor if current stored energy % is >= desired level, otherwise activate	
			-- First pass will have curStoredEnergyPercent=0 until displayBars() is run once
			if curStoredEnergyPercent >= maxStoredEnergyPercent then
				reactor.setActive(false)
			elseif curStoredEnergyPercent <= minStoredEnergyPercent then
				reactor.setActive(true)
			end

			temperatureControl()
			displayBars()
			sleep(loopTime)
			save()
		end
	end
end

function eventHandler()
	while not finished do
		event, arg1, arg2, arg3 = os.pullEvent()
		
		if event == "monitor_touch" then
			xClick, yClick = math.floor(arg2), math.floor(arg3)
			-- Draw debug stuff
			--print("Monitor touch X: "..xClick.." Y: "..yClick, 1, 10)
		elseif event == "mouse_click" and not monitor then
			xClick, yClick = math.floor(arg2), math.floor(arg3)
			--print("Mouse click X: "..xClick.." Y: "..yClick, 1, 11)
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

while not finished do
	parallel.waitForAny(eventHandler, main)
	sleep(loopTime)
end

term.clear()
term.setCursorPos(1,1)
FC_API.restoreNativeTerminal()
term.clear()
term.setCursorPos(1,1)

