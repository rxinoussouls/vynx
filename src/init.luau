--!strict
local CoreGui = game:GetService("CoreGui")

local Elements = require(script.Core.Elements)
local Theme = require(script.Core.Theme)
local SaveManager = require(script.Core.SaveManager)
local Window = require(script.Components.Window)
local Notification = require(script.Components.Notification)

local Library = {
	Toggles = {} :: { [string]: any },
	Options = {} :: { [string]: any },
	Theme = Theme,
	SaveManager = SaveManager,
	ScreenGui = nil :: ScreenGui?,
	ActiveWindow = nil :: any,
}

SaveManager:SetLibrary(Library)

local function getGuiParent(): Instance
	if typeof(gethui) == "function" then
		return gethui()
	end
	return CoreGui
end

function Library:InitGui(): ScreenGui
	if self.ScreenGui then
		return self.ScreenGui
	end

	local gui = Elements.Create("ScreenGui", {
		Name = "vynx_" .. string.sub(tostring(math.random()), 3, 8),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = getGuiParent(),
	}) :: ScreenGui

	if typeof(syn) == "table" and typeof((syn :: any).protect_gui) == "function" then
		(syn :: any).protect_gui(gui)
	end

	self.ScreenGui = gui
	Notification.Init(gui)
	return gui
end

function Library:CreateWindow(options: any)
	local gui = self:InitGui()
	local win = Window.New(gui, options, self)
	self.ActiveWindow = win
	return win
end

function Library:Notify(info: { Title: string?, Content: string, Duration: number? })
	if not self.ScreenGui then
		self:InitGui()
	end
	Notification.Show(info)
end

function Library:SetTheme(nameOrPalette: any)
	Theme.SetTheme(nameOrPalette)
end

function Library:Unload()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end
	table.clear(self.Toggles)
	table.clear(self.Options)
end

return Library
