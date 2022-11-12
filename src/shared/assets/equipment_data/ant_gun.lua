return {
  Data = {
    EquipTime = 1,
    Model = "ant_gun",
    Animations = {
      ["Equip"] = 11041884487,
      ["Idle"] = 11041608965,
      ["Use"] = 11041853460
    },
    DefaultOffset = CFrame.new(0,0,-1)
  },

  Varibles = {
    Shits = 10,
    Debounce = true,
    DebounceTime = 1
  },

  Actions = {
    Controls = {
      [Enum.UserInputType.MouseButton1] = function(self, InputBegan)
        if not InputBegan then return end
        if self.Varibles.Debounce then
          self.Varibles.Debounce = false
          self.Animator:play("Use")
          print("ant go shit")
          task.wait(self.Varibles.DebounceTime)
          self.Varibles.Debounce = true
        end
      end
    },

    OnEquip = function(self)
      
    end,
    
    OnUnequip = function(self)
      self.Animator:stop("Idle")
    end
  }
}