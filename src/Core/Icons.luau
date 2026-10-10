local Elements = require(script.Parent.Elements)

local Icons = {}

-- Original SF-inspired glyph mappings using clean unicode symbols
Icons.Glyphs = {
	["gear"] = "⚙",
	["settings"] = "⚙",
	["sliders"] = "⚲",
	["combat"] = "⚔",
	["shield"] = "🛡",
	["eye"] = "◎",
	["visuals"] = "◎",
	["waveform"] = "〰",
	["audio"] = "♫",
	["keyboard"] = "⌨",
	["paint"] = "🎨",
	["palette"] = "🎨",
	["folder"] = "📁",
	["search"] = "⌕",
	["close"] = "✕",
	["minimize"] = "−",
	["maximize"] = "+",
	["chevron.right"] = "›",
	["chevron.down"] = "⌄",
	["checkmark"] = "✓",
	["circle"] = "●",
	["star"] = "★",
	["sparkles"] = "✦",
	["cursor"] = "➤",
	["bell"] = "🔔",
	["info"] = "ⓘ",
	["warn"] = "⚠",
	["error"] = "✕",
}

function Icons.Get(nameOrAsset)
	if not nameOrAsset or nameOrAsset == "" then
		return nil
	end
	if Icons.Glyphs[nameOrAsset] then
		return Icons.Glyphs[nameOrAsset]
	end
	return nameOrAsset
end

function Icons.Render(nameOrAsset, parent, size, color)
	local resolved = Icons.Get(nameOrAsset)
	if not resolved then
		return nil
	end

	local sz = size or 16
	if string.sub(resolved, 1, 13) == "rbxassetid://" or string.sub(resolved, 1, 9) == "http://" or string.sub(resolved, 1, 10) == "https://" then
		local img = Elements.Create("ImageLabel", {
			Size = UDim2.fromOffset(sz, sz),
			BackgroundTransparency = 1,
			Image = resolved,
			ImageColor3 = color or Color3.fromRGB(255, 255, 255),
			Parent = parent,
		})
		return img
	else
		local lbl = Elements.Create("TextLabel", {
			Size = UDim2.fromOffset(sz, sz),
			BackgroundTransparency = 1,
			Text = resolved,
			TextColor3 = color or Color3.fromRGB(255, 255, 255),
			TextSize = math.floor(sz * 0.9),
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Parent = parent,
		})
		return lbl
	end
end

return Icons
