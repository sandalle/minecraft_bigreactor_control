--[[
	Programmer: Lolmer
	Last update: 2026-04-17
	Pastebin: http://pastebin.com/ZTMzRLez
	GitHub: https://github.com/sandalle/minecraft_bigreactor_control

	Description:
	This program controls a Big Reactors nuclear reactor
	in Minecraft with a Computercraft computer, using Computercraft's
	own wired modem connected to the reactors computer control port.

	Save this file as "startup" on your computer for it to auto-start on Computer boot.
	To easily get this file into your Computercraft Computer, run the following after right-clicking on your Computercraft computer (includes prompts).
	> rm startup
	> lua
	lua> shell.run("pastebin", "get", "ZTMzRLez", "startup")

	Requirements:
		Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
		Computer or Advanced Computer
		Modems (not wireless) connecting each of the Computer to both the Advanced Monitor and Reactor Computer Port.

	This script is available from:
		http://pastebin.com/ZTMzRLez
		https://github.com/sandalle/minecraft_bigreactor_control
	And is used to control the following script:
		http://pastebin.com/fguScPBQ
	Other reactor control which I based my program on:
		http://pastebin.com/aMAu4X5J (ScatmanJohn)
		http://pastebin.com/HjUVNDau (version ScatmanJohn based his on)
	A simpler Big Reactor control is available from:
		http://pastebin.com/tFkhQLYn (IronClaymore)

	Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
]]--
os.setComputerLabel("ReactorControl")

-- Version-pinned config: change these to match the desired release
local CONTROL_VERSION = "0.3.19"
local REACTORCONTROL_PASTEBIN_ID = "fguScPBQ"  -- Version-pinned pastebin ID
local STARTUP_PASTEBIN_ID = "ZTMzRLez"         -- Version-pinned pastebin ID
local BOOTSTRAP_TIMEOUT = 30  -- seconds to try downloading before falling back to local copy

-- Helper: attempt to download a script, with a timeout and fallback
local function downloadScript(name, pastebinId, timeoutSec)
	-- Try downloading first
	local success, err = pcall(function()
		local startTime = os.clock()
		repeat
			local result = shell.run("pastebin", "get", pastebinId, name)
			if result == 0 then
				return true
			end
			if os.clock() - startTime > timeoutSec then
				break
			end
			os.sleep(2)
		until false
		return false
	end)
	if success and err then
		return true
	end
	-- Fallback: if local file already exists, use it (warning instead of crash)
	if fs.exists(name) then
		write("WARNING: Could not download " .. name .. " from pastebin. Using local copy.\n")
		return true
	end
	-- Nothing to fall back to — fatal
	error("Could not download " .. name .. ". Please update your startup script.")
end

-- Remove any prior, possibly old, versions of "reactorcontrol"
local oldExists = fs.exists("reactorcontrol")
if oldExists then
	shell.run("rm", "reactorcontrol")
end

-- Download reactorcontrol with version pinning and fallback
if not downloadScript("reactorcontrol", REACTORCONTROL_PASTEBIN_ID, BOOTSTRAP_TIMEOUT) then
	error("Failed to obtain reactorcontrol program. Cannot boot.")
end

-- Verify version if available
if fs.exists("reactorcontrol") then
	local f = fs.open("reactorcontrol", "r")
	if f then
		local firstLine = f.readLine()
		f.close()
		if firstLine and string.find(firstLine, "Version: v"..CONTROL_VERSION) then
			write("Loaded reactorcontrol v" .. CONTROL_VERSION .. "\n")
		else
			write("WARNING: Loaded reactorcontrol has unexpected version info. Expected v" .. CONTROL_VERSION .. "\n")
		end
	end
end

shell.run("reactorcontrol")
