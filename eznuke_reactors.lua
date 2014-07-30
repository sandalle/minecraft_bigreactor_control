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
				--initialize the default table
				_G[reactorNames[reactorIndex]] = {}
				_G[reactorNames[reactorIndex]]["ReactorOptions"] = {}
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"] = 80
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"] = 0
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"] = true
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["activeCooled"] = true
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"] = 1400 --set for passive-cooled, the active-cooled subroutine will correct it
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"] = 1000
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] = false
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorName"] = reactorNames[reactorIndex]
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = false
				if reactor.getConnected() then
					printLog("reactor["..reactorIndex.."] in findReactors() is connected.")
				else
					printLog("reactor["..reactorIndex.."] in findReactors() is NOT connected.")
					return -- Disconnected reactor
				end
			end
			
			--failsafe
			local tempTable = _G[reactorNames[reactorIndex]]
			
			--check to make sure we get a valid config
			if (config.load(reactorNames[reactorIndex]..".options")) ~= nil then
				tempTable = config.load(reactorNames[reactorIndex]..".options")
			else
				--if we don't have a valid config from disk, make a valid config
				config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
			end
			
			--load values from tempTable, checking for nil values along the way
			if tempTable["ReactorOptions"]["baseControlRodLevel"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"] = tempTable["ReactorOptions"]["baseControlRodLevel"]
			end
			
			if tempTable["ReactorOptions"]["lastTempPoll"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"] = tempTable["ReactorOptions"]["lastTempPoll"]
			end
			
			if tempTable["ReactorOptions"]["autoStart"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"] = tempTable["ReactorOptions"]["autoStart"]
			end
			
			if tempTable["ReactorOptions"]["activeCooled"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["activeCooled"] = tempTable["ReactorOptions"]["activeCooled"]
			end
			
			if tempTable["ReactorOptions"]["reactorMaxTemp"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"] = tempTable["ReactorOptions"]["reactorMaxTemp"]
			end
			
			if tempTable["ReactorOptions"]["reactorMinTemp"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"] = tempTable["ReactorOptions"]["reactorMinTemp"]
			end
			
			if tempTable["ReactorOptions"]["rodOverride"] ~= nil then
				printLog("Got value from config file for Rod Override, the value is: "..tempTable["ReactorOptions"]["rodOverride"].." EOL")
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] = tempTable["ReactorOptions"]["rodOverride"]
			end
			
			if tempTable["ReactorOptions"]["reactorName"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorName"] = tempTable["ReactorOptions"]["reactorName"]
			end
			
			if tempTable["ReactorOptions"]["reactorCruising"] ~= nil then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = tempTable["ReactorOptions"]["reactorCruising"]
			end
			
			--stricter typing, let's set these puppies up with the right type of value.
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"] = tonumber(_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"])
			
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"] = tonumber(_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"])
			
			if (tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"]) == "true") then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"] = true
			else
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["autoStart"] = false
			end
			
			if (tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["activeCooled"]) == "true") then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["activeCooled"] = true
			else
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["activeCooled"] = false
			end
			
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"] = tonumber(_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"])
			
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"] = tonumber(_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"])
			
			if (tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"]) == "true") then
				printLog("Setting Rod Override for  "..reactorNames[reactorIndex].." to true because value was ".._G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"].." EOL")
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] = true
			else
				printLog("Setting Rod Override for  "..reactorNames[reactorIndex].." to false because value was ".._G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"].." EOL")
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] = false
			end
			
			if (tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"]) == "true") then
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = true
			else
				_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = false
			end
						
			--save one more time, in case we didn't have a complete config file before
			config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
		end -- for reactorIndex = 1, #newReactorList do
	end -- if #newReactorList == 0 then

	-- Overwrite old reactor list with the now updated list
	reactorList = newReactorList

	-- Start turbine monitor offset after reactors get monitors
	-- This assumes that there is a monitor for each turbine and reactor, plus the overall monitor display
	turbineMonitorOffset = #reactorList + 1 -- #turbineList will start at "1" if turbines found and move us just beyond #reactorList and status monitor range

	printLog("Found "..#reactorList.." reactor(s) in findReactors().")
	printLog("Set turbineMonitorOffset to "..turbineMonitorOffset.." in findReactors().")
end -- function findReactors()

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

local function reactorCruise(cruiseMaxTemp, cruiseMinTemp, reactorIndex)
	printLog("Called as reactorCruise(cruiseMaxTemp="..cruiseMaxTemp..",cruiseMinTemp="..cruiseMinTemp..",lastPolledTemp=".._G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"]..",reactorIndex="..reactorIndex..").")
	
	--sanitization
	local lastPolledTemp = tonumber(_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"])
	cruiseMaxTemp = tonumber(cruiseMaxTemp)
	cruiseMinTemp = tonumber(cruiseMinTemp)
	
	if ((lastPolledTemp < cruiseMaxTemp) and (lastPolledTemp > cruiseMinTemp)) then
		local reactor = nil
		reactor = reactorList[reactorIndex]
		if not reactor then
			printLog("reactor["..reactorIndex.."] in reactorCruise(cruiseMaxTemp="..cruiseMaxTemp..",cruiseMinTemp="..cruiseMinTemp..",lastPolledTemp="..lastPolledTemp..",reactorIndex="..reactorIndex..") is NOT a valid Big Reactor.")
			return -- Invalid reactorIndex
		else
			printLog("reactor["..reactorIndex.."] in reactorCruise(cruiseMaxTemp="..cruiseMaxTemp..",cruiseMinTemp="..cruiseMinTemp..",lastPolledTemp="..lastPolledTemp..",reactorIndex="..reactorIndex..") is a valid Big Reactor.")
			if reactor.getConnected() then
				printLog("reactor["..reactorIndex.."] in reactorCruise(cruiseMaxTemp="..cruiseMaxTemp..",cruiseMinTemp="..cruiseMinTemp..",lastPolledTemp="..lastPolledTemp..",reactorIndex="..reactorIndex..") is connected.")
			else
				printLog("reactor["..reactorIndex.."] in reactorCruise(cruiseMaxTemp="..cruiseMaxTemp..",cruiseMinTemp="..cruiseMinTemp..",lastPolledTemp="..lastPolledTemp..",reactorIndex="..reactorIndex..") is NOT connected.")
				return -- Disconnected reactor
			end -- if reactor.getConnected() then
		end -- if not reactor then

		local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
		local reactorTemp = math.ceil(reactor.getFuelTemperature())
		_G[reactorNames[reactorIndex]]["ReactorOptions"]["baseControlRodLevel"] = rodPercentage
		
		if ((reactorTemp < cruiseMaxTemp) and (reactorTemp > cruiseMinTemp)) then
			if (reactorTemp < lastPolledTemp) then
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
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = false
		end -- if ((reactorTemp < cruiseMaxTemp) and (reactorTemp > cruiseMinTemp)) then
	else
		--I don't know how we'd get here, but let's turn the cruise mode off
		_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = false
	end -- if ((lastPolledTemp < cruiseMaxTemp) and (lastPolledTemp > cruiseMinTemp)) then
	_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"] = reactorTemp
	_G[reactorNames[reactorIndex]]["ReactorOptions"]["activeCooled"] = true
	_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"] = cruiseMaxTemp
	_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"] = cruiseMinTemp
	config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
end -- function reactorCruise(cruiseMaxTemp, cruiseMinTemp, lastPolledTemp, reactorIndex)

-- Modify reactor control rod levels to keep temperature with defined parameters, but
-- wait an in-game half-hour for the temperature to stabalize before modifying again
local function temperatureControl(reactorIndex)
	printLog("Called as temperatureControl(reactorIndex="..reactorIndex..")")

	local reactor = nil
	reactor = reactorList[reactorIndex]
	if not reactor then
		printLog("reactor["..reactorIndex.."] in temperatureControl(reactorIndex="..reactorIndex..") is NOT a valid Big Reactor.")
		return -- Invalid reactorIndex
	else
		printLog("reactor["..reactorIndex.."] in temperatureControl(reactorIndex="..reactorIndex..") is a valid Big Reactor.")

		if reactor.getConnected() then
			printLog("reactor["..reactorIndex.."] in temperatureControl(reactorIndex="..reactorIndex..") is connected.")
		else
			printLog("reactor["..reactorIndex.."] in temperatureControl(reactorIndex="..reactorIndex..") is NOT connected.")
			return -- Disconnected reactor
		end -- if reactor.getConnected() then
	end

	local reactorNum = reactorIndex
	local rodPercentage = math.ceil(reactor.getControlRodLevel(0))
	local reactorTemp = math.ceil(reactor.getFuelTemperature())
	local localMinReactorTemp, localMaxReactorTemp = _G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"], _G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"]

	--bypass if the reactor itself is set to not be auto-controlled
	if ((not _G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"]) or (_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] == "false")) then
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
			else
				localMinReactorTemp = _G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMinTemp"]
				localMaxReactorTemp = _G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorMaxTemp"]
			end
			local lastTempPoll = _G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"]
			if _G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] then
				--let's bypass all this math and hit the much-more-subtle cruise feature
				--printLog("min: "..localMinReactorTemp..", max: "..localMaxReactorTemp..", lasttemp: "..lastTempPoll..", ri: "..reactorIndex.."  EOL")
				reactorCruise(localMaxReactorTemp, localMinReactorTemp, reactorIndex)
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
							diffAmount = (round(diffAmount/10, 0))/5
							controlRodAdjustAmount = diffAmount
							if (rodPercentage + controlRodAdjustAmount) > 99 then
								reactor.setAllControlRodLevels(99)
							else
								reactor.setAllControlRodLevels(rodPercentage + controlRodAdjustAmount)
							end
						end --if ((reactorTemp - lastTempPoll) > 100) then
					elseif (reactorTemp == lastTempPoll) then
						--temperature has stagnated, kick it very lightly
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
							diffAmount = (round(diffAmount/10, 0))/5
							controlRodAdjustAmount = diffAmount
							if (rodPercentage - controlRodAdjustAmount) < 0 then
								reactor.setAllControlRodLevels(0)
							else
								reactor.setAllControlRodLevels(rodPercentage - controlRodAdjustAmount)
							end
						end --if ((lastTempPoll - reactorTemp) > 100) then
					elseif (reactorTemp == lastTempPoll) then
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

				if ((reactorTemp > localMinReactorTemp) and (reactorTemp < localMaxReactorTemp)) then
					--engage cruise mode
					_G[reactorNames[reactorIndex]]["ReactorOptions"]["reactorCruising"] = true
				end -- if ((reactorTemp > localMinReactorTemp) and (reactorTemp < localMaxReactorTemp)) then
			end -- if reactorCruising then
			--always set this number
			_G[reactorNames[reactorIndex]]["ReactorOptions"]["lastTempPoll"] = reactorTemp
			config.save(reactorNames[reactorIndex]..".options", _G[reactorNames[reactorIndex]])
		end -- if reactor.getActive() then
	else
		printLog("Bypassed temperature control due to rodOverride being "..tostring(_G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"]).." EOL")
	end -- if not _G[reactorNames[reactorIndex]]["ReactorOptions"]["rodOverride"] then
end -- function temperatureControl(reactorIndex)
