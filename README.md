Lolmer's iteration of the EZ-NUKE Minecraft BigReactor Computercraft Control Program
============================

Description
----------------------------
This program controls a Big Reactors nuclear reactor in Minecraft with a Computercraft computer, using Computercraft's own wired modem connected to the reactors computer control port.

This program was designed to work with the mods and versions installed on Never Stop Toasting (NST) Diet
- http://www.technicpack.net/modpack/details/never-stop-toasting-diet.254882
- Endeavour: Never Stop Toasting: Diet official Minecraft server http://forums.somethingawful.com/showthread.php?threadid=3603757

To simplify the code and guesswork, I assume the following monitor layout:
- One Advanced Monitor for overall status display plus

	one or more Reactors plus

	none or more Turbines.
OR
- One Advanced Monitor for overall status display plus (first found monitor)

	one Advanced Monitor for each connected Reactor plus (subsequent found monitors)

	one Advanced Monitor for each connected Turbine (last group of monitors found).

If you enable debug mode, add one additional Advanced Monitor for #1 or #2.

Notes
----------------------------
- Only one reactor and one, two, and three turbines have been tested with the above, but IN THEORY any number is supported.
- Devices are found in the reverse order they are plugged in, so monitor_10 will be found before monitor_9.

When using actively cooled reactors with turbines, keep the following in mind:
- 1 mB steam carries up to 10RF of potential energy to extract in a turbine.
- Actively cooled reactors produce steam, not power.
- You will need about 10 mB of water for each 1 mB of steam that you want to create in a 7^3 reactor.
- Two 15x15x14 Turbines can output 260K RF/t by just one 7^3 (four rods) reactor putting out 4k mB steam

Features
----------------------------
- Configurable min/max energy buffer and min/max temperature via ReactorOptions file.
- ReactorOptions is read on start and then current values are saved every program cycle.
- Rod Control value in ReactorOptions is only useful for initial start, after that the program saves the current Rod Control average over all Fuel Rods for next boot.
- Auto-adjusts control rods per reactor to maintain temperature.
- Will display reactor data to all attached monitors of correct dimensions.
	- For multiple monitors, the first monitor (often last plugged in) is the overall status monitor.

GUI Usage
----------------------------
- The "<" and ">" buttons, when right-clicked with the mouse, will decrease and increase, respectively, the values assigned to the monitor:
	- "Rod (%)" will lower/raise the Reactor Control Rods for that Reactor
	- "Flow mB/t" will lower/raise the Turbine Flow Rate maximum for that Turbine
- Right-clicking between the "<" and ">" (not on) will disable auto-adjust of that value for attached device.
	- Right-clicking on the "Enabled" or "Disabled" text for auto-adjust will do the same.
- Right-clicking on "ONLINE" or "OFFLINE" at the top-right will toggle the state of attached device.

