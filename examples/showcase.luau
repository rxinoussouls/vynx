--!strict
--[[
    Vynx UI Library - Standalone Showcase Script
    Usage:
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/<user>/vynx/main/build/bundle.luau"))()
]]--

local Library = loadfile and loadfile("C:/Users/Admin/.gemini/antigravity/scratch/vynx/build/bundle.luau")()
if not Library then
    -- Fallback for relative requires in Studio
    Library = require(script.Parent.Parent.src)
end

-- 1. Initialize Watermark
Library:SetWatermark("vynx | universal | 60 fps | 28 ms")

-- 2. Create Window
local Window = Library:CreateWindow({
    Title = "vynx",
    SubTitle = "v1.0.0 | universal",
    Size = UDim2.fromOffset(600, 420),
    TabWidth = 140,
    Keybind = Enum.KeyCode.RightControl,
})

-- 3. Main Tab
local MainTab = Window:AddTab("Main")

local CombatBox = MainTab:AddLeftGroupbox("Combat & Automation")

local aimbotToggle = CombatBox:AddToggle("AimbotToggle", {
    Text = "Silent Aim",
    Default = false,
    Tooltip = "Automatically redirects projectiles toward enemy hitboxes",
    Callback = function(val: boolean)
        print("[Vynx] Silent Aim:", val)
    end,
})

-- Attach inline Keybind to Silent Aim toggle
aimbotToggle:AddKeybind("AimbotKey", {
    Default = Enum.KeyCode.V,
    Mode = "Toggle",
    Callback = function()
        print("[Vynx] Aimbot key toggled!")
    end,
})

CombatBox:AddSlider("FOVRadius", {
    Text = "FOV Radius",
    Default = 90,
    Min = 10,
    Max = 360,
    Rounding = 0,
    Suffix = " px",
    Tooltip = "Radius of targeting circle in pixels",
    Callback = function(val: number)
        print("[Vynx] FOV Radius set to:", val)
    end,
})

CombatBox:AddDropdown("HitPart", {
    Text = "Target Hitbox",
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = "Head",
    Tooltip = "Body part prioritized by aimbot target selector",
    Callback = function(part: string)
        print("[Vynx] Hit part set to:", part)
    end,
})

CombatBox:AddButton({
    Text = "Trigger Test Notification",
    Tooltip = "Spawns a floating notification in the bottom right corner",
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

-- 4. Visuals Tab
local VisualsTab = Window:AddTab("Visuals")

local ESPBox = VisualsTab:AddLeftGroupbox("ESP Settings")

local espBoxToggle = ESPBox:AddToggle("ESPBoxes", {
    Text = "2D Boxes",
    Default = true,
    Tooltip = "Renders 2D bounding boxes around enemy players",
    Callback = function(val: boolean)
        print("[Vynx] ESP Boxes:", val)
    end,
})

-- Attach inline Colorpicker to ESPBoxes toggle!
espBoxToggle:AddColorpicker("BoxColor", {
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

-- 5. Settings Tab
local SettingsTab = Window:AddTab("Settings")

local ThemeBox = SettingsTab:AddLeftGroupbox("Interface & Themes")

ThemeBox:AddDropdown("ThemeSelect", {
    Text = "Color Theme",
    Values = { "Obsidian", "Cyberpunk", "Emerald", "Monochrome" },
    Default = "Obsidian",
    Tooltip = "Dynamically switches theme palette with live tweens",
    Callback = function(themeName: string)
        Library:SetTheme(themeName)
    end,
})

ThemeBox:AddButton({
    Text = "Toggle Watermark",
    Func = function()
        if Library.ActiveWatermark then
            local isVis = Library.ActiveWatermark.Frame.Visible
            Library:SetWatermarkVisibility(not isVis)
        end
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

-- Cleanup listener
Library:OnUnload(function()
    print("[Vynx] Custom unload listener cleaned up.")
end)

-- Welcome Notification
Library:Notify({
    Title = "vynx Loaded",
    Content = "Press [RightControl] to toggle menu visibility.",
    Duration = 5,
})

return Library
