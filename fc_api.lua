-- This script is from http://pastebin.com/A9hcbZWe and is not mine

function getDeviceSide(deviceType)
	deviceType = deviceType:lower()
   
	for i, side in pairs(rs.getSides()) do
		if (peripheral.isPresent(side)) then
			if (string.lower(peripheral.getType(side)) == deviceType) then
					return side;
			end
		end
	end
   
	return nil;
end

function wrapMonitor()
	local monitor, i = nil, 0
	while monitor == nil and i <= 100 do
		monitor = peripheral.wrap("monitor_"..i)
		i = i + 1
	end

	if monitor == nil then
		side = getDeviceSide("Monitor")
		if side ~= nil then
			return peripheral.wrap(side)
		else
			return nil
		end
	else
		return monitor
	end
end

function wrapGate()
	local gate, i = nil, 0
	while gate == nil and i <= 100 do
		gate = peripheral.wrap("stargate_"..i)
		i = i + 1
	end
	return gate
end

function wrapBR()
	side = getDeviceSide("BigReactors-Reactor")
	if side ~= nil then
		return peripheral.wrap(side)
	else
		return nil
	end
end

function round(float)
	if float%math.floor(float) >= 0 then
		return math.ceil(float)
	else
		return math.floor(float)
	end
end

function roundToTen(float)
	float = math.ceil(float)
	if ((float % 10) - 10) >= 0 then
		return math.ceil(float + float%10)
	else
		return math.floor(float - float%10)
	end
end

function clearMonitor(str)
	local gap = 2
	term.clear()
	local width, height = term.getSize()
	
	printCentered(str, 1)

	for i=1, width do
		term.setCursorPos(i, gap)
		term.write("-")
	end		
	
	term.setCursorPos(1, gap+1)
end

function formatSeconds(s)
	if s > 86400 then
		return math.ceil(s/86400).."d "..formatSeconds(s%86400)
	elseif s > 3600 then
		return math.ceil(s/3600).."h "..formatSeconds(s%3600)
	elseif s > 60 then
		return math.ceil(s/60).."m "..formatSeconds(s%60)
	else
		return math.ceil(s).."s"
	end
end

function printCentered(str, yPos)
	local width, height = term.getSize()
	term.setCursorPos(math.floor(width/2) - math.ceil(str:len()/2) , yPos)
	term.clearLine()
	term.write(str)
end

function restoreNativeTerminal()
	repeat
		term.restore()
		local w, h = term.getSize()
	until w == 51 and h == 19
end

function stringToBool(str)
	if str == "false" then
		return false
	else
		return true
	end
end

function sortTables(table1, table2)
	for i=1, #table1, 1 do
		valTI = table1[i]
		valTI2 = table2[i]
		holePos = i
		while holePos > 1 and string.lower(valTI) < string.lower(table1[holePos - 1]) do
			table1[holePos] = table1[holePos - 1]
			table2[holePos] = table2[holePos - 1]
			holePos = holePos - 1
		end
		table1[holePos] = valTI
		table2[holePos] = valTI2
	end
end
