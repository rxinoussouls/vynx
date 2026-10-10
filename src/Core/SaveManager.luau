--!strict
local HttpService = game:GetService("HttpService")

local SaveManager = {}

SaveManager.Folder = "vynx"
SaveManager.SubFolder = "configs"
SaveManager.Library = nil

local function getPath(name: string): string
	return string.format("%s/%s/%s.json", SaveManager.Folder, SaveManager.SubFolder, name)
end

function SaveManager:SetLibrary(library: any)
	self.Library = library
end

function SaveManager:InitFolders()
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
		if not isfolder(self.Folder .. "/" .. self.SubFolder) then
			makefolder(self.Folder .. "/" .. self.SubFolder)
		end
	end
end

function SaveManager:Save(name: string): boolean
	if not self.Library then return false end
	self:InitFolders()

	local data = {
		Toggles = {},
		Options = {},
	}

	for id, toggle in pairs(self.Library.Toggles) do
		data.Toggles[id] = toggle.Value
	end

	for id, option in pairs(self.Library.Options) do
		local val = option.Value
		if typeof(val) == "Color3" then
			data.Options[id] = { Type = "Color3", R = val.R, G = val.G, B = val.B }
		elseif typeof(val) == "EnumItem" then
			data.Options[id] = { Type = "EnumItem", Name = val.Name }
		else
			data.Options[id] = { Type = "Primitive", Value = val }
		end
	end

	local encoded = HttpService:JSONEncode(data)
	if typeof(writefile) == "function" then
		writefile(getPath(name), encoded)
		return true
	end
	return false
end

function SaveManager:Load(name: string): boolean
	if not self.Library then return false end
	local filePath = getPath(name)
	if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" or not isfile(filePath) then
		return false
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(readfile(filePath))
	end)

	if not success or typeof(data) ~= "table" then
		return false
	end

	if data.Toggles then
		for id, val in pairs(data.Toggles) do
			if self.Library.Toggles[id] then
				self.Library.Toggles[id]:SetValue(val)
			end
		end
	end

	if data.Options then
		for id, item in pairs(data.Options) do
			if self.Library.Options[id] then
				if item.Type == "Color3" then
					self.Library.Options[id]:SetValue(Color3.new(item.R, item.G, item.B))
				elseif item.Type == "EnumItem" then
					local key = (Enum.KeyCode :: any)[item.Name]
					if key then
						self.Library.Options[id]:SetValue(key)
					end
				else
					self.Library.Options[id]:SetValue(item.Value)
				end
			end
		end
	end

	return true
end

function SaveManager:BuildConfigSection(tab: any)
	local box = tab:AddRightGroupbox("Configuration")

	local configNameInput = box:AddInput("ConfigName", {
		Text = "Config Name",
		Placeholder = "default",
	})

	box:AddButton({
		Text = "Save Config",
		Func = function()
			local name = configNameInput.Value
			if name and #name > 0 then
				local ok = self:Save(name)
				if self.Library.Notify then
					self.Library:Notify({
						Title = "Config Manager",
						Content = ok and ("Saved config: " .. name) or "Failed to save config",
					})
				end
			end
		end,
	})

	box:AddButton({
		Text = "Load Config",
		Func = function()
			local name = configNameInput.Value
			if name and #name > 0 then
				local ok = self:Load(name)
				if self.Library.Notify then
					self.Library:Notify({
						Title = "Config Manager",
						Content = ok and ("Loaded config: " .. name) or "Config not found",
					})
				end
			end
		end,
	})
end

return SaveManager
