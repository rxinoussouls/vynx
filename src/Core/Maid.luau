--!strict
local Maid = {}
Maid.__index = Maid

export type Maid = {
	Tasks: { any },
	Give: (self: Maid, task: any) -> any,
	Clean: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),
}

function Maid.new(): Maid
	return setmetatable({
		Tasks = {},
	}, Maid) :: any
end

function Maid:Give(task: any)
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
