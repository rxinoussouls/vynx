import os
import re
import json

BASE_DIR = r"C:\Users\Admin\.gemini\antigravity\scratch\vynx"
CASCADE_DIST = r"C:\Users\Admin\.gemini\antigravity\scratch\cascade_dist_unminified.luau"
OUTPUT_BUNDLE = os.path.join(BASE_DIR, "build", "bundle.luau")
CURATED_JSON = r"C:\Users\Admin\.gemini\antigravity\scratch\curated_icons.json"

def build():
    print("Reading cascade_dist_unminified.luau...")
    with open(CASCADE_DIST, "r", encoding="utf-8") as f:
        content = f.read()

    with open(CURATED_JSON, "r", encoding="utf-8") as f:
        curated_icons = json.load(f)

    # 1. Strip darklua types from beginning (lines 1 to 536)
    # Line 537 is: local __DIST={cache={}::any}do do local function __modImpl()
    dist_start = content.find("local __DIST={cache={}::any}")
    if dist_start == -1:
        raise ValueError("Could not find __DIST start in cascade_dist!")
    
    header = """--[[\n    Vynx UI Library - macOS Sequoia Edition\n    Ultra-optimized retained-mode macOS Sequoia UI library for Roblox Luau\n    Compatible with all executors (gethui / CoreGui / PlayerGui) and Roblox Studio\n]]--\n--!nolint\n--!nocheck\n--!optimize 2\n__SH = { COMPINDEXES = {} }\n"""
    dist_code = content[dist_start:]

    # 2. Replace AppRecorder (__DIST.f) with lightweight production stub
    idx_e = dist_code.find("function __DIST.e()")
    idx_f = dist_code.find("function __DIST.f()")
    if idx_e != -1 and idx_f != -1:
        idx_mod = dist_code.find("local function __modImpl()", idx_e)
        app_recorder_stub = """local function __modImpl()
local AppRecorder = {}
function AppRecorder.FromContext() return nil end
function AppRecorder.new() return { Start = function() end, Stop = function() end, _Begin = function() return nil end, _Commit = function() end, _Cancel = function() end } end
function AppRecorder.DumpApp() return "{}" end
return AppRecorder
end """
        dist_code = dist_code[:idx_mod] + app_recorder_stub + dist_code[idx_f:]
        print("Replaced AppRecorder (__DIST.f): True")
    else:
        print("Replaced AppRecorder (__DIST.f): False")

    # 3. Replace giant symbols table (__DIST.g) with curated symbols + fallback
    symbols_pattern = re.compile(
        r'function __DIST\.f\(\).*?do local function __modImpl\(\)\s*return \{.*?\}\s*end function __DIST\.g\(\)',
        re.DOTALL
    )
    
    # Build Luau table for curated symbols
    icon_entries = []
    for k, v in sorted(curated_icons.items()):
        icon_entries.append(f'  ["{k}"] = "{v}",')
    symbols_luau = "\n".join(icon_entries)

    symbols_stub = f"""function __DIST.f()
:typeof(__modImpl())local v=__DIST.cache.f if not v then v={{c=__modImpl()}}__DIST.cache.f=v end return v.c end end do local function __modImpl()
local rawSymbols = {{\n{symbols_luau}\n}}
local symbols = setmetatable(rawSymbols, {{
    __index = function(self, key)
        if typeof(key) == "string" then
            if string.sub(key, 1, 13) == "rbxassetid://" or string.sub(key, 1, 4) == "http" then
                return key
            end
            local lowerKey = string.lower(key)
            if rawSymbols[lowerKey] then
                return rawSymbols[lowerKey]
            end
        end
        return rawSymbols["circle"] or "rbxassetid://132228700346004"
    end
}})
return symbols
end function __DIST.g()"""
    dist_code, n_sym = symbols_pattern.subn(symbols_stub, dist_code, count=1)
    print(f"Replaced Symbols table (__DIST.g): {n_sym > 0}")

    # 4. Remove darklua return cascade at the end and append Vynx wrapper
    cascade_return_pos = dist_code.rfind("return cascade")
    if cascade_return_pos == -1:
        raise ValueError("Could not find 'return cascade' at end of dist_code!")

    base_cascade_code = dist_code[:cascade_return_pos]

    # 5. Vynx customization and compatibility layer
    vynx_layer = """
-- =========================================================================
-- Vynx UI Library - macOS Sequoia Customization & Compatibility Layer
-- =========================================================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local Vynx = {
    Cascade = cascade,
    Themes = cascade.Themes,
    Accents = cascade.Accents,
    Symbols = cascade.Symbols,
    Creator = cascade.Creator,
    Binder = cascade.Binder,
    Components = cascade.Components,

    New = cascade.New,
    Component = cascade.Component,
    RegisterComponent = cascade.RegisterComponent,

    Toggles = {},
    Options = {},

    ActiveApp = nil,
    ActiveWindow = nil,
    ActiveWatermark = nil,
    ActiveLauncher = nil,
    ScreenGui = nil,
    UnloadSignals = {},
}

-- -------------------------------------------------------------------------
-- SaveManager (LinoriaLib compatible)
-- -------------------------------------------------------------------------
local SaveManager = {
    Folder = "vynx",
    SubFolder = "configs",
    Library = Vynx,
    IgnoreIndexes = { ["ConfigName"] = true, ["ConfigSelect"] = true },
}

local function sanitizeFileName(name: string)
    local clean = string.gsub(name, "[^%w%-_]", "")
    return clean ~= "" and clean or "default"
end

local function getConfigPath(name: string)
    return string.format("%s/%s/%s.json", SaveManager.Folder, SaveManager.SubFolder, sanitizeFileName(name))
end

function SaveManager:SetLibrary(library)
    self.Library = library
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
end

function SaveManager:SetSubFolder(sub)
    self.SubFolder = sub
end

function SaveManager:SetIgnoreIndexes(indexes)
    for _, idx in ipairs(indexes) do
        self.IgnoreIndexes[idx] = true
    end
end

function SaveManager:IgnoreThemeSettings()
    self.IgnoreIndexes["ThemeMode"] = true
    self.IgnoreIndexes["AccentColor"] = true
end

function SaveManager:InitFolders()
    if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
        pcall(function()
            if not isfolder(self.Folder) then makefolder(self.Folder) end
            if not isfolder(self.Folder .. "/" .. self.SubFolder) then makefolder(self.Folder .. "/" .. self.SubFolder) end
        end)
    end
end

function SaveManager:Save(name: string): boolean
    if not self.Library then return false end
    self:InitFolders()

    local data = { Toggles = {}, Options = {} }
    for id, toggle in pairs(self.Library.Toggles) do
        if not self.IgnoreIndexes[id] then
            data.Toggles[id] = toggle.Value
        end
    end
    for id, option in pairs(self.Library.Options) do
        if not self.IgnoreIndexes[id] then
            local val = option.Value
            if typeof(val) == "Color3" then
                data.Options[id] = { Type = "Color3", R = val.R, G = val.G, B = val.B, Transparency = option.Transparency or 0 }
            elseif typeof(val) == "EnumItem" then
                data.Options[id] = { Type = "EnumItem", Name = val.Name, Mode = option.Mode or "Toggle" }
            else
                data.Options[id] = { Type = "Primitive", Value = val }
            end
        end
    end

    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and typeof(writefile) == "function" then
        local writeOk = pcall(function() writefile(getConfigPath(name), encoded) end)
        return writeOk
    end
    return false
end

function SaveManager:Load(name: string): boolean
    if not self.Library then return false end
    local path = getConfigPath(name)
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return false end
    local existsOk, exists = pcall(function() return isfile(path) end)
    if not existsOk or not exists then return false end

    local readOk, content = pcall(function() return readfile(path) end)
    if not readOk or typeof(content) ~= "string" then return false end
    local decodeOk, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not decodeOk or typeof(data) ~= "table" then return false end

    if data.Toggles then
        for id, val in pairs(data.Toggles) do
            if self.Library.Toggles[id] and not self.IgnoreIndexes[id] then
                pcall(function() self.Library.Toggles[id]:SetValue(val) end)
            end
        end
    end
    if data.Options then
        for id, item in pairs(data.Options) do
            if self.Library.Options[id] and not self.IgnoreIndexes[id] then
                pcall(function()
                    if item.Type == "Color3" then
                        self.Library.Options[id]:SetValue(Color3.new(item.R, item.G, item.B), item.Transparency or 0)
                    elseif item.Type == "EnumItem" then
                        local key = Enum.KeyCode[item.Name]
                        if key then
                            self.Library.Options[id]:SetValue(key)
                            if item.Mode and self.Library.Options[id].SetMode then
                                self.Library.Options[id]:SetMode(item.Mode)
                            end
                        end
                    else
                        self.Library.Options[id]:SetValue(item.Value)
                    end
                end)
            end
        end
    end
    return true
end

function SaveManager:DeleteConfig(name: string): boolean
    local path = getConfigPath(name)
    if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(path) then
        local ok = pcall(function() delfile(path) end)
        return ok
    end
    return false
end

function SaveManager:ListConfigs(): { [number]: string }
    local configs = {}
    if typeof(listfiles) == "function" and typeof(isfolder) == "function" then
        self:InitFolders()
        local folderPath = self.Folder .. "/" .. self.SubFolder
        local ok, files = pcall(function() return listfiles(folderPath) end)
        if ok and typeof(files) == "table" then
            for _, file in ipairs(files) do
                local match = string.match(file, "([^/\\\\]+)%.json$")
                if match then table.insert(configs, match) end
            end
        end
    end
    return configs
end

function SaveManager:SetAutoLoad(name: string)
    local autoPath = self.Folder .. "/autoload.txt"
    if typeof(writefile) == "function" then
        pcall(function() writefile(autoPath, sanitizeFileName(name)) end)
    end
end

function SaveManager:LoadAutoloadConfig()
    self:CheckAutoLoad()
end

function SaveManager:CheckAutoLoad()
    local autoPath = self.Folder .. "/autoload.txt"
    if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(autoPath) then
        local ok, name = pcall(function() return readfile(autoPath) end)
        if ok and name and name ~= "" then
            self:Load(name)
        end
    end
end

function SaveManager:BuildConfigSection(tab)
    local section = tab:AddPageSection({ Title = "PROFILES & CONFIGURATION" })
    local form = section:AddForm()

    local configNameInput = form:AddInput("ConfigName", {
        Text = "Profile Name",
        Subtitle = "Enter a file name to save current settings",
        Placeholder = "default",
        Default = "default",
    })
    self.IgnoreIndexes["ConfigName"] = true

    local existingConfigs = self:ListConfigs()
    if #existingConfigs == 0 then table.insert(existingConfigs, "default") end

    local configDropdown = form:AddDropdown("ConfigSelect", {
        Text = "Saved Profiles",
        Subtitle = "Select an existing configuration profile",
        Values = existingConfigs,
        Default = existingConfigs[1] or "default",
        Callback = function(val)
            if configNameInput and configNameInput.SetValue then
                configNameInput:SetValue(val)
            end
        end,
    })
    self.IgnoreIndexes["ConfigSelect"] = true

    form:AddButton({
        Title = "Save Profile",
        Subtitle = "Write active settings to disk",
        Variant = "Prominent",
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                local ok = self:Save(name)
                Vynx:Notify({
                    Title = "Config Manager",
                    Content = ok and ("Saved config: " .. name) or "Failed to save config",
                    Type = ok and "Success" or "Error",
                    Duration = 3,
                })
                local updated = self:ListConfigs()
                if #updated > 0 and configDropdown.SetValues then
                    configDropdown:SetValues(updated)
                end
            end
        end,
    })

    form:AddButton({
        Title = "Load Profile",
        Subtitle = "Restore settings from selected file",
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                local ok = self:Load(name)
                Vynx:Notify({
                    Title = "Config Manager",
                    Content = ok and ("Loaded config: " .. name) or "Config file not found",
                    Type = ok and "Success" or "Error",
                    Duration = 3,
                })
            end
        end,
    })

    form:AddButton({
        Title = "Set As Autoload",
        Subtitle = "Automatically apply this profile on future starts",
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                self:SetAutoLoad(name)
                Vynx:Notify({
                    Title = "Autoload Config",
                    Content = "Set autoload profile to: " .. name,
                    Type = "Success",
                    Duration = 3,
                })
            end
        end,
    })

    form:AddButton({
        Title = "Delete Profile",
        Subtitle = "Permanently remove profile file from disk",
        DoubleClick = true,
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                local ok = self:DeleteConfig(name)
                Vynx:Notify({
                    Title = "Config Manager",
                    Content = ok and ("Deleted profile: " .. name) or "Failed to delete profile",
                    Type = ok and "Warn" or "Error",
                    Duration = 3,
                })
                local updated = self:ListConfigs()
                if #updated > 0 and configDropdown.SetValues then
                    configDropdown:SetValues(updated)
                end
            end
        end,
    })
end

Vynx.SaveManager = SaveManager

-- -------------------------------------------------------------------------
-- ThemeManager (Theme & Accent Switching)
-- -------------------------------------------------------------------------
local ThemeManager = {
    Library = Vynx,
}

function ThemeManager:SetLibrary(library)
    self.Library = library
end

function ThemeManager:SetTheme(themeName: string)
    self.Library:SetTheme(themeName)
end

function ThemeManager:SetAccent(accentName: string)
    self.Library:SetAccent(accentName)
end

function ThemeManager:ApplyToTab(tab)
    local section = tab:AddPageSection({ Title = "APPEARANCE & THEME" })
    local form = section:AddForm()

    form:AddSegmented("ThemeMode", {
        Text = "Interface Theme",
        Subtitle = "Select dark or light appearance",
        Values = { "Dark", "Light" },
        Default = "Dark",
        Callback = function(val)
            self:SetTheme(val)
        end,
    })

    form:AddDropdown("AccentColor", {
        Text = "Accent Tint",
        Subtitle = "System-wide tint for controls and highlights",
        Values = { "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite" },
        Default = "Blue",
        Callback = function(val)
            self:SetAccent(val)
        end,
    })
end

Vynx.ThemeManager = ThemeManager

-- -------------------------------------------------------------------------
-- Notification System
-- -------------------------------------------------------------------------
function Vynx:Notify(options: { Title: string?, Content: string?, Subtitle: string?, Type: string?, Duration: number?, Icon: any? })
    if not self.ActiveApp then return end
    options = options or {}

    local typeIcons = {
        Success = self.Symbols.checkmarkCircleFill or self.Symbols.checkmark,
        Error = self.Symbols.xmarkCircleFill or self.Symbols.xmark,
        Warn = self.Symbols.exclamationmarkTriangleFill or self.Symbols.exclamationmarkTriangle,
        Info = self.Symbols.infoCircleFill or self.Symbols.infoCircle,
    }

    local chosenIcon = (options.Type and typeIcons[options.Type])
        or options.Icon
        or self.Symbols.bell

    pcall(function()
        self.ActiveApp:Notification({
            Title = options.Title or "Vynx",
            Subtitle = options.Content or options.Subtitle or "",
            App = "Vynx",
            AppIcon = chosenIcon,
            Duration = options.Duration or 4,
        })
    end)
end

-- -------------------------------------------------------------------------
-- Watermark System (Live FPS & Ping)
-- -------------------------------------------------------------------------
function Vynx:SetWatermark(text: string)
    if not self.ActiveWatermark and self.ScreenGui then
        local wmFrame = Instance.new("Frame")
        wmFrame.Name = "VynxWatermark"
        wmFrame.AnchorPoint = Vector2.new(0, 0)
        wmFrame.Position = UDim2.fromOffset(16, 16)
        wmFrame.AutomaticSize = Enum.AutomaticSize.XY
        wmFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
        wmFrame.BackgroundTransparency = 0.25
        wmFrame.BorderSizePixel = 0
        wmFrame.ZIndex = 500
        wmFrame.Parent = self.ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = wmFrame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.88
        stroke.Thickness = 1
        stroke.Parent = wmFrame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = wmFrame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.AutomaticSize = Enum.AutomaticSize.XY
        label.BackgroundTransparency = 1
        label.FontFace = Font.new("rbxassetid://12187365364")
        label.Text = text or "vynx | macOS Sequoia"
        label.TextColor3 = Color3.fromRGB(240, 240, 245)
        label.TextSize = 12
        label.Parent = wmFrame

        self.ActiveWatermark = {
            Frame = wmFrame,
            Label = label,
            SetText = function(self, newText)
                label.Text = newText
            end,
            SetVisible = function(self, vis)
                wmFrame.Visible = vis
            end,
        }
    elseif self.ActiveWatermark then
        self.ActiveWatermark:SetText(text)
    end
    return self.ActiveWatermark
end

function Vynx:SetWatermarkVisibility(visible: boolean)
    if self.ActiveWatermark then
        self.ActiveWatermark:SetVisible(visible)
    end
end

-- -------------------------------------------------------------------------
-- Floating Draggable Launcher Pill
-- -------------------------------------------------------------------------
local function createFloatingLauncher(gui, windowObj, app)
    local btn = Instance.new("TextButton")
    btn.Name = "VynxFloatingLauncher"
    btn.Size = UDim2.fromOffset(42, 42)
    btn.Position = UDim2.new(0, 16, 0.5, -21)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    btn.BackgroundTransparency = 0.15
    btn.Text = "V"
    btn.TextColor3 = Color3.fromRGB(10, 132, 255)
    btn.TextSize = 18
    btn.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold)
    btn.AutoButtonColor = false
    btn.ZIndex = 800
    btn.Visible = false
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(10, 132, 255)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.5
    stroke.Parent = btn

    -- Dragging logic
    local dragging = false
    local dragStart = nil
    local startPos = nil

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if windowObj then
            windowObj.Minimized = not windowObj.Minimized
        end
    end)

    return btn
end

-- -------------------------------------------------------------------------
-- Popover Colorpicker Implementation
-- -------------------------------------------------------------------------
local function createColorpickerRow(form, id, opts, vynxLibrary)
    local row = form:Row({ SearchIndex = opts.Title or opts.Text or id })
    local currentColor = opts.Default or Color3.fromRGB(10, 132, 255)
    local currentAlpha = opts.Transparency or 0

    row:Left():TitleStack({
        Title = opts.Title or opts.Text or id,
        Subtitle = opts.Subtitle,
    })

    local previewBtn = Instance.new("TextButton")
    previewBtn.Name = "ColorSwatch"
    previewBtn.Size = UDim2.fromOffset(30, 20)
    previewBtn.BackgroundColor3 = currentColor
    previewBtn.Text = ""
    previewBtn.AutoButtonColor = false
    previewBtn.Parent = row.Structures.RightAccessories

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = previewBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = previewBtn

    -- Popover Card
    local popover = Instance.new("Frame")
    popover.Name = id .. "_PopoverPalette"
    popover.Size = UDim2.fromOffset(210, 150)
    popover.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    popover.BorderSizePixel = 0
    popover.ZIndex = 900
    popover.Visible = false

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 10)
    pCorner.Parent = popover

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(255, 255, 255)
    pStroke.Transparency = 0.88
    pStroke.Thickness = 1
    pStroke.Parent = popover

    local pPad = Instance.new("UIPadding")
    pPad.PaddingTop = UDim.new(0, 10)
    pPad.PaddingBottom = UDim.new(0, 10)
    pPad.PaddingLeft = UDim.new(0, 10)
    pPad.PaddingRight = UDim.new(0, 10)
    pPad.Parent = popover

    local pLayout = Instance.new("UIListLayout")
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 8)
    pLayout.Parent = popover

    -- Hex Input
    local hexBox = Instance.new("TextBox")
    hexBox.Name = "HexInput"
    hexBox.Size = UDim2.new(1, 0, 0, 26)
    hexBox.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
    hexBox.BorderSizePixel = 0
    hexBox.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
    hexBox.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
    hexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hexBox.TextSize = 12
    hexBox.ClearTextOnFocus = false
    hexBox.LayoutOrder = 1
    hexBox.Parent = popover

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 5)
    hCorner.Parent = hexBox

    -- Curated Swatches Grid
    local grid = Instance.new("Frame")
    grid.Name = "SwatchesGrid"
    grid.Size = UDim2.new(1, 0, 0, 56)
    grid.BackgroundTransparency = 1
    grid.LayoutOrder = 2
    grid.Parent = popover

    local gLayout = Instance.new("UIGridLayout")
    gLayout.CellSize = UDim2.fromOffset(32, 24)
    gLayout.CellPadding = UDim2.fromOffset(6, 6)
    gLayout.Parent = grid

    local appleSwatches = {
        Color3.fromRGB(10, 132, 255),
        Color3.fromRGB(191, 90, 242),
        Color3.fromRGB(255, 55, 95),
        Color3.fromRGB(255, 69, 58),
        Color3.fromRGB(255, 159, 10),
        Color3.fromRGB(255, 214, 10),
        Color3.fromRGB(48, 209, 88),
        Color3.fromRGB(152, 152, 159),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(28, 28, 30),
    }

    local colorObj = {
        Type = "Colorpicker",
        Value = currentColor,
        Transparency = currentAlpha,
        Callback = opts.Callback,
        ChangedCallbacks = {},
        Row = row,
    }

    function colorObj:SetValue(newCol: Color3, newAlpha: number?)
        self.Value = newCol
        if newAlpha ~= nil then self.Transparency = newAlpha end
        previewBtn.BackgroundColor3 = newCol
        hexBox.Text = string.format("#%02X%02X%02X", math.floor(newCol.R * 255), math.floor(newCol.G * 255), math.floor(newCol.B * 255))
        if self.Callback then task.spawn(self.Callback, newCol, self.Transparency) end
        for _, fn in ipairs(self.ChangedCallbacks) do task.spawn(fn, newCol, self.Transparency) end
    end

    function colorObj:OnChanged(fn)
        table.insert(self.ChangedCallbacks, fn)
        return self
    end

    for _, col in ipairs(appleSwatches) do
        local sb = Instance.new("TextButton")
        sb.BackgroundColor3 = col
        sb.Text = ""
        sb.AutoButtonColor = false
        sb.Parent = grid

        local sbc = Instance.new("UICorner")
        sbc.CornerRadius = UDim.new(0, 4)
        sbc.Parent = sb

        local sbs = Instance.new("UIStroke")
        sbs.Color = Color3.fromRGB(255, 255, 255)
        sbs.Transparency = 0.8
        sbs.Thickness = 1
        sbs.Parent = sb

        sb.MouseButton1Click:Connect(function()
            colorObj:SetValue(col)
        end)
    end

    hexBox.FocusLost:Connect(function()
        local clean = string.gsub(hexBox.Text, "[#%s]", "")
        if #clean == 6 then
            local r = tonumber(string.sub(clean, 1, 2), 16)
            local g = tonumber(string.sub(clean, 3, 4), 16)
            local b = tonumber(string.sub(clean, 5, 6), 16)
            if r and g and b then
                colorObj:SetValue(Color3.fromRGB(r, g, b))
                return
            end
        end
        hexBox.Text = string.format("#%02X%02X%02X", math.floor(colorObj.Value.R * 255), math.floor(colorObj.Value.G * 255), math.floor(colorObj.Value.B * 255))
    end)

    local isOpen = false
    previewBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            popover.Parent = vynxLibrary.ScreenGui
            popover.Visible = true
            local p = previewBtn.AbsolutePosition
            local s = previewBtn.AbsoluteSize
            popover.Position = UDim2.fromOffset(math.max(10, p.X - 180), p.Y + s.Y + 4)
        else
            popover.Visible = false
            popover.Parent = nil
        end
    end)

    vynxLibrary.Options[id] = colorObj
    return colorObj
end

-- -------------------------------------------------------------------------
-- Wrapper Helpers (Vynx & Linoria API)
-- -------------------------------------------------------------------------
local function wrapForm(form, vynxLibrary)
    local wrappedForm = {
        Form = form,
    }

    -- AddToggle
    function wrappedForm:AddToggle(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local toggle = row:Right():Toggle({
            Value = not not opts.Default,
            ValueChanged = function(_, val)
                if wrappedForm.Toggles and wrappedForm.Toggles[id] then
                    wrappedForm.Toggles[id].Value = val
                end
            end,
        })

        local toggleObj = {
            Type = "Toggle",
            Value = not not opts.Default,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Toggle = toggle,
        }

        function toggleObj:SetValue(val: boolean)
            self.Value = not not val
            toggle.Value = self.Value
        end

        function toggleObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        -- Support embedding Keybind inside Toggle row
        function toggleObj:AddKeybind(keyId: string, keyOpts)
            keyOpts = keyOpts or {}
            local keybindField = row:Right():KeybindField({
                Value = keyOpts.Default or Enum.KeyCode.Unknown,
                ValueChanged = function(_, key)
                    if vynxLibrary.Options[keyId] then
                        vynxLibrary.Options[keyId].Value = key
                    end
                end,
            })

            local keyObj = {
                Type = "Keybind",
                Value = keyOpts.Default or Enum.KeyCode.Unknown,
                Mode = keyOpts.Mode or "Toggle",
                Callback = keyOpts.Callback,
                ChangedCallbacks = {},
                Field = keybindField,
            }

            function keyObj:SetValue(k)
                self.Value = k
                keybindField.Value = k
            end

            function keyObj:OnChanged(fn)
                table.insert(self.ChangedCallbacks, fn)
                return self
            end

            if keyOpts.Callback then
                keybindField.ValueChanged = function(_, key)
                    keyObj.Value = key
                    task.spawn(keyOpts.Callback, key)
                    for _, fn in ipairs(keyObj.ChangedCallbacks) do task.spawn(fn, key) end
                end
            end

            vynxLibrary.Options[keyId] = keyObj
            return keyObj
        end

        -- Support embedding Colorpicker inside Toggle row
        function toggleObj:AddColorpicker(colorId: string, colorOpts)
            colorOpts = colorOpts or {}
            local colorObj = createColorpickerRow(form, colorId, colorOpts, vynxLibrary)
            return colorObj
        end

        if opts.Callback then
            toggle.ValueChanged = function(_, val)
                toggleObj.Value = val
                task.spawn(opts.Callback, val)
                for _, fn in ipairs(toggleObj.ChangedCallbacks) do task.spawn(fn, val) end
            end
        end

        vynxLibrary.Toggles[id] = toggleObj
        return toggleObj
    end

    -- AddSlider
    function wrappedForm:AddSlider(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local minVal = opts.Min or 0
        local maxVal = opts.Max or 100
        local defVal = opts.Default or minVal

        local slider = row:Right():Slider({
            Minimum = minVal,
            Maximum = maxVal,
            Value = defVal,
        })

        local valLabel = row:Right():Label({
            Text = tostring(defVal) .. (opts.Suffix or ""),
        })

        local sliderObj = {
            Type = "Slider",
            Value = defVal,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Slider = slider,
            Label = valLabel,
        }

        local function formatValue(val: number)
            local rounded = val
            if opts.Rounding then
                if opts.Rounding == 0 then
                    rounded = math.round(val)
                else
                    local p = 10 ^ opts.Rounding
                    rounded = math.round(val * p) / p
                end
            end
            return rounded
        end

        slider.ValueChanged = function(_, val)
            local rounded = formatValue(val)
            valLabel.Text = tostring(rounded) .. (opts.Suffix or "")
            sliderObj.Value = rounded
            if opts.Callback then task.spawn(opts.Callback, rounded) end
            for _, fn in ipairs(sliderObj.ChangedCallbacks) do task.spawn(fn, rounded) end
        end

        function sliderObj:SetValue(val: number)
            local rounded = formatValue(val)
            self.Value = rounded
            slider.Value = rounded
            valLabel.Text = tostring(rounded) .. (opts.Suffix or "")
        end

        function sliderObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = sliderObj
        return sliderObj
    end

    -- AddDropdown
    function wrappedForm:AddDropdown(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local valuesList = opts.Values or {}
        local defIdx = 1
        if typeof(opts.Default) == "string" then
            defIdx = table.find(valuesList, opts.Default) or 1
        elseif typeof(opts.Default) == "number" then
            defIdx = opts.Default
        end

        local popup = row:Right():PopUpButton({
            Options = valuesList,
            Value = defIdx,
            Maximum = opts.Multi and 999 or 1,
        })

        local dropdownObj = {
            Type = "Dropdown",
            Value = opts.Default or valuesList[1],
            Values = valuesList,
            Multi = opts.Multi == true,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Popup = popup,
        }

        popup.ValueChanged = function(_, rawVal)
            local resolved
            if dropdownObj.Multi and typeof(rawVal) == "table" then
                resolved = {}
                for _, idx in ipairs(rawVal) do
                    if valuesList[idx] then table.insert(resolved, valuesList[idx]) end
                end
            else
                local idx = typeof(rawVal) == "table" and rawVal[1] or rawVal
                resolved = valuesList[idx] or rawVal
            end

            dropdownObj.Value = resolved
            if opts.Callback then task.spawn(opts.Callback, resolved) end
            for _, fn in ipairs(dropdownObj.ChangedCallbacks) do task.spawn(fn, resolved) end
        end

        function dropdownObj:SetValue(val)
            if self.Multi and typeof(val) == "table" then
                local indices = {}
                for _, item in ipairs(val) do
                    local idx = table.find(valuesList, item)
                    if idx then table.insert(indices, idx) end
                end
                popup.Value = indices
            else
                local idx = table.find(valuesList, val)
                if idx then popup.Value = idx end
            end
        end

        function dropdownObj:SetValues(newValues)
            valuesList = newValues
            self.Values = newValues
            popup.Options = newValues
        end

        function dropdownObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = dropdownObj
        return dropdownObj
    end

    -- AddColorpicker
    function wrappedForm:AddColorpicker(id: string, opts)
        return createColorpickerRow(form, id, opts, vynxLibrary)
    end

    -- AddKeybind
    function wrappedForm:AddKeybind(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local keybindField = row:Right():KeybindField({
            Value = opts.Default or Enum.KeyCode.Unknown,
        })

        local keyObj = {
            Type = "Keybind",
            Value = opts.Default or Enum.KeyCode.Unknown,
            Mode = opts.Mode or "Toggle",
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Field = keybindField,
        }

        keybindField.ValueChanged = function(_, key)
            keyObj.Value = key
            if opts.Callback then task.spawn(opts.Callback, key) end
            for _, fn in ipairs(keyObj.ChangedCallbacks) do task.spawn(fn, key) end
        end

        function keyObj:SetValue(k)
            self.Value = k
            keybindField.Value = k
        end

        function keyObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = keyObj
        return keyObj
    end

    -- AddButton
    function wrappedForm:AddButton(opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Title or opts.Text or "Button" })
        if opts.Subtitle or opts.Text then
            row:Left():TitleStack({
                Title = opts.Title or opts.Text or "",
                Subtitle = opts.Subtitle,
            })
        end

        local clicks = 0
        local lastClick = 0

        local btn = row:Right():Button({
            Label = opts.Title or opts.Text or "Button",
            Variant = opts.Variant or "Default",
            Pushed = function()
                if opts.DoubleClick then
                    local now = os.clock()
                    if now - lastClick < 0.35 then
                        if opts.Func then opts.Func() end
                    end
                    lastClick = now
                else
                    if opts.Func then opts.Func() end
                end
            end,
        })

        return btn
    end

    -- AddInput
    function wrappedForm:AddInput(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local tf = row:Right():TextField({
            Value = opts.Default or "",
            Placeholder = opts.Placeholder or "",
            ValueChanged = function(_, text)
                if vynxLibrary.Options[id] then
                    vynxLibrary.Options[id].Value = text
                end
            end,
        })

        local inputObj = {
            Type = "Input",
            Value = opts.Default or "",
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            TextField = tf,
        }

        tf.ValueChanged = function(_, text)
            inputObj.Value = text
            if opts.Callback then task.spawn(opts.Callback, text) end
            for _, fn in ipairs(inputObj.ChangedCallbacks) do task.spawn(fn, text) end
        end

        function inputObj:SetValue(val: string)
            self.Value = val
            tf.Value = val
        end

        function inputObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = inputObj
        return inputObj
    end

    -- AddStepper
    function wrappedForm:AddStepper(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local minVal = opts.Min or 0
        local maxVal = opts.Max or 100
        local stepVal = opts.Step or 1
        local defVal = opts.Default or minVal

        local stepper = row:Right():Stepper({
            Minimum = minVal,
            Maximum = maxVal,
            Step = stepVal,
            Value = defVal,
        })

        local stepperObj = {
            Type = "Stepper",
            Value = defVal,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Stepper = stepper,
        }

        stepper.ValueChanged = function(_, val)
            stepperObj.Value = val
            if opts.Callback then task.spawn(opts.Callback, val) end
            for _, fn in ipairs(stepperObj.ChangedCallbacks) do task.spawn(fn, val) end
        end

        function stepperObj:SetValue(val: number)
            self.Value = val
            stepper.Value = val
        end

        function stepperObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = stepperObj
        return stepperObj
    end

    -- AddSegmented
    function wrappedForm:AddSegmented(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local valuesList = opts.Values or {}
        local defIdx = 1
        if typeof(opts.Default) == "string" then
            defIdx = table.find(valuesList, opts.Default) or 1
        elseif typeof(opts.Default) == "number" then
            defIdx = opts.Default
        end

        local radioGroup = row:Right():RadioButtonGroup({
            Options = valuesList,
            Value = defIdx,
        })

        local segmentedObj = {
            Type = "Segmented",
            Value = opts.Default or valuesList[1],
            Values = valuesList,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            RadioGroup = radioGroup,
        }

        radioGroup.ValueChanged = function(_, idx)
            local resolved = valuesList[idx] or idx
            segmentedObj.Value = resolved
            if opts.Callback then task.spawn(opts.Callback, resolved) end
            for _, fn in ipairs(segmentedObj.ChangedCallbacks) do task.spawn(fn, resolved) end
        end

        function segmentedObj:SetValue(val)
            local idx = table.find(valuesList, val)
            if idx then radioGroup.Value = idx end
        end

        function segmentedObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = segmentedObj
        return segmentedObj
    end

    -- AddLabel
    function wrappedForm:AddLabel(text: string)
        local row = form:Row()
        row:Left():Label({ Text = text })
        return row
    end

    -- AddDivider
    function wrappedForm:AddDivider()
        -- Row divider is automatic between rows in Form
    end

    -- AddDependencyBox
    function wrappedForm:AddDependencyBox(toggleObj)
        local subForm = form -- rows in this sub-form track toggleObj.Value
        local depForm = wrapForm(subForm, vynxLibrary)
        local originalAddToggle = depForm.AddToggle
        local originalAddSlider = depForm.AddSlider
        local originalAddDropdown = depForm.AddDropdown

        local managedRows = {}

        local function updateVisibility(active: boolean)
            for _, r in ipairs(managedRows) do
                if r.Structures and r.Structures.Body then
                    r.Structures.Body.Visible = active
                end
            end
        end

        if toggleObj and toggleObj.OnChanged then
            toggleObj:OnChanged(function(val)
                updateVisibility(val == true)
            end)
        end

        local depWrapper = setmetatable({}, {
            __index = function(_, k)
                local origMethod = depForm[k]
                if typeof(origMethod) == "function" then
                    return function(self, ...)
                        local res = origMethod(depForm, ...)
                        if res and res.Row then
                            table.insert(managedRows, res.Row)
                            if toggleObj and toggleObj.Value ~= nil then
                                if res.Row.Structures and res.Row.Structures.Body then
                                    res.Row.Structures.Body.Visible = (toggleObj.Value == true)
                                end
                            end
                        end
                        return res
                    end
                end
                return origMethod
            end
        })

        return depWrapper
    end

    return wrappedForm
end

local function wrapPageSection(pageSection, vynxLibrary)
    local wrappedPS = {
        PageSection = pageSection,
    }

    function wrappedPS:AddForm()
        local form = pageSection:Form()
        return wrapForm(form, vynxLibrary)
    end

    return wrappedPS
end

local function wrapTab(tab, vynxLibrary)
    local wrappedTab = {
        Tab = tab,
    }

    function wrappedTab:AddPageSection(opts)
        opts = opts or {}
        local ps = tab:PageSection({
            Title = opts.Title,
            Subtitle = opts.Subtitle,
        })
        return wrapPageSection(ps, vynxLibrary)
    end

    function wrappedTab:AddForm()
        local form = tab:Form()
        return wrapForm(form, vynxLibrary)
    end

    -- Classic Linoria compatibility: AddLeftGroupbox / AddRightGroupbox / AddGroupbox
    function wrappedTab:AddLeftGroupbox(title: string)
        local ps = tab:PageSection({ Title = string.upper(title) })
        local form = ps:Form()
        return wrapForm(form, vynxLibrary)
    end

    function wrappedTab:AddRightGroupbox(title: string)
        local ps = tab:PageSection({ Title = string.upper(title) })
        local form = ps:Form()
        return wrapForm(form, vynxLibrary)
    end

    function wrappedTab:AddGroupbox(title: string)
        local ps = tab:PageSection({ Title = string.upper(title) })
        local form = ps:Form()
        return wrapForm(form, vynxLibrary)
    end

    return wrappedTab
end

local function wrapSection(section, vynxLibrary)
    local wrappedSec = {
        Section = section,
    }

    function wrappedSec:AddTab(opts)
        if typeof(opts) == "string" then opts = { Title = opts } end
        opts = opts or {}

        local icon = opts.Icon
        if typeof(icon) == "string" and vynxLibrary.Symbols[icon] then
            icon = vynxLibrary.Symbols[icon]
        end

        local tab = section:Tab({
            Title = opts.Title or opts.Text or "Tab",
            Icon = icon,
            Selected = opts.Selected,
        })
        return wrapTab(tab, vynxLibrary)
    end

    function wrappedSec:CreateTab(opts)
        return self:AddTab(opts)
    end

    return wrappedSec
end

-- -------------------------------------------------------------------------
-- CreateWindow (Main entrypoint)
-- -------------------------------------------------------------------------
function Vynx:CreateWindow(options)
    options = options or {}

    -- Resolve Theme
    local themeObj = self.Themes.Dark
    if options.Theme == "Light" or options.Theme == self.Themes.Light then
        themeObj = self.Themes.Light
    end

    -- Resolve Accent
    local accentObj = self.Accents.Blue
    if typeof(options.Accent) == "string" and self.Accents[options.Accent] then
        accentObj = self.Accents[options.Accent]
    elseif typeof(options.Accent) == "table" then
        accentObj = options.Accent
    end

    -- Create App
    local app = self.New({
        WindowPill = options.WindowPill ~= false,
        Theme = themeObj,
        Accent = accentObj,
    })
    self.ActiveApp = app

    -- Container ScreenGui
    local screenGui = app.__container or (app.Structures and app.Structures.WindowPill and app.Structures.WindowPill.Parent)
    self.ScreenGui = screenGui

    -- Create Window
    local window = app:Window({
        Title = options.Title or "Vynx",
        Subtitle = options.Subtitle or options.SubTitle,
        Size = options.Size or UDim2.fromOffset(720, 480),
        Dropshadow = options.Dropshadow ~= false,
        Resizable = options.Resizable ~= false,
        Searching = options.Searchable ~= false,
    })
    self.ActiveWindow = window

    -- Responsive Mobile Auto-Scale (UIScale)
    local bodyFrame = window.Structures and window.Structures.Body
    if bodyFrame then
        local uiScale = Instance.new("UIScale")
        uiScale.Name = "VynxResponsiveScale"
        uiScale.Parent = bodyFrame

        local function updateScale()
            local cam = workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
            local targetW = (options.Size and options.Size.X.Offset > 0) and options.Size.X.Offset or 720
            local targetH = (options.Size and options.Size.Y.Offset > 0) and options.Size.Y.Offset or 480

            local scaleX = (vp.X - 24) / targetW
            local scaleY = (vp.Y - 24) / targetH
            local minScale = math.min(scaleX, scaleY)
            if minScale < 1 then
                uiScale.Scale = math.clamp(minScale, 0.55, 1)
            else
                uiScale.Scale = 1
            end
        end
        updateScale()
        local scaleConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        table.insert(self.UnloadSignals, function() scaleConn:Disconnect() end)
    end

    -- Keybind toggle listener
    local toggleKey = options.Keybind or Enum.KeyCode.RightControl
    local uisConn = UserInputService.InputEnded:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            window.Minimized = not window.Minimized
        end
    end)
    table.insert(self.UnloadSignals, function() uisConn:Disconnect() end)

    -- Floating Launcher Button
    if screenGui then
        local launcher = createFloatingLauncher(screenGui, window, app)
        self.ActiveLauncher = launcher
        window:GetPropertyChangedSignal("Minimized"):Connect(function()
            launcher.Visible = window.Minimized
        end)
    end

    -- Wrapped Window
    local defaultSection = nil
    local wrappedWin = {
        Window = window,
        App = app,
    }

    function wrappedWin:AddSection(title: string)
        local sec = window:Section({
            Title = title,
            Disclosure = false,
        })
        return wrapSection(sec, Vynx)
    end

    function wrappedWin:AddTab(opts)
        if not defaultSection then
            defaultSection = self:AddSection("Navigation")
        end
        return defaultSection:AddTab(opts)
    end

    function wrappedWin:CreateTab(opts)
        return self:AddTab(opts)
    end

    return wrappedWin
end

-- -------------------------------------------------------------------------
-- Theme Switching API
-- -------------------------------------------------------------------------
function Vynx:SetTheme(themeName: string)
    if not self.ActiveApp then return end
    if themeName == "Light" or themeName == self.Themes.Light then
        self.ActiveApp.Theme = self.Themes.Light
    else
        self.ActiveApp.Theme = self.Themes.Dark
    end
end

function Vynx:SetAccent(accentName: string)
    if not self.ActiveApp then return end
    if typeof(accentName) == "string" and self.Accents[accentName] then
        self.ActiveApp.Accent = self.Accents[accentName]
    elseif typeof(accentName) == "table" then
        self.ActiveApp.Accent = accentName
    end
end

-- -------------------------------------------------------------------------
-- Teardown / Unload
-- -------------------------------------------------------------------------
function Vynx:OnUnload(cb)
    table.insert(self.UnloadSignals, cb)
end

function Vynx:Unload()
    for _, fn in ipairs(self.UnloadSignals) do
        pcall(fn)
    end
    table.clear(self.UnloadSignals)

    if self.ActiveWindow and self.ActiveWindow.Destroy then
        pcall(function() self.ActiveWindow:Destroy() end)
    end
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end

    table.clear(self.Toggles)
    table.clear(self.Options)
    self.ActiveWindow = nil
    self.ActiveApp = nil
    self.ActiveWatermark = nil
    self.ActiveLauncher = nil
end

return Vynx
"""

    bundle_full = header + base_cascade_code + vynx_layer

    os.makedirs(os.path.dirname(OUTPUT_BUNDLE), exist_ok=True)
    with open(OUTPUT_BUNDLE, "w", encoding="utf-8") as out:
        out.write(bundle_full)

    print(f"Bundle successfully created at: {OUTPUT_BUNDLE}")
    print(f"Bundle size: {len(bundle_full)} chars ({len(bundle_full.encode('utf-8'))} bytes)")
    print(f"Lines count: {len(bundle_full.splitlines())}")

if __name__ == "__main__":
    build()
