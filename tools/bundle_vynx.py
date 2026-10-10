import os
import re

BASE_DIR = r"C:\Users\Admin\.gemini\antigravity\scratch\vynx"
SRC_DIR = os.path.join(BASE_DIR, "src")
BUILD_DIR = os.path.join(BASE_DIR, "build")
OUTPUT_FILE = os.path.join(BUILD_DIR, "bundle.luau")

MODULES = [
    ("Core.Motion", os.path.join(SRC_DIR, "Core", "Motion.luau")),
    ("Core.Theme", os.path.join(SRC_DIR, "Core", "Theme.luau")),
    ("Core.Elements", os.path.join(SRC_DIR, "Core", "Elements.luau")),
    ("Core.Icons", os.path.join(SRC_DIR, "Core", "Icons.luau")),
    ("Core.Maid", os.path.join(SRC_DIR, "Core", "Maid.luau")),
    ("Core.Drag", os.path.join(SRC_DIR, "Core", "Drag.luau")),
    ("Core.Tooltip", os.path.join(SRC_DIR, "Core", "Tooltip.luau")),
    ("Core.SaveManager", os.path.join(SRC_DIR, "Core", "SaveManager.luau")),
    ("Components.Popover", os.path.join(SRC_DIR, "Components", "Popover.luau")),
    ("Components.TitleStack", os.path.join(SRC_DIR, "Components", "TitleStack.luau")),
    ("Components.Row", os.path.join(SRC_DIR, "Components", "Row.luau")),
    ("Components.Launcher", os.path.join(SRC_DIR, "Components", "Launcher.luau")),
    ("Components.StatusBar", os.path.join(SRC_DIR, "Components", "StatusBar.luau")),
    ("Components.Watermark", os.path.join(SRC_DIR, "Components", "Watermark.luau")),
    ("Components.Button", os.path.join(SRC_DIR, "Components", "Button.luau")),
    ("Components.Colorpicker", os.path.join(SRC_DIR, "Components", "Colorpicker.luau")),
    ("Components.Keybind", os.path.join(SRC_DIR, "Components", "Keybind.luau")),
    ("Components.Toggle", os.path.join(SRC_DIR, "Components", "Toggle.luau")),
    ("Components.Slider", os.path.join(SRC_DIR, "Components", "Slider.luau")),
    ("Components.Input", os.path.join(SRC_DIR, "Components", "Input.luau")),
    ("Components.Stepper", os.path.join(SRC_DIR, "Components", "Stepper.luau")),
    ("Components.Segmented", os.path.join(SRC_DIR, "Components", "Segmented.luau")),
    ("Components.Dropdown", os.path.join(SRC_DIR, "Components", "Dropdown.luau")),
    ("Components.Notification", os.path.join(SRC_DIR, "Components", "Notification.luau")),
    ("Components.Form", os.path.join(SRC_DIR, "Components", "Form.luau")),
    ("Components.PageSection", os.path.join(SRC_DIR, "Components", "PageSection.luau")),
    ("Components.Page", os.path.join(SRC_DIR, "Components", "Page.luau")),
    ("Components.Tab", os.path.join(SRC_DIR, "Components", "Tab.luau")),
    ("Components.Section", os.path.join(SRC_DIR, "Components", "Section.luau")),
    ("Components.Groupbox", os.path.join(SRC_DIR, "Components", "Groupbox.luau")),
    ("Components.Window", os.path.join(SRC_DIR, "Components", "Window.luau")),
    ("Main", os.path.join(SRC_DIR, "init.luau")),
]

