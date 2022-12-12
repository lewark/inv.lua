![Screenshot](https://github.com/knector01/inv.lua/blob/master/inv-client-screenshot.png?raw=true)

# inv.lua

This software provides a lightweight, configurable inventory management and autocrafting system for ComputerCraft:Tweaked / Restitched. Sequences of recipes can be automatically crafted using a crafting turtle alongside crafting machines such as furnaces. A client interface is also provided, allowing quick retrieval and crafting of items, and this interface was created using a [custom GUI toolkit](https://github.com/knector01/gui.lua).

## Installation

The client and server software can be downloaded from GitHub and installed onto turtles in-game using [gitget](http://www.computercraft.info/forums2/index.php?/topic/17387-gitget-version-2-release/).
```
pastebin get W5ZkVYSi gitget
gitget knector01 inv.lua master inv
cd inv
```

## Usage

This system requires that CC:Tweaked generic peripherals be enabled. Recent versions enable this feature by default but for older ones you may need to change a setting in `computercraft_server.toml`.

To use this system, you must connect your chests to a ComputerCraft wired modem network. ComputerCraft offers full-block wired modems crafted by putting a small wired modem into the crafting table, and this type must be used when connecting peripherals like chests and turtles that aren't full blocks. Place wired modems on each chest, connect the modems together with modem cables, and right-click on each modem to connect the chest peripherals to the network.

Then connect a crafting turtle to the network in a similar fashion. This turtle will act as the central server for the inventory system. Install the inv.lua software on this turtle, and run `run_server.lua` to host the server. Optionally, you can also create a `startup.lua` script in the turtle's root directory that runs the server on boot:

```lua
shell.setDir("inv")
shell.run("run_server.lua")
```

Finally, place a separate Advanced Turtle connected to the same network. This one will be used as a client to retrieve items from the inventory system. Install the software as before, then run `inv_client.lua SERVER_ID` on the client turtle, replacing `SERVER_ID` with the numeric computer ID of the server. This ID can be found by running the `id` command  on the server turtle. If desired, you can make a startup script for the client as well:

```lua
local SERVER_ID = 1 -- replace with your server's ID
shell.setDir("inv")
shell.run("run_client.lua", SERVER_ID)
```

You can then use the client turtle's GUI to request items from the storage network, and they will be placed in the turtle's inventory. The turtles and chests can be placed anywhere as long as they are connected to the network by cables and modems, and an arbitrary number of client turtles can be connected.

## Troubleshooting

Make sure to use `cd` to enter the `inv` folder before running the client or server.

If the client or server crash when run, or you are unable to view the list of items in the network, then one of the turtles likely has not been connected to the server properly (check the cables). If the items show up in the list but cannot be pulled into to the client inventory then you may have forgotten to right-click the modem to connect the turtle fully to the network.

## Configuration

### Devices

Custom settings for connected devices such as chests, furnaces, or barrels can be specified within `server.json` inside the `overrides` list. For example, a type of inventory can be assigned a higher priority so that items are preferentially stored within inventories of that type:

```json
{
    "type":"storagedrawers:controller",
    "priority":3
}
```

Alternatively, a specific inventory can be configured with its own unique settings. In this example, an individual chest is given filters so that only specific items can be stored within it:

```json
{
    "name":"minecraft:chest_0",
    "filters":[
        {"name":"minecraft:cobblestone"},
        {"tags":["minecraft:planks"]}
    ],
    "priority":2
}
```

Inventories can also be designated as crafting machines instead of storage. The default `server.json` contains this entry to treat furnaces as a machine:

```json
{
    "type":"minecraft:furnace",
    "purpose":"crafting"
}
```

Possible values for the `purpose` field are `crafting` and `storage`, the latter of which is the default for connected devices with an inventory.

### Recipes

Custom crafting recipes must be specified in `recipes/minecraft.json`. Like inventory filters, recipes can address input items by name or by Ore Dictionary tags. The "tags" field may consist of an array of tags, e.g. `["tag","tag2"]`, or a dictionary in the format `{"tag":true,"tag2":true}`. An item matches a tag specification if one or more of the tags in the "tags" list is present on the item.

```json
[
    {
        "machine":"workbench",
        "input":{
            "1":{"name":"minecraft:oak_log"}
        },
        "output":{
            "10":{
                "name":"minecraft:oak_planks",
                "count":4,
                "tags":["minecraft:planks"]
            }
        }
    },
    {
        "machine":"workbench",
        "input":{
            "1":{"tags":["minecraft:planks"]},
            "4":{"tags":["minecraft:planks"]}
        },
        "output":{
            "10":{
                "name":"minecraft:stick",
                "count":4,
                "tags":["forge:rods/wooden"]
            }
        }
    },
    {
        "machine":"minecraft:furnace",
        "input":{
            "1":{"name":"minecraft:cobblestone","count":8},
            "2":{"name":"minecraft:charcoal"}
        },
        "output":{
            "3":{"name":"minecraft:stone","count":8}
        }
    }
]
```