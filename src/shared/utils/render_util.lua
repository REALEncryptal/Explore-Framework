local renderer = {}

renderer.renderVaribles = {}
renderer.renderStack = {}
renderer.connection = nil


function renderer.hookVar(varibleName, initialValue)
  renderer.renderVaribles[varibleName] = initialValue
end

function renderer.hookFunc(name, func)
  renderer.renderStack[name] = func
end

function renderer.delFunc(name)
  renderer.renderStack[name] = nil
end

function renderer.init()
  renderer.connection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    for _, func in pairs(renderer.renderStack) do
      renderer.renderVaribles = func(deltaTime, renderer.renderVaribles)
    end
  end)
end

function renderer.disconnect()
  renderer.connection:Disconnect()
end

return renderer