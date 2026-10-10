--!strict
--[[
    Vynx UI Library - macOS Sequoia Edition Showcase Script
    Usage:
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rxinoussouls/vynx/main/build/bundle.luau"))()
]]--

local Library = loadfile and loadfile("C:/Users/Admin/.gemini/antigravity/scratch/vynx/build/bundle.luau")()
if not Library then
    Library = require(script.Parent.Parent.src)
end

-- 1. Initialize Status Watermark
Library:SetWatermark("vynx | macOS Sequoia | 60 fps | 24 ms")

-- 2. Create Window (macOS Sequoia Settings window)
local Window = Library:CreateWindow({
    Title = "Settings",
    Size = UDim2.fromOffset(720, 480),
    SidebarWidth = 200,
    Theme = "Dark",
    Accent = "Blue",
    Keybind = Enum.KeyCode.RightControl,
    Dropshadow = true,
    Resizable = true,
    Searchable = true,
})

-- 3. Section: GENERAL
local GeneralSec = Window:AddSection("General")

local FeaturesTab = GeneralSec:AddTab({
    Title = "Features",
    Icon = "settings",
    Selected = true,
})

-- PageSection 1: Automation
local AutoSection = FeaturesTab:AddPageSection({
    Title = "AUTOMATION",
    Subtitle = "Core targeting and automated weapon routines",
})
local AutoForm = AutoSection:AddForm()

local silentAimToggle = AutoForm:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Subtitle = "Redirects bullet trajectories directly to priority bones",
    Default = false,
    Tooltip = "High precision client-side raycast override",
    Callback = function(val)
        print("[Vynx] Silent Aim:", val)
    end,
})

silentAimToggle:AddKeybind("AimKey", {
    Default = Enum.KeyCode.E,
    Mode = "Toggle",
    Callback = function(active)
        print("[Vynx] Silent Aim key triggered:", active)
    end,
})

silentAimToggle:AddColorpicker("AimColor", {
    Default = Color3.fromRGB(10, 132, 255),
    Callback = function(col)
        print("[Vynx] Silent Aim indicator color:", col)
    end,
})

AutoForm:AddSlider("FOVRadius", {
    Text = "Field of View",
    Subtitle = "Max targeting angle in degrees (double-click label to type)",
    Default = 90,
    Min = 10,
    Max = 360,
    Rounding = 0,
    Suffix = "°",
    Callback = function(val)
        print("[Vynx] FOV set to:", val)
    end,
})

AutoForm:AddDropdown("HitPart", {
    Text = "Target Priority",
    Subtitle = "Preferred bone structure for target selection",
    Values = { "Head", "UpperTorso", "HumanoidRootPart", "Closest Bone" },
    Default = "Head",
    Callback = function(val)
        print("[Vynx] Target Bone:", val)
    end,
})

-- PageSection 2: Movement & Physics
local MoveSection = FeaturesTab:AddPageSection({
    Title = "MOVEMENT & LOCOMOTION",
    Subtitle = "Local humanoid physics modification",
})
local MoveForm = MoveSection:AddForm()

local speedToggle = MoveForm:AddToggle("SpeedMultiplier", {
    Text = "Speed Multiplier",
    Subtitle = "Boost walk speed past standard game limitations",
    Default = false,
})

local speedDep = MoveForm:AddDependencyBox(speedToggle)
speedDep:AddSlider("SpeedValue", {
    Text = "WalkSpeed Value",
    Subtitle = "Custom studs per second rate",
    Default = 28,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(val)
        print("[Vynx] Custom speed:", val)
    end,
})

MoveForm:AddStepper("JumpPower", {
    Text = "Jump Multiplier",
    Subtitle = "Discrete step-based jump height adjustment",
    Min = 1,
    Max = 10,
    Step = 1,
    Default = 1,
    Suffix = "x",
    Callback = function(stepVal)
        print("[Vynx] Jump step:", stepVal)
    end,
})

-- 4. Tab: APPEARANCE & THEME
local AppearanceTab = GeneralSec:AddTab({
    Title = "Appearance",
    Icon = "palette",
})

local VisualSection = AppearanceTab:AddPageSection({
    Title = "THEME & ACCENTS",
    Subtitle = "Apple Sequoia dynamic appearance controls",
})
local VisualForm = VisualSection:AddForm()

VisualForm:AddSegmented("ThemeMode", {
    Text = "Interface Theme",
    Subtitle = "Select dark or light appearance",
    Values = { "Dark", "Light" },
    Default = "Dark",
    Callback = function(themeName)
        Library:SetTheme(themeName)
    end,
})

VisualForm:AddDropdown("AccentColor", {
    Text = "Accent Color",
    Subtitle = "System-wide tint for controls and active highlights",
    Values = { "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite" },
    Default = "Blue",
    Callback = function(accentName)
        Library:SetAccent(accentName)
    end,
})

VisualForm:AddButton({
    Title = "Trigger Success Toast",
    Subtitle = "Spawns a top-right macOS Sequoia notification toast",
    Variant = "Prominent",
    Func = function()
        Library:Notify({
            Title = "Theme Updated",
            Content = "System appearance synchronized successfully.",
            Type = "Success",
            Duration = 3.5,
        })
    end,
})

-- 5. Section: PROFILES & DATA
local SystemSec = Window:AddSection("System")

local ConfigTab = SystemSec:AddTab({
    Title = "Profiles",
    Icon = "folder",
})

-- Built-in SaveManager section
Library.SaveManager:BuildConfigSection(ConfigTab)

-- Unload Action
local MaintSection = ConfigTab:AddPageSection({
    Title = "MAINTENANCE",
})
local MaintForm = MaintSection:AddForm()

MaintForm:AddButton({
    Title = "Unload Vynx",
    Subtitle = "Disconnects all connections and destroys UI safely",
    DoubleClick = true,
    Func = function()
        Library:Unload()
        print("[Vynx] Library cleanly unloaded.")
    end,
})

-- Welcome Notification
Library:Notify({
    Title = "Vynx Ready",
    Content = "Press [RightControl] to toggle or click the floating launcher.",
    Type = "Info",
    Duration = 4.5,
})

return Library
