local util = {}
local FastCast = require(game.ReplicatedStorage.Assets.Modules.FastCastRedux)
local PartCacheModule = require(game.ReplicatedStorage.Assets.Modules.PartCache)


local RNG = Random.new()							-- Set up a randomizer.
local TAU = math.pi * 2							-- Set up mathematical constant Tau (pi * 2)
-- INIT

local Caster = FastCast.new()

local CastParams = RaycastParams.new()
CastParams.IgnoreWater = true
CastParams.FilterType = Enum.RaycastFilterType.Blacklist
CastParams.FilterDescendantsInstances = {game.Players.LocalPlayer, workspace.CurrentCamera}

local CosmeticBulletsFolder = workspace.Ignore.Bullets
local CosmeticPartProvider = PartCacheModule.new(game.ReplicatedStorage.Assets.CosmeticBullet, 100, workspace.Ignore.Bullets, CosmeticBulletsFolder)

local CastBehavior = FastCast.newBehavior()
CastBehavior.RaycastParams = CastParams
CastBehavior.MaxDistance = 1000
CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default

-- CastBehavior.CosmeticBulletTemplate = CosmeticBullet -- Uncomment if you just want a simple template part and aren't using PartCache
CastBehavior.CosmeticBulletProvider = CosmeticPartProvider -- Comment out if you aren't using PartCache.

CastBehavior.CosmeticBulletContainer = workspace.Ignore.Bullets
CastBehavior.Acceleration = Vector3.new(0, -workspace.Gravity, 0)
CastBehavior.AutoIgnoreContainer = false -- We already do this! We don't need the default value of true (see the bottom of this script)

-- Funcs
local Callbacks = {}
Callbacks.Updated =  function(cast, segmentOrigin, segmentDirection, length, segmentVelocity, cosmeticBulletObject)
    -- Whenever the caster steps forward by one unit, this function is called.
    -- The bullet argument is the same object passed into the fire function.
    if cosmeticBulletObject == nil then return end
    local bulletLength = cosmeticBulletObject.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
    local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
    cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

Callbacks.Hit = function(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
    
end

Callbacks.Terminated = function(cast)
	local cosmeticBullet = cast.RayInfo.CosmeticBulletObject
	if cosmeticBullet ~= nil then
		-- This code here is using an if statement on CastBehavior.CosmeticBulletProvider so that the example gun works out of the box.
		-- In your implementation, you should only handle what you're doing (if you use a PartCache, ALWAYS use ReturnPart. If not, ALWAYS use Destroy.
		if CastBehavior.CosmeticBulletProvider ~= nil then
			CastBehavior.CosmeticBulletProvider:ReturnPart(cosmeticBullet)
		else
			cosmeticBullet:Destroy()
		end
	end
end


function util.fire(direction, minSpread, maxSpread, bulletSpeed, FirePointObject)
    -- UPD. 11 JUNE 2019 - Add support for random angles.
    local directionalCF = CFrame.new(Vector3.new(), direction)
    -- Now, we can use CFrame orientation to our advantage.
    -- Overwrite the existing Direction value.
    local direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(minSpread, maxSpread)), 0, 0)).LookVector

    local modifiedBulletSpeed = (direction * bulletSpeed)-- + myMovementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.

    return Caster:Fire(FirePointObject.Position, direction, modifiedBulletSpeed, CastBehavior)
end

function util.hook(callbackType, callback)
    if Callbacks[callbackType] then
        Callbacks[callbackType] = callback 
    end
end

Caster.RayHit:Connect(Callbacks.Hit)
Caster.LengthChanged:Connect(Callbacks.Updated)
Caster.CastTerminating:Connect(Callbacks.Terminated)

return util