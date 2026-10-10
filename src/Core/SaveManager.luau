--!strict
local HttpService = game:GetService("HttpService")

local SaveManager = {}

SaveManager.Folder = "vynx"
SaveManager.SubFolder = "configs"
SaveManager.Library = nil
SaveManager.IgnoreIndexes = { ["ConfigName"] = true } :: { [string]: boolean }

local function sanitize(name: string): string
	local clean = string.gsub(name, "[^%w%-_]", "")
	return clean ~= "" and clean or "default"
end

local function getPath(name: string): string
	return string.format("%s/%s/%s.json", SaveManager.Folder, SaveManager.SubFolder, sanitize(name))
end

function SaveManager:SetLibrary(library: any)
	self.Library = library
end

function SaveManager:SetIgnoreIndexes(indexes: { string })
	for _, idx in ipairs(indexes) do
		self.IgnoreIndexes[idx] = true
	end
end

function SaveManager:InitFolders()
	if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
		pcall(function()
			if not isfolder(self.Folder) then
				makefolder(self.Folder)
			end
			if not isfolder(self.Folder .. "/" .. self.SubFolder) then
				makefolder(self.Folder .. "/" .. self.SubFolder)
			end
		end)
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
		if not self.IgnoreIndexes[id] then
			data.Toggles[id] = toggle.Value
		end
	end

	for id, option in pairs(self.Library.Options) do
		if not self.IgnoreIndexes[id] then
			local val = option.Value
			if typeof(val) == "Color3" then
				data.Options[id] = {
					Type = "Color3",
					R = val.R,
					G = val.G,
					B = val.B,
					Transparency = option.Transparency or 0,
				}
			elseif typeof(val) == "EnumItem" then
				data.Options[id] = {
					Type = "EnumItem",
					Name = val.Name,
					Mode = option.Mode or "Toggle",
				}
			else
				data.Options[id] = { Type = "Primitive", Value = val }
			end
		end
	end

	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if ok and typeof(writefile) == "function" then
		local writeOk = pcall(function()
			writefile(getPath(name), encoded)
		end)
		return writeOk
	end
	return false
end

function SaveManager:Load(name: string): boolean
	if not self.Library then return false end
	local filePath = getPath(name)

	if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then
		return false
	end

	local existsOk, exists = pcall(function() return isfile(filePath) end)
	if not existsOk or not exists then return false end

	local readOk, content = pcall(function() return readfile(filePath) end)
	if not readOk or typeof(content) ~= "string" then return false end

	local decodeOk, data = pcall(function() return HttpService:JSONDecode(content) end)
	if not decodeOk or typeof(data) ~= "table" then return false end

	if data.Toggles then
		for id, val in pairs(data.Toggles) do
			if self.Library.Toggles[id] and not self.IgnoreIndexes[id] then
				self.Library.Toggles[id]:SetValue(val)
			end
		end
	end

	if data.Options then
		for id, item in pairs(data.Options) do
			if self.Library.Options[id] and not self.IgnoreIndexes[id] then
				if item.Type == "Color3" then
					self.Library.Options[id]:SetValue(Color3.new(item.R, item.G, item.B), item.Transparency or 0)
				elseif item.Type == "EnumItem" then
					local key = (Enum.KeyCode :: any)[item.Name]
					if key then
						self.Library.Options[id]:SetValue(key)
						if item.Mode and self.Library.Options[id].SetMode then
							self.Library.Options[id]:SetMode(item.Mode)
						end
					end
				else
					self.Library.Options[id]:SetValue(item.Value)
				end
			end
		end
	end

	return true
end

function SaveManager:DeleteConfig(name: string): boolean
	local filePath = getPath(name)
	if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(filePath) then
		local ok = pcall(function() delfile(filePath) end)
		return ok
	end
	return false
end

function SaveManager:ListConfigs(): { string }
	local configs = {}
	if typeof(listfiles) == "function" and typeof(isfolder) == "function" then
		self:InitFolders()
		local folderPath = self.Folder .. "/" .. self.SubFolder
		local ok, files = pcall(function() return listfiles(folderPath) end)
		if ok and typeof(files) == "table" then
			for _, file in ipairs(files) do
				local match = string.match(file, "([^/\\]+)%.json$")
				if match then
					table.insert(configs, match)
				end
			end
		end
	end
	return configs
end

function SaveManager:SetAutoLoad(name: string)
	local autoPath = self.Folder .. "/autoload.txt"
	if typeof(writefile) == "function" then
		pcall(function() writefile(autoPath, sanitize(name)) end)
	end
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

function SaveManager:BuildConfigSection(tab: any)
	local box = tab:AddRightGroupbox("Configuration")

	local configNameInput = box:AddInput("ConfigName", {
		Text = "Config Name",
		Placeholder = "default",
	})
	self.IgnoreIndexes["ConfigName"] = true

	local existingConfigs = self:ListConfigs()
	if #existingConfigs == 0 then
		table.insert(existingConfigs, "default")
	end

	local configDropdown = box:AddDropdown("ConfigSelect", {
		Text = "Saved Configs",
		Values = existingConfigs,
		Default = existingConfigs[1] or "default",
		Callback = function(val)
			configNameInput:SetValue(val)
		end,
	})
	self.IgnoreIndexes["ConfigSelect"] = true

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
						Type = ok and "Success" or "Error",
					})
				end
				configDropdown:SetValues(self:ListConfigs())
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
						Content = ok and ("Loaded config: " .. name) or "Config file not found",
						Type = ok and "Success" or "Error",
					})
				end
			end
		end,
	})

	box:AddButton({
		Text = "Delete Config",
		DoubleClick = true,
		Func = function()
			local name = configNameInput.Value
			if name and #name > 0 then
				local ok = self:DeleteConfig(name)
				if self.Library.Notify then
					self.Library:Notify({
						Title = "Config Manager",
						Content = ok and ("Deleted config: " .. name) or "Failed to delete config",
						Type = ok and "Warn" or "Error",
					})
				end
				configDropdown:SetValues(self:ListConfigs())
			end
		end,
	})
end

return SaveManager
