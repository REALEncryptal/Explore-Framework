local uis = game:GetService("UserInputService")

local util      ={}
util.sways      ={}
util.walkcycles ={}

util.sways.YSways ={}
util.sways.XSways ={}

util.sways.YSways.LeadingSway = function(spring, deltaTime)
    local MouseDelta = uis:GetMouseDelta()
    spring:shove()
end

return util