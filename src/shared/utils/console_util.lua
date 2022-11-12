local console = {}
local ui = game.Players.LocalPlayer.PlayerGui
local shared_loadout_util = require(game.ReplicatedStorage.Common.utils.shared_loadout_util)
local network_util = require(game.ReplicatedStorage.Common.utils.network_util)

console.errors = {}
console.errors.CMD = "command doesnt exist"
console.errors.ARG = "argument error"

console.commands = {}



function console.call(text)
    text = string.split(text, ' ')
    local command = console.commands[string.lower(text[1])]

    if not command then return "ERR", console.errors.CMD end

    table.remove(text, 1)

    return command(text)
end

function console.insertReaction(name, parent, callback)
    parent[name] = callback
end

function ToBool(x)
    if x == "true" then
        return true
    else
        return false
    end
end

function ToInt(x)
    for i,v in pairs(x) do
        x[i] = tonumber(v)
    end

    return x
end

function ToRad(x)
    for i,v in pairs(x) do
        x[i] = math.rad(v)
    end

    return x
end

function toVector(x)
    x = string.split(x, '(')

    if x[1] == 'cf' or x[1] == 'cframe' then
        return CFrame.new(unpack(
            ToInt(string.split(
               string.gsub(x[2],'%)',''),
                ','
            ))
        ))
    elseif x[1] == 'v3' or x[1] == 'vector3' then
        return Vector3.new(unpack(
            ToInt(string.split(
               string.gsub(x[2],'%)',''),
                ','
            ))
        ))
    elseif x[1] == 'a' or x[1] == 'angles' then
        return CFrame.Angles(unpack(
            ToRad(ToInt(string.split(
               string.gsub(x[2],'%)',''),
                ','
            )))
        ))
    end
end

--- ADD COMMANDS

console.insertReaction("window", console.commands, function(args)
    if #args ~= 2 then return "ERR", console.errors.ARG end

    if args[1] == "debug" or args[1] == "log" or args[1] == "logging" then
        ui.Logging.Enabled = ToBool(args[2])
    else
        return "ERR", "window doesnt exist"
    end

    return 'CMD', ''
end)

console.insertReaction("player", console.commands, function(args)
    if #args ~= 2 then return "ERR", console.errors.ARG end

    if args[1] == "speed" then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(args[2])
    elseif args[1] == "jump" or args[1] == "jumppower" then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = tonumber(args[2])
    elseif args[1] == "health" or args[1] == "hp" then
        game.Players.LocalPlayer.Character.Humanoid.Health = tonumber(args[2])
    else
        return "ERR", "window doesnt exist"
    end

    return 'CMD', ''
end)

console.insertReaction("tool", console.commands, function(args)
    if not (#args >= 2) then return "ERR", console.errors.ARG end

    if args[1] == "offset" or  args[1] == "o"then
        shared_loadout_util.loadout[tonumber(args[2])].Offsets[args[3]] = toVector(args[4])
    elseif args[1] == "data" or  args[1] == "d"then
        local data = shared_loadout_util.loadout[tonumber(args[2])].Data.Data

        data[args[2]] = args[3]
    elseif args[1] == "list" then
        if args[2] == "offset" or  args[2] == "o"then
            print(shared_loadout_util.loadout[args[2]].Offsets)
        end
    end

    return 'CMD', ''
end)

console.insertReaction("game", console.commands, function(args)
    if not (#args >= 2) then return "ERR", console.errors.ARG end

    if args[1] == "canstart" or  args[1] == "cs" then
        network_util.Call("StartGame", {ToBool(args[2])})
    elseif args[1] == "stop" or  args[1] == "s" then
        network_util.Call("StopGame", {})
    end

    return 'CMD', ''
end)

return console