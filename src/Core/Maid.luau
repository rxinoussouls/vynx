local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({
		Tasks = {},
	}, Maid)
end

function Maid:Give(task)
	table.insert(self.Tasks, task)
	return task
end

function Maid:Clean()
	for _, task in ipairs(self.Tasks) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "function" then
			task()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		elseif typeof(task) == "table" and typeof(task.Destroy) == "function" then
			task:Destroy()
		end
	end
	table.clear(self.Tasks)
end

function Maid:Destroy()
	self:Clean()
end

return Maid
