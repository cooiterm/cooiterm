--[[
    CooiTerm's Part Velocity
    Uses velocity and body gyro to fling players with unanchored parts in the workspace.
    modify things to your liking:
    local spin
    local speed
    local blacklist
    you can also modify the body gyro and velocity (if you know what you are doing)
    Created By @cooiterm, please credit if you are going to use this in any scripts.
    Or contact me via discord for permission (without credit)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local on = false
local noclip = true
local killconnection = nil
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local spin = 5000-- modify these to ur likings
local speed = 300-- modify these to ur likings
-- ──────────────────────┐
local blacklist = {--    ├──> Players to NOT target while PV is is on
    "PLAYER1",--         │
    "PLAYER2",--         │
    "PLAYER3"--          │
}--                      │

local function noti(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end
-- ─────────────────────────────────────────────────────────────────┐
if _G.scrloaded then--                                              │
    noti("CooiTerm's PartVelocity", "script already running.", 5)-- │
    return--                                                        ├──> This is the script check (check if script already running) feel free to comment it out if you want multiple instances for sum reason
end--                                                               │
--                                                                  │
_G.scrloaded = true--                                               │
local function partcheck(part)
    if not part:IsA("BasePart") or part.Anchored or part:IsDescendantOf(character) then
        return
    end
    if noclip then
        part.CanCollide = false
    end

    local bodyGyro = part:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000-- adjust this for desired power
    bodyGyro.Parent = part
    local bodyVelocity = part:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 10000-- adjust this for desired power
    bodyVelocity.Parent = part
end

local function cleanupPart(part)
    if part:FindFirstChild("BodyGyro") then
        part.BodyGyro:Destroy()
    end
    if part:FindFirstChild("BodyVelocity") then
        part.BodyVelocity:Destroy()
    end
    if noclip then
        part.CanCollide = true
    end
end

local function partvel()
    killconnection = RunService.Heartbeat:Connect(function()
        local targets = {}
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and not table.find(blacklist, otherPlayer.Name) then
                local otherCharacter = otherPlayer.Character
                if otherCharacter and otherCharacter:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, otherCharacter.HumanoidRootPart.Position)
                end
            end
        end

        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) then
                partcheck(part)

                local bodyGyro = part:FindFirstChild("BodyGyro")
                if bodyGyro then
                    bodyGyro.CFrame = bodyGyro.CFrame * CFrame.Angles(0, math.rad(spin), 0)
                end

                local ctarget = nil
                local cdist = math.huge
                for _, tpos in ipairs(targets) do
                    local distance = (part.Position - tpos).Magnitude
                    if distance < cdist then
                        ctarget = tpos
                        cdist = distance
                    end
                end

                if ctarget then
                    local bodyVelocity = part:FindFirstChild("BodyVelocity")
                    if bodyVelocity then
                        bodyVelocity.Velocity = (ctarget - part.Position).Unit * speed
                    end
                end
            end
        end
    end)
end

local function stop()
    if killconnection then
        killconnection:Disconnect()
        killconnection = nil
    end

    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(character) then
            cleanupPart(part)
        end
    end
end

local function pv()
    if on then
        stop()
        noti("CooiTerm's PartVelocity", "PV is on.", 3)
    else
        partvel()
        noti("CooiTerm's PartVelocity", "PV is off.", 3)
    end
    on = not on
end

local function tnoclip()
    noclip = not noclip
    local status = noclip and "is on" or "is off"
    noti("CooiTerm's PartVelocity", "Noclip  " .. status, 3)
end

player.CharacterAdded:Connect(function(newCharacter)
    local on = false
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    stop()
    noti("CooiTerm's PartVelocity", "pv was reset", 5)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.T then
        pv()
    elseif input.KeyCode == Enum.KeyCode.N then
        tnoclip()
    end
end)

noti("CooiTerm's PartVelocity", "loaded, T to start and N for noclip", 5)
