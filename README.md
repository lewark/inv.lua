![Screenshot](https://github.com/knector01/inv.lua/blob/master/inv-client-screenshot.png?raw=true)

# inv.lua

Inventory management system for CC:Tweaked. Supports recursive autocrafting but is largely untested. Use with caution.

This software's UI was made using my [gui.lua](https://github.com/knector01/gui.lua) toolkit.

## Installation

Currently, the easiest way to install inv.lua is using [gitget](http://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/).
```
pastebin get W5ZkVYSi gitget
gitget knector01 inv.lua master inv
cd inv
```

## Usage

This system requires that CC:Tweaked generic peripherals be enabled. Recent versions enable this feature by default but for older ones you may need to change a setting in `computercraft_server.toml`.

To use this system, you must connect your chests to a ComputerCraft wired modem network. Place wired modems on each chest, and connect the modems together with modem cables.

Run `inv_server.lua` on a central crafting turtle connected to the network using another wired modem.

Then place a separate Advanced Turtle connected to the same network in a similar fashion. This one will be used as a client to retrieve items from the network. Edit this turtle's `client.json` file and enter the ID of the server turtle so that the two can connect over rednet. Finally, run `inv_client.lua` on the client turtle.

You can then use the client turtle's GUI to request items from the storage network, and they will be placed in the turtle's inventory. Recipes must be specified in JSON files under the recipes folder.

The turtles and chests can be placed anywhere as long as they are connected by cables, and an arbitrary number of client turtles can be connected.

## Troubleshooting

Make sure to use `cd` to enter the `inv` folder before running the client or server.

If the client program freezes at the command line and does not respond, then it most likely has either not been connected to the server properly (check the cables and the `client.json` file) or the server program has crashed due to this software's many bugs.

Also, the Forge Ore Dictionary support is currently buggy, and the server might not recognize a recipe as providing a specific ingredient until it has seen it in storage before. For example, it might not realize that the built-in recipe for `minecraft:stick` counts as a `forge:rods/wooden` until a stick is placed in a connected chest at least once.