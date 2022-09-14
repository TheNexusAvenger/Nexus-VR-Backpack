# Nexus VR Backpack
Nexus VR Backpack is a replacement for the default Roblox
backpack user interface for VR players. It is intended
to be used with [Nexus VR Character Model](https://github.com/TheNexusAvenger/Nexus-VR-Character-Model),
but can be used without it.

# Setup
## Nexus VR Character Model Loader
With Nexus VR Character Model V.2.4.0 and later, Nexus
VR Character Model is able to loaded with either the
default configuration. In the [loader for Nexus VR Character Model](https://github.com/TheNexusAvenger/Nexus-VR-Character-Model/blob/master/NexusVRCharacterModelLoader.server.lua),
the value of `NexusVRBackpackEnabled` under `Extra` must
be set to `true`. By default, this is enabled for
the V.2.4.0 loader. Previous loaders will not have this
property and will default to be disabled unless added.

## Manual
Nexus VR Backpack can be used with or without Nexus
VR Character Model. Nexus VR Character Model will
include Nexus VR Backpack if it is set to load. Otherwise,
it will need to be provided in the game. An updated
version can be loadeed using `require(10728805649)()`,
but a static version can be used. `NexusVRBackpack` as
a module in `ReplicatedStorage` is recommended but
not required.

To load Nexus VR Backpack, `Load` in the module needs
to be called.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NexusVRBackpack = require(ReplicatedStorage:WaitForChild("NexusVRBackpack"))
NexusVRBackpack:Load()

--Optional - Changes the key to open the backpack from the Right Thumbstick.
NexusVRBackpack:SetKeyCode(Enum.KeyCode.X)

--Optional - Changes the UserCFrame the backpack will open at from the Right Hand.
NexusVRBackpack:SetUserCFrame((Enum.UserCFrame.Left)

--Optional - Enables or disables the backpack.
NexusVRBackpack:SetBackpackEnabled(false)

--Optional - Returns if the backpack is enabled or not.
print(NexusVRBackpack:GetBackpackEnabled())
```

## Contributing
Both issues and pull requests are accepted for this project.

## License
Nexus VR Backpack is available under the terms of the MIT 
Liscence. See [LICENSE](LICENSE) for details.
