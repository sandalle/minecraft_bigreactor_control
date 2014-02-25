Lolmer's iteration of the EZ-NUKE Minecraft BigReactor Computercraft Control Program
============================

Description
----------------------------
This program controls a Big Reactors nuclear reactor in Minecraft with a Computercraft computer, using Computercraft's own wired modem connected to the reactors computer control port.

Features
----------------------------
- Configurable min/max energy buffer and min/max temperature via ReactorOptions file.
- ReactorOptions is read on start and then current values are saved every program cycle.
- Rod Control value in ReactorOptions is only useful for initial start, after that the program saves the current Rod Control average over all Fuel Rods for next boot.
- Auto-adjusts control rods per reactor to maintain temperature.
- Will display reactor data to all attached monitors of correct dimensions.
- Dynamically detect and add/remove monitors as they are connected to the network (not recommended).

Default values
----------------------------
- Rod Control: 90% (Let's start off safe and then power up as we can)
- Minimum Energy Buffer: 15% (will power on below this value)
- Maximum Energy Buffer: 85% (will power off above this value)
- Minimum Temperature: 850^C (will raise control rods below this value)
- Maximum Temperature: 950^C (will lower control rods above this value)

Requirements
----------------------------
- Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
- Computer or Advanced Computer
- Modems (not wireless) connecting each of the Computer to both the Advanced Monitor and Reactor Computer Port.
- Big Reactors (http://www.big-reactors.com/) 0.3
- Computercraft (http://computercraft.info/) 1.57+

Resources
----------------------------
- This script is available from:

	http://pastebin.com/fguScPBQ

	https://github.com/sandalle/minecraft_bigreactor_control

- Start-up script is available from:

	http://pastebin.com/ZTMzRLez

	https://github.com/sandalle/minecraft_bigreactor_control

- Other reactor control program which I based my program on:

	http://pastebin.com/aMAu4X5J (ScatmanJohn)

	http://pastebin.com/HjUVNDau (version ScatmanJohn based his on)

- A simpler Big Reactor control program is available from:

	http://pastebin.com/tFkhQLYn (IronClaymore)

- Reactor Computer Port API: http://wiki.technicpack.net/Reactor_Computer_Port

- Computercraft API: http://computercraft.info/wiki/Category:APIs

ChangeLog
============================
- 0.3.1
	- Add fuel consumption per tick to display

- 0.3.0
	- Add multi-monitor support! Sends one reactor's data to all monitors.
	- print function now takes table to support optional specified monitor
	- Set "numRods" every cycle for some people (mechaet)
	- Don't redirect terminal output with multiple monitor support
	- Log troubleshooting data to reactorcontrol.log
	- FC_API no longer used (copied and modified what I needed)
	- Multi-reactor support is theoretically implemented, but it is UNTESTED!
	- Updated for Big Reactor 0.3 (no longer works with 0.2)
	- BR getFuelTemperature() now returns many significant digits, just use math.ceil()
	- BR 0.3 removed individual rod temperatures, now it's only reactor-level temperature

- 0.2.4
	- Simplify math, don't divide by a simple large number and then multiply by 100 (#/10000000*100)
	- Fix direct-connected (no modem) devices. getDeviceSide -> FC_API.getDeviceSide (simple as that :))

- 0.2.3
	- Check bounds on reactor.setRodControlLevel(#,#), Big Reactor doesn't check for us.

- 0.2.2
	- Do not auto-start the reactor if it was manually powered off (autoStart=false)

- 0.2.1
	- Lower/raise only the hottest/coldest Control Rod while trying to control the reactor temperature.
	- "<" Rod Control buttons was off by one (to the left)

- 0.2.0 - Lolmer Edition :)
	- Add min/max stored energy percentage (default is 15%/85%), configurable via ReactorOptions file.
	- No reason to keep burning fuel if our power output is going nowhere. :)
	- Use variables variable for the title and version.
	- Try to keep the temperature between configured values (default is 850^C-950^C)
	- Add Waste and number of Control/Fuel Rods to displayBards()

TODO
============================
- Support multiple reactors
	- If multiple reactors, require a monitor for each reactor and display only that reactor on a monitor
	- Save parameters per reactor instead of one global set for all reactors
- Add min/max RF/t output and have it override temperature concerns (maybe?)
- Add support for wireless modems, see http://computercraft.info/wiki/Modem_%28API%29, will not be secure (anyone can send/listen to your channels)!
- Add support for any sized monitor (minimum 3x3), dynamic allocation/alignment
- Add BR 0.3 Turbine control support
- Add BR 0.3 active-cooled reactor support
