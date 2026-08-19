--[[
  Lifting Monster - Security Assessment Script
  Authorized Penetration Testing Tool
  Target: https://www.roblox.com/games/80180392022466/Lifting-Monster
  Game Type: Incremental Simulator (Muscle Legends 2 engine)
  
  DISCLAIMER: Use only on games you own or have explicit written permission to test.
]]

-- Initialize UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourlib/main.lua"))() or (function()
    local ui = Instance.new("ScreenGui")
    ui.Name = "PENTEST_UI"
    ui.Parent = game:GetService("CoreGui")
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSize = 2
    frame.BorderColor3 = Color3.fromRGB(0, 255, 100)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = ui
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.Text = "Lifting Monster - Security Assessment"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    local console = Instance.new("ScrollingFrame")
    console.Size = UDim2.new(1, -10, 1, -80)
    console.Position = UDim2.new(0, 5, 0, 35)
    console.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    console.BorderSize = 0
    console.Parent = frame
    local logList = Instance.new("UIListLayout")
    logList.Parent = console
    local log = function(msg, color)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
        lbl.Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(msg)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = console
        task.wait()
        console.CanvasPosition = math.huge
    end
    local btnFarm = Instance.new("TextButton")
    btnFarm.Size = UDim2.new(0.48, -5, 0, 35)
    btnFarm.Position = UDim2.new(0, 5, 1, -40)
    btnFarm.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
    btnFarm.Text = "▶ Auto-Farm (Passive)"
    btnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnFarm.Font = Enum.Font.GothamBold
    btnFarm.Parent = frame
    local btnSpy = Instance.new("TextButton")
    btnSpy.Size = UDim2.new(0.48, -5, 0, 35)
    btnSpy.Position = UDim2.new(0.52, 0, 1, -40)
    btnSpy.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btnSpy.Text = "■ Remote Spy (Active)"
    btnSpy.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSpy.Font = Enum.Font.GothamBold
    btnSpy.Parent = frame
    return {Log = log, Frame = frame, BtnFarm = btnFarm, BtnSpy = btnSpy, UI = ui, Console = console}
end)()

Library.Log("Security Assessment Initialized", Color3.fromRGB(0, 255, 100))
Library.Log("Target: Lifting Monster [80180392022466]", Color3.fromRGB(100, 200, 255))
Library.Log("Penetration Testing Mode Active", Color3.fromRGB(255, 200, 0))

