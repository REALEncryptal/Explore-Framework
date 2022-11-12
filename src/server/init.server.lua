local loadout_util = require(game:GetService("ReplicatedStorage").Common.utils.loadout_util)

local NetworkEvent = game.ReplicatedStorage.networkE 
local NetworkFunction = game.ReplicatedStorage.networkF

local Teams = game:GetService("Teams")

function check()
    return #game.Players:GetPlayers() >= 2
end

function listHalf(list)
    local nohalf = math.round(#list/2)
    local half = {}
    local otherhalf = {}
  
    for i=1,#list do
      if i <= nohalf then
        half[i] = list[i]
      else
        otherhalf[i] = list[i]
      end
    end
  
    return half, otherhalf, list
end

function getSpawn(path)
  local spawns = game.Workspace.Map.Zones.Spawns[path]
  return spawns:GetChildren()[math.random(1, #spawns:GetChildren())].Position
end

local CanStart = false
local InGame = false
local Score = {0,0}
local fullA

function StopGame()
  InGame = false
  Score = {0,0}

  for _,plr in pairs(fullA) do
    plr.TeamColor = BrickColor.new("White")
    plr.Character.Humanoid:TakeDamage(999)
  end
end

NetworkEvent.OnServerEvent:Connect(function(Player, Type, Data)
  if Type == "DamagePlayer" then
    Data["Victim"].Character.Humanoid:TakeDamage(Data["Damage"])

    if Data["Victim"].Character.Humanoid.Health <= 0 and InGame then
      if Data["Victim"].TeamColor == BrickColor.new('Really red') then
        Score[2] += 1
      else
        Score[1] += 1
      end

      NetworkEvent:FireAllClients("UpdateScore", Score)

      if Score[1] > (#game.Players:GetPlayers() * 7) or  Score[1] > (#game.Players:GetPlayers() * 7) then
        InGame = false
        Score = {0,0}

      end
    end
  elseif Type=="StartGame" then
    if Player.Name == "Encryptal" then
      CanStart = Data[1]
    end
  elseif Type=="StopGame" then
    if Player.Name == "Encryptal" then
      StopGame()
    end
  end
end)

while true do
    if #game.Players:GetPlayers() > 0 and CanStart then
      task.wait(4)
      InGame = true
      Score = {0,0}
      NetworkEvent:FireAllClients("ToggleTDM", {true})
      NetworkEvent:FireAllClients("NewLoadout", {{"NONE","NONE","NONE"}})
      local red, blue, full = listHalf(game.Players:GetPlayers())
      fullA = full

      for _,player in pairs(full) do
        player.Character.Humanoid.JumpHeight = 0
      end

      for _,player in ipairs(red) do
          player.TeamColor = BrickColor.new('Really red')
          player.Character:MoveTo(getSpawn("Alphas"))
      end

      for _,player in ipairs(blue) do
          player.TeamColor = BrickColor.new('Really blue')
          player.Character:MoveTo(getSpawn("Deltas"))
      end

      task.wait(1)
      for i=10,0,-1 do
        NetworkEvent:FireAllClients("UpdateCountdown", {i})
        task.wait(1)
      end
      NetworkEvent:FireAllClients("EndCountdown")
      NetworkEvent:FireAllClients("NewLoadout", {{"ex_m4a1","NONE","NONE"}})

      for _,player in pairs(full) do
        player.Character.Humanoid.JumpHeight = 2.3
      end

      for i = 180,0,-1 do
        if not InGame then return end
        task.wait(1)
      end

      InGame = false
      Score = {0,0}

      for _,plr in pairs(full) do
        plr.TeamColor = BrickColor.new("White")
        plr.Character.Humanoid:TakeDamage(999)
      end

      task.wait(20)

    else task.wait() end
end



