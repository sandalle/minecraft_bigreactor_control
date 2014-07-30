
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
				printLog("turbineList["..turbineIndex.."] in findTurbines() is NOT a valid Big Reactors Turbine.")
				return -- Invalid turbineIndex
			else
			
				_G[turbineNames[turbineIndex]] = {}
				_G[turbineNames[turbineIndex]]["TurbineOptions"] = {}
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastSpeed"] = 0
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"] = 2726
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["autoStart"] = true
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"] = 2000 --open up with all the steam wide open
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] = false
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["turbineName"] = turbineNames[turbineIndex]
				printLog("turbineList["..turbineIndex.."] in findTurbines() is a valid Big Reactors Turbine.")
				if turbine.getConnected() then
					printLog("turbine["..turbineIndex.."] in findTurbines() is connected.")
				else
					printLog("turbine["..turbineIndex.."] in findTurbines() is NOT connected.")
					return -- Disconnected turbine
				end
			end
			
			--failsafe
			local tempTable = _G[turbineNames[turbineIndex]]
			
			--check to make sure we get a valid config
			if (config.load(turbineNames[turbineIndex]..".options")) ~= nil then
				tempTable = config.load(turbineNames[turbineIndex]..".options")
			else
				--if we don't have a valid config from disk, make a valid config
				config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
			end
			
			--load values from tempTable, checking for nil values along the way
			if tempTable["TurbineOptions"]["LastSpeed"] ~= nil then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastSpeed"] = tempTable["TurbineOptions"]["LastSpeed"]
			end
			
			if tempTable["TurbineOptions"]["BaseSpeed"] ~= nil then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"] = tempTable["TurbineOptions"]["BaseSpeed"]
			end
			
			if tempTable["TurbineOptions"]["autoStart"] ~= nil then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["autoStart"] = tempTable["TurbineOptions"]["autoStart"]
			end
			
			if tempTable["TurbineOptions"]["LastFlow"] ~= nil then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"] = tempTable["TurbineOptions"]["LastFlow"]
			end
			
			if tempTable["TurbineOptions"]["flowOverride"] ~= nil then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] = tempTable["TurbineOptions"]["flowOverride"]
			end
			
			if tempTable["TurbineOptions"]["turbineName"] ~= nil then
				_G[turbineNames[turbineIndex]]["TurbineOptions"]["turbineName"] = tempTable["TurbineOptions"]["turbineName"]
			end
			
			--save once more just to make sure we got it
			config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
		end -- for turbineIndex = 1, #newTurbineList do

		-- Overwrite old turbine list with the now updated list
		turbineList = newTurbineList
	end -- if #newTurbineList == 0 then

	printLog("Found "..#turbineList.." turbine(s) in findTurbines().")
end -- function findTurbines()

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

-- Maintain Turbine flow rate at 900 or 1,800 RPM
local function flowRateControl(turbineIndex)
	if ((not _G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"]) or (_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] == "false")) then
		
		printLog("Called as flowRateControl(turbineIndex="..turbineIndex..").")

		-- Grab current turbine
		local turbine = nil
		turbine = turbineList[turbineIndex]

		-- assign for the duration of this run
		local lastTurbineSpeed = tonumber(_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastSpeed"])
		local turbineBaseSpeed = tonumber(_G[turbineNames[turbineIndex]]["TurbineOptions"]["BaseSpeed"])

		if not turbine then
			printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is NOT a valid Big Turbine.")
			return -- Invalid turbineIndex
		else
			printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is a valid Big Turbine.")

			if turbine.getConnected() then
				printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is connected.")
			else
				printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is NOT connected.")
			end -- if turbine.getConnected() then
		end -- if not turbine then

		-- No point modifying control rod levels for temperature if the turbine is offline
		if turbine.getActive() then
			printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is active.")

			local flowRate = tonumber(_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"])
			local flowRateUserMax = math.ceil(turbine.getFluidFlowRateMax())
			local rotorSpeed = math.ceil(turbine.getRotorSpeed())
			local newFlowRate = 0

			-- Going to control the turbine based on target RPM since changing the target flow rate bypasses this function
			if (rotorSpeed < turbineBaseSpeed) then
				printLog("BELOW COMMANDED SPEED")
				if (rotorSpeed > lastTurbineSpeed) then
					--we're still increasing, let's let it level off
					--also lets the first control pass go by on startup
				elseif (rotorSpeed < lastTurbineSpeed) then
					--we're decreasing where we should be increasing, do something
					if ((lastTurbineSpeed - rotorSpeed) > 100) then
						--kick it harder
						newFlowRate = 2000
						printLog("HARD KICK")
					else
						--let's adjust based on proximity
						flowAdjustment = (turbineBaseSpeed - rotorSpeed)/5
						newFlowRate = flowRate + flowAdjustment
						printLog("Light Kick: new flow rate is "..newFlowRate.." mB/t and flowAdjustment was "..flowAdjustment.." EOL")
					end
				else
					--we've stagnated, kick it.
					flowAdjustment = (turbineBaseSpeed - lastTurbineSpeed)
					newFlowRate = flowRate + flowAdjustment
					printLog("Stagnated: new flow rate is "..newFlowRate.." mB/t and flowAdjustment was "..flowAdjustment.." EOL")
				end --if (rotorSpeed > lastTurbineSpeed) then
			else
				--we're above commanded turbine speed
				printLog("ABOVE COMMANDED SPEED")
				if (rotorSpeed < lastTurbineSpeed) then
				--we're decreasing, let it level off
				--also bypasses first control pass on startup
				elseif (rotorSpeed > lastTurbineSpeed) then
					--we're above and ascending.
					if ((rotorSpeed - lastTurbineSpeed) > 100) then
						--halt
						newFlowRate = 25
					else
						--let's adjust based on proximity
						flowAdjustment = (rotorSpeed - turbineBaseSpeed)/5
						newFlowRate = flowRate - flowAdjustment
						printLog("Light Kick: new flow rate is "..newFlowRate.." mB/t and flowAdjustment was "..flowAdjustment.." EOL")
					end
				else
					--we've stagnated, kick it.
					flowAdjustment = (lastTurbineSpeed - turbineBaseSpeed)
					newFlowRate = flowRate - flowAdjustment
					printLog("Stagnated: new flow rate is "..newFlowRate.." mB/t and flowAdjustment was "..flowAdjustment.." EOL")
				end --if (rotorSpeed < lastTurbineSpeed) then
			end --if (rotorSpeed < turbineBaseSpeed)

			--check to make sure an adjustment was made
			if (newFlowRate == 0) then
				--do nothing, we didn't ask for anything this pass
			else
				--boundary check
				if newFlowRate > 2000 then
					newFlowRate = 2000
				elseif newFlowRate < 25 then
					newFlowRate = 25 -- Don't go to zero, might as well power off
				end -- if newFlowRate > 2000 then
				--no sense running an adjustment if it's not necessary
				if ((newFlowRate < flowRate) or (newFlowRate > flowRate)) then
					printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is being commanded to "..newFlowRate.." mB/t flow")
					newFlowRate = round(newFlowRate, 0)
					turbine.setFluidFlowRateMax(newFlowRate)
					_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastFlow"] = newFlowRate
					config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
				end
			end
			--always set this
			_G[turbineNames[turbineIndex]]["TurbineOptions"]["LastSpeed"] = rotorSpeed
			config.save(turbineNames[turbineIndex]..".options", _G[turbineNames[turbineIndex]])
		else
			printLog("turbine["..turbineIndex.."] in flowRateControl(turbineIndex="..turbineIndex..") is NOT active.")
		end -- if turbine.getActive() then
	else
		printLog("turbine["..turbineIndex.."] has flow override set to "..tostring(_G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"])..", bypassing flow control.")
	end -- if not _G[turbineNames[turbineIndex]]["TurbineOptions"]["flowOverride"] then
end -- function flowRateControl(turbineIndex)
