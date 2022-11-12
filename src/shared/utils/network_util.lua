local network = {}

local callbacks = {}
callbacks.UpdatedLoadout = function()end

network.RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("networkF")
network.RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("networkE")

function network.GetLoadout()
  return network.RemoteFunction:InvokeServer("GetLoadout")
end

function network.RequestEquip(slot)
  return network.RemoteFunction:InvokeServer("RequestEquip", slot)
end

function network.Call(...)
  network.RemoteEvent:FireServer(...)
end

function network.hook(name, func)
  callbacks[name] = func
end

network.RemoteEvent.OnClientEvent:Connect(function(Type, Args)
  Args = Args or {}
  callbacks[Type](unpack(Args))
end)

return network