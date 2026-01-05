-- [[ KA HUB - VERSÃO COMPATIBILIDADE MÁXIMA ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- Garantir que a GUI antiga seja apagada antes de iniciar
if PlayerGui:FindFirstChild("KA_SIMPLE") then PlayerGui.KA_SIMPLE:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KA_SIMPLE"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

-- PAINEL PRINCIPAL (SIMPLES)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 220)
Main.Position = UDim2.new(0, 50, 0, 50)
Main.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "KA HUB V8 - LIGHT"
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

-- VARIÁVEIS
local Clicking = false
local Aimbot = false
local ESP = false
local ClickCount = 0

-- MIRA (SÓ UM PONTO VERMELHO NO MEIO PARA TESTE)
local Mira = Instance.new("Frame", ScreenGui)
Mira.Size = UDim2.new(0, 10, 0, 10)
Mira.Position = UDim2.new(0.5, -5, 0.5, -5)
Mira.BackgroundColor3 = Color3.new(1, 0, 0)
Mira.Active = true
Mira.Draggable = true -- VOCÊ PODE ARRASTAR A MIRA

-- FUNÇÃO CRIAR BOTÃO
local function CreateBtn(text, pos, callback)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = pos
    b.Text = text .. ": OFF"
    b.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    b.TextColor3 = Color3.new(1,1,1)
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text .. ": " .. (state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.new(0, 0.5, 0) or Color3.new(0.3, 0.3, 0.3)
        callback(state)
    end)
end

-- BOTÕES
CreateBtn("AUTO CLICK", UDim2.new(0.05, 0, 0, 40), function(v) Clicking = v end)
CreateBtn("AIMBOT", UDim2.new(0.05, 0, 0, 90), function(v) Aimbot = v end)
CreateBtn("ESP", UDim2.new(0.05, 0, 0, 140), function(v) ESP = v end)

-- LÓGICA DE CLIQUE (HEARTBEAT - ULTRA RÁPIDO)
RunService.Heartbeat:Connect(function()
    if Clicking then
        local pos = Mira.AbsolutePosition + (Mira.AbsoluteSize / 2)
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end
end)

-- LÓGICA AIMBOT & ESP
RunService.RenderStepped:Connect(function()
    if Aimbot then
        local target = nil
        local dist = 200
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
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

    if ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    local h = Instance.new("Highlight", p.Character)
                    h.FillColor = Color3.new(1, 0, 0)
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Highlight") then
                p.Character.Highlight:Destroy()
            end
        end
    end
end)
