local Page = require(script.Parent.Page)

local Tab = {}

function Tab.New(parent, name, library)
	local page = Page.New(parent, name, library)

	local tabObj = {
		Name = name,
		Page = page,
		AddPageSection = function(self, options)
			return page:AddPageSection(options)
		end,
		AddForm = function(self)
			return page:AddForm()
		end,
		-- Backward compatibility aliases: AddLeftGroupbox & AddRightGroupbox
		-- create a PageSection + Form in the single scrolling column (left first, then right)
		AddLeftGroupbox = function(self, title)
			return page:AddPageSection({ Title = title })
		end,
		AddRightGroupbox = function(self, title)
			return page:AddPageSection({ Title = title })
		end,
		Show = function(self)
			page:Show()
		end,
		Hide = function(self)
			page:Hide()
		end,
	}

	return tabObj
end

return Tab
