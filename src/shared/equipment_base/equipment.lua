local Equipment = {}
Equipment.__index = Equipment

local animation_util = require(game.ReplicatedStorage.Common.utils.animation_util)
local input_util = require(game.ReplicatedStorage.Common.utils.input_util)
local vm_builder_util = require(game.ReplicatedStorage.Common.equipment_base.utils.vm_builder_util)
local spring_util = require(game.ReplicatedStorage.Common.utils.spring_util)


Equipment.Utils = {}
Equipment.Utils.Angles = function(x, y, z)
	x = x or 0
	y = y or 0
	z = z or 0

	return CFrame.Angles(
		math.rad(x),
		math.rad(y),
		math.rad(z)
	)
end

Equipment.Utils.Limits = function(x, min, max)
	return Vector3.new(
		math.clamp(x.X, min, max),
		math.clamp(x.Y, min, max),
		math.clamp(x.Z, min, max)
	)
end

function Equipment.new(Viewmodel, Data)
	local self = setmetatable({},Equipment)
	--self.Viewmodel = Viewmodel
	self.Data = table.clone(require(Data))

	self.ControlsEnabled = false
	self.Equipped = false
	self.Varibles = self.Data.Varibles
	self.Offsets = {}
	self.Springs = {}

	if self.Data.Data.Springs then
		for Name, SpringData in pairs(self.Data.Data.Springs) do
			self.Springs[Name] = spring_util.Create(unpack(SpringData))
		end
	end

	-- build model
	local eqpmnt = game.ReplicatedStorage.Assets.Models:FindFirstChild(self.Data.Data["Model"]):Clone()
	if self.Data.Data["Independent"] then
		self.Viewmodel = eqpmnt
	else
		self.Viewmodel = Viewmodel
	end
	self.Viewmodel.Parent = workspace.Camera
	vm_builder_util.build(self.Viewmodel, eqpmnt, self.Data)

	self.Viewmodel.PrimaryPart.Transparency = 1
	--Viewmodel.CameraBone.Transparency = 1

	self.Animator = animation_util.new(self.Viewmodel, self.Data.Data.Animations)
	self.Viewmodel.Parent = nil

	
	return self
end

-- Internal
function Equipment:HookControl(key, func)
	  input_util:Hook(key, function(began)
			if self.ControlsEnabled then
				func(self, began)
			end

			return self.Equipped
		end)
end

function Equipment:Render(delta)
	self.Data.Actions.Update(self, delta)

	local Offsets = CFrame.new()

	for _,offset in pairs(self.Offsets) do
		if typeof(offset) == "CFrame" then
			Offsets *= offset
		else
			Offsets *= offset.Value
		end
	end

	self.Viewmodel.PrimaryPart.CFrame = workspace.Camera.CFrame * self.Data.Data.DefaultOffset * Offsets
end

-- Interface
function Equipment:Equip()
	for key, func in pairs(self.Data.Actions.Controls) do
		self:HookControl(key, func)
	end
	
	self.Viewmodel.Parent = workspace.Camera
	self.Animator:play("Idle")
	self.Animator:fplay("Equip")
	
	if self.Data.Data.EquipTime then
		self.Animator:lplay("Equip", self.Data.Data.EquipTime)
		task.wait(self.Data.Data.EquipTime)
	else
		task.wait(self.Animator:play("Equip", 1))
	end
	self.Animator:play("Idle")

	self.Equipped = true
	self.ControlsEnabled = true

	

	self.Data.Actions.OnEquip(self)
end

function Equipment:Unequip()
	self.Viewmodel.Parent = nil
	self.Equipped = false
	self.ControlsEnabled = false

	self.Data.Actions.OnUnequip(self)
end

return Equipment
