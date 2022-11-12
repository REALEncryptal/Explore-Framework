local ReplicatedStorage = game:GetService("ReplicatedStorage")

local equipment_class = require(ReplicatedStorage.Common.equipment_base.equipment)
local network_util = require(ReplicatedStorage.Common.utils.network_util)
local loadout_util = require(ReplicatedStorage.Common.utils.loadout_util)
local render_util = require(ReplicatedStorage.Common.utils.render_util)
local logging_util = require(ReplicatedStorage.Common.utils.logging_util)
local input_util = require(ReplicatedStorage.Common.utils.input_util)
local shared_loadout_util = require(ReplicatedStorage.Common.utils.shared_loadout_util)

_G.Loadout = loadout_util.empty
_G.Slot = 0

local loadout = {
  [1] = nil,
  [2] = nil,
  [3] = nil
}

local keycodes = {
  [1] = Enum.KeyCode.One,
  [2] = Enum.KeyCode.Two,
  [3] = Enum.KeyCode.Three,
}

logging_util.debug.init()


-- get equipment function
local function getEquipment(name)
  if name == "NONE" then return end
  local data = ReplicatedStorage.Common.assets.equipment_data:FindFirstChild(name)
  local equipment = equipment_class.new(
    ReplicatedStorage.Assets.vm:Clone(),
    data
  )

  return equipment
end

local function equipWeapon(name, index)
  if name == "NONE" then return end

  loadout[index] = getEquipment(name)
  _G.Loadout[index] = name

  shared_loadout_util.loadout = loadout
end


--- Hook inputs

input_util:Hook(Enum.KeyCode.RightControl, function(began)
  local box = game.Players.LocalPlayer.PlayerGui.Console.Input.TextBox
    if began then
      if box:IsFocused() then
        box:ReleaseFocus()
      else
        box:CaptureFocus()
      end
    end
end)

input_util:Hook(Enum.KeyCode.LeftShift, function(began)
  print(began)
  if began then
    game.ReplicatedStorage.RunSpeed.Value = 18
  elseif not began then
      game.ReplicatedStorage.RunSpeed.Value = 11
  end
end)

for key, _ in pairs(_G.Loadout) do
  input_util:Hook(keycodes[key], function(began)
    if not began then return end
    if _G.Slot == key then return end
    _G.Slot = key

    for _,equipment in pairs(loadout) do
      equipment:Unequip()
    end

    if _G.Loadout[key] ~= "NONE" then
      loadout[key]:Equip()
    end
  end)
end

logging_util.log("client", "input_util", "hooked")  
--- Hook render actions)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
  for _,equipment in pairs(loadout) do
    equipment:Render(deltaTime)
  end
end)

render_util.init()
logging_util.log("client", "render_util", "initialized")  
-- Hook network actions
network_util.hook("UpdateLoadoutOld", function(new_loadout) -- Server force loadout change
  local SelectedSlotChanged = _G.Loadout[_G.Slot] ~= new_loadout[_G.Slot]
  if SelectedSlotChanged and  _G.Loadout[_G.Slot] ~= "NONE" then
    _G.Loadout[_G.Slot]:Unequip()
  end

  _G.Loadout = new_loadout

  if SelectedSlotChanged then
    _G.Loadout[_G.Slot]:Equip()
  end

  shared_loadout_util.loadout = loadout
end)

network_util.hook("NewLoadout", function(new_loadout) -- Server force loadout change
  if loadout[_G.Slot] then
    loadout[_G.Slot]:Unequip()
  end
  loadout = {
    [1] = nil,
    [2] = nil,
    [3] = nil
  }
  _G.Loadout = new_loadout

  equipWeapon(new_loadout[1], 1)
  equipWeapon(new_loadout[2], 2)
  equipWeapon(new_loadout[2], 2)
  _G.Slot = 1
  loadout[_G.Slot]:Equip()
end)
logging_util.log("client", "network_util", "hooked")

----------------------------------------------------
------------------ Main Logic ----------------------
----------------------------------------------------


equipWeapon("ex_m4a1", 1)


-- Gamemode handlers
local gameui = game.Players.LocalPlayer.PlayerGui.Game


function fade(x, y, z, t)
  game:GetService("TweenService"):Create(x, TweenInfo.new(z, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {[t]=y}):Play()
end


gameui.Frame.Visible = false

network_util.hook("ToggleTDM", function(visible)
  gameui.Frame.Visible = visible
  game.Lighting.Gray.Saturation = -.06
  gameui.Vignette.ImageTransparency = 0.2
  gameui.Start.Count.Text = "TDM"
end)

network_util.hook("UpdateScore", function(x, y)
  gameui.Frame.Count.Left.Text = tostring(x)
  gameui.Frame.Count.Right.Text = tostring(y)
end)

network_util.hook("UpdateCountdown", function(x)
  gameui["Tick"]:Play()
  gameui.Start.Count.Text = tostring(x)

  if x < 2 then
    fade(gameui.Vignette, 1, 1, "ImageTransparency")
    fade(game.Lighting.Gray, 0, 1, "Saturation")
  end

  if x < 1 or x == 0 then
    gameui["Bass Boom"]:Play()
  end
end)

network_util.hook("EndCountdown", function()
  gameui.Start.Count.Text = ""
end)



