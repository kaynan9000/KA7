-- [[ KA HUB V8.1 - CUSTOM EDITION (NO EXTERNAL LIB) ]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- [[ VARIÁVEIS DE CONTROLE ]]
local Clicking = false
local AimbotEnabled = false
local EspEnabled = false
local ClickCount = 0
local LastClickCount = 0
local LastUpdate = tick()
local FOV = 150

-- [[ CRIAÇÃO DA INTERFACE PRINCIPAL ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KAHUB_V8"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(80, 150, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "KA HUB V8.1 - ULTIMATE"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

-- [[ BOTÕES ESTILIZADOS ]]
local function CreateToggleButton(name, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Name = name
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = name .. ": " .. (enabled and "ON" or "OFF")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(45, 45, 60)
        callback(enabled)
    end)
    return btn
end

local CPSLabel = Instance.new("TextLabel", MainFrame)
CPSLabel.Size = UDim2.new(1, 0, 0, 30)
CPSLabel.Position = UDim2.new(0, 0, 0, 45)
CPSLabel.Text = "CPS: 0"
CPSLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
CPSLabel.BackgroundTransparency = 1
CPSLabel.Font = Enum.Font.GothamBold

CreateToggleButton("Auto Clicker (V8)", UDim2.new(0.05, 0, 0, 80), function(v) Clicking = v end)
CreateToggleButton("Aimbot (Lock Head)", UDim2.new(0.05, 0, 0, 130), function(v) AimbotEnabled = v end)
CreateToggleButton("ESP (Highlights)", UDim2.new(0.05, 0, 0, 180), function(v) EspEnabled = v end)

local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0.9, 0, 0, 30)
Close.Position = UDim2.new(0.05, 0, 0, 270)
Close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Close.Text = "FECHAR SCRIPT"
Close.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- [[ MIRA FLUTUANTE ARRASTÁVEL ]]
local CursorHitbox = Instance.new("Frame", ScreenGui)
CursorHitbox.Size = UDim2.new(0, 60, 0, 60)
CursorHitbox.Position = UDim2.new(0.5, -30, 0.5, -30)
CursorHitbox.BackgroundTransparency = 1
CursorHitbox.Active = true
CursorHitbox.Draggable = true

local Cross1 = Instance.new("Frame", CursorHitbox)
Cross1.Size = UDim2.new(1, 0, 0, 2)
Cross1.Position = UDim2.new(0, 0, 0.5, -1)
Cross1.BackgroundColor3 = Color3.new(1, 1, 1)

local Cross2 = Instance.new("Frame", CursorHitbox)
Cross2.Size = UDim2.new(0, 2, 1, 0)
Cross2.Position = UDim2.new(0.5, -1, 0, 0)
Cross2.BackgroundColor3 = Color3.new(1, 1, 1)

-- [[ LÓGICA CORE ]]

-- High Speed Clicker
RunService.Heartbeat:Connect(function()
    if Clicking then
        local pos = CursorHitbox.AbsolutePosition + CursorHitbox.AbsoluteSize/2
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        ClickCount = ClickCount + 1
    end
end)

-- Aimbot & ESP Loop
RunService.RenderStepped:Connect(function()
    -- Atualiza CPS
    if tick() - LastUpdate >= 1 then
        CPSLabel.Text = "CPS: " .. (ClickCount - LastClickCount)
        LastClickCount = ClickCount
        LastUpdate = tick()
    end

    -- Aimbot
    if AimbotEnabled then
        local target = nil
        local dist = FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then
                        dist = mag
                        target = p
                    end
                end
            end
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("KA_ESP")
            if EspEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "KA_ESP"
                    highlight.FillColor = Color3.new(1, 0, 0)
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end)

print("KA HUB CARREGADO COM SUCESSO!")
