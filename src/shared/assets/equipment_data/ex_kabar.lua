return {
    Data = {
      EquipTime = 1,
      Model = "exp_kabar",
      Animations = {
        ["Equip"] = 11297706345,
        ["Idle"] = 11297714316
      },
      DefaultOffset = CFrame.new(-.6,0,-.5)
    },
  
    Varibles = {
      Damage = 10,
      Speed = 1
    },
  
    Actions = {
      Build = function(vm, weapon)
        weapon.Parent = vm
        weapon.Handle2.Main.Part0 = vm.HumanoidRootPart
  
        return vm
      end,
      
      Update = function(self, deltatime)
        
      end,
  
      Controls = {
        [Enum.UserInputType.MouseButton1] = function(Equipment, InputBegan)
          if not InputBegan then return end
          print("WOW SLICE AWND DICE!")
        end
      },
  
      OnEquip = function(self)
        
      end,
      
      OnUnequip = function(self)
        self.Animator:stop("Idle")
      end
    }
  }