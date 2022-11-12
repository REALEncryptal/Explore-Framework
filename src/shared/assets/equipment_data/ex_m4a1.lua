local player_util = require(game.ReplicatedStorage.Common.utils.player_util)
local logging_util = require(game.ReplicatedStorage.Common.utils.logging_util)
local cast_util = require(game.ReplicatedStorage.Common.utils.cast_util)
return {
  Data = {
    EquipTime = false,
    Independent = true,
    Model = "ex_m4a1",
    Animations = {
      ["Equip"] = 11330612670,
      ["Unequip"]= 11330616772,
      ["Fire"] = 11330614594,
      ["Reload"] = 11330611269,
      ["ReloadE"] = 11330610059,
      ["Idle"] = 11330741304
    },
    DefaultOffset = CFrame.new(0,-1.7,0) * CFrame.Angles(math.rad(6),0,0),
    Springs = {  -- Mass:5 Force:50 Damping:4 Speed:4 HasLimit Limit
      ["Sway"] = {10, 50, 5, 4, false},
      ["Walk"] = {5, 50, 5, 2 , false},
      ["Jitter"] = {10, 50, 5, 3, false},
      ["Breathing"] = {10, 50, 5, 3, false},
    }
  },

  Varibles = {
    Ammo = 10,
    Damage = 10,
    Speed = 1,
    AimTime = .2,
    rpm = 200,
    ShootDebounce = true,
    Aiming = false,
    Reloading = false,
    UI = nil
  },

  Actions = {
    Build = function(vm)
      return vm
    end,
    
    Update = function(self, deltatime)
      local MouseDelta = game:GetService("UserInputService"):GetMouseDelta()


      if not self.Varibles.Aim then
        self.Varibles.Aim = Instance.new("CFrameValue")
      end

      
      self.Springs.Sway:Shove(Vector3.new(MouseDelta.X/200, -MouseDelta.Y/200, 0))
      local Sway = self.Springs.Sway:Update(deltatime)

      if player_util.Walking() then
        local freq = 7
        local mag = .1
        local TICK = tick()

        local wave =  CFrame.new(
          math.cos(TICK*freq)* mag,
          math.sin(TICK*freq*2)* mag,
          0 )

        self.Springs.Walk:Shove(wave)
      else
        self.Springs.Jitter:Shove(Vector3.new((math.random(-10,10)/2000), (math.random(-10,10)/2000), 0))
        self.Springs.Breathing:Shove(Vector3.new(
        math.cos(tick())*.001,
        math.sin(tick()*2)*.01,
        0
      ))
      end
      local Walk = CFrame.new(self.Springs.Walk:Update(deltatime))
      local Jitter = CFrame.new(self.Springs.Jitter:Update(deltatime))
      local CycleMag = 10

      local Breathing =  CFrame.new(self.Springs.Breathing:Update(deltatime))

      self.Offsets.Sway = self.Varibles.Aim.Value * CFrame.new(Sway) * self.Utils.Angles(Sway.Y*30, -Sway.X*30) * self.Utils.Angles(Walk.Y*CycleMag, Walk.X*CycleMag, Walk.X*CycleMag/2) * Jitter * Breathing
      --add debug
      logging_util.debug.add(" ShootDebounce: "..tostring(self.Varibles.ShootDebounce))
      logging_util.debug.add(" Reloading: "..tostring(self.Varibles.Reloading))
      logging_util.debug.add(" Ammo: "..tostring(self.Varibles.Ammo))
      logging_util.debug.add(" FPS  : "..tostring(math.round(1/deltatime)))
    end,

    Controls = {
      [Enum.UserInputType.MouseButton1] = function(self, InputBegan)
        if not InputBegan then return end
        if not self.Varibles.ShootDebounce then return end
        self.Varibles.ShootDebounce = false
        if self.Varibles.Reloading then
          self.Varibles.Reloading = false
          self.Animator:stop("ReloadE")
        end
        
        task.spawn(function()
          print(cast_util.fire(
          (workspace.CurrentCamera.CFrame.LookVector - workspace.CurrentCamera.CFrame.Position).Unit,
          -4,4,
          100,
          workspace.CurrentCamera.CFrame
          ))
        end)

        local fx = self.Viewmodel.Fire:Clone()
        fx.Parent = workspace.CurrentCamera
        fx:Play()
        task.spawn(function()
          self.Viewmodel.MuzzlePart.Light.Enabled = true
          wait(.05)
          self.Viewmodel.MuzzlePart.Light.Enabled = false
        end)
        self.Viewmodel.MuzzlePart.muzzle:Emit(10)
        self.Viewmodel.MuzzlePart.smoke:Emit(10)
        game:GetService("Debris"):AddItem(fx, 2)
        
        self.Animator:play("Fire")
        self.Varibles.Ammo -= 1
        self.Varibles.UI.Text = self.Varibles.Ammo
        task.wait(60/self.Varibles.rpm)
        self.Varibles.ShootDebounce = true
      end,
      [Enum.KeyCode.R] = function(self, InputBegan)
        if not InputBegan then return end
        if self.Varibles.Reloading then return end
        self.Varibles.Reloading = true
        wait(self.Animator:play("ReloadE"))
        if not self.Varibles.Reloading then return end
        self.Varibles.Ammo = 10
        self.Varibles.UI.Text = self.Varibles.Ammo
        self.Varibles.Reloading = false
      end,
      [Enum.UserInputType.MouseButton2] = function(self, InputBegan) -- Aim
        if InputBegan and not self.Varibles.Reloading and false then
          self.Varibles.Aiming = true
          self.Varibles.AimTween = game:GetService("TweenService"):Create(self.Varibles.Aim,TweenInfo.new(self.Varibles.AimTime,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Value=self.Viewmodel.AimPart.CFrame:ToObjectSpace(workspace.Camera.CFrame)})
          self.Varibles.AimTween:Play()
        else
          self.Varibles.AimTween:Cancel()
          game:GetService("TweenService"):Create(self.Varibles.Aim,TweenInfo.new(self.Varibles.AimTime,Enum.EasingStyle.Exponential,Enum.EasingDirection.InOut),{Value=CFrame.new()}):Play()
        end
      end
    },

    OnEquip = function(self)
      self.Varibles.UI = self.Viewmodel.WeaponData:Clone()
      self.Varibles.UI.Parent = game.Players.LocalPlayer.PlayerGui.ScreenGui.WeaponFrame
      self.Varibles.UI.Text = self.Varibles.Ammo

      cast_util.hook("hit",function(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
        print(cast, raycastResult, segmentVelocity, cosmeticBulletObject)
      end)
    end,
    
    OnUnequip = function(self)
      if self.Varibles.UI then
        self.Varibles.UI:Destroy()
      end
      cast_util.hook("hit",function(cast, raycastResult, segmentVelocity, cosmeticBulletObject)end)
    end
  }
}