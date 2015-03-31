--[[
	Programmer: Lolmer
	Last update: 2015-03-31
	Pastebin: http://pastebin.com/ZTMzRLez
	GitHub: https://github.com/sandalle/minecraft_bigreactor_control/

	Description:
	This program controls a Big Reactors nuclear reactor
	in Minecraft with a Computercraft computer, using Computercraft's
	own wired modem connected to the reactors computer control port.

	Save this file as "startup" on your computer for it to auto-start on Computer boot.
	To easily get this file into your Computercraft Computer, run the following after right-clicking on your Computercraft computer (includes prompts).
	> rm startup
	> lua
	lua> shell.run("pastebin", "get", "ZTMzRLez", "startup")

	Now uses gitget http://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/

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
		http://pastebin.com/7S5xCvgL (IronClaymore)

	Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
]]--
os.setComputerLabel("ReactorControl")

-- Remove any prior, possibly old, versions of "reactorcontrol"
shell.run("rm", "reactorcontrol")
shell.run("rm", "minecraft_bigreactor_control")

-- Install ElvishJerricco's JSON parsing API from http://pastebin.com/raw.php?i=4nRg9CHU
if not fs.exists(json) then
	shell.run("pastebin", "get", "4nRg9CHU", "gitget")
end

-- Install gitget2 http://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/page__st__20
if fs.exists(gitget) then
	shell.run("gitget", "sandalle", "minecraft_bigreactor_control")
else -- Fallback to pastebin to retrieve gitget
	-- Download http://pastebin.com/raw.php?i=W5ZkVYSi and name "gitget"
	shell.run("pastebin", "get", "W5ZkVYSi", "gitget")
	shell.run("gitget", "sandalle", "minecraft_bigreactor_control")
end

shell.run("minecraft_bigreactor_control")