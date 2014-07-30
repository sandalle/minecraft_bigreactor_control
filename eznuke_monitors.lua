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
		printLog("monitor["..monitorIndex.."] in print() is NOT a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in printCentered() is NOT a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in printLeft() is NOT a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in printRight() is NOT a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in clearMonitor(printString="..printString..",monitorIndex="..monitorIndex..") is NOT a valid monitor.")
		return -- Invalid monitorIndex
	end

	local gap = 2
	monitor.clear()
	local width, height = monitor.getSize()
	monitor.setTextScale(1.0) -- Make sure scale is correct

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

-- Draw a line across the entire x-axis
local function drawLine(yPos, monitorIndex)
	local monitor = nil
	monitor = monitorList[monitorIndex]

	if not monitor then
		printLog("monitor["..monitorIndex.."] in drawLine() is NOT a valid monitor.")
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
		printLog("monitor["..monitorIndex.."] in drawBar() is NOT a valid monitor.")
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

	if not monitor then
		printLog("monitor["..monitorIndex.."] in drawPixel() is NOT a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- PaintUtils only outputs to term., not monitor.
	-- See http://www.computercraft.info/forums2/index.php?/topic/15540-paintutils-on-a-monitor/
	term.redirect(monitor)
	paintutils.drawPixel(xPos, yPos, color)
	monitor.setBackgroundColor(colors.black) -- PaintUtils doesn't restore the color
	term.native()
end -- function drawPixel(xPos, yPos, color, monitorIndex)

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
				printLog("monitorList["..monitorIndex.."] in findMonitors() is NOT a valid monitor.")
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

	printLog("Found "..#monitorList.." monitor(s) in findMonitors().")
end -- local function findMonitors()

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
		printLog("monitor["..monitorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactor["..reactorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT a valid Big Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("reactor["..reactorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is a valid Big Reactor.")
		if reactor.getConnected() then
			printLog("reactor["..reactorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is connected.")
		else
			printLog("reactor["..reactorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT connected.")
			return -- Disconnected reactor
		end -- if reactor.getConnected() then
	end -- if not reactor then

	-- Draw border lines
	local width, height = monitor.getSize()
	printLog("Size of monitor is "..width.."w x"..height.."h in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..")")

	for i=3, 5 do
		monitor.setCursorPos(22, i)
		monitor.write("|")
	end

	drawLine(2, monitorIndex)
	drawLine(6, monitorIndex)

	-- Draw some text
	local fuelString = "Fuel: "
	local tempString = "Temp: "
	local energyBufferString = ""

	if reactor.isActivelyCooled() then
		energyBufferString = "Steam: "
	else
		energyBufferString = "Energy: "
	end

	local padding = math.max(string.len(fuelString), string.len(tempString), string.len(energyBufferString))

	local fuelPercentage = round(reactor.getFuelAmount()/reactor.getFuelAmountMax()*100,1)
	print{fuelString,2,3,monitorIndex}
	print{fuelPercentage.." %",padding+2,3,monitorIndex}

	local reactorTemp = math.ceil(reactor.getFuelTemperature())
	print{tempString,2,5,monitorIndex}
	print{reactorTemp.." C",padding+2,5,monitorIndex}

	local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
	printLog("Current Rod Percentage for reactor["..reactorIndex.."] is "..rodPercentage.."% in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
	-- Allow controlling Reactor Control Rod Level from GUI
	-- Decrease rod button: 23X, 4Y
	-- Increase rod button: 28X, 4Y
	if (xClick == 23) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		printLog("Decreasing Rod Levels in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
		--Decrease rod level by amount
		newRodPercentage = rodPercentage - (5 * controlRodAdjustAmount)
		if newRodPercentage < 0 then
			newRodPercentage = 0
		end
		sideClick, xClick, yClick = 0, 0, 0

		printLog("Setting reactor["..reactorIndex.."] Rod Levels to "..newRodPercentage.."% in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
		reactor.setAllControlRodLevels(newRodPercentage)
		_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"] = newRodPercentage

		-- Save updated rod percentage
		config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
		rodPercentage = newRodPercentage
	elseif (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		printLog("Increasing Rod Levels in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
		--Increase rod level by amount
		newRodPercentage = rodPercentage + (5 * controlRodAdjustAmount)
		if newRodPercentage > 100 then
			newRodPercentage = 100
		end
		sideClick, xClick, yClick = 0, 0, 0

		printLog("Setting reactor["..reactorIndex.."] Rod Levels to "..newRodPercentage.."% in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
		reactor.setAllControlRodLevels(newRodPercentage)
		_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"] = newRodPercentage
		
		-- Save updated rod percentage
		config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
		rodPercentage = round(newRodPercentage,0)
	else
		printLog("No change to Rod Levels requested by "..progName.." GUI in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	print{"Rod (%)",23,3,monitorIndex}
	print{"<     >",23,4,monitorIndex}
	print{stringTrim(rodPercentage),25,4,monitorIndex}


	-- getEnergyProducedLastTick() is used for both RF/t (passively cooled) and mB/t (actively cooled)
	local energyBuffer = reactor.getEnergyProducedLastTick()
	if reactor.isActivelyCooled() then
		printLog("reactor["..reactorIndex.."] produced "..energyBuffer.." mB last tick in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
	else
		printLog("reactor["..reactorIndex.."] produced "..energyBuffer.." RF last tick in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")
	end

	print{energyBufferString,2,4,monitorIndex}

	-- Actively cooled reactors do not produce energy, only hot fluid mB/t to be used in a turbine
	-- still uses getEnergyProducedLastTick for mB/t of hot fluid generated
	if not reactor.isActivelyCooled() then
		printLog("reactor["..reactorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT an actively cooled reactor.")

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
		printLog("reactor["..reactorIndex.."] in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is an actively cooled reactor.")
		print{math.ceil(energyBuffer).." mB/t",padding+2,4,monitorIndex}
	end -- if not reactor.isActivelyCooled() then

	-- Print rod override status
	local reactorRodOverrideStatus = ""

	print{"Rod Auto-adjust:",2,9,monitorIndex}

	if not _G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] then
		printLog("Reactor Rod Override status is: "..tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"]).." EOL")
		reactorRodOverrideStatus = "Enabled"
		monitor.setTextColor(colors.green)
	else
		printLog("Reactor Rod Override status is: "..tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"]).." EOL")
		reactorRodOverrideStatus = "Disabled"
		monitor.setTextColor(colors.red)
	end -- if not reactorRodOverride then
	printLog("reactorRodOverrideStatus is \""..reactorRodOverrideStatus.."\" in displayReactorBars(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..").")

	print{reactorRodOverrideStatus, width - string.len(reactorRodOverrideStatus) - 1, 9, monitorIndex}
	monitor.setTextColor(colors.white)

	print{"Reactivity: "..math.ceil(reactor.getFuelReactivity()).." %", 2, 10, monitorIndex}
	print{"Fuel: "..round(reactor.getFuelConsumedLastTick(),3).." mB/t", 2, 11, monitorIndex}
	print{"Waste: "..reactor.getWasteAmount().." mB", width-(string.len(reactor.getWasteAmount())+10), 11, monitorIndex}

	monitor.setTextColor(colors.blue)
	printCentered(_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorName"],12,monitorIndex)
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
		printLog("monitor["..monitorIndex.."] in reactorStatus(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current reactor
	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactor["..reactorIndex.."] in reactorStatus(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT a valid Big Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("reactor["..reactorIndex.."] in reactorStatus(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is a valid Big Reactor.")
	end

	local width, height = monitor.getSize()
	local reactorStatus = ""

	if reactor.getConnected() then
		printLog("reactor["..reactorIndex.."] in reactorStatus(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is connected.")

		if reactor.getActive() then
			reactorStatus = "ONLINE"

			-- Set "ONLINE" to blue if the actively cooled reactor is both in cruise mode and online
			if _G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] and reactor.isActivelyCooled() then
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
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"] = reactor.getActive()
				config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
				sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it

				-- If someone offlines the reactor (offline after a status click was detected), then disable autoStart
				if not reactor.getActive() then
					_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"] = false
				end
			end -- if yClick == 1 then
		end -- if (xClick >= (width - string.len(reactorStatus) - 1) and xClick <= (width-1)) and (sideClick == monitorNames[monitorIndex]) then

		-- Allow disabling rod level auto-adjust and only manual rod level control
		if ((xClick > 23 and xClick < 28 and yClick == 4)
				or (xClick > 20 and xClick < 27 and yClick == 9))
				and (sideClick == monitorNames[monitorIndex]) then
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] = not _G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"]
			config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
			sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
		end -- if (xClick > 23) and (xClick < 28) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	else
		printLog("reactor["..reactorIndex.."] in reactorStatus(reactorIndex="..reactorIndex..",monitorIndex="..monitorIndex..") is NOT connected.")
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
		printLog("monitor["..monitorIndex.."] in displayAllStatus() is NOT a valid monitor.")
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

	printCentered("Fuel: "..round(totalReactorFuelConsumed,3).." mB/t", 11, monitorIndex)
	print{"Buffer: "..math.ceil(totalEnergy,3).."/"..totalMaxEnergyStored.." RF", 2, 12, monitorIndex}
end -- function displayAllStatus()


-- Get turbine status
local function displayTurbineBars(turbineIndex, monitorIndex)
	printLog("Called as displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")

	-- Grab current monitor
	local monitor = nil
	monitor = monitorList[monitorIndex]
	if not monitor then
		printLog("monitor["..monitorIndex.."] in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is NOT a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbine["..turbineIndex.."] in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is NOT a valid Big Turbine.")
		return -- Invalid turbineIndex
	else
		printLog("turbine["..turbineIndex.."] in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is a valid Big Turbine.")
		if turbine.getConnected() then
			printLog("turbine["..turbineIndex.."] in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is connected.")
		else
			printLog("turbine["..turbineIndex.."] in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is NOT connected.")
			return -- Disconnected turbine
		end -- if turbine.getConnected() then
	end -- if not turbine then

	--local variable to match the view on the monitor
	local turbineBaseSpeed = tonumber(_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"])

	-- Draw border lines
	local width, height = monitor.getSize()

	for i=3, 6 do
		monitor.setCursorPos(21, i)
		monitor.write("|")
	end

	drawLine(2,monitorIndex)
	drawLine(7,monitorIndex)

	-- Allow controlling Turbine Flow Rate from GUI
	-- Decrease flow rate button: 22X, 4Y
	-- Increase flow rate button: 28X, 4Y
	local turbineFlowRate = tonumber(_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"])
	if (xClick == 22) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		printLog("Decrease to Flow Rate requested by "..progName.." GUI in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")
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
		_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"] = newTurbineFlowRate
		-- Save updated Turbine Flow Rate
		turbineFlowRate = newTurbineFlowRate
		config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
	elseif (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
		printLog("Increase to Flow Rate requested by "..progName.." GUI in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")
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
		_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"] = turbineFlowRate
		config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
	else
		printLog("No change to Flow Rate requested by "..progName.." GUI in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then

	if (xClick == 22) and (yClick == 6) and (sideClick == monitorNames[monitorIndex]) then
		printLog("Decrease to Turbine RPM requested by "..progName.." GUI in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")
		rpmRateAdjustment = 909
		newTurbineBaseSpeed = turbineBaseSpeed - rpmRateAdjustment
		if newTurbineBaseSpeed < 908 then
			newTurbineBaseSpeed = 908
		end
		sideClick, xClick, yClick = 0, 0, 0
		_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"] = newTurbineBaseSpeed
		config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
	elseif (xClick == 29) and (yClick == 6) and (sideClick == monitorNames[monitorIndex]) then
		printLog("Increase to Turbine RPM requested by "..progName.." GUI in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")
		rpmRateAdjustment = 909
		newTurbineBaseSpeed = turbineBaseSpeed + rpmRateAdjustment
		if newTurbineBaseSpeed > 2726 then
			newTurbineBaseSpeed = 2726
		end
		sideClick, xClick, yClick = 0, 0, 0
		_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"] = newTurbineBaseSpeed
		config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
	else
		printLog("No change to Turbine RPM requested by "..progName.." GUI in displayTurbineBars(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..").")
	end -- if (xClick == 29) and (yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
	print{"  mB/t",22,3,monitorIndex}
	print{"<      >",22,4,monitorIndex}
	print{stringTrim(turbineFlowRate),24,4,monitorIndex}
	print{"  RPM",22,5,monitorIndex}
	print{"<      >",22,6,monitorIndex}
	print{stringTrim(tonumber(_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"])),24,6,monitorIndex}
	local rotorSpeedString = "Speed: "
	local energyBufferString = "Energy: "
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
	drawBar(1,9,28,9,colors.gray,monitorIndex)

	local curStoredEnergyPercent = getTurbineStoredEnergyBufferPercent(turbine)
	if curStoredEnergyPercent > 4 then
		drawBar(1, 9, math.floor(26*curStoredEnergyPercent/100)+2, 9, colors.yellow,monitorIndex)
	elseif curStoredEnergyPercent > 0 then
		drawPixel(1, 9, colors.yellow, monitorIndex)
	end -- if curStoredEnergyPercent > 4 then

	print{"Energy Buffer",1,8,monitorIndex}
	print{curStoredEnergyPercent, width-(string.len(curStoredEnergyPercent)+2),8,monitorIndex}
	print{"%",28,8,monitorIndex}

	-- Print rod override status
	local turbineFlowRateOverrideStatus = ""

	print{"Flow Auto-adjust:",2,10,monitorIndex}

	if ((not _G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"]) or (_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] == "false")) then
		turbineFlowRateOverrideStatus = "Enabled"
		monitor.setTextColor(colors.green)
	else
		turbineFlowRateOverrideStatus = "Disabled"
		monitor.setTextColor(colors.red)
	end -- if not reactorRodOverride then

	print{turbineFlowRateOverrideStatus, width - string.len(turbineFlowRateOverrideStatus) - 1, 10, monitorIndex}
	monitor.setTextColor(colors.white)

	monitor.setTextColor(colors.blue)
	printCentered(_G[turbineNames[turbineIndex]]["TurbineOptions"]["turbineName"],12,monitorIndex)
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
		printLog("monitor["..monitorIndex.."] in turbineStatus(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is NOT a valid monitor.")
		return -- Invalid monitorIndex
	end

	-- Grab current turbine
	local turbine = nil
	turbine = turbineList[turbineIndex]
	if not turbine then
		printLog("turbine["..turbineIndex.."] in turbineStatus(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is NOT a valid Big Turbine.")
		return -- Invalid turbineIndex
	else
		printLog("turbine["..turbineIndex.."] in turbineStatus(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is a valid Big Turbine.")
	end

	local width, height = monitor.getSize()
	local turbineStatus = ""

	if turbine.getConnected() then
		printLog("turbine["..turbineIndex.."] in turbineStatus(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is connected.")
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
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["autoStart"] = turbine.getActive()
				config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
				sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
			end -- if yClick == 1 then
		end -- if (xClick >= (width - string.len(turbineStatus) - 1)) and (xClick <= (width-1)) and (sideClick == monitorNames[monitorIndex]) then

		-- Allow disabling/enabling flow rate auto-adjust
		if (xClick > 23 and xClick < 28 and yClick == 4) and (sideClick == monitorNames[monitorIndex]) then
			_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] = true
			sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
		elseif (xClick > 20 and xClick < 27 and yClick == 10) and (sideClick == monitorNames[monitorIndex]) then
			
			if ((_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"]) or (_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] == "true")) then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] = false
			else
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] = true
			end
			sideClick, xClick, yClick = 0, 0, 0 -- Reset click after we register it
		end
		config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])

	else
		printLog("turbine["..turbineIndex.."] in turbineStatus(turbineIndex="..turbineIndex..",monitorIndex="..monitorIndex..") is NOT connected.")
		turbineStatus = "DISCONNECTED"
		monitor.setTextColor(colors.red)
	end -- if turbine.getConnected() then

	print{turbineStatus, width - string.len(turbineStatus) - 1, 1, monitorIndex}
	monitor.setTextColor(colors.white)
end -- function function turbineStatus(turbineIndex, monitorIndex)
