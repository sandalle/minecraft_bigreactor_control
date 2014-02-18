--[[
	Programmer: Lolmer
	Last update: 2014-02-18
	Pastebin: http://pastebin.com/ZTMzRLez

	Description: 
	This program controls a Big Reactors nuclear reactor
	in Minecraft with a Computercraft computer, using Computercraft's
	own wired modem connected to the reactors computer control port.

	This script is available from:
		http://pastebin.com/ZTMzRLez
		https://github.com/sandalle/minecraft_bigreactor_control
	And is used to control the following script:
		http://pastebin.com/fguScPBQ
	Other reactor control which I based my program on:
		http://pastebin.com/aMAu4X5J (ScatmanJohn)
		http://pastebin.com/HjUVNDau (version ScatmanJohn based his on)
	FC API, required:
		http://pastebin.com/A9hcbZWe
	A simpler Big Reactor control is available from:
		http://pastebin.com/tFkhQLYn (IronClaymore)

	Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
]]--
os.setComputerLabel("ReactorControl")

shell.run("rm", "reactorcontrol")
shell.run("pastebin", "get", "fguScPBQ", "reactorcontrol")

shell.run("rm", "FC_API")
shell.run("pastebin", "get", "A9hcbZWe", "FC_API")

shell.run("reactorcontrol")
