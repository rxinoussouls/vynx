import os
import re

BASE_DIR = r"C:\Users\Admin\.gemini\antigravity\scratch\vynx"
SRC_DIR = os.path.join(BASE_DIR, "src")
BUILD_DIR = os.path.join(BASE_DIR, "build")
OUTPUT_FILE = os.path.join(BUILD_DIR, "bundle.luau")

MODULES = [
    ("Core.Elements", os.path.join(SRC_DIR, "Core", "Elements.luau")),
    ("Core.Theme", os.path.join(SRC_DIR, "Core", "Theme.luau")),
    ("Core.Drag", os.path.join(SRC_DIR, "Core", "Drag.luau")),
    ("Core.SaveManager", os.path.join(SRC_DIR, "Core", "SaveManager.luau")),
    ("Components.Button", os.path.join(SRC_DIR, "Components", "Button.luau")),
    ("Components.Toggle", os.path.join(SRC_DIR, "Components", "Toggle.luau")),
    ("Components.Slider", os.path.join(SRC_DIR, "Components", "Slider.luau")),
    ("Components.Input", os.path.join(SRC_DIR, "Components", "Input.luau")),
    ("Components.Dropdown", os.path.join(SRC_DIR, "Components", "Dropdown.luau")),
    ("Components.Colorpicker", os.path.join(SRC_DIR, "Components", "Colorpicker.luau")),
    ("Components.Keybind", os.path.join(SRC_DIR, "Components", "Keybind.luau")),
    ("Components.Notification", os.path.join(SRC_DIR, "Components", "Notification.luau")),
    ("Components.Groupbox", os.path.join(SRC_DIR, "Components", "Groupbox.luau")),
    ("Components.Tab", os.path.join(SRC_DIR, "Components", "Tab.luau")),
    ("Components.Window", os.path.join(SRC_DIR, "Components", "Window.luau")),
    ("Main", os.path.join(SRC_DIR, "init.luau")),
]

def clean_code(content: str) -> str:
    # remove leading --!strict
    lines = content.splitlines()
    filtered = []
    for line in lines:
        if line.strip() == "--!strict":
            continue
        filtered.append(line)
    return "\n".join(filtered)

def generate_bundle():
    os.makedirs(BUILD_DIR, exist_ok=True)
    
    parts = []
    parts.append("--[[")
    parts.append("    Vynx UI Library - Standalone Single File Bundle")
    parts.append("    Generated for Roblox Luau execution (gethui / CoreGui)")
    parts.append("]]--")
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

    for mod_name, file_path in MODULES:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace requires with _require aliases
        content = re.sub(r'require\(script\.Parent\.Parent\.Core\.Elements\)', '_require("Core.Elements")', content)
        content = re.sub(r'require\(script\.Parent\.Parent\.Core\.Theme\)', '_require("Core.Theme")', content)
        content = re.sub(r'require\(script\.Parent\.Parent\.Core\.Drag\)', '_require("Core.Drag")', content)
        content = re.sub(r'require\(script\.Parent\.Parent\.Core\.SaveManager\)', '_require("Core.SaveManager")', content)
        content = re.sub(r'require\(script\.Parent\.Button\)', '_require("Components.Button")', content)
        content = re.sub(r'require\(script\.Parent\.Toggle\)', '_require("Components.Toggle")', content)
        content = re.sub(r'require\(script\.Parent\.Slider\)', '_require("Components.Slider")', content)
        content = re.sub(r'require\(script\.Parent\.Input\)', '_require("Components.Input")', content)
        content = re.sub(r'require\(script\.Parent\.Dropdown\)', '_require("Components.Dropdown")', content)
        content = re.sub(r'require\(script\.Parent\.Colorpicker\)', '_require("Components.Colorpicker")', content)
        content = re.sub(r'require\(script\.Parent\.Keybind\)', '_require("Components.Keybind")', content)
        content = re.sub(r'require\(script\.Parent\.Notification\)', '_require("Components.Notification")', content)
        content = re.sub(r'require\(script\.Parent\.Groupbox\)', '_require("Components.Groupbox")', content)
        content = re.sub(r'require\(script\.Parent\.Tab\)', '_require("Components.Tab")', content)
        content = re.sub(r'require\(script\.Parent\.Window\)', '_require("Components.Window")', content)
        content = re.sub(r'require\(script\.Core\.Elements\)', '_require("Core.Elements")', content)
        content = re.sub(r'require\(script\.Core\.Theme\)', '_require("Core.Theme")', content)
        content = re.sub(r'require\(script\.Core\.SaveManager\)', '_require("Core.SaveManager")', content)
        content = re.sub(r'require\(script\.Components\.Window\)', '_require("Components.Window")', content)
        content = re.sub(r'require\(script\.Components\.Notification\)', '_require("Components.Notification")', content)

        clean = clean_code(content)
        
        parts.append(f"_modules['{mod_name}'] = function()")
        parts.append(clean)
        parts.append("end\n")

    parts.append("return _require('Main')")

    bundle_code = "\n".join(parts)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as out:
        out.write(bundle_code)
    print(f"Bundle successfully created at {OUTPUT_FILE} ({len(bundle_code)} bytes)")

if __name__ == "__main__":
    generate_bundle()
