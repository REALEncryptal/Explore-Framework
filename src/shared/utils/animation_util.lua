local animation = {}
animation.__index = animation

function animation.new(model, animationsList)
	local self = setmetatable({},animation)

	self.model = model
	self.animator = model:FindFirstChild("Animator", true)

  self.cache = {}
  for name, id in pairs(animationsList) do
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://"..tostring(id)
    self.cache[name] = self.animator:LoadAnimation(anim)
  end 

	return self
end

function animation:play(name, speed)
  speed = speed or 1
	self.cache[name]:AdjustSpeed(speed)
  self.cache[name]:Play()
  self.cache[name]:AdjustSpeed(1)
  return self.cache[name].Length
end

function animation:lplay(name, length)
	self.cache[name]:AdjustSpeed(self.cache[name].Length/length)
  self.cache[name]:Play()
  self.cache[name]:AdjustSpeed(1)
end

function animation:fplay(name, time)
  self.cache[name]:AdjustSpeed(0)
  self.cache[name]:Play()
  self.cache[name].TimePosition = time or 0
end

function animation:stop(name)
  self.cache[name]:Stop()
end

function animation:get(name)
  return self.cache[name]
end

return animation
