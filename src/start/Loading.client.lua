-- Timestamp // 01/27/2023 12:04:10 MNT
-- Author // @iohgoodness
-- Description // For loading the player into the game
--// I do love coding fun intro animations, my "art style" is normally more directed, but I will certainly try on my own too!

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function Enable()
    UserInputService.ModalEnabled = false
    ContextActionService:UnbindAction("freezeMovement")
end
local function Disable()
    UserInputService.ModalEnabled = true
    ContextActionService:BindAction(
        "freezeMovement",
        function() return Enum.ContextActionResult.Sink end,
        false,
        unpack(Enum.PlayerActions:GetEnumItems())
    )
end

task.spawn(function()
    for i=1, 20 do
        pcall(function() Disable() end)
        task.wait(.1)
    end
end)

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ContentProvider = game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")

function Tween(obj, properties, timer, easingStyle)
    TweenService:Create(obj, TweenInfo.new(timer or 3, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
for _,v in pairs(playerGui:GetChildren()) do v.Enabled = false end
local character = player.Character or player.CharacterAdded:Wait()

local ColorCorrection = game.Lighting:WaitForChild('ColorCorrection')
local DepthOfField = game.Lighting:WaitForChild('DepthOfField')
DepthOfField.FarIntensity = .9
local Blur = game.Lighting:WaitForChild('Blur')
Blur.Size = 28

ContentProvider:PreloadAsync({ })

ColorCorrection.TintColor = Color3.new(0, 0, 0)

ReplicatedFirst:RemoveDefaultLoadingScreen()

if not game:IsLoaded() then game.Loaded:Wait() end

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)

local humanoid = character:WaitForChild('Humanoid')
humanoid.WalkSpeed = 2
task.delay(1, function() Tween(humanoid, {WalkSpeed = 16}, 1, Enum.EasingStyle.Linear) end)
Tween(DepthOfField, {FarIntensity = .134}, 3.8)
Tween(Blur, {Size = 0}, 5)
humanoid:MoveTo(workspace:WaitForChild('SpawnLocation'):WaitForChild('Part').Position)

local cam = workspace.CurrentCamera
cam.CameraType = Enum.CameraType.Scriptable
local y,z = 45,60
RunService:BindToRenderStep('cam-intro', 1, function(dt)
    y-=dt*14
    z-=dt*14
    cam.CFrame = CFrame.new( (character:GetPivot()*CFrame.new(8, math.clamp(y, 4, 40), math.clamp(z, 8, 60))).Position, character:GetPivot().Position )
end)
task.delay(4.8, function()
    RunService:UnbindFromRenderStep('cam-intro')
    local ay = 0
    local cf = character:GetPivot() * CFrame.Angles(0, ay, ay*.1) * CFrame.new(8, -1, 8)
    Tween(cam, {CFrame = CFrame.new(cf.Position, character:GetPivot().Position)}, .2, Enum.EasingStyle.Linear)
    task.wait(.2)
    local v = 1.8
    RunService:BindToRenderStep('cam-intro', 1, function(dt)
        local cframe = character:GetPivot() * CFrame.Angles(0, ay, ay*.1) * CFrame.new(8, -1, 8)
        cam.CFrame = CFrame.new(cframe.Position, character:GetPivot().Position)
        ay+=dt*v
    end)
    task.wait(3)
    for i=1.8, .1, -.1 do v=i task.wait(.01) end
    RunService:UnbindFromRenderStep('cam-intro')
end)

--[[
    --# Quick trick to convert emotes into animation ids
    local id = '3823158750';local is = game:GetService('InsertService');print(is:LoadAsset(id):FindFirstChildOfClass'Animation'.AnimationId)
    10714347256
]]

local function Animate()
    local Animator = humanoid:WaitForChild("Animator")
    local animation = Instance.new('Animation')
    animation.AnimationId = 'rbxassetid://10214311282'
    local track = Animator:LoadAnimation(animation)
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = false
    track:Play()
end

Tween(ColorCorrection, {TintColor = Color3.new(1, 1, 1)}, 7)
task.delay(3, function() Animate(); end)
task.delay(6, function() humanoid.WalkSpeed = 16; for _,v in pairs(playerGui:GetChildren()) do v.Enabled = true; Enable(); cam.CameraType = Enum.CameraType.Custom; end end)