Default values
----------------------------
- Rod Control: 90% (Let's start off safe and then power up as we can)
- Minimum Energy Buffer: 15% (will power on below this value)
- Maximum Energy Buffer: 85% (will power off above this value)
- Minimum Temperature: 850^C (will raise control rods below this value)
- Maximum Temperature: 950^C (will lower control rods above this value)
- Minimum Active Cooling Temperature: 300^C (will raise the control rods below this value)
- Maximum Active Cooling Temperature: 420^C (will lower control rods above this value)
- Optimal Turbine RPM: 900, 1,800, or 2,700 (divisible by 900)
	- New user-controlled option for target speed of turbines, defaults to 2726RPM, which is high-optimal.

Requirements
----------------------------
- Advanced Monitor size is X: 29, Y: 12 with a 3x2 size
- Computer or Advanced Computer
- Modems (not wireless) connecting each of the Computer to both the Advanced Monitor and Reactor Computer Port.
- Big Reactors (http://www.big-reactors.com/) 0.3.2A+
- Computercraft (http://computercraft.info/) 1.63+
- Reset the computer any time number of connected devices change.

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

	http://pastebin.com/7S5xCvgL (IronClaymore only for passively cooled reactors)

- Reactor Computer Port API: http://wiki.technicpack.net/Reactor_Computer_Port

- Computercraft API: http://computercraft.info/wiki/Category:APIs
- Big Reactors Efficiency, Speculation and Questions! http://www.reddit.com/r/feedthebeast/comments/1vzds0/big_reactors_efficiency_speculation_and_questions/
- Big Reactors API code: https://github.com/erogenousbeef/BigReactors/blob/master/erogenousbeef/bigreactors/common/multiblock/tileentity/TileEntityReactorComputerPort.java
- Big Reactors API: http://big-reactors.com/cc_api.html

ChangeLog
============================
- 0.3.9
	- Algorithm pass by Mechaet
	- Additional user config options by Mechaet

- 0.3.8
	- Update to ComputerCraft 1.6 API (only term.restore() -> term.native() required :)).

- 0.3.7
	- Fix typo when initializing TurbineNames array.
	- Fix Issue #1, turbine display is using the Reactor buffer size (10M RF) instead of the Turbine buffer size (1M RF).

- 0.3.6
	- Fix multi-reactors displaying on the correct monitors (thanks HybridFusion).
	- Fix rod auto-adjust text position.
	- Reactors store 10M RF and Turbines store 1M RF in their buffer.
	- Add more colour to displayAllStatus().
	- Sleep for only two seconds instead of five.
	- Fix getDeviceStoredEnergyBufferPercent() for Reactors storing 10M RF in buffer.
	- Keep actively cooled reactors between 0-300^C (non-configurable for now).

- 0.3.5
	- Do not discover connected devices every loop - nicer on servers. Reset computer anytime number of connected devices change.
	- Fix multi-reactor setups to display the additional reactors on monitors, rather than the last one found.
	- Fix passive reactor display having auto-adjust and energy buffer overwrite each other (removes rod count).

- 0.3.4
	- Fix arithmetic for checking if we have enough monitors for the number of reactors.
	- Turbines are optimal at 900, 1800, *and* 2700 RPM
	- Increase loop timer from 1 to 5 to be nicer to servers

- 0.3.3
	- Add Big Reactors Turbine support.
	- First found monitor (appears to be last connected monitor) is used to display status of all found devices (if more than one valid monitor is found)
	- Display monitor number on top left of each monitor as "M#" to help find which monitor is which.
	- Enabling debug will use the last monitor found, if more than one, to print out debug info (also written to file)
	- Only clear monitors when we're about to use them (e.g. turbine monitors no longer clear, then wait for all reactors to update)
	- Fix getDeviceStoredEnergyBufferPercent(), was off by a decimal place
	- Just use first Control Rod level for entire reactor, they are no longer treated individually in BR 0.3
	- Allow for one monitor for n number of reactors and m number of turbines
	- Auto-adjust turbine flow rate by 25 mB to keep rotor speed at 900 or 1,800 RPM.
	- Clicks on monitors relate to what the monitor is showing (e.g. clicking on reactor 1's display won't modify turbine 1's nor reactor 2's values)
	- Print monitor name and device (reactor|turbine) name in blue to monitor associated for easier design by users.
	- Remove version number from monitors to free up space for monitor names.
	- Add option of right-clicking on "Enabled"/"Disabled" of auto-adjust to toggle it.

- 0.3.2
	- Allow for rod control to override (disable) auto-adjust via UI (Rhonyn)

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
- Save parameters per reactor instead of one global set for all reactors
- Add min/max RF/t output and have it override temperature concerns (maybe?)
- Add support for wireless modems, see http://computercraft.info/wiki/Modem_%28API%29, will not be secure (anyone can send/listen to your channels)!
- Add support for any sized monitor (minimum 3x3), dynamic allocation/alignment
- Lookup using pcall for better error handling - http://www.computercraft.info/forums2/index.php?/topic/10992-using-pcall/
- Still requires a monitor for reach reactor and turbine to function.
