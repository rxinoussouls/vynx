--!strict
--[[
    Vynx UI Library - Standalone Showcase Script
    Usage:
        local Library = loadstring(game:HttpGet(".../bundle.luau"))()
        -- Or execute directly in Studio / Executor
]]--

local Library = loadfile and loadfile("C:/Users/Admin/.gemini/antigravity/scratch/vynx/build/bundle.luau")()
if not Library then
    -- Fallback for relative requires in Studio
    Library = require(script.Parent.Parent.src)
end

-- 1. Create Window
local Window = Library:CreateWindow({
    Title = "vynx",
    SubTitle = "v1.0.0 | universal",
    Size = UDim2.fromOffset(600, 420),
    TabWidth = 140,
    Keybind = Enum.KeyCode.RightControl,
})

-- 2. Main Tab
local MainTab = Window:AddTab("Main")

local CombatBox = MainTab:AddLeftGroupbox("Combat & Automation")

CombatBox:AddToggle("AimbotToggle", {
    Text = "Silent Aim",
    Default = false,
    Callback = function(val: boolean)
        print("[Vynx] Silent Aim:", val)
    end,
})

CombatBox:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 90,
    Min = 10,
    Max = 360,
    Rounding = 0,
    Suffix = " px",
    Callback = function(val: number)
        print("[Vynx] FOV Radius set to:", val)
    end,
})

CombatBox:AddDropdown("HitPart", {
    Text = "Target Hitbox",
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = "Head",
    Callback = function(part: string)
        print("[Vynx] Hit part set to:", part)
    end,
})

CombatBox:AddButton({
    Text = "Trigger Test Notification",
    Func = function()
        Library:Notify({
            Title = "Combat System",
            Content = "Target locked successfully!",
            Duration = 3,
        })
    end,
})

local MovementBox = MainTab:AddRightGroupbox("Movement")

MovementBox:AddToggle("SpeedToggle", {
    Text = "Speed Multiplier",
    Default = false,
    Callback = function(val: boolean)
        print("[Vynx] Speed Multiplier:", val)
    end,
})

MovementBox:AddSlider("SpeedValue", {
    Text = "WalkSpeed Value",
    Default = 16,
    Min = 16,
    Max = 150,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(val: number)
        print("[Vynx] WalkSpeed:", val)
    end,
})

MovementBox:AddKeybind("FlyKeybind", {
    Text = "Fly Toggle Key",
    Default = Enum.KeyCode.X,
    Mode = "Toggle",
    Callback = function(active: boolean)
        print("[Vynx] Fly key triggered!")
    end,
})

-- 3. Visuals Tab
local VisualsTab = Window:AddTab("Visuals")

local ESPBox = VisualsTab:AddLeftGroupbox("ESP Settings")

ESPBox:AddToggle("ESPBoxes", {
    Text = "2D Boxes",
    Default = true,
    Callback = function(val: boolean)
        print("[Vynx] ESP Boxes:", val)
    end,
})

ESPBox:AddColorpicker("BoxColor", {
    Text = "Box Color",
    Default = Color3.fromRGB(138, 75, 255),
    Callback = function(col: Color3)
        print("[Vynx] ESP Box Color changed:", col)
    end,
})

ESPBox:AddToggle("TracerToggle", {
    Text = "Tracers",
    Default = false,
    Callback = function(val: boolean)
        print("[Vynx] Tracers:", val)
    end,
})

local WorldBox = VisualsTab:AddRightGroupbox("World Ambience")

WorldBox:AddColorpicker("AmbientColor", {
    Text = "Ambience Tint",
    Default = Color3.fromRGB(0, 240, 255),
    Callback = function(col: Color3)
        print("[Vynx] Ambience Tint:", col)
    end,
})

WorldBox:AddInput("CustomSkyboxId", {
    Text = "Custom Skybox Asset ID",
    Placeholder = "e.g. 12345678",
    Numeric = true,
    Callback = function(idStr: string)
        print("[Vynx] Skybox ID:", idStr)
    end,
})

-- 4. Settings Tab
local SettingsTab = Window:AddTab("Settings")

local ThemeBox = SettingsTab:AddLeftGroupbox("Interface & Themes")

ThemeBox:AddDropdown("ThemeSelect", {
    Text = "Color Theme",
    Values = { "Obsidian", "Cyberpunk", "Emerald", "Monochrome" },
    Default = "Obsidian",
    Callback = function(themeName: string)
        Library:SetTheme(themeName)
    end,
})

ThemeBox:AddButton({
    Text = "Unload UI",
    Func = function()
        Library:Unload()
        print("[Vynx] Library unloaded.")
    end,
})

-- Build SaveManager Config Section
Library.SaveManager:BuildConfigSection(SettingsTab)

-- Welcome Notification
Library:Notify({
    Title = "vynx Loaded",
    Content = "Press [RightControl] to toggle menu visibility.",
    Duration = 5,
})

return Library