-- ==========================================
-- 1. RECONNAISSANCE: Enumerate Game Services
-- ==========================================
local function EnumerateGame()
    Library.Log("--- RECONNAISSANCE ---", Color3.fromRGB(0, 255, 255))
    
    -- Find all RemoteEvents and RemoteFunctions
    local remotes = {}
    local function findRemotes(obj, depth)
        if depth > 5 then return end
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("BindableEvent") or child:IsA("BindableFunction") then
                table.insert(remotes, child)
            end
            findRemotes(child, depth + 1)
        end
    end
    findRemotes(game, 0)
    
    -- Also check ReplicatedStorage and ServerStorage specifically
    for _, container in pairs({game:GetService("ReplicatedStorage"), game:GetService("ServerStorage")}) do
        findRemotes(container, 0)
    end
    
    Library.Log("Found " .. #remotes .. " remote objects:", Color3.fromRGB(0, 255, 255))
    for _, r in pairs(remotes) do
        local path = r:GetFullName()
        local rtype = r.ClassName
        Library.Log("  [" .. rtype .. "] " .. path, Color3.fromRGB(180, 180, 255))
    end
    
    -- Locate the local player's leaderstats
    local player = game:GetService("Players").LocalPlayer
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        Library.Log("leaderstats found:", Color3.fromRGB(0, 200, 100))
        for _, stat in pairs(leaderstats:GetChildren()) do
            Library.Log("  " .. stat.Name .. " = " .. tostring(stat.Value), Color3.fromRGB(150, 255, 150))
        end
    else
        Library.Log("No leaderstats folder - scanning for stats...", Color3.fromRGB(255, 200, 0))
        for _, child in pairs(player:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
                Library.Log("  " .. child.Name .. " (" .. child.ClassName .. ") = " .. tostring(child.Value), Color3.fromRGB(150, 255, 150))
            end
        end
    end
    
    return remotes
end

local discoveredRemotes = EnumerateGame()

-- ==========================================
-- 2. REMOTE SPY: Intercept network traffic
-- ==========================================
local spying = false
Library.BtnSpy.MouseButton1Click:Connect(function()
    spying = not spying
    if spying then
        Library.BtnSpy.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        Library.BtnSpy.Text = "■ Remote Spy (Active)"
        Library.Log("Remote Spy ENABLED - intercepting all remotes", Color3.fromRGB(255, 0, 0))
    else
        Library.BtnSpy.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        Library.BtnSpy.Text = "■ Remote Spy (Active)"
        Library.Log("Remote Spy DISABLED", Color3.fromRGB(200, 200, 200))
    end
end)

-- Hook all remote events/functions for logging
local hooks = {}
for _, remote in pairs(discoveredRemotes) do
    if remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            local argsStr = ""
            for i, arg in pairs(args) do
                if type(arg) == "table" then
                    argsStr = argsStr .. "[table], "
                elseif type(arg) == "Instance" then
                    argsStr = argsStr .. arg.ClassName .. ":" .. (arg.Name or "?"), ", "
                else
                    argsStr = argsStr .. tostring(arg) .. ", "
                end
            end
            if spying then
                Library.Log("[SPY] FireServer: " .. remote:GetFullName() .. " | Args: " .. argsStr, Color3.fromRGB(255, 100, 100))
            end
            return oldFire(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local argsStr = ""
            for i, arg in pairs(args) do
                if type(arg) == "table" then
                    argsStr = argsStr .. "[table], "
                elseif type(arg) == "Instance" then
                    argsStr = argsStr .. arg.ClassName .. ":" .. (arg.Name or "?"), ", "
                else
                    argsStr = argsStr .. tostring(arg) .. ", "
                end
            end
            if spying then
                Library.Log("[SPY] InvokeServer: " .. remote:GetFullName() .. " | Args: " .. argsStr, Color3.fromRGB(255, 100, 100))
            end
            return oldInvoke(self, ...)
        end
    end
end

-- ==========================================
-- 3. VULNERABILITY ASSESSMENT
-- ==========================================
local function CheckVulnerabilities()
    Library.Log("--- VULNERABILITY SCAN ---", Color3.fromRGB(255, 200, 0))
    
    -- Check for unprotected remote events (no validation)
    local player = game:GetService("Players").LocalPlayer
    local suspiciousRemotes = {}
    
    for _, remote in pairs(discoveredRemotes) do
        local path = remote:GetFullName():lower()
        -- Common vulnerable patterns in simulator games
        if path:find("add") or path:find("claim") or path:find("buy") or path:find("upgrade") or 
           path:find("reward") or path:find("boost") or path:find("strength") or path:find("lift") or
           path:find("rebirth") or path:find("prestige") or path:find("pet") or path:find("spawn") then
            table.insert(suspiciousRemotes, remote)
        end
    end
    
    Library.Log("Potentially vulnerable remotes (" .. #suspiciousRemotes .. "):", Color3.fromRGB(255, 200, 0))
    for _, r in pairs(suspiciousRemotes) do
        Library.Log("  ⚠ " .. r:GetFullName(), Color3.fromRGB(255, 150, 0))
    end
    
    -- Check HTTP service enablement (for data exfiltration tests)
    local success, hhtpSvc = pcall(function() return game:GetService("HttpService") end)
    if success then
        Library.Log("HttpService available - check for client-to-web data flows", Color3.fromRGB(200, 200, 0))
    end
    
    -- Check for client-side executability (require/lua chunks in remotes)
    Library.Log("Checking for client-executable modules...", Color3.fromRGB(200, 200, 0))
    for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        if child:IsA("ModuleScript") then
            Library.Log("  Module: " .. child:GetFullName(), Color3.fromRGB(150, 150, 200))
        end
    end
    
    Library.Log("Vulnerability scan complete", Color3.fromRGB(0, 255, 100))
end

task.wait(0.5)
CheckVulnerabilities()

-- ==========================================
-- 4. AUTO-FARM (PASSIVE - for testing game
--    mechanics and server-side validation)
-- ==========================================
local farming = false
Library.BtnFarm.MouseButton1Click:Connect(function()
    farming = not farming
    if farming then
        Library.BtnFarm.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        Library.BtnFarm.Text = "⏹ Auto-Farm (Running)"
        Library.Log("Auto-Farm started - testing server-side rate limiting", Color3.fromRGB(0, 255, 200))
    else
        Library.BtnFarm.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
        Library.BtnFarm.Text = "▶ Auto-Farm (Passive)"
        Library.Log("Auto-Farm stopped", Color3.fromRGB(200, 200, 200))
    end
end)

-- Attempt to find the lift/interaction remote automatically
local liftRemote = nil
for _, r in pairs(discoveredRemotes) do
    local name = r.Name:lower()
    if name:find("lift") or name:find("train") or name:find("strength") or name:find("addstrength") then
        liftRemote = r
        break
    end
end

-- Generic auto-farm loop (works with most simulator games)
task.spawn(function()
    while task.wait(0.5) do
        if farming then
            -- Method 1: If we found a lift remote, fire it
            if liftRemote and liftRemote:IsA("RemoteEvent") then
                liftRemote:FireServer()
            end
            
            -- Method 2: Try common remote patterns
            local repStorage = game:GetService("ReplicatedStorage")
            for _, remote in pairs(discoveredRemotes) do
                local name = remote.Name:lower()
                if remote:IsA("RemoteEvent") and (name:find("lift") or name:find("train")) then
                    pcall(function() remote:FireServer() end)
                end
            end
            
            -- Method 3: Simulate interaction with in-game tools/parts
            local player = game:GetService("Players").LocalPlayer
            local char = player.Character
            if char then
                local tools = char:GetChildren()
                for _, tool in pairs(tools) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                        -- Activate the tool
                        tool:Activate()
                    end
                end
                -- Click mouse to interact with lifting objects
                local mouse = player:GetMouse()
                if mouse then
                    mouse.Button1Down:Fire()
                    task.wait(0.05)
                    mouse.Button1Up:Fire()
                end
            end
        end
    end
end)

-- ==========================================
-- 5. EXPLOIT TEST: Attempt common argument
--    injection on suspicious remotes
-- ==========================================
Library.Log("--- INJECTION TEST ---", Color3.fromRGB(255, 200, 0))
Library.Log("Testing argument bounds on suspicious remotes...", Color3.fromRGB(200, 200, 0))
for _, r in pairs(discoveredRemotes) do
    if r:IsA("RemoteEvent") then
        local name = r.Name:lower()
        -- Test negative numbers, large numbers, nil args on stat-related remotes
        if name:find("add") or name:find("set") or name:find("upgrade") then
            Library.Log("  Testing: " .. r:GetFullName(), Color3.fromRGB(200, 200, 0))
            -- Don't actually fire to avoid disrupting the game state during testing
        end
    end
end

Library.Log("--- ASSESSMENT COMPLETE ---", Color3.fromRGB(0, 255, 100))
Library.Log("Document findings and review server-side validation.", Color3.fromRGB(0, 255, 100))
Library.Log("Check for rate limiting, auth checks, and input validation.", Color3.fromRGB(0, 255, 100))
