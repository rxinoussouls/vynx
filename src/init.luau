local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Elements = require(script.Core.Elements)
local Theme = require(script.Core.Theme)
local Maid = require(script.Core.Maid)
local Tooltip = require(script.Core.Tooltip)
local SaveManager = require(script.Core.SaveManager)
local Popover = require(script.Components.Popover)
local Window = require(script.Components.Window)
local Notification = require(script.Components.Notification)
local Watermark = require(script.Components.Watermark)

local Library = {
	Toggles = {},
	Options = {},
	Theme = Theme,
	SaveManager = SaveManager,
	ScreenGui = nil,
	ActiveWindow = nil,
	ActiveWatermark = nil,
	UnloadSignals = {},
	Maid = Maid.new(),
}

SaveManager:SetLibrary(Library)

local function getGuiParent()
	if typeof(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end

	local okCore = pcall(function()
		local test = Instance.new("Folder")
		test.Parent = CoreGui
		test:Destroy()
	end)
	if okCore then
		return CoreGui
	end

	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local playerGui = player:FindFirstChildOfClass("PlayerGui")
	if playerGui then
		return playerGui
	end

	return CoreGui
end

function Library:InitGui()
	if self.ScreenGui and self.ScreenGui.Parent then
		return self.ScreenGui
	end

	local gui = Elements.Create("ScreenGui", {
		Name = "vynx_" .. string.sub(tostring(math.random()), 3, 8),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = getGuiParent(),
	})

	if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
		pcall(function() syn.protect_gui(gui) end)
	end

	self.ScreenGui = gui
	Popover.Init(gui, self.Maid)
	Notification.Init(gui)
	Tooltip.Init(gui)
	return gui
end

function Library:CreateWindow(options)
	local gui = self:InitGui()
	local win = Window.New(gui, options, self)
	self.ActiveWindow = win
	return win
end

function Library:Notify(info)
	if not self.ScreenGui then
		self:InitGui()
	end
	Notification.Show(info)
end

function Library:SetWatermark(text)
	local gui = self:InitGui()
	if not self.ActiveWatermark then
		self.ActiveWatermark = Watermark.New(gui, text)
	else
		self.ActiveWatermark:SetText(text)
	end
	return self.ActiveWatermark
end

function Library:SetWatermarkVisibility(visible)
	if self.ActiveWatermark then
		self.ActiveWatermark:SetVisible(visible)
	end
end

function Library:SetTheme(nameOrPalette)
	Theme.SetTheme(nameOrPalette)
end

function Library:SetAccent(accentName)
	Theme.SetAccent(accentName)
end

function Library:OnUnload(callback)
	table.insert(self.UnloadSignals, callback)
end

function Library:Unload()
	for _, cb in ipairs(self.UnloadSignals) do
		task.spawn(cb)
	end
	table.clear(self.UnloadSignals)

	self.Maid:Clean()
	Popover.Clean()
	Tooltip.Clean()
	Notification.Clean()

	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end

	table.clear(self.Toggles)
	table.clear(self.Options)
	self.ActiveWatermark = nil
	self.ActiveWindow = nil
end

return Library