def generate_bundle():
    os.makedirs(BUILD_DIR, exist_ok=True)
    
    parts = []
    parts.append("--[[\n    Vynx UI Library - Standalone Single File Bundle (macOS Sequoia Edition)\n    Compatible with all Luau executors and Roblox Studio\n]]--")
    parts.append("local _modules = {}")
    parts.append("local _loaded = {}")
    parts.append("local function _require(name)")
    parts.append("    if _loaded[name] then")
    parts.append("        return _loaded[name]")
    parts.append("    end")
    parts.append("    if _modules[name] then")
    parts.append("        _loaded[name] = _modules[name]()")
    parts.append("        return _loaded[name]")
    parts.append("    end")
    parts.append("    error('Module not found: ' .. tostring(name))")
    parts.append("end\n")

    substitutions = [
        # Relative require patterns
        (r'require\(script\.Parent\.Parent\.Core\.Motion\)', '_require("Core.Motion")'),
        (r'require\(script\.Parent\.Parent\.Core\.Elements\)', '_require("Core.Elements")'),
        (r'require\(script\.Parent\.Parent\.Core\.Theme\)', '_require("Core.Theme")'),
        (r'require\(script\.Parent\.Parent\.Core\.Icons\)', '_require("Core.Icons")'),
        (r'require\(script\.Parent\.Parent\.Core\.Maid\)', '_require("Core.Maid")'),
        (r'require\(script\.Parent\.Parent\.Core\.Tooltip\)', '_require("Core.Tooltip")'),
        (r'require\(script\.Parent\.Parent\.Core\.Drag\)', '_require("Core.Drag")'),
        (r'require\(script\.Parent\.Parent\.Core\.SaveManager\)', '_require("Core.SaveManager")'),
        
        (r'require\(script\.Parent\.Motion\)', '_require("Core.Motion")'),
        (r'require\(script\.Parent\.Elements\)', '_require("Core.Elements")'),
        (r'require\(script\.Parent\.Theme\)', '_require("Core.Theme")'),
        (r'require\(script\.Parent\.Icons\)', '_require("Core.Icons")'),
        (r'require\(script\.Parent\.Maid\)', '_require("Core.Maid")'),
        (r'require\(script\.Parent\.Tooltip\)', '_require("Core.Tooltip")'),
        (r'require\(script\.Parent\.Drag\)', '_require("Core.Drag")'),
        (r'require\(script\.Parent\.SaveManager\)', '_require("Core.SaveManager")'),

        (r'require\(script\.Parent\.Popover\)', '_require("Components.Popover")'),
        (r'require\(script\.Parent\.TitleStack\)', '_require("Components.TitleStack")'),
        (r'require\(script\.Parent\.Row\)', '_require("Components.Row")'),
        (r'require\(script\.Parent\.Form\)', '_require("Components.Form")'),
        (r'require\(script\.Parent\.PageSection\)', '_require("Components.PageSection")'),
        (r'require\(script\.Parent\.Page\)', '_require("Components.Page")'),
        (r'require\(script\.Parent\.Section\)', '_require("Components.Section")'),
        (r'require\(script\.Parent\.StatusBar\)', '_require("Components.StatusBar")'),
        (r'require\(script\.Parent\.Launcher\)', '_require("Components.Launcher")'),
        (r'require\(script\.Parent\.Button\)', '_require("Components.Button")'),
        (r'require\(script\.Parent\.Colorpicker\)', '_require("Components.Colorpicker")'),
        (r'require\(script\.Parent\.Keybind\)', '_require("Components.Keybind")'),
        (r'require\(script\.Parent\.Toggle\)', '_require("Components.Toggle")'),
        (r'require\(script\.Parent\.Slider\)', '_require("Components.Slider")'),
        (r'require\(script\.Parent\.Input\)', '_require("Components.Input")'),
        (r'require\(script\.Parent\.Stepper\)', '_require("Components.Stepper")'),
        (r'require\(script\.Parent\.Segmented\)', '_require("Components.Segmented")'),
        (r'require\(script\.Parent\.Dropdown\)', '_require("Components.Dropdown")'),
        (r'require\(script\.Parent\.Notification\)', '_require("Components.Notification")'),
        (r'require\(script\.Parent\.Watermark\)', '_require("Components.Watermark")'),
        (r'require\(script\.Parent\.Groupbox\)', '_require("Components.Groupbox")'),
        (r'require\(script\.Parent\.Tab\)', '_require("Components.Tab")'),
        (r'require\(script\.Parent\.Window\)', '_require("Components.Window")'),

        (r'require\(script\.Core\.Motion\)', '_require("Core.Motion")'),
        (r'require\(script\.Core\.Elements\)', '_require("Core.Elements")'),
        (r'require\(script\.Core\.Theme\)', '_require("Core.Theme")'),
        (r'require\(script\.Core\.Icons\)', '_require("Core.Icons")'),
        (r'require\(script\.Core\.Maid\)', '_require("Core.Maid")'),
        (r'require\(script\.Core\.Tooltip\)', '_require("Core.Tooltip")'),
        (r'require\(script\.Core\.Drag\)', '_require("Core.Drag")'),
        (r'require\(script\.Core\.SaveManager\)', '_require("Core.SaveManager")'),
        (r'require\(script\.Components\.Popover\)', '_require("Components.Popover")'),
        (r'require\(script\.Components\.Window\)', '_require("Components.Window")'),
        (r'require\(script\.Components\.Notification\)', '_require("Components.Notification")'),
        (r'require\(script\.Components\.Watermark\)', '_require("Components.Watermark")'),
    ]

    for mod_name, file_path in MODULES:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        for pattern, replacement in substitutions:
            content = re.sub(pattern, replacement, content)

        parts.append(f"_modules['{mod_name}'] = function()")
        parts.append(content.strip())
        parts.append("end\n")

    parts.append("return _require('Main')")

    bundle_code = "\n".join(parts)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as out:
        out.write(bundle_code)
    print(f"Bundle successfully created at {OUTPUT_FILE} ({len(bundle_code)} bytes)")

if __name__ == "__main__":
    generate_bundle()
