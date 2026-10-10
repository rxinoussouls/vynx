--!strict
--[[
    Vynx UI Library - macOS Sequoia Edition
    Loads the standalone bundle or build/bundle.luau
]]--

local bundleScript = script.Parent:FindFirstChild("build") and script.Parent.build:FindFirstChild("bundle")
if bundleScript and bundleScript:IsA("ModuleScript") then
	return require(bundleScript)
end

local ok, lib = pcall(function()
	if loadfile then
		return loadfile("C:/Users/Admin/.gemini/antigravity/scratch/vynx/build/bundle.luau")()
	end
	return nil
end)

if ok and lib then
	return lib
end

error("Vynx: build/bundle.luau could not be located. Run python tools/bundle_vynx.py first.")
