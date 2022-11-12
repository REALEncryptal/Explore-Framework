local util = {}

function lockXY(x)
    return Vector3.new(
        x.X,
        0,
        x.Y
    )
end

util.Walking = function()
    return game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0 
end

return util