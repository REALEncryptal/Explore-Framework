-- constants
local ITERATION_ENABLED: boolean = true
local ITERATIONS: number = 8

-- module
local module = {}
module.__index = module

local function Vector2ToVector3(vector2: Vector2): Vector3 -- basic function that converts vector2 to vector3. a result of how i used to do limits. 
	return Vector3.new(vector2.X, vector2.Y, 0)
end

function module.Create(mass: number?, force: number?, damping: number?, speed: number?, hasLimit: boolean?, limits: Vector3) -- Creates new "Spring" object.
	local self = {}
	
	self.Target = Vector3.zero
	self.Position = Vector3.zero
	self.Velocity = Vector3.zero
	
	self.Mass = mass or 5
	self.Force = force or 50
	self.Damping = damping or 4
	self.Speed = speed or 4
	
	self.LimitsEnabled = hasLimit or false
	self.Limits = limits or Vector3.zero
	
	if typeof(self.Limits) == "Vector2" then
		self.Limits = Vector2ToVector3(self.Limits) -- lets convert it to vector3
	end
	
	setmetatable(self, module)
	return self
end

function module:ChangeLimits(limits: Vector3|Vector2) -- Prefered way of updating limits.
	self.Limits = limits or Vector3.zero

	if typeof(self.Limits) == "Vector2" then
		self.Limits = Vector2ToVector3(self.Limits)
	end
end

function module:Shove(force: Vector3) -- Adds a force to the spring.
	local components: {x: number, y: number, z: number} = {x = force.X, y = force.Y, z = force.Z}
	for index, v in pairs(components) do
		if v == math.huge or v == -math.huge then
			components[index] = 0
		end
	end
	
	self.Velocity += Vector3.new(components.x, components.y, components.z)
end

function module:Update(deltaTime: number) -- Actually updates the spring.
	local scaledDeltaTime = math.min(deltaTime, 1) * self.Speed
	if ITERATION_ENABLED then
		scaledDeltaTime /= ITERATIONS
		for i = 1, ITERATIONS do
			local force = self.Target - self.Position
			local acceleration = (force * self.Force) / self.Mass
			
			acceleration = acceleration - self.Velocity * self.Damping
			
			self.Velocity = self.Velocity + acceleration * scaledDeltaTime
			self.Position = self.Position + self.Velocity * scaledDeltaTime
			
			if self.LimitsEnabled then
				local x: number, y: number, z: number = self.Limits.X, self.Limits.Y, self.Limits.Z
				self.Position = Vector3.new(math.clamp(self.Position.X, -x, x), math.clamp(self.Position.Y, -y, y), math.clamp(self.Position.Z, -z, z))
			end
		end
	else
		local force = self.Target - self.Position
		local acceleration = (force * self.Force) / self.Mass

		acceleration = acceleration - self.Velocity * self.Damping

		self.Velocity = self.Velocity + acceleration * scaledDeltaTime
		self.Position = self.Position + self.Velocity * scaledDeltaTime

		if self.LimitsEnabled then
			local x: number, y: number, z: number = self.Limits.X, self.Limits.Y, self.Limits.Z
			self.Position = Vector3.new(math.clamp(self.Position.X, -x, x), math.clamp(self.Position.Y, -y, y), math.clamp(self.Position.Z, -z, z))
		end
	end
	return self.Position
end

return module