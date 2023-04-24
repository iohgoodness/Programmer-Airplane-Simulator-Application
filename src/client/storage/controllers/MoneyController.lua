-- Timestamp // 01/27/2023 12:53:29 MNT
-- Author // @iohgoodness
-- Description // Money handling
--// Using Knit, we listen to the service signal/remote for a value update of money

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MoneyController = Knit.CreateController { Name = "MoneyController" }

local frontScreenGui = Knit.playerGui:WaitForChild('Front')
local valuesFrame = frontScreenGui:WaitForChild('Values')
local moneyLabel = valuesFrame:WaitForChild('Money')

local QuadBezier = Knit.common.Math.QuadBezier
local Abbreviate = Knit.common.Math.Abbreviate
local ConvertToCommas = Knit.common.Math.ConvertToCommas
local Tween = Knit.common.Interface.Tween

--// A UI animation that I made in the past for a fun "ROBLOX" style cartoonish money floating animation
--// This is an effective demonstration of mathematics/tweens/"threading" applied to the client's UI to make game feel more "rewarding/satisfying"
function MoneyController:AnimateNewMoney(change, special)
    task.spawn(function()
        local t = self._moneyText:Clone()
        t.Text = '$' .. ConvertToCommas(change)
        local tsize = t.Size
        t.Position = UDim2.fromScale(t.Position.X.Scale*(math.random(98, 102)/100), t.Position.Y.Scale*(math.random(98, 102)/100))
        t.Size = UDim2.fromScale(0, 0)
        if special then t.TextColor3 = Color3.fromRGB(214, 0, 221); Tween(t, {TextColor3 = Color3.fromRGB(0, 199, 221)}, 0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut) end
        t.Visible = true
        t.Rotation = math.random(-1,1)==-1 and -3 or 3
        t.Parent = self._parent
        if special then
            Tween(t, {Size = UDim2.fromScale(tsize.X.Scale*(math.random(28, 30)/10), tsize.Y.Scale*(math.random(28, 30)/10))}, 0.31, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        else
            Tween(t, {Size = UDim2.fromScale(tsize.X.Scale*(math.random(16, 18)/10), tsize.Y.Scale*(math.random(16, 18)/10))}, 0.31, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        end
        task.delay(.91, function()
            Tween(t, {Size = UDim2.fromScale(0, 0)}, 0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(t, {TextTransparency = 1}, 0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(t.UIStroke, {Transparency = 1}, 0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.delay(.24+.1, function() t:Destroy() end)
        end)
        local p0 = Vector2.new(t.Position.X.Scale, t.Position.Y.Scale)
        local p1 = Vector2.new(t.Position.X.Scale*(math.random(98,102)/100), t.Position.Y.Scale*(math.random(95,96)/100))
        local p2 = Vector2.new(t.Position.X.Scale*(math.random(98,102)/100), t.Position.Y.Scale*(math.random(84,87)/100))
        local tk = 0
        local tempBindName = 'money-'..os.clock()..tostring(math.random(0, 1000))
        RunService:BindToRenderStep(tempBindName, 7, function(dt)
            if not t then RunService:UnbindFromRenderStep(tempBindName) return end
            local vec2 = QuadBezier(tk, p0, p1, p2)
            t.Position = UDim2.new(vec2.X, 0, vec2.Y, 0)
            tk+=(dt*1.4)
        end)
        repeat task.wait() until tk>=2
        RunService:UnbindFromRenderStep(tempBindName)
    end)
    for i=1, 6 do
        task.spawn(function()
            local m = self._moneyImgs[i]:Clone()
            local size = m.Size
            m.Position = UDim2.fromScale(m.Position.X.Scale*(math.random(96, 104)/100), m.Position.Y.Scale*(math.random(99, 101)/100))
            m.Size = UDim2.fromScale(0, 0)
            m.Visible = true
            m.Parent = self._parent
            Tween(m, {Size = UDim2.fromScale(size.X.Scale*.89, size.Y.Scale*.89)}, 0.51, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.delay(.71, function()
                Tween(m, {Size = UDim2.fromScale(0, 0)}, 0.31, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                Tween(m, {ImageTransparency = 1}, 0.29, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                task.delay(.31+.1, function() m:Destroy() end)
            end)
            local p0 = Vector2.new(m.Position.X.Scale, m.Position.Y.Scale)
            local p1 = Vector2.new(m.Position.X.Scale*(math.random(98,102)/100), m.Position.Y.Scale*(math.random(95,96)/100))
            local p2 = Vector2.new(m.Position.X.Scale*(math.random(98,102)/100), m.Position.Y.Scale*(math.random(84,87)/100))
            local tk = 0
            local tempName = 'money-'..os.clock()..tostring(math.random(0, 1000)..tostring(i))
            RunService:BindToRenderStep(tempName, 7, function(dt)
                if not m then RunService:UnbindFromRenderStep(tempName) return end
                local vec2 = QuadBezier(tk, p0, p1, p2)
                m.Position = UDim2.new(vec2.X, 0, vec2.Y, 0)
                tk+=(dt*1.4)
            end)
            repeat task.wait() until tk>=2
            RunService:UnbindFromRenderStep(tempName)
        end)
    end
end

--# Setting up the client to handle the money animations
function MoneyController:KnitStart()
    self._parent = Knit.playerGui:WaitForChild('Animations')
    self._moneyImgs = {}
    for i=1, 6 do
        local mImg = self._parent:WaitForChild(tostring('m'..i))
        table.insert(self._moneyImgs, mImg:Clone())
        mImg:Destroy()
    end
    self._moneyText = self._parent:WaitForChild('Money')

    local MoneyService = Knit.GetService("MoneyService")
    MoneyService.UpdateMoney:Connect(function(money, change)
        change = change or 0
        moneyLabel.Text = `$ {Abbreviate(money)}`
        if change > 0 then
            self:AnimateNewMoney(change)
        end
    end)
end

return MoneyController
