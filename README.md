# vynx UI Library

High-performance, modular Roblox Luau UI library modeled after the Obsidian / LinoriaLib architecture.

---

## Features
- **Obsidian State Architecture**: Global `Library.Toggles` and `Library.Options` registries with direct `.Value` access and `:SetValue(...)` hooks.
- **Dynamic Theme Engine**: Live token-based theme switching (`Obsidian`, `Cyberpunk`, `Emerald`, `Monochrome`) with smooth tweens.
- **Physics-Based Drag Engine**: Lerp-based smooth dragging for PC and Touch/Mobile.
- **Dual-Column Layout**: Structured Window -> Tab -> Left/Right Groupbox hierarchy.
- **Config Persistence**: Built-in `SaveManager` with JSON file serialization (`writefile`/`readfile`).
- **Complete Component Suite**:
  - `Toggle`: Animated pill switch
  - `Button`: Push bounce & double-click protection
  - `Slider`: Precise integer/float dragging with suffixes
  - `Dropdown`: Single & multi-select with ZIndex popover
  - `Colorpicker`: Color swatch with palette popover
  - `Keybind`: UserInputService key listener (Toggle / Hold)
  - `Input`: Text & numeric input box
  - `Notification`: Non-blocking floating toast queue

---

## Quick Start

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/rxinoussouls/vynx/main/build/bundle.luau"))()

local Window = Library:CreateWindow({
    Title = "vynx",
    SubTitle = "v1.0.0",
    Size = UDim2.fromOffset(600, 420),
    TabWidth = 140,
    Keybind = Enum.KeyCode.RightControl,
})

local MainTab = Window:AddTab("Main")
local LeftBox = MainTab:AddLeftGroupbox("Features")

LeftBox:AddToggle("MyToggle", {
    Text = "Enable ESP",
    Default = false,
    Callback = function(enabled)
        print("ESP:", enabled)
    end,
})

LeftBox:AddSlider("WalkSpeed", {
    Text = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 120,
    Rounding = 0,
    Suffix = " studs/s",
    Callback = function(val)
        print("WalkSpeed:", val)
    end,
})

-- Hotkey: RightControl toggles window visibility
```

---

## Directory Layout
- `src/Core/`: Base rendering utilities, theme engine, drag engine, and save manager.
- `src/Components/`: Modular UI element definitions.
- `build/bundle.luau`: Single-file standalone distribution build.
- `examples/showcase.luau`: Full feature test script.
