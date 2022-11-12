local logging_util = require(game.ReplicatedStorage.Common.utils.logging_util)

return {
build = function(vm, equipment, data)
  if  data.Actions["Build"] then
    data.Actions.Build(vm, equipment)
  else
    logging_util.warn("vm_builder_util", "build", "missing build function!")
  end
end
}
