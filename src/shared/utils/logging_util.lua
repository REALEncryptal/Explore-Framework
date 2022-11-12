local logging = {}

--[[

== [TODO] ==
1. Implement ui console.
2. Add hover tools for logs
3. Add timestamps.
4. Change logging system to automatically detect the script and its context

--]]

function logging.log(Name, Section, Info)
  print("["..Name.." > "..Section.."] "..Info)
end

function logging.warn(Name, Section, Info)
  warn("["..Name.." > "..Section.."] "..Info)
end

logging.debug = {}
logging.debug.log = {}

local ui = game.Players.LocalPlayer.PlayerGui:WaitForChild("Logging").Frame
local line = game.ReplicatedStorage.Assets.Line

function logging.debug.init()
  game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    for _,v in pairs(ui:GetChildren()) do
      if v.Name == "Line" then
        v:Destroy()
      end
    end

    for _, text in pairs(logging.debug.log) do
      local item = line:Clone()
      item.Text = text
      item.Parent = ui
    end
    
    logging.debug.log = {}
  end)
end

function logging.debug.add(x)
  table.insert(logging.debug.log, x)
end

return logging