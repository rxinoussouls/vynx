# vynx UI Library (macOS Sequoia Edition)

Roblox Luau UI library inspired by the macOS Sequoia Settings interface, while maintaining full backward compatibility with Obsidian / LinoriaLib scripts.

---

## Architecture

Vynx uses a structured, form-based layout hierarchy:

```
Window
 ├── Titlebar (Traffic lights, Window Title, Search field)
 ├── Sidebar (Sections, Tabs with SF-style glyph icons)
 ├── Content Area
 │    └── Page (Single full-width scrolling column, large title)
 │         └── PageSection (Heading + Subtitle)
 │              └── Form (Rounded card, hairline borders, inset dividers)
 │                   └── Row (Left: TitleStack | Right: Control)
 └── StatusBar (Config profile, live FPS and ping counter)
```

### Full Backward Compatibility
Existing scripts continue to work without modification:
- `Tab:AddLeftGroupbox(title)` and `Tab:AddRightGroupbox(title)` map directly into PageSections and Forms.
- Global registries `Library.Toggles` and `Library.Options` maintain `.Value`, `:SetValue(val)`, and `:OnChanged(fn)`.
- `SaveManager` configs, auto-loads, and keybinds operate seamlessly.

---

## Design Tokens & Themes

Vynx decouples the base **Theme** from the active **Accent**, allowing both to change independently with smooth runtime transitions:

- **Themes**: `Dark` (default, `#1C1C1E`) and `Light` (`#F2F2F7`).
- **Accents**: `Blue` (`#0A84FF`), `Purple` (`#BF5AF2`), `Pink` (`#FF375F`), `Red` (`#FF453A`), `Orange` (`#FF9F0A`), `Yellow` (`#FFD60A`), `Green` (`#30D158`), `Graphite` (`#98989F`).

```lua
Library:SetTheme("Dark")
Library:SetAccent("Purple")
```

---

## Quick Start

### 1. Modern macOS Sequoia API

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rxinoussouls/vynx/main/build/bundle.luau"))()

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

local General = Window:AddSection("General")
local MainTab = General:AddTab({
    Title = "Controls",
    Icon = "settings",
    Selected = true,
})

local CombatSec = MainTab:AddPageSection({
    Title = "COMBAT",
    Subtitle = "Targeting and projectile modifications",
})

local CombatForm = CombatSec:AddForm()

local aimToggle = CombatForm:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Subtitle = "Overrides bullet trajectory toward target",
    Default = false,
    Callback = function(enabled)
        print("Silent Aim:", enabled)
    end,
})

-- Inline sub-controls on rows
aimToggle:AddKeybind("AimKey", {
    Default = Enum.KeyCode.E,
    Mode = "Toggle",
})

aimToggle:AddColorpicker("AimColor", {
    Default = Color3.fromRGB(10, 132, 255),
})

CombatForm:AddSlider("FOV", {
    Text = "Field of View",
    Subtitle = "Targeting radius (double-click label to type directly)",
    Default = 90,
    Min = 10,
    Max = 360,
    Suffix = "°",
})

CombatForm:AddDropdown("Priority", {
    Text = "Target Bone",
    Values = { "Head", "UpperTorso", "HumanoidRootPart" },
    Default = "Head",
})

CombatForm:AddSegmented("Mode", {
    Text = "Targeting Mode",
    Values = { "Distance", "Crosshair", "Health" },
    Default = "Crosshair",
})

CombatForm:AddStepper("Multiplier", {
    Text = "Damage Multiplier",
    Min = 1,
    Max = 10,
    Step = 1,
    Default = 1,
    Suffix = "x",
})
```

### 2. Classic Obsidian / LinoriaLib API (Drop-in Replacement)

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rxinoussouls/vynx/main/build/bundle.luau"))()

local Window = Library:CreateWindow({ Title = "vynx" })
local Tab = Window:AddTab("Main")

local LeftBox = Tab:AddLeftGroupbox("Features")
LeftBox:AddToggle("MyToggle", { Text = "ESP", Default = false })
LeftBox:AddSlider("Speed", { Text = "Speed", Min = 16, Max = 150, Default = 16 })

-- Direct event listening
Library.Toggles.MyToggle:OnChanged(function(val)
    print("Toggle updated:", val)
end)
```

---

## Component Suite

| Component | Features |
| :--- | :--- |
| **Window** | Traffic lights (`✕`, `−`, `+`), search bar (`Ctrl+K`), auto-scaling for mobile, smooth open/close, optional drop shadow and resize handle |
| **Sidebar** | 200px column with section headers, 32px tab rows, built-in SF-style glyph icons, filled accent selection |
| **Row** | Minimum 44px (52px on touch), auto-wrapping Title + Subtitle stack, right-aligned controls, inset hairline dividers |
| **Toggle** | 40×24 macOS switch pill, 20px white knob with shadow, press-stretch animation, embedded Keybind and Colorpicker support |
| **Slider** | 4px track, 16px white knob, double-click value label to type numbers directly, divide-by-zero protection |
| **Button** | Default macOS pill style and `Prominent` variant, click bounce, double-click confirmation mode |
| **Stepper** | `[−]` and `[+]` connected capsule control for step-based numerical values |
| **Segmented** | Sliding pill segmented control for selecting between distinct modes |
| **Input** | macOS text field, debounced input processing, numeric filtering mode |
| **Keybind** | Keyboard and mouse button binding, `Toggle` / `Hold` / `Always` modes |
| **Dropdown** | PopUpButton in top-level popover layer, search filter for > 8 items, multi-select with checkmarks |
| **Colorpicker** | Swatch button opening popover with Apple system palette, hex input box, and live sync |
| **Notification** | Top-right macOS notification toasts, auto-height, pause on hover, progress timer, semantic types |
| **StatusBar** | Bottom 24px bar displaying active configuration name and real-time FPS/ping |
| **Launcher** | Draggable floating button ("V") restoring the window on mobile or when minimized |

---

## Installation & Distribution

- **Raw Bundle**: `https://raw.githubusercontent.com/rxinoussouls/vynx/main/build/bundle.luau`
- **Rojo Sync**: Use `rojo serve` with `default.project.json` to mount `src/` to `ReplicatedStorage.vynx` in Roblox Studio.
- **Build Script**: Run `python tools/bundle_vynx.py` to regenerate the standalone bundle.
