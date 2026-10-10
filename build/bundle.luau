--[[
    Vynx UI Library - macOS Sequoia Edition
    Ultra-optimized retained-mode macOS Sequoia UI library for Roblox Luau
    Compatible with all executors (gethui / CoreGui / PlayerGui) and Roblox Studio
]]--
--!nolint
--!nocheck
--!optimize 2
__SH = { COMPINDEXES = {} }
local __DIST={cache={}::any}do do local function __modImpl()
--// Variables

local utility = {}

--// Initialize
utility.Clone = function(object: any)
	local clonedObject: any

	if type(object) == "function" then
		clonedObject = clonefunction and clonefunction(object)
	elseif typeof(object) == "Instance" then
		clonedObject = cloneref and cloneref(object)
	end

	return clonedObject or object
end

utility.ProtectUI = function(gui: Instance): ScreenGui | string
	local sHiddenUi, hiddenUi = pcall(function()
		return gethui()
	end)

	local sCoreGui, coreGui = pcall(function()
		local layer = utility.Clone(game:GetService("CoreGui"))

		if layer and layer.ClassName then
			return layer
		end

		return
	end)

	local success, returned = pcall(function()
		gui.Parent = sHiddenUi and hiddenUi
			or sCoreGui and coreGui
			or utility.Clone(game:GetService("Players")).LocalPlayer.PlayerGui
	end)

	return success and gui or returned
end

return utility
end function __DIST.a():typeof(__modImpl())local v=__DIST.cache.a if not v then v={c=__modImpl()}__DIST.cache.a=v end return v.c end end do local function __modImpl()













































































































































































































































































































































































































































































































































return 1
end function __DIST.b():typeof(__modImpl())local v=__DIST.cache.b if not v then v={c=__modImpl()}__DIST.cache.b=v end return v.c end end do local function __modImpl()
local binder = {}

function binder.Apply(properties: { [string]: any }, object: any, excludes: { [number]: string }?): any
	for property, value in pairs(properties) do
		if excludes and table.find(excludes, property) then
			continue
		end

		pcall(function()
			object[property] = value
		end)
	end

	return object
end

function binder.ReactiveTable(initial, onChange)
	local raw = table.clone(initial or {})
	local proxy = {}

	local mt = {
		__index = function(_, key)
			return raw[key]
		end,
		__newindex = function(_, key, value)
			raw[key] = value
			if onChange then
				onChange(raw)
			end
		end,
		__len = function()
			return #raw
		end,
		__pairs = function()
			return pairs(raw)
		end,
		__ipairs = function()
			return ipairs(raw)
		end,
		__metatable = false,
	}

	return setmetatable(proxy, mt)
end

function binder.Wrap(
	object: { [string]: any },
	bindings: { [string]: (any) -> () },
	instance: Instance?,
	excludeSets: { [number]: any }?
): any
	local proxy = {}

	setmetatable(proxy, {
		__index = function(_, key)
			if object[key] ~= nil then
				return object[key]
			elseif instance then
				local ok, value = pcall(function()
					return instance[key]
				end)

				if ok then
					return value
				end
			end

			return
		end,

		__newindex = function(_, key, value)
			local handler = bindings[key]

			if handler then
				handler(value)

				if not (excludeSets and table.find(excludeSets, key)) then
					object[key] = value
				end
			elseif instance then
				local ok, _ = pcall(function()
					instance[key] = value
				end)

				if not ok then
					object[key] = value
				end
			else
				object[key] = value
			end
		end,
	})

	return proxy
end

return binder
end function __DIST.c():typeof(__modImpl())local v=__DIST.cache.c if not v then v={c=__modImpl()}__DIST.cache.c=v end return v.c end end do local function __modImpl()
local types = __DIST.b()
local binder = __DIST.c()

local creator = {}

function creator.Value(value: any): ValueState__DARKLUA_TYPE_m	
local callbacks = {}

	return binder.Wrap({
		Value = value,
		Connect = function(self, fn)
			table.insert(callbacks, fn)
			return fn
		end,
	}, {
		Value = function(newValue)
			for _, callback in pairs(callbacks) do
				pcall(callback, newValue)
			end
		end,
	})
end

function creator.Create(className: string)
	return function(properties)
		properties = properties or {}

		local instance = Instance.new(className)

		for key, value in pairs(properties) do
			if key == "__dynamicKeys" and type(value) == "table" then
				for property, valueObject: ValueState__DARKLUA_TYPE_m in pairs(value) do
					pcall(function()
						instance[property] = valueObject.Value
					end)

					valueObject:Connect(function(newValue)
						task.defer(pcall, function()
							if properties["__contextKeys"] and properties["__contextKeys"]["_general"] then
								properties["__contextKeys"]["_general"]()
							end

							instance[property] = properties["__contextKeys"]
									and properties["__contextKeys"][property]
									and properties["__contextKeys"][property]()
								or newValue
						end)
					end)
				end

				continue
			end

			if typeof(value) == "table" and value.__unique then
				value.Parent = instance
			end

			pcall(function()
				instance[key] = value
			end)
		end

		return setmetatable({ __unique = true }, {
			__metatable = instance,
			__index = function(_, key)
				if key == "__instance" then
					return instance
				end

				local value = instance[key]

				if typeof(value) == "function" then
					return function(_, ...)
						return value(instance, ...)
					end
				else
					return value
				end
			end,
			__newindex = function(_, key, value)
				instance[key] = value
			end,
		})
	end
end

return creator
end function __DIST.d():typeof(__modImpl())local v=__DIST.cache.d if not v then v={c=__modImpl()}__DIST.cache.d=v end return v.c end end do local function __modImpl()--// Imports

local utility = __DIST.a()

--// Functions
local function cast(service: string): any
	return utility.Clone(game:GetService(service))
end

--// Initialize
return {
	HttpService = cast("HttpService") :: HttpService,
	TweenService = cast("TweenService") :: TweenService,
	RunService = cast("RunService") :: RunService,
	UserInputService = cast("UserInputService") :: UserInputService,
	GuiService = cast("GuiService") :: GuiService,

	Workspace = cast("Workspace") :: Workspace,
	Players = cast("Players") :: Players,
	Lighting = cast("Lighting") :: Lighting,
}
end function __DIST.e():typeof(__modImpl())local v=__DIST.cache.e if not v then v={c=__modImpl()}__DIST.cache.e=v end return v.c end end do local function __modImpl()
local AppRecorder = {}
function AppRecorder.FromContext() return nil end
function AppRecorder.new() return { Start = function() end, Stop = function() end, _Begin = function() return nil end, _Commit = function() end, _Cancel = function() end } end
function AppRecorder.DumpApp() return "{}" end
return AppRecorder
end function __DIST.f()
:typeof(__modImpl())local v=__DIST.cache.f if not v then v={c=__modImpl()}__DIST.cache.f=v end return v.c end end do local function __modImpl()
local rawSymbols = {
  ["appleTerminal"] = "rbxassetid://88837948823350",
  ["appleTerminalFill"] = "rbxassetid://83023410889826",
  ["arrowClockwise"] = "rbxassetid://135150629431078",
  ["arrowCounterclockwise"] = "rbxassetid://93269551188316",
  ["arrowDown"] = "rbxassetid://104294868419018",
  ["arrowLeft"] = "rbxassetid://139677317950411",
  ["arrowRight"] = "rbxassetid://105335022791801",
  ["arrowUp"] = "rbxassetid://78648712658851",
  ["backward"] = "rbxassetid://122427584897716",
  ["bell"] = "rbxassetid://133308773796467",
  ["bellFill"] = "rbxassetid://120560073129118",
  ["bellSlash"] = "rbxassetid://131140638570899",
  ["bolt"] = "rbxassetid://112193227421813",
  ["boltFill"] = "rbxassetid://71909592017771",
  ["checkmark"] = "rbxassetid://117709091345748",
  ["checkmarkCircle"] = "rbxassetid://113497182715811",
  ["checkmarkCircleFill"] = "rbxassetid://80701432625608",
  ["checkmarkShield"] = "rbxassetid://116476478760645",
  ["checkmarkShieldFill"] = "rbxassetid://123693100854806",
  ["checkmarkSquare"] = "rbxassetid://90140343305408",
  ["checkmarkSquareFill"] = "rbxassetid://81712190011585",
  ["chevronDown"] = "rbxassetid://116067852952871",
  ["chevronLeft"] = "rbxassetid://120112805068615",
  ["chevronLeftForwardslashChevronRight"] = "rbxassetid://89806716346278",
  ["chevronRight"] = "rbxassetid://78578344679238",
  ["chevronUp"] = "rbxassetid://71994936177602",
  ["circle"] = "rbxassetid://77351764572440",
  ["circleFill"] = "rbxassetid://132609101842833",
  ["clipboard"] = "rbxassetid://131839244113738",
  ["clipboardFill"] = "rbxassetid://134384663588746",
  ["code"] = "rbxassetid://89806716346278",
  ["cpu"] = "rbxassetid://124308556421451",
  ["crosshair"] = "rbxassetid://111411956958702",
  ["display"] = "rbxassetid://129576202104478",
  ["display2"] = "rbxassetid://104707340982471",
  ["doc"] = "rbxassetid://80680488161934",
  ["docOnDoc"] = "rbxassetid://74221368188325",
  ["dotCrosshair"] = "rbxassetid://111411956958702",
  ["ellipsis"] = "rbxassetid://124361135229418",
  ["ellipsisCircle"] = "rbxassetid://113784442485781",
  ["exclamationmarkCircle"] = "rbxassetid://124980468238909",
  ["exclamationmarkCircleFill"] = "rbxassetid://118467060972001",
  ["exclamationmarkTriangle"] = "rbxassetid://107822175160368",
  ["exclamationmarkTriangleFill"] = "rbxassetid://114874558386316",
  ["eye"] = "rbxassetid://111055543166389",
  ["eyeFill"] = "rbxassetid://77235800413545",
  ["eyeSlash"] = "rbxassetid://119498809185323",
  ["eyeSlashFill"] = "rbxassetid://81778913526360",
  ["flame"] = "rbxassetid://108768547584054",
  ["flameFill"] = "rbxassetid://119270312720784",
  ["folder"] = "rbxassetid://125012160621787",
  ["folderFill"] = "rbxassetid://139360049720186",
  ["forward"] = "rbxassetid://113037057903118",
  ["gear"] = "rbxassetid://133102912527371",
  ["gearshape"] = "rbxassetid://127735318557062",
  ["gearshapeFill"] = "rbxassetid://98061574923339",
  ["globe"] = "rbxassetid://75166161739358",
  ["heart"] = "rbxassetid://107768052948480",
  ["heartFill"] = "rbxassetid://133334197582974",
  ["home"] = "rbxassetid://137977066267668",
  ["house"] = "rbxassetid://137977066267668",
  ["houseFill"] = "rbxassetid://139946019827392",
  ["infoCircle"] = "rbxassetid://140318155547831",
  ["infoCircleFill"] = "rbxassetid://120424810493200",
  ["key"] = "rbxassetid://133434192543807",
  ["keyFill"] = "rbxassetid://100941145516940",
  ["laptopcomputer"] = "rbxassetid://93924665405931",
  ["line3Horizontal"] = "rbxassetid://111782926831220",
  ["link"] = "rbxassetid://136619733214436",
  ["lock"] = "rbxassetid://75059666276795",
  ["lockFill"] = "rbxassetid://113641566747489",
  ["lockOpen"] = "rbxassetid://102783678054610",
  ["lockOpenFill"] = "rbxassetid://126165516505365",
  ["macwindow"] = "rbxassetid://120538366729599",
  ["macwindowOnRectangle"] = "rbxassetid://72758136163509",
  ["magnifyingglass"] = "rbxassetid://91129038063259",
  ["memorychip"] = "rbxassetid://72442769456866",
  ["minus"] = "rbxassetid://89004332408449",
  ["minusCircle"] = "rbxassetid://137503047808593",
  ["minusCircleFill"] = "rbxassetid://114233698275838",
  ["moon"] = "rbxassetid://82139899083256",
  ["moonFill"] = "rbxassetid://80943018865798",
  ["network"] = "rbxassetid://120498202241355",
  ["paintbrush"] = "rbxassetid://109533740362394",
  ["paintbrushPointed"] = "rbxassetid://127402849243896",
  ["paintpalette"] = "rbxassetid://138490319699379",
  ["paintpaletteFill"] = "rbxassetid://131716243676081",
  ["palette"] = "rbxassetid://138490319699379",
  ["pause"] = "rbxassetid://86021151376401",
  ["pauseFill"] = "rbxassetid://133135421688612",
  ["pencil"] = "rbxassetid://130705269869803",
  ["pencilAndOutline"] = "rbxassetid://71370761213291",
  ["person"] = "rbxassetid://110701632373035",
  ["person2"] = "rbxassetid://112399905717309",
  ["personCropCircle"] = "rbxassetid://118995818358156",
  ["personFill"] = "rbxassetid://87697331384088",
  ["play"] = "rbxassetid://128461418943884",
  ["playFill"] = "rbxassetid://74081916085124",
  ["plus"] = "rbxassetid://104140268501180",
  ["plusCircle"] = "rbxassetid://134903849508497",
  ["plusCircleFill"] = "rbxassetid://126835916552120",
  ["search"] = "rbxassetid://91129038063259",
  ["settings"] = "rbxassetid://127735318557062",
  ["shield"] = "rbxassetid://140526681233529",
  ["shieldFill"] = "rbxassetid://124747829928806",
  ["sliderHorizontal3"] = "rbxassetid://99890330649872",
  ["sliders"] = "rbxassetid://99890330649872",
  ["sparkles"] = "rbxassetid://105054419961789",
  ["speakerSlash"] = "rbxassetid://111943193498500",
  ["speakerSlashFill"] = "rbxassetid://110093423263690",
  ["speakerWave2"] = "rbxassetid://93687295077826",
  ["speakerWave2Fill"] = "rbxassetid://103180330131669",
  ["square"] = "rbxassetid://85143053995767",
  ["squareFill"] = "rbxassetid://89837132511355",
  ["star"] = "rbxassetid://97208341574073",
  ["starFill"] = "rbxassetid://112524490690853",
  ["stop"] = "rbxassetid://132098862323602",
  ["stopFill"] = "rbxassetid://74225402177219",
  ["sunMax"] = "rbxassetid://136191950602850",
  ["sunMaxFill"] = "rbxassetid://129021699626953",
  ["swatchpalette"] = "rbxassetid://125516289768416",
  ["switch2"] = "rbxassetid://99218016450501",
  ["target"] = "rbxassetid://84037566052726",
  ["terminal"] = "rbxassetid://88837948823350",
  ["toggle"] = "rbxassetid://99218016450501",
  ["trash"] = "rbxassetid://138210305619993",
  ["trashFill"] = "rbxassetid://106522682727620",
  ["user"] = "rbxassetid://110701632373035",
  ["wifi"] = "rbxassetid://127365451355653",
  ["wifiSlash"] = "rbxassetid://105782001663907",
  ["xmark"] = "rbxassetid://80129517509086",
  ["xmarkCircle"] = "rbxassetid://74086380322275",
  ["xmarkCircleFill"] = "rbxassetid://76720364341917",
}
local symbols = setmetatable(rawSymbols, {
    __index = function(self, key)
        if typeof(key) == "string" then
            if string.sub(key, 1, 13) == "rbxassetid://" or string.sub(key, 1, 4) == "http" then
                return key
            end
            local lowerKey = string.lower(key)
            if rawSymbols[lowerKey] then
                return rawSymbols[lowerKey]
            end
        end
        return rawSymbols["circle"] or "rbxassetid://132228700346004"
    end
})
return symbols
end function __DIST.g():typeof(__modImpl())local v=__DIST.cache.g if not v then v={c=__modImpl()}__DIST.cache.g=v end return v.c end end do local function __modImpl()--[[
	@original dawid-script/Fluent/src/modules/Acrylic
]]

--// Imports

local services = __DIST.e()
local creator = __DIST.d()

--// References
local workspace = services.Workspace
local lighting = services.Lighting

local create = creator.Create

--// Functions
local function map(value, inMin, inMax, outMin, outMax)
	return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

local function viewportPointToWorld(location, distance)
	local unitRay = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
	return unitRay.Origin + unitRay.Direction * distance
end

local function getOffset()
	local viewportSizeY = workspace.CurrentCamera.ViewportSize.Y
	return map(viewportSizeY, 0, 2560, 8, 56)
end

--// Initialize
local function createBlur(distance: number?)
	local blurEffects = Instance.new("Folder", workspace.CurrentCamera)
	local connections = {}

	local triPositions = {
		topLeft = Vector2.new(),
		topRight = Vector2.new(),
		bottomRight = Vector2.new(),
	}
	local model = create("Part")({
		Color = Color3.new(0, 0, 0),
		Material = Enum.Material.Glass,
		Size = Vector3.new(1, 1, 0),
		Anchored = true,
		CanTouch = false,
		CanCollide = false,
		CanQuery = false,
		Locked = true,
		CastShadow = false,
		Transparency = 0.98,

		create("SpecialMesh")({
			MeshType = Enum.MeshType.Brick,
			Offset = Vector3.new(0, 0, -0.000001),
		}),
	}) :: Part
	local effect = create("DepthOfFieldEffect")({
		FarIntensity = 0,
		NearIntensity = 1,
		InFocusRadius = 0.1,
		Parent = lighting,
	})
	local mesh = model:FindFirstChildWhichIsA("SpecialMesh")

	distance = distance or 0.001

	local function updatePositions(size, position)
		triPositions.topLeft = position
		triPositions.topRight = position + Vector2.new(size.X, 0)
		triPositions.bottomRight = position + size
	end

	local function render()
		local camera = workspace.CurrentCamera
		local cameraTransform = if camera then camera.CFrame else CFrame.identity

		local topLeft = triPositions.topLeft
		local topRight = triPositions.topRight
		local bottomRight = triPositions.bottomRight

		local topLeft3D = viewportPointToWorld(topLeft, distance)
		local topRight3D = viewportPointToWorld(topRight, distance)
		local bottomRight3D = viewportPointToWorld(bottomRight, distance)

		local width = (topRight3D - topLeft3D).Magnitude
		local height = (topRight3D - bottomRight3D).Magnitude

		model.CFrame = CFrame.fromMatrix(
			(topLeft3D + bottomRight3D) / 2,
			cameraTransform.XVector,
			cameraTransform.YVector,
			cameraTransform.ZVector
		)

		if mesh then
			mesh.Scale = Vector3.new(width, height, 0)
		end
	end

	local function onChange(rbx)
		local offset = getOffset()
		local size = rbx.AbsoluteSize - Vector2.new(offset, offset)
		local position = rbx.AbsolutePosition + Vector2.new(offset / 2, offset / 2)

		updatePositions(size, position)
		task.spawn(render)
	end

	local function renderOnChange()
		local camera = workspace.CurrentCamera

		if not camera then
			return
		end

		connections[#connections + 1] = camera:GetPropertyChangedSignal("CFrame"):Connect(render)
		connections[#connections + 1] = camera:GetPropertyChangedSignal("ViewportSize"):Connect(render)
		connections[#connections + 1] = camera:GetPropertyChangedSignal("FieldOfView"):Connect(render)

		task.spawn(render)
	end

	model.Parent = blurEffects

	model.Destroying:Connect(function()
		for _, item in connections do
			pcall(function()
				effect:Destroy()
				blurEffects:Destroy()
				item:Disconnect()
			end)
		end
	end)

	renderOnChange()

	return onChange, model
end

return function(frame: GuiObject, distance: number?)
	local blur = {}
	local onChange, model = createBlur(distance)

	blur.SetVisibility = function(Value)
		model.Transparency = Value and 0.98 or 1
	end

	frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		onChange(frame)
	end)

	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		onChange(frame)
	end)

	frame:GetPropertyChangedSignal("Visible"):Connect(function()
		blur.SetVisibility(frame.Visible)
	end)

	frame.Destroying:Connect(function()
		model:Destroy()
	end)

	blur.Model = model

	onChange(frame)

	return blur
end
end function __DIST.h():typeof(__modImpl())local v=__DIST.cache.h if not v then v={c=__modImpl()}__DIST.cache.h=v end return v.c end end do local function __modImpl()
return {
	UIBlur = __DIST.h(),
}
end function __DIST.i():typeof(__modImpl())local v=__DIST.cache.i if not v then v={c=__modImpl()}__DIST.cache.i=v end return v.c end end do local function __modImpl()
return function(self)
	--// Imports
	local creator = __DIST.d()
	local services = __DIST.e()

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local structures = {}

	--// UI
	structures.Body = create("Frame")({
		Name = "TextField",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(150, 23),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0, 5),
		}),

		create("UIStroke")({
			Name = "UIStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,

			__dynamicKeys = {
				Color = self.Theme.Controls.ViewBorder[1],
				Transparency = self.Theme.Controls.ViewBorder[2],
			},
		}),

		create("TextBox")({
			Name = "Field",
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(138, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			CursorPosition = -1,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxassetid://12187365364"),
			PlaceholderText = "",
			Text = "",
			TextSize = 15,

			__dynamicKeys = {
				PlaceholderColor3 = self.Theme.Text.Tertiary[1],
				TextTransparency = self.Theme.Text.Tertiary[2],
			},

			__contextKeys = {
				_general = function()
					local field = structures["Field"]

					if not field then
						return
					end

					if field.Text == "" then
						field.PlaceholderColor3 = self.Theme.Text.Tertiary[1].Value
						field.TextTransparency = self.Theme.Text.Tertiary[2].Value
					else
						field.TextColor3 = self.Theme.Text.Primary[1].Value
						field.TextTransparency = self.Theme.Text.Primary[2].Value
					end
				end,
				TextTransparency = function()
					if not structures["Field"] then
						return 1
					end

					return structures["Field"].Text == "" and self.Theme.Text.Tertiary[2].Value
						or self.Theme.Text.Primary[2].Value
				end,
			},

			create("UIPadding")({
				Name = "UIPadding",
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
		}),

		create("UIPadding")({
			Name = "UIPadding",
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
		}),

		create("UIListLayout")({
			Name = "UIListLayout",
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 4)
		}),
	}) :: Frame

	--// Initialize
	structures.Stroke = structures.Body:FindFirstChild("UIStroke") :: UIStroke
	structures.Padding = structures.Body:FindFirstChild("UIPadding") :: UIPadding
	structures.Corner = structures.Body:FindFirstChild("UICorner") :: UICorner
	structures.Layout = structures.Body:FindFirstChild("UIListLayout") :: UIListLayout
	structures.Field = structures.Body:FindFirstChild("Field") :: TextBox
	structures.FieldPadding = structures.Field:FindFirstChild("UIPadding") :: UIPadding

	local currentTween: Tween
	local enter = TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local leave = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	structures.Field.Focused:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = tweenService:Create(structures.Stroke, enter, {
			Color = self.Theme.Controls.SelectionStroke[1].Value,
			Transparency = self.Theme.Controls.SelectionStroke[2].Value,
			Thickness = 3,
		})
		currentTween:Play()
	end)

	structures.Field.FocusLost:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = tweenService:Create(structures.Stroke, leave, {
			Color = self.Theme.Controls.ViewBorder[1].Value,
			Transparency = self.Theme.Controls.ViewBorder[2].Value,
			Thickness = 1,
		})
		currentTween:Play()
	end)

	structures.Field:GetPropertyChangedSignal("Text"):Connect(function()
		if structures.Field.Text == "" then
			structures.Field.PlaceholderColor3 = self.Theme.Text.Tertiary[1].Value
			structures.Field.TextTransparency = self.Theme.Text.Tertiary[2].Value
		else
			structures.Field.TextColor3 = self.Theme.Text.Primary[1].Value
			structures.Field.TextTransparency = self.Theme.Text.Primary[2].Value
		end
	end)

	return structures
end
end function __DIST.j():typeof(__modImpl())local v=__DIST.cache.j if not v then v={c=__modImpl()}__DIST.cache.j=v end return v.c end end do local function __modImpl()
return function(self)
	--// Imports
	local creator = __DIST.d()
	local textField = __DIST.j()(self)

	--// References
	local create = creator.Create

	--// Variables
	local window = nil
	local rawHistory = {}
	local currentIndex = 0
	local structures = {}

	--// Functions
	local function getBounds(frame)
		local pos = frame.AbsolutePosition
		local size = frame.AbsoluteSize
		return {
			Left = pos.X,
			Right = pos.X + size.X,
			Top = pos.Y,
			Bottom = pos.Y + size.Y,
		}
	end

	--// UI
	structures.Body = create("Frame")({
		Name = "Toolbar",
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),

		__dynamicKeys = {
			BackgroundColor3 = self.Theme.Controls.Titlebar[1],
			BackgroundTransparency = self.Theme.Controls.Titlebar[2],
		},

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0, 10),
		}),

		create("Frame")({
			Name = "Shadow",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(234, 234, 234),
			BackgroundTransparency = 0.75,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.new(1, 0, 0, 2),
			ZIndex = 0,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.TitlebarShadow.Background[1],
				BackgroundTransparency = self.Theme.Controls.TitlebarShadow.Background[2],
			},

			create("UIGradient")({
				Name = "UIGradient",
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
				}),
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.35),
					NumberSequenceKeypoint.new(1, 0.35),
				}),

				__dynamicKeys = {
					Color = self.Theme.Controls.TitlebarShadow.Color,
					Transparency = self.Theme.Controls.TitlebarShadow.Transparency,
				},
			}),
		}),

		create("Frame")({
			Name = "Content",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),

			create("Frame")({
				Name = "Leading",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, 1),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				create("Frame")({
					Name = "TitleSubtitle",
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = 2,

					create("UIListLayout")({
						Name = "UIListLayout",
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					create("TextLabel")({
						Name = "Subtitle",
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
						LayoutOrder = 1,
						RichText = true,
						Size = UDim2.fromOffset(0, 14),
						Text = "Subtitle",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 12,
						Visible = false,

						__dynamicKeys = {
							TextColor3 = self.Theme.Text.Secondary[1],
							TextTransparency = self.Theme.Text.Secondary[2],
						},
					}),

					create("TextLabel")({
						Name = "Title",
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						FontFace = Font.new(
							"rbxassetid://12187365364",
							Enum.FontWeight.SemiBold,
							Enum.FontStyle.Normal
						),
						LineHeight = 0,
						RichText = true,
						Size = UDim2.fromOffset(0, 20),
						Text = "Title",
						TextSize = 16,

						__dynamicKeys = {
							TextColor3 = self.Theme.Text.Primary[1],
							TextTransparency = self.Theme.Text.Primary[2],
						},
					}),
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),

				create("Frame")({
					Name = "NavigationButtons",
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = 1,

					create("UIListLayout")({
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 1),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					create("TextButton")({
						Name = "Back",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						Size = UDim2.fromOffset(27, 20),
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14,

						create("ImageLabel")({
							Name = "Image",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Image = "rbxassetid://137248392050045",
							ImageColor3 = Color3.fromRGB(0, 0, 0),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(9, 15),

							__dynamicKeys = {
								ImageColor3 = self.Theme.Text.Tertiary[1],
								ImageTransparency = self.Theme.Text.Tertiary[2],
							},
							__contextKeys = {
								ImageColor3 = function()
									local backable = currentIndex > 1
									local theme = window.Theme.Text

									return (backable and theme.Secondary[1].Value) or theme.Tertiary[1].Value
								end,
								ImageTransparency = function()
									local backable = currentIndex > 1
									local theme = window.Theme.Text

									return (backable and theme.Secondary[2].Value) or theme.Tertiary[2].Value
								end,
							},
						}),
					}),

					create("TextButton")({
						Name = "Forward",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						LayoutOrder = 1,
						Size = UDim2.fromOffset(27, 20),
						Text = "",
						TextColor3 = Color3.fromRGB(0, 0, 0),
						TextSize = 14,

						create("ImageLabel")({
							Name = "Image",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Image = "rbxassetid://95285878898359",
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromOffset(9, 15),

							__dynamicKeys = {
								ImageColor3 = self.Theme.Text.Tertiary[1],
								ImageTransparency = self.Theme.Text.Tertiary[2],
							},
							__contextKeys = {
								ImageColor3 = function()
									local forwardable = currentIndex < #rawHistory
									local theme = window.Theme.Text

									return (forwardable and theme.Secondary[1].Value) or theme.Tertiary[1].Value
								end,
								ImageTransparency = function()
									local forwardable = currentIndex < #rawHistory
									local theme = window.Theme.Text

									return (forwardable and theme.Secondary[2].Value) or theme.Tertiary[2].Value
								end,
							},
						}),
					}),
				}),

				create("Frame")({
					Name = "SidebarButton",
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(38, 34),

					create("ImageButton")({
						Name = "Image",
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoButtonColor = false,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = "rbxassetid://74380920233260",
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(20, 16),

						__dynamicKeys = {
							ImageColor3 = self.Theme.Text.Secondary[1],
							ImageTransparency = self.Theme.Text.Secondary[2],
						},
					}),
				}),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "Trailing",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, 1),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),

				create("UIListLayout")({
					Name = "UIListLayout",
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
			}),
		}),

		create("Frame")({
			Name = "CornerClipRight",
			AnchorPoint = Vector2.new(1, 1),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.new(0, 10, 0.5, 0),
			ZIndex = -1,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Titlebar[1],
			},
		}),

		create("Frame")({
			Name = "CornerClipLeft",
			AnchorPoint = Vector2.new(0, 1),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(0, 10, 1, 0),
			ZIndex = -1,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Titlebar[1],
			},
		}),
	}) :: TextButton

	--// Initialize
	structures.CornerClipLeft = structures.Body:FindFirstChild("CornerClipLeft") :: Frame
	structures.CornerClipRight = structures.Body:FindFirstChild("CornerClipRight") :: Frame
	structures.Content = structures.Body:FindFirstChild("Content") :: Frame
	structures.Leading = structures.Content:FindFirstChild("Leading") :: Frame
	structures.Trailing = structures.Content:FindFirstChild("Trailing") :: Frame
	structures.NavigationButtons = structures.Leading:FindFirstChild("NavigationButtons") :: Frame
	structures.Back = structures.NavigationButtons:FindFirstChild("Back") :: TextButton
	structures.Forward = structures.NavigationButtons:FindFirstChild("Forward") :: TextButton
	structures.SidebarButton = structures.Leading:FindFirstChild("SidebarButton"):FindFirstChild("Image") :: ImageButton
	structures.TitleStack = structures.Leading:FindFirstChild("TitleSubtitle") :: Frame
	structures.Title = structures.TitleStack:FindFirstChild("Title") :: TextLabel
	structures.Subtitle = structures.TitleStack:FindFirstChild("Subtitle") :: TextLabel

	structures.SearchField = textField
	structures.SearchField.Body.Size = UDim2.fromOffset(126, 28)
	structures.SearchField.Field.Size = UDim2.fromOffset(90, 0)
	structures.SearchField.Layout.Padding = UDim.new(0, 8)
	structures.SearchField.Field.LayoutOrder = 1
	structures.SearchField.Field.PlaceholderText = "Search"
	structures.SearchField.Padding.PaddingLeft = UDim.new(0, 7)
	structures.SearchField.Padding.PaddingRight = UDim.new(0, 7)
	structures.SearchField.Corner = UDim.new(0, 6)

	create("ImageLabel")({
		Name = "ImageLabel",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://120817720539967",
		Size = UDim2.fromOffset(13, 14),
		Parent = structures.SearchField.Body.__instance,

		__dynamicKeys = {
			ImageColor3 = self.Theme.Text.PrimaryAccent[1],
			ImageTransparency = self.Theme.Text.PrimaryAccent[2],
		},
	})

	structures.SearchField.Body.Parent = structures.Trailing

	local function updateNavStates()
		if not window then
			return
		end

		local backImage = structures.Back:FindFirstChild("Image")
		local forwardImage = structures.Forward:FindFirstChild("Image")

		local theme = window.Theme.Text

		if backImage then
			local backable = currentIndex > 1

			backImage.ImageColor3 = (backable and theme.Secondary[1].Value) or theme.Tertiary[1].Value
			backImage.ImageTransparency = (backable and theme.Secondary[2].Value) or theme.Tertiary[2].Value
			structures.Back.Interactable = backable
		end

		if forwardImage then
			local forwardable = currentIndex < #rawHistory

			forwardImage.ImageColor3 = (forwardable and theme.Secondary[1].Value) or theme.Tertiary[1].Value
			forwardImage.ImageTransparency = (forwardable and theme.Secondary[2].Value) or theme.Tertiary[2].Value
			structures.Forward.Interactable = forwardable
		end
	end

	local navigationHistory = setmetatable({}, {
		__newindex = function(_, key, value)
			rawset(rawHistory, key, value)

			updateNavStates()
		end,
		__index = function(_, key)
			return rawHistory[key]
		end,
		__len = function()
			return #rawHistory
		end,
	})

	local function setPage(page)
		if window and window.Tabs then
			for _, tab in pairs(window.Tabs) do
				if tab.__container == page then
					tab.Selected = true
				else
					tab.Selected = false
				end
			end
		end
	end

	local function attachHandlers()
		structures.Back.MouseButton1Click:Connect(function()
			if currentIndex > 1 then
				currentIndex -= 1
				setPage(rawHistory[currentIndex])
				updateNavStates()
			end
		end)

		structures.Forward.MouseButton1Click:Connect(function()
			if currentIndex < #rawHistory then
				currentIndex += 1
				setPage(rawHistory[currentIndex])
				updateNavStates()
			end
		end)
	end

	local function checkAccessoryBounds()
		for _, trailing in pairs(structures.Trailing:GetChildren()) do
			if not trailing:IsA("GuiObject") then
				continue
			end

			local trailingBounds = getBounds(trailing)
			local isVisible = true

			for _, leading in pairs(structures.Leading:GetChildren()) do
				if not leading:IsA("GuiObject") then
					continue
				end

				local leadingBounds = getBounds(leading)

				local overlapping = (
					leadingBounds.Right >= trailingBounds.Left and leadingBounds.Left <= trailingBounds.Right
				)
					and (leadingBounds.Bottom >= trailingBounds.Top and leadingBounds.Top <= trailingBounds.Bottom)

				if overlapping then
					isVisible = false
					break
				end
			end

			trailing.Visible = isVisible
		end
	end

	checkAccessoryBounds()
	structures.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkAccessoryBounds)

	return structures,
		function(newWindow)
			window = newWindow
			attachHandlers()

			return function(page)
				for i = #rawHistory, currentIndex + 1, -1 do
					rawHistory[i] = nil
				end

				currentIndex += 1
				navigationHistory[currentIndex] = page
			end
		end
end
end function __DIST.k():typeof(__modImpl())local v=__DIST.cache.k if not v then v={c=__modImpl()}__DIST.cache.k=v end return v.c end end do local function __modImpl()
return function(object, minScale)
	--// Imports
	local creator = __DIST.d()

	--// References
	local create = creator.Create

	--// Variables
	local structures = {}

	--// UI
	structures.Handles = create("Folder")({
		Name = "Handles",
		Parent = object,

		create("Frame")({
			Name = "E",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 0.5),
			Size = UDim2.new(0, 6, 1, 0),
			ZIndex = 8,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://122180269146343",
				CursorIcon = "rbxassetid://122180269146343",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "N",
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(1, 0, 0, 6),
			ZIndex = 8,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://109321922977357",
				CursorIcon = "rbxassetid://109321922977357",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "NE",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 9,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://78578587100983",
				CursorIcon = "rbxassetid://78578587100983",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "NW",
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 9,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://127507239458439",
				CursorIcon = "rbxassetid://127507239458439",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "S",
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.new(1, 0, 0, 6),
			ZIndex = 8,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://109321922977357",
				CursorIcon = "rbxassetid://109321922977357",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "SE",
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 9,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://127507239458439",
				CursorIcon = "rbxassetid://127507239458439",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "SW",
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromOffset(10, 10),
			ZIndex = 9,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://78578587100983",
				CursorIcon = "rbxassetid://78578587100983",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),

		create("Frame")({
			Name = "W",
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 0, 81),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.new(0, 6, 1, 0),
			ZIndex = 8,

			create("UIDragDetector")({
				Name = "UIDragDetector",
				ActivatedCursorIcon = "rbxassetid://122180269146343",
				CursorIcon = "rbxassetid://122180269146343",
				ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
				SelectionModeDragSpeed = UDim2.new(),
				SelectionModeRotateSpeed = 0,
			}),
		}),
	}) :: Folder

	--// Initialize
	minScale = minScale or Vector2.new(0, 0)

	structures.N = structures.Handles:FindFirstChild("N"):FindFirstChild("UIDragDetector")
	structures.S = structures.Handles:FindFirstChild("S"):FindFirstChild("UIDragDetector")
	structures.W = structures.Handles:FindFirstChild("W"):FindFirstChild("UIDragDetector")
	structures.E = structures.Handles:FindFirstChild("E"):FindFirstChild("UIDragDetector")
	structures.NE = structures.Handles:FindFirstChild("NE"):FindFirstChild("UIDragDetector")
	structures.SE = structures.Handles:FindFirstChild("SE"):FindFirstChild("UIDragDetector")
	structures.NW = structures.Handles:FindFirstChild("NW"):FindFirstChild("UIDragDetector")
	structures.SW = structures.Handles:FindFirstChild("SW"):FindFirstChild("UIDragDetector")

	local dragStartPosition
	local dragStartSize
	local resizeHandler = {}

	resizeHandler.__index = resizeHandler

	local function resizeObject(delta: Vector2, handleName: string)
		local sizeFactor = Vector2.zero

		if string.find(handleName, "N") then
			sizeFactor += Vector2.new(0, -1)
		end
		if string.find(handleName, "S") then
			sizeFactor += Vector2.new(0, 1)
		end
		if string.find(handleName, "W") then
			sizeFactor += Vector2.new(-1, 0)
		end
		if string.find(handleName, "E") then
			sizeFactor += Vector2.new(1, 0)
		end

		local sizeDelta = Vector2.new(
			(sizeFactor.X ~= 0) and (delta.X * sizeFactor.X) or 0,
			(sizeFactor.Y ~= 0) and (delta.Y * sizeFactor.Y) or 0
		)

		local newSize = dragStartSize + sizeDelta
		newSize = Vector2.new(math.max(minScale.X, newSize.X), math.max(minScale.Y, newSize.Y))

		local sizeChange = newSize - dragStartSize
		local centerCompensation = Vector2.new(
			sizeFactor.X < 0 and -sizeChange.X * 0.5 or sizeChange.X * 0.5,
			sizeFactor.Y < 0 and -sizeChange.Y * 0.5 or sizeChange.Y * 0.5
		)
		local newPositionOffset = dragStartPosition + centerCompensation

		object.Size = UDim2.fromOffset(newSize.X, newSize.Y)
		object.Position = UDim2.new(0.5, newPositionOffset.X, 0.5, newPositionOffset.Y)
	end

	local function addHandle(handle, handleName: string)
		handle.DragStart:Connect(function()
			dragStartSize = object.AbsoluteSize
			dragStartPosition = Vector2.new(object.Position.X.Offset, object.Position.Y.Offset)
		end)

		handle.DragContinue:Connect(function()
			resizeObject(Vector2.new(handle.DragUDim2.X.Offset, handle.DragUDim2.Y.Offset), handleName)
		end)
	end

	function resizeHandler.CreateClient()
		addHandle(structures.NW, "NW")
		addHandle(structures.NE, "NE")
		addHandle(structures.SW, "SW")
		addHandle(structures.SE, "SE")

		addHandle(structures.E, "E")
		addHandle(structures.W, "W")

		addHandle(structures.S, "S")
		addHandle(structures.N, "N")
	end

	function resizeHandler.SetEnabled(state: boolean)
		for i, v in pairs(structures) do
			if v:IsA("UIDragDetector") then
				v.Enabled = state
			end
		end
	end

	return resizeHandler
end
end function __DIST.l():typeof(__modImpl())local v=__DIST.cache.l if not v then v={c=__modImpl()}__DIST.cache.l=v end return v.c end end do local function __modImpl()
return function(self, properties)
	--// Imports
	local creator = __DIST.d()

	--// References
	local create = creator.Create

	--// Variables
	local structures = {}
    local contextKeys = {
        Exit = {
			ImageColor3 = function()
				return properties.CanExit and self.Theme.Controls.Exit[1].Value
					or self.Theme.Controls.WindowControlDisabled[1].Value
			end,
			ImageTransparency = function()
				return properties.CanExit and self.Theme.Controls.Exit[2].Value
					or self.Theme.Controls.WindowControlDisabled[2].Value
			end,
		},
        
        Minimize = {
			ImageColor3 = function()
				return properties.CanMinimize and self.Theme.Controls.Minimize[1].Value
					or self.Theme.Controls.WindowControlDisabled[1].Value
			end,
			ImageTransparency = function()
				return properties.CanMinimize and self.Theme.Controls.Minimize[2].Value
					or self.Theme.Controls.WindowControlDisabled[2].Value
			end,
		},

        Zoom = {
			ImageColor3 = function()
				return properties.CanZoom and self.Theme.Controls.Zoom[1].Value
					or self.Theme.Controls.WindowControlDisabled[1].Value
			end,
			ImageTransparency = function()
				return properties.CanZoom and self.Theme.Controls.Zoom[2].Value
					or self.Theme.Controls.WindowControlDisabled[2].Value
			end,
		}
    }

	structures.Body = create("Frame")({
		Name = "WindowControls",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(92, 38),

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("UIPadding")({
			Name = "UIPadding",
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
		}),
	})

	structures.Exit = create("ImageButton")({
		Name = "Exit",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://132228700346004",
		Size = UDim2.fromOffset(12, 12),
        Parent = structures.Body.__instance,

		__dynamicKeys = {
			ImageColor3 = self.Theme.Controls.Exit[1],
			ImageTransparency = self.Theme.Controls.Exit[2],
		},
		__contextKeys = contextKeys.Exit,

		create("ImageLabel")({
			Name = "Stroke",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://94763505860483",
			Size = UDim2.fromScale(1, 1),

			__dynamicKeys = {
				ImageColor3 = self.Theme.Controls.WindowControlStroke[1],
				ImageTransparency = self.Theme.Controls.WindowControlStroke[2],
			},
		}),

		create("ImageLabel")({
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://94781753558308",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Visible = false,

			__dynamicKeys = {
				ImageColor3 = self.Theme.Controls.WindowControlIcon[1],
				ImageTransparency = self.Theme.Controls.WindowControlIcon[2],
			},
		}),
	})

	structures.Minimize = create("ImageButton")({
		Name = "Minimize",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://132228700346004",
		LayoutOrder = 1,
		Size = UDim2.fromOffset(12, 12),
        Parent = structures.Body.__instance,

		__dynamicKeys = {
			ImageColor3 = self.Theme.Controls.Minimize[1],
			ImageTransparency = self.Theme.Controls.Minimize[2],
		},
		__contextKeys = contextKeys.Minimize,

		create("ImageLabel")({
			Name = "Stroke",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://94763505860483",
			Size = UDim2.fromScale(1, 1),

			__dynamicKeys = {
				ImageColor3 = self.Theme.Controls.WindowControlStroke[1],
				ImageTransparency = self.Theme.Controls.WindowControlStroke[2],
			},
		}),

		create("ImageLabel")({
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://118368309445367",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Visible = false,

			__dynamicKeys = {
				ImageColor3 = self.Theme.Controls.WindowControlIcon[1],
				ImageTransparency = self.Theme.Controls.WindowControlIcon[2],
			},
		}),
	})

	structures.Zoom = create("ImageButton")({
		Name = "Zoom",
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://132228700346004",
		LayoutOrder = 2,
		Size = UDim2.fromOffset(12, 12),
        Parent = structures.Body.__instance,

		__dynamicKeys = {
			ImageColor3 = self.Theme.Controls.Zoom[1],
			ImageTransparency = self.Theme.Controls.Zoom[2],
		},
		__contextKeys = contextKeys.Zoom,

		create("ImageLabel")({
			Name = "Stroke",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://94763505860483",
			Size = UDim2.fromScale(1, 1),

			__dynamicKeys = {
				ImageColor3 = self.Theme.Controls.WindowControlStroke[1],
				ImageTransparency = self.Theme.Controls.WindowControlStroke[2],
			},
		}),

		create("ImageLabel")({
			Name = "Icon",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://114376524082699",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Visible = false,

			__dynamicKeys = {
				ImageColor3 = self.Theme.Controls.WindowControlIcon[1],
				ImageTransparency = self.Theme.Controls.WindowControlIcon[2],
			},
		}),
	})

    return structures, contextKeys
end
end function __DIST.m():typeof(__modImpl())local v=__DIST.cache.m if not v then v={c=__modImpl()}__DIST.cache.m=v end return v.c end end do local function __modImpl()-- We uh
-- We dont talk about this..


local types = __DIST.b()

return function(self, properties: WindowProperties__DARKLUA_TYPE_w): Window__DARKLUA_TYPE_x	--// Imports
	
local effects = __DIST.i()
	local services = __DIST.e()
	local creator = __DIST.d()
	local binder = __DIST.c()

	local titleBar, addToHistory = __DIST.k()(self)
	local resizeHandler = __DIST.l()

	--// References
	local create = creator.Create

	local userInputService = services.UserInputService
	local tweenService = services.TweenService

	--// Variables
	local parent = self.__container or self.__instance or self
	local window = create("Frame")({
		Name = "Window",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Parent = parent,
	}).__instance
	local originalSize
	local originalPosition
	local originalPosition2
	local minimizing
	local dragging
	local resizeClient
	local structures = {}

	--// UI
	properties = properties or {}

	properties.Size = properties.Size or UDim2.fromOffset(850, 530)
	properties.Maximized = properties.Maximized == true
	properties.Minimized = properties.Minimized == true
	properties.Searching = properties.Searching ~= false
	properties.Resizable = properties.Resizable ~= false
	properties.Draggable = properties.Draggable ~= false
	properties.CanExit = properties.CanExit ~= false
	properties.CanMinimize = properties.CanMinimize ~= false
	properties.CanZoom = properties.CanZoom ~= false
	properties.Resizable = properties.Resizable ~= false
	properties.Dropshadow = properties.Dropshadow ~= false
	properties.UIBlur = properties.UIBlur ~= false
	properties.Title = properties.Title or "Title"

	local windowControls, windowControlsCKeys = __DIST.m()(self, properties)

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "Body",
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Parent = window,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Sidebar[1],
				BackgroundTransparency = self.Theme.Controls.Sidebar[2],
			},

			__contextKeys = {
				BackgroundTransparency = function()
					return properties.UIBlur and self.Theme.Controls.Sidebar[2].Value or 0
				end,
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 10),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "Sidebar",
				BackgroundColor3 = Color3.fromRGB(234, 234, 234),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 200, 1, 0),
				ClipsDescendants = true,

				create("UIPadding")({
					Name = "UIPadding",
				}),

				create("Frame")({
					Name = "Margins",
					BackgroundColor3 = Color3.fromRGB(234, 234, 234),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(0, 200, 1, 0),
					create("Folder")({
						Name = "LayoutIgnore",

						create("Frame")({
							Name = "Shadow",
							AnchorPoint = Vector2.new(1, 0),
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Position = UDim2.new(1, 2, 0, 0),
							Size = UDim2.new(0, 5, 1, 0),
							ZIndex = 0,
							__dynamicKeys = {
								BackgroundColor3 = self.Theme.Controls.Separator.Shadow[1],
								BackgroundTransparency = self.Theme.Controls.Separator.Shadow[2],
							},

							create("UIGradient")({
								Name = "UIGradient",
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 1),
									NumberSequenceKeypoint.new(1, 0),
								}),
							}),
						}),
					}),

					create("UIPadding")({
						Name = "UIPadding",
						PaddingRight = UDim.new(0, 2),
					}),

					create("Frame")({
						Name = "Toolbar",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0, 52),
					}),

					create("ScrollingFrame")({
						Name = "SidebarList",
						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						CanvasSize = UDim2.new(),
						Position = UDim2.fromOffset(0, 52),
						ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
						ScrollBarImageTransparency = 0.7,
						ScrollBarThickness = 6,
						Size = UDim2.new(1, 0, 1, -52),

						__dynamicKeys = {
							ScrollBarImageColor3 = self.Theme.Controls.ScrollBar[1],
							ScrollBarImageTransparency = self.Theme.Controls.ScrollBar[2],
						},

						create("UIListLayout")({
							Name = "UIListLayout",
							Padding = UDim.new(0, 9),
							SortOrder = Enum.SortOrder.LayoutOrder,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
						}),

						create("UIPadding")({
							Name = "UIPadding",
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
							PaddingBottom = UDim.new(0, 10),
						}),
					}),
				}),
			}),

			create("Frame")({
				Name = "Separator",
				AnchorPoint = Vector2.new(1, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(0, 1, 1, 0),
				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.Separator.Background[1],
					BackgroundTransparency = self.Theme.Controls.Separator.Background[2],
				},
			}),

			create("Frame")({
				Name = "ContentBody",
				AnchorPoint = Vector2.new(1, 0),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = 2,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.new(1, -201, 1, 0),

				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.Background[1],
					BackgroundTransparency = self.Theme.Controls.Background[2],
				},

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 10),
				}),

				create("Frame")({
					Name = "Content",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(255, 199, 199),
					BorderMode = Enum.BorderMode.Inset,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Position = UDim2.fromOffset(0, 52),
					Size = UDim2.new(1, 0, 1, -52),

					create("UIPadding")({
						Name = "Margins",
						PaddingBottom = UDim.new(0, 3),
						PaddingLeft = UDim.new(0, 3),
						PaddingRight = UDim.new(0, 3),
						PaddingTop = UDim.new(0, 3),
					}),
				}),

				create("Frame")({
					Name = "CornerClip",
					AnchorPoint = Vector2.new(0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.fromOffset(10, 10),
					ZIndex = -1,

					__dynamicKeys = {
						BackgroundColor3 = self.Theme.Controls.Background[1],
					},
				}),
			}),

			create("Folder")({
				Name = "LayoutIgnore",

				create("TextButton")({
					Name = "TopArea",
					AutoButtonColor = false,
					Active = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 52),
					ZIndex = 0,
					Text = "",
					Modal = false,
				}),

				create("ImageLabel")({
					Name = "Dropshadow",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://138260268144845",
					ImageTransparency = 0.65,
					Interactable = false,
					Position = UDim2.new(0.5, 0, 0.5, 3),
					ScaleType = Enum.ScaleType.Slice,
					Size = UDim2.new(1, 24, 1, 24),
					SliceCenter = Rect.new(28, 26, 96, 94),
					ZIndex = 0,
				}),
			}),
		})
	) :: Frame

	--// Initialize
	structures.Scale = create("UIScale")({
		Parent = window,
	})
	structures.Cornering = structures.Body:FindFirstChild("UICorner") :: UICorner
	structures.LayoutIgnore = structures.Body:FindFirstChild("LayoutIgnore") :: Folder
	structures.Dropshadow = structures.LayoutIgnore:FindFirstChild("Dropshadow") :: ImageLabel
	structures.Separator = structures.Body:FindFirstChild("Separator") :: Frame
	structures.SidebarMargins = structures.Body:FindFirstChild("Sidebar")
	structures.Sidebar = structures.SidebarMargins:FindFirstChild("Margins") :: Frame
	structures.SidebarList = structures.Sidebar:FindFirstChild("SidebarList") :: Frame
	structures.Toolbar = structures.Sidebar:FindFirstChild("Toolbar") :: Frame
	structures.ContentBody = structures.Body:FindFirstChild("ContentBody") :: Frame
	structures.Content = structures.ContentBody:FindFirstChild("Content") :: Frame
	structures.CornerClip = structures.ContentBody:FindFirstChild("CornerClip") :: Frame

	structures.Titlebar = titleBar
	structures.Titlebar.Body.Parent = structures.ContentBody

	structures.WindowControls = windowControls
	structures.WindowControls.Body.Parent = structures.Toolbar

	originalSize = structures.Body.Size
	originalPosition = structures.Body.Position

	local bindings = {
		Title = function(value: string)
			structures.Titlebar.Title.Visible = value and true or false

			if value then
				structures.Titlebar.Title.Text = value
			end
		end,
		Subtitle = function(value: string)
			structures.Titlebar.Subtitle.Visible = value and true or false

			if value then
				structures.Titlebar.Subtitle.Text = value
			end
		end,
		Searching = function(value: boolean)
			structures.Titlebar.SearchField.Body.Parent = value and structures.Titlebar.Trailing or nil
			structures.Titlebar.SearchField.Body.Visible = value
		end,
		Draggable = function(value: boolean)
			dragging = not value and false
		end,
		Resizable = function(value: boolean)
			if resizeClient and not properties.Maximized then
				resizeClient.SetEnabled(value)
			end
		end,
		Minimized = function(value: boolean?, tween: boolean?)
			local useTween = tween ~= false

			if value and not minimizing then
				originalPosition2 = structures.Body.Position

				if structures["BlurModel"] then
					structures["BlurModel"].SetVisibility(false)
				end
			end

			local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local bodyTarget = {
				Position = value and UDim2.new(0.5, 0, 0.5, structures.Body.AbsoluteSize.Y * 2) or originalPosition2,
			}
			local scaleTarget = { Scale = value and 0 or 1 }

			if useTween then
				minimizing = true
				tweenService:Create(structures.Body.__instance, tweenInfo, bodyTarget):Play()

				local scaleTween: Tween = tweenService:Create(structures.Scale.__instance, tweenInfo, scaleTarget)

				scaleTween:Play()
				scaleTween.Completed:Once(function()
					minimizing = false

					if structures["BlurModel"] and not properties.Minimized then
						structures["BlurModel"].SetVisibility(true)
					end
				end)
			else
				structures.Body.Position = bodyTarget.Position
				structures.Scale.Scale = scaleTarget.Scale

				if value and structures["BlurModel"] then
					structures["BlurModel"].SetVisibility(false)
				end
			end
		end,
		Maximized = function(value: boolean?, tween: boolean?)
			tween = tween ~= false

			if value then
				originalSize = structures.Body.Size
				originalPosition = structures.Body.Position
				resizeClient.SetEnabled(false)
			else
				dragging = false
			end

			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local bodyTarget = {
				Size = value and UDim2.fromScale(1, 1) or originalSize,
				Position = value and UDim2.fromScale(0.5, 0.5) or originalPosition,
			}
			local cornerTarget = { CornerRadius = value and UDim.new(0, 0) or UDim.new(0, 10) }

			if tween then
				tweenService:Create(structures.Body.__instance, tweenInfo, bodyTarget):Play()
				tweenService:Create(structures.Cornering, tweenInfo, cornerTarget):Play()
			else
				structures.Body.Size = bodyTarget.Size
				structures.Body.Position = bodyTarget.Position
				structures.Cornering.CornerRadius = cornerTarget.CornerRadius
			end

			if not value then
				resizeClient.SetEnabled(properties.Resizable)
			end
		end,
		Dropshadow = function(value: boolean)
			structures.Dropshadow.Visible = value
		end,
		UIBlur = function(value: boolean)
			if structures["BlurModel"] then
				structures["BlurModel"].Model:Destroy()
				structures["BlurModel"] = nil
			end

			structures.Body.BackgroundTransparency = value and self.Theme.Controls.Sidebar[2].Value or 0

			if value and not properties.Minimized then
				structures.BlurModel = effects.UIBlur(structures.Body)
			end
		end,
		CanExit = function(value: boolean)
			properties.CanExit = value

			structures.WindowControls.Exit.ImageColor3 = windowControlsCKeys.Exit.ImageColor3()
			structures.WindowControls.Exit.ImageTransparency = windowControlsCKeys.Exit.ImageTransparency()

			structures.WindowControls.Exit.Active = value
		end,
		CanMinimize = function(value: boolean)
			properties.CanMinimize = value

			structures.WindowControls.Minimize.ImageColor3 = windowControlsCKeys.Minimize.ImageColor3()
			structures.WindowControls.Minimize.ImageTransparency = windowControlsCKeys.Minimize.ImageTransparency()

			structures.WindowControls.Minimize.Active = value
		end,
		CanZoom = function(value: boolean)
			properties.CanZoom = value

			structures.WindowControls.Zoom.ImageColor3 = windowControlsCKeys.Zoom.ImageColor3()
			structures.WindowControls.Zoom.ImageTransparency = windowControlsCKeys.Zoom.ImageTransparency()

			structures.WindowControls.Zoom.Active = value
		end,
	}
	local object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Window"
	object.Theme = self.Theme
	object.Structures = structures
	object.Tabs = {}
	object.addToHistory = addToHistory(object)
	object.__container = structures.Content

	do -- Resize handler
		resizeClient = resizeHandler(structures.Body.__instance, Vector2.new(350, 250))

		resizeClient.CreateClient()
	end

	do -- Sidebar button
		local toggled = true

		local function toggle()
			toggled = not toggled

			local marginsTargetSize = toggled and UDim.new(0, 0) or UDim.new(0, -200)
			local sidebarTargetSize = toggled and UDim2.new(0, 200, 1, 0) or UDim2.new(0, 0, 1, 0)
			local contentTargetSize = toggled and UDim2.new(1, -201, 1, 0) or UDim2.new(1, 0, 1, 0)
			local cornerLeftSize = toggled and UDim2.new(0, 10, 1, 0) or UDim2.new(0, 10, 0.5, 0)

			local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

			structures.Separator.Visible = toggled and true or false
			structures.CornerClip.Visible = toggled and true

			tweenService
				:Create(structures.ContentBody, tweenInfo, {
					Size = contentTargetSize,
				})
				:Play()

			tweenService
				:Create(structures.SidebarMargins:FindFirstChild("UIPadding"), tweenInfo, {
					PaddingLeft = marginsTargetSize,
				})
				:Play()

			local sidebarTween = tweenService:Create(structures.SidebarMargins, tweenInfo, {
				Size = sidebarTargetSize,
			})

			tweenService
				:Create(structures.Titlebar.CornerClipLeft, tweenInfo, {
					Size = cornerLeftSize,
				})
				:Play()

			sidebarTween:Play()

			if not toggled then
				sidebarTween.Completed:Connect(function()
					structures.CornerClip.Visible = false
				end)
			end
		end

		structures.Titlebar.SidebarButton.MouseButton1Click:Connect(toggle)
	end

	do -- Page searching
		local field = structures.Titlebar.SearchField.Field
		local pageCaches = {}

		local function toCache(page, descendants)
			local cache = {}

			for _, child in ipairs(descendants) do
				if child:IsA("GuiObject") then
					cache[child] = child.Visible
				end
			end

			pageCaches[page] = cache
		end

		local function fromCache(page, descendants)
			local cache = pageCaches[page]

			if not cache then
				return
			end

			for _, child in ipairs(descendants) do
				if child:IsA("GuiObject") then
					child.Visible = cache[child] ~= false
				end
			end
		end

		field:GetPropertyChangedSignal("Text"):Connect(function()
			local matches = {}
			local items = {}
			local page = structures.Content:FindFirstChildOfClass("ScrollingFrame")

			if not page then
				return
			end

			local descendants = page:GetDescendants()

			if not pageCaches[page] then
				toCache(page, descendants)
			end

			local query = field.Text:lower()

			if query == "" then
				fromCache(page, descendants)
				return
			end

			for _, child in ipairs(descendants) do
				if child:IsA("GuiObject") then
					local searchIndex = child:GetAttribute("SearchIndex")

					if typeof(searchIndex) == "string" and searchIndex:lower():find(query) then
						table.insert(matches, child)
					end
				end
			end

			for _, match in ipairs(matches) do
				items[match] = true

				local parent = match.Parent

				while parent and parent ~= page do
					if parent:IsA("GuiObject") then
						items[parent] = true
					end

					parent = parent.Parent
				end
			end

			for _, child in ipairs(descendants) do
				if child:IsA("GuiObject") then
					child.Visible = false
				end
			end

			for _, match in ipairs(matches) do
				match.Visible = true

				local parent = match.Parent

				while parent and parent ~= page do
					if parent:IsA("GuiObject") then
						parent.Visible = true
					end

					parent = parent.Parent
				end

				local cache = pageCaches[page]

				for _, descendant in ipairs(match:GetDescendants()) do
					if descendant:IsA("GuiObject") then
						local wasVisible = cache and cache[descendant]
						if wasVisible then
							descendant.Visible = true
						end
					end
				end
			end
		end)
	end

	do -- Window controls
		local wcBody = structures.WindowControls.Body
		local exit = wcBody:FindFirstChild("Exit") :: ImageButton
		local minimize = wcBody:FindFirstChild("Minimize") :: ImageButton
		local zoom = wcBody:FindFirstChild("Zoom") :: ImageButton

		local function rollOver()
			exit:FindFirstChild("Icon").Visible = properties.CanExit
					and wcBody.GuiState ~= Enum.GuiState.Hover
				or false
			minimize:FindFirstChild("Icon").Visible = properties.CanMinimize
					and wcBody.GuiState ~= Enum.GuiState.Hover
				or false
			zoom:FindFirstChild("Icon").Visible = properties.CanZoom
					and wcBody.GuiState ~= Enum.GuiState.Hover
				or false
		end

		zoom.MouseButton1Click:Connect(function()
			if not properties.CanZoom then
				return
			end
			properties.Maximized = not properties.Maximized
			bindings.Maximized(properties.Maximized, true)
		end)

		minimize.MouseButton1Click:Connect(function()
			if not properties.CanMinimize then
				return
			end
			properties.Minimized = not properties.Minimized
			bindings.Minimized(properties.Minimized, true)
		end)

		if self.Structures and self.Structures["WindowPill"] then
			local pill: ImageButton = self.Structures["WindowPill"]

			pill.MouseButton1Click:Connect(function()
				properties.Minimized = not properties.Minimized
				bindings.Minimized(properties.Minimized, true)
			end)
		end

		exit.MouseButton1Click:Connect(function()
			if not properties.CanExit then
				return
			end

			bindings.Minimized(true)
			task.delay(0.25, structures.Body.Destroy)
		end)

		wcBody.MouseEnter:Connect(rollOver)
		wcBody.MouseLeave:Connect(rollOver)
	end

	do -- Window dragging
		local inputPos = nil
		local startPos = nil
		local connection = nil
		local boundingUi = structures.LayoutIgnore:FindFirstChild("TopArea")

		boundingUi.InputBegan:Connect(function(input)
			if
				(
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				)
				and properties.Draggable
				and not properties.Maximized
			then
				dragging = true
				inputPos = input.Position
				startPos = structures.Body.Position

				if connection then
					connection:Disconnect()
				end

				connection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		userInputService.InputChanged:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				if dragging then
					local delta = input.Position - inputPos
					local newPosition = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + delta.X,
						startPos.Y.Scale,
						startPos.Y.Offset + delta.Y
					)

					structures.Body.Position = newPosition
				end
			end
		end)
	end

	binder.Apply(properties, object)

	local function recheck() -- Due to roblox resizing issues
		-- If there's a better way to do this please tell me or make a PR
		for i, v in pairs(structures.Body:GetDescendants()) do
			if not pcall(function()
				return v.Size
			end) then
				continue
			end

			local original = v.Size

			v.Size = UDim2.fromOffset(0, 0)
			v.Size = original
		end
	end

	task.defer(recheck)
	task.delay(1, recheck)

	return object
end
end function __DIST.n():typeof(__modImpl())local v=__DIST.cache.n if not v then v={c=__modImpl()}__DIST.cache.n=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: SectionProperties__DARKLUA_TYPE_y): Section__DARKLUA_TYPE_z	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()
	local services = __DIST.e()

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local parent = self.Type == "Window" and self.Structures.SidebarList or self.__instance or self
	local structures = {}

	--// Functions
	local function watchAutosize(structure: Frame, connections: { RBXScriptConnection }, update: (...any) -> (), ...)
		local args = table.pack(...)

		for _, child in ipairs(structure:GetChildren()) do
			if child:IsA("GuiObject") then
				table.insert(
					connections,
					child:GetPropertyChangedSignal("AbsoluteSize"):Connect(function(...)
						update(table.unpack(args, 1, args.n))
					end)
				)
				table.insert(
					connections,
					child:GetPropertyChangedSignal("Visible"):Connect(function(...)
						update(table.unpack(args, 1, args.n))
					end)
				)
			end
		end

		table.insert(
			connections,
			structure.ChildAdded:Connect(function(child)
				if child:IsA("GuiObject") then
					table.insert(
						connections,
						child:GetPropertyChangedSignal("AbsoluteSize"):Connect(function(...)
							update(table.unpack(args, 1, args.n))
						end)
					)
					table.insert(
						connections,
						child:GetPropertyChangedSignal("Visible"):Connect(function(...)
							update(table.unpack(args, 1, args.n))
						end)
					)
					update(table.unpack(args, 1, args.n))
				end
			end)
		)

		table.insert(
			connections,
			structure.ChildRemoved:Connect(function(...)
				update(table.unpack(args, 1, args.n))
			end)
		)
	end

	--// UI
	properties = properties or {}

	properties.Title = properties.Title or "Section Title"
	properties.Disclosure = properties.Disclosure ~= false
	properties.Expanded = properties.Expanded ~= false

	structures.SidebarGroup = binder.Apply(
		properties,
		create("TextButton")({
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 23),
			Text = "",
			AutoButtonColor = false,
			Parent = parent,

			create("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
			}),

			create("Frame")({
				Name = "SectionHeader",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0),

				create("Frame")({
					Name = "Disclosure",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
					LayoutOrder = 1,
					Size = UDim2.fromOffset(13, 14),
					TextColor3 = Color3.fromRGB(0, 0, 0),
					TextSize = 14,

					create("ImageLabel")({
						Name = "DisclosureImage",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = "rbxassetid://115960806571685",
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(11, 7),
						__dynamicKeys = {
							ImageColor3 = self.Theme.Text.Tertiary[1],
							ImageTransparency = self.Theme.Text.Tertiary[2],
						},
					}),
				}),

				create("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				create("UIPadding")({
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 12),
					PaddingTop = UDim.new(0, 3),
				}),

				create("TextLabel")({
					Name = "Title",
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
					LineHeight = 0,
					RichText = true,
					Size = UDim2.fromOffset(0, 14),
					Text = "Section Title",
					TextSize = 12,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,
					__dynamicKeys = {
						TextColor3 = self.Theme.Text.Tertiary[1],
						TextTransparency = self.Theme.Text.Tertiary[2],
					},
				}),
			}),
		})
	) :: Frame

	--// Initialize
	structures.Layout = structures.SidebarGroup:FindFirstChild("UIListLayout") :: UIListLayout
	structures.SectionHeader = structures.SidebarGroup:FindFirstChild("SectionHeader") :: Frame
	structures.Title = structures.SectionHeader:FindFirstChild("Title") :: TextLabel
	structures.Disclosure = structures.SectionHeader:FindFirstChild("Disclosure") :: TextButton
	structures.DisclosureImage = structures.Disclosure:FindFirstChild("DisclosureImage") :: ImageLabel

	local connections = {}
	local bindings = {
		Title = function(name: string)
			structures.Title.Text = name
		end,
		Disclosure = function(state: boolean)
			structures.Disclosure.Visible = state
			structures.SidebarGroup.Active = state
		end,
		Expanded = function(state: boolean, tween: boolean?)
			tween = (tween == nil and true) or false

			local sidebarGroup = structures.SidebarGroup.__instance
			local disclosureImage = structures.DisclosureImage

			sidebarGroup.AutomaticSize = Enum.AutomaticSize.None

			for _, connection: RBXScriptConnection in ipairs(connections) do
				connection:Disconnect()
			end

			table.clear(connections)

			local updateSize = function(useTween: boolean)
				local targetHeight = state and structures.Layout.AbsoluteContentSize.Y or 23
				local tween = tweenService:Create(
					sidebarGroup,
					TweenInfo.new(useTween and 0.35 or 0, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = UDim2.new(1, 0, 0, targetHeight),
					}
				)
				tween:Play()
			end

			if state then
				watchAutosize(sidebarGroup, connections, updateSize, false)
			end

			updateSize(tween)
			tweenService
				:Create(
					disclosureImage,
					TweenInfo.new(tween and 0.35 or 0, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Rotation = state and 0 or -90,
					}
				)
				:Play()
		end,
	}
	local object = binder.Wrap(properties, bindings, structures.SidebarGroup)

	object.Type = "Section"
	object.Theme = self.Theme
	object.Structures = structures
	object.__window = self

	structures.SidebarGroup.MouseButton1Click:Connect(function()
		if not properties.Disclosure then
			return
		end
		
		object.Expanded = not object.Expanded
	end)

	binder.Apply(properties, object)

	return object
end
end function __DIST.o():typeof(__modImpl())local v=__DIST.cache.o if not v then v={c=__modImpl()}__DIST.cache.o=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: PageProperties__DARKLUA_TYPE_M)
	--// Imports
	local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	properties = properties or {}

	local structures = {}

	structures.Page = binder.Apply(
		properties,
		create("ScrollingFrame")({
			Name = "ContentList",
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(),
			ClipsDescendants = false,
			ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
			ScrollBarImageTransparency = 0.6,
			ScrollBarThickness = 7,
			Size = UDim2.fromScale(1, 1),

			__dynamicKeys = {
				ScrollBarImageColor3 = self.Theme.Controls.ScrollBar[1],
				ScrollBarImageTransparency = self.Theme.Controls.ScrollBar[2],
			},

			create("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				Name = "Margins",
				PaddingBottom = UDim.new(0, 17),
				PaddingLeft = UDim.new(0, 17),
				PaddingRight = UDim.new(0, 17),
				PaddingTop = UDim.new(0, 17),
			}),
		})
	) :: ScrollingFrame

	local function refreshPadding()
		local scoped = {}

		for _, instance in ipairs(__SH.COMPINDEXES) do
			if instance.Parent == structures.Page.__instance then
				table.insert(scoped, instance)
			end
		end

		for i, child in ipairs(scoped) do
			if child.Name == "PageSection" then
				local prev = scoped[i - 1]
				local padding = child:FindFirstChildOfClass("UIPadding")
				
				if padding then
					if prev and prev.Name ~= "PageSection" then
						padding.PaddingTop = UDim.new(0, 18)
					else
						padding.PaddingTop = UDim.new(0, 0)
					end
				end
			end
		end
	end

	structures.Page.ChildAdded:Connect(refreshPadding)
	structures.Page.ChildRemoved:Connect(refreshPadding)

	refreshPadding()

	local object = binder.Wrap(properties, {
		Parent = function(p)
			structures.Page.Parent = p
		end,
	}, structures.Page)

	object.Type = "Page"
	object.Theme = self.Theme
	object.Structures = structures
	if self.__window then
		object.__window = self.__window
	end
	object.__container = structures.Page.__instance or structures.Page

	return object
end
end function __DIST.p():typeof(__modImpl())local v=__DIST.cache.p if not v then v={c=__modImpl()}__DIST.cache.p=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: TabProperties__DARKLUA_TYPE_A): Tab__DARKLUA_TYPE_B	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()
	local Page = __DIST.p()

	--// References
	local create = creator.Create
	local window = self.Type == "Window" and self or self.__window

	--// Variables
	local parent = self.Type == "Window" and self.Structures.SidebarList
		or self.Type == "Tab" and self.__instance.Parent
		or self.__instance
		or self
	local structures = {}

	--// UI
	properties = properties or {}

	properties.Title = properties.Title or "Label"
	properties.Indentation = properties.Indentation or 0
	properties.Selected = properties.Selected == true

	structures.Body = binder.Apply(
		properties,
		create("TextButton")({
			Name = "SidebarItem",
			AutoButtonColor = false,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
			LayoutOrder = window.Tabs and #window.Tabs or 1,
			Size = UDim2.new(1, 0, 0, 28),
			Text = "",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 14,
			Parent = parent,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.SelectionFocused[1],
				BackgroundTransparency = self.Theme.Controls.SelectionFocused[2],
			},
			__contextKeys = {
				BackgroundTransparency = function()
					return properties.Selected and self.Theme.Controls.SelectionFocused[2].Value or 1
				end,
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 5),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				Padding = UDim.new(0, 14),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("UIPadding")({
				Name = "UIPadding",
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 8),
			}),

			create("Frame")({
				Name = "Leading",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.new(1, -34, 0, 0),

				create("TextLabel")({
					Name = "Title",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					FontFace = Font.new("rbxassetid://12187365364"),
					LayoutOrder = 2,
					LineHeight = 0,
					RichText = true,
					Size = UDim2.new(1, -22, 0, 20),
					TextSize = 15,
					TextTruncate = Enum.TextTruncate.AtEnd,
					TextXAlignment = Enum.TextXAlignment.Left,

					__dynamicKeys = {
						TextColor3 = self.Theme.Text.SelectionPrimary[1],
						TextTransparency = self.Theme.Text.SelectionPrimary[2],
					},
					__contextKeys = {
						TextColor3 = function()
							return properties.Selected and self.Theme.Text.SelectionPrimary[1].Value
								or self.Theme.Text.Primary[1].Value
						end,
						TextTransparency = function()
							return properties.Selected and self.Theme.Text.SelectionPrimary[2].Value
								or self.Theme.Text.Primary[2].Value
						end,
					},
				}),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				create("ImageLabel")({
					Name = "Symbol",
					Visible = false,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://127049167227557",
					LayoutOrder = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(20, 20),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Controls.Selection[1],
						ImageTransparency = self.Theme.Controls.Selection[2],
					},
					__contextKeys = {
						ImageColor3 = function()
							return properties.Selected and self.Theme.Text.SelectionPrimary[1].Value
								or self.Theme.Controls.Selection[1].Value
						end,
						ImageTransparency = function()
							return properties.Selected and self.Theme.Text.SelectionPrimary[2].Value
								or self.Theme.Controls.Selection[2].Value
						end,
					},
				}),
			}),

			create("Frame")({
				Name = "Trailing",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(20, 16),
			}),
		})
	) :: TextButton

	--// Initialize
	structures.Trailing = structures.Body:FindFirstChild("Trailing") :: Frame
	structures.Leading = structures.Body:FindFirstChild("Leading") :: Frame
	structures.Title = structures.Leading:FindFirstChild("Title") :: TextLabel
	structures.Symbol = structures.Leading:FindFirstChild("Symbol") :: ImageLabel
	structures.Padding = structures.Body:FindFirstChild("UIPadding") :: UIPadding

	local pageComponent = nil

	if properties and properties.Page then
		if type(properties.Page) == "table" and properties.Page.Type == "Page" then
			pageComponent = properties.Page
			structures.Page = pageComponent.Structures.Page
		else
			structures.Page = properties.Page
		end
	else
		pageComponent = Page(self, properties and properties.PageProperties)
		structures.Page = pageComponent.Structures.Page
	end

	local object
	object = binder.Wrap(properties, {
		Title = function(name: string)
			structures.Title.Text = name
		end,
		Icon = function(icon: string?)
			structures.Symbol.Visible = icon and true or false
			if icon then
				structures.Symbol.Image = icon
			end
		end,
		Indentation = function(indentation: number)
			structures.Padding.PaddingLeft += UDim.new(0, (11 * indentation))
		end,
		Selected = function(selected: boolean)
			if selected then
				for _, tab: Tab__DARKLUA_TYPE_B in pairs(window.Tabs) do
					if tab.__container == object.__container then
						continue
					end

					tab.Selected = false
				end
			end

			structures.Body.Transparency = selected and self.Theme.Controls.SelectionFocused[2].Value or 1

			structures.Title.TextColor3 = selected and self.Theme.Text.SelectionPrimary[1].Value
				or self.Theme.Text.Primary[1].Value
			structures.Title.TextTransparency = selected and self.Theme.Text.SelectionPrimary[2].Value
				or self.Theme.Text.Primary[2].Value

			structures.Symbol.ImageColor3 = selected and self.Theme.Text.SelectionPrimary[1].Value
				or self.Theme.Controls.Selection[1].Value
			structures.Symbol.ImageTransparency = selected and self.Theme.Text.SelectionPrimary[2].Value
				or self.Theme.Controls.Selection[2].Value

			structures.Page.Parent = selected and window and window.__container or nil
		end,
	}, structures.Body)

	object.Navigate = function(self, targetPage: Page__DARKLUA_TYPE_N)
		if not targetPage or type(targetPage) ~= "table" or targetPage.Type ~= "Page" then
			warn("Tab:Navigate expects a Page component.")
			return
		end

		local newPageStructure = targetPage.Structures.Page

		if object.Selected and window and window.__container then
			if structures.Page then
				structures.Page.Parent = nil
			end
			newPageStructure.Parent = window.__container
		end

		structures.Page = newPageStructure

		pageComponent = targetPage
	end

	object.Type = "Tab"
	object.Theme = self.Theme
	object.Structures = structures
	object.__container = structures.Page.__instance or structures.Page
	object.__window = self.__window

	binder.Apply(properties, object)

	if window then
		table.insert(window.Tabs, object)

		if object.Selected then
			window.addToHistory(object.__container)
		end

		structures.Body.MouseButton1Click:Connect(function()
			if object.Selected then
				return
			end

			object.Selected = true
			
				window.addToHistory(object.__container)
		end)
	end

	if self.Type == "Tab" then
		object.Indentation = self.Indentation + 1
	end

	return object
end
end function __DIST.q():typeof(__modImpl())local v=__DIST.cache.q if not v then v={c=__modImpl()}__DIST.cache.q=v end return v.c end end do local function __modImpl()
return function(self)
	--// Imports
	local creator = __DIST.d()

	--// References
	local create = creator.Create

	--// Variables
	local structures = {}

	--// UI
	structures.Body = create("Frame")({
		Name = "TitleStack",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, 0),

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("UIPadding")({
			Name = "UIPadding",
		}),

		create("TextLabel")({
			Name = "Subtitle",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364"),
			LayoutOrder = 1,
			RichText = true,
			Size = UDim2.new(0, 0, 0, 14),
			Text = "Subtitle",
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = false,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Secondary[1],
				TextTransparency = self.Theme.Text.Secondary[2],
			},
		}),

		create("TextLabel")({
			Name = "Title",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364"),
			RichText = true,
			Size = UDim2.new(0, 0, 0, 16),
			Text = "Title",
			TextColor3 = Color3.fromRGB(0, 0, 0),
			TextSize = 15,
			TextTransparency = 0.15,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Primary[1],
				TextTransparency = self.Theme.Text.Primary[2],
			},
		}),
	}) :: Frame

	--// Initialize
	structures.Title = structures.Body:FindFirstChild("Title") :: TextLabel
	structures.Subtitle = structures.Body:FindFirstChild("Subtitle") :: TextLabel
	structures.Padding = structures.Body:FindFirstChild("UIPadding") :: UIPadding

	return structures
end
end function __DIST.r():typeof(__modImpl())local v=__DIST.cache.r if not v then v={c=__modImpl()}__DIST.cache.r=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: PageSectionProperties__DARKLUA_TYPE_K): PageSection__DARKLUA_TYPE_L	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	local titleStack = __DIST.r()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = titleStack(self)

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Title"

	local section = create("Frame")({
		Name = "PageSection",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		create("UIPadding")({
			PaddingBottom = UDim.new(0, 18)
		}),
	})

	structures.Body.Parent = section.__instance

	--// Initialize
	structures.Padding.PaddingLeft = UDim.new(0, 8)
	structures.Padding.PaddingRight = UDim.new(0, 8)

	structures.Title.FontFace = Font.new(structures.Title.FontFace.Family, Enum.FontWeight.SemiBold)
	structures.Body.LayoutOrder = -1

	local object = binder.Wrap(properties, {
		Title = function(value: string)
			structures.Title.Text = value
		end,
		Subtitle = function(value: string)
			structures.Subtitle.Visible = true
			structures.Subtitle.Text = value
		end,
	}, section)

	object.Type = "PageSection"
	object.Theme = self.Theme
	object.Structures = structures
	object.__container = section.__instance

	binder.Apply(properties, object)

	return object
end
end function __DIST.s():typeof(__modImpl())local v=__DIST.cache.s if not v then v={c=__modImpl()}__DIST.cache.s=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: Frame__DARKLUA_TYPE_g): Form__DARKLUA_TYPE_D	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}
	local queue = {}
	local entries = {}

	--// UI
	properties = properties or {}

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "Form",
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0),
			Parent = parent,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.View[1],
				BackgroundTransparency = self.Theme.Controls.View[2],
			},

			create("UIListLayout")({
				Name = "UIListLayout",
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				Name = "Margins",
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}),

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 6),
			}),

			create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}),
		})
	) :: Frame

	--// Initialize
	local object = binder.Wrap(properties, {}, structures.Body)

	object.Type = "Form"
	object.Theme = self.Theme
	object.Structures = structures

	local function updateDivs()
		for i, entry in ipairs(entries) do
			local currentVisible = entry.section.Visible
			local nextEntry = entries[i + 1]
			local nextVisible = nextEntry and nextEntry.section.Visible

			entry.divider.Visible = currentVisible and nextVisible == true
		end
	end

	structures.Body.ChildAdded:Connect(function(child)
		if child:IsA("Frame") and child:FindFirstChild("LayoutIgnore") then
			local divider = child.LayoutIgnore:FindFirstChild("Divider")

			if divider then
				table.insert(queue, divider)
				table.insert(entries, { section = child, divider = divider })

				child:GetPropertyChangedSignal("Visible"):Connect(function()
					updateDivs()
				end)

				updateDivs()
			end
		end
	end)

	binder.Apply(properties, object)

	return object
end
end function __DIST.t():typeof(__modImpl())local v=__DIST.cache.t if not v then v={c=__modImpl()}__DIST.cache.t=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: RowProperties__DARKLUA_TYPE_E): Row__DARKLUA_TYPE_F	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	--// UI
	properties = properties or {}

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "Row",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0),
			Parent = parent,

			create("Frame")({
				Name = "LeftAccessory",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, 1),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Wraps = true,
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 10),
				}),
			}),

			create("Frame")({
				Name = "RightAccessory",
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0, 1),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Wraps = true,
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 11),
					PaddingTop = UDim.new(0, 10),
				}),
			}),

			create("Folder")({
				Name = "LayoutIgnore",

				create("Frame")({
					Name = "Divider",
					AnchorPoint = Vector2.new(0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.new(1, 0, 0, 1),
					Visible = false,

					__dynamicKeys = {
						BackgroundColor3 = self.Theme.Controls.ViewBorder[1],
						BackgroundTransparency = self.Theme.Controls.ViewBorder[2],
					},
				}),
			}),
		})
	) :: Frame

	--// Initialize
	structures.LeftAccessories = structures.Body:FindFirstChild("LeftAccessory") :: Frame
	structures.RightAccessories = structures.Body:FindFirstChild("RightAccessory") :: Frame

	local function updateAccessories()
		local parentWidth = structures.LeftAccessories.Parent.AbsoluteSize.X
		local rightWidth = structures.RightAccessories.AbsoluteSize.X

		local minLeftWidth = 75
		local calculatedLeftWidth = math.max(parentWidth - rightWidth, minLeftWidth)

		if parentWidth - rightWidth < minLeftWidth then
			structures.LeftAccessories.Size = UDim2.new(0, minLeftWidth, 1, 0)
		else
			structures.LeftAccessories.Size = UDim2.new(0, calculatedLeftWidth, 1, 0)
		end
	end

	updateAccessories()
	structures.RightAccessories:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateAccessories)
	structures.LeftAccessories.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateAccessories)

	local object = binder.Wrap(properties, {
		SearchIndex = function(value: string)
			structures.Body:SetAttribute("SearchIndex", value)
		end,
	}, structures.Body)

	object.Type = "Row"
	object.Theme = self.Theme
	object.Structures = structures
	object.Left = function()
		local newObject = table.clone(object)

		newObject.__container = structures.LeftAccessories

		return newObject
	end
	object.Right = function()
		local newObject = table.clone(object)

		newObject.__container = structures.RightAccessories

		return newObject
	end

	binder.Apply(properties, object)

	return object
end
end function __DIST.u():typeof(__modImpl())local v=__DIST.cache.u if not v then v={c=__modImpl()}__DIST.cache.u=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: StackProperties__DARKLUA_TYPE_G): Stack__DARKLUA_TYPE_H	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Padding = properties.Padding or UDim.new(0, 10)
    properties.VerticalAlignment = properties.VerticalAlignment or Enum.VerticalAlignment.Center
    properties.HorizontalAlignment = properties.HorizontalAlignment or Enum.HorizontalAlignment.Right

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "HStack",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			Parent = parent,

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = true,
			}),
		})
	) :: Frame

	--// Initialize
	structures.Layout = structures.Body:FindFirstChild("UIListLayout") :: UIListLayout

	local object = binder.Wrap(properties, {
		Padding = function(value: UDim)
			structures.Layout.Padding = value
		end,
		HorizontalAlignment = function(value: Enum.HorizontalAlignment)
			structures.Layout.HorizontalAlignment = value
		end,
		VerticalAlignment = function(value: Enum.VerticalAlignment)
			structures.Layout.VerticalAlignment = value
		end,
	}, structures.Body)

	object.Type = "HStack"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.v():typeof(__modImpl())local v=__DIST.cache.v if not v then v={c=__modImpl()}__DIST.cache.v=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: StackProperties__DARKLUA_TYPE_G): Stack__DARKLUA_TYPE_H	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Padding = properties.Padding or UDim.new(0, 10)
    properties.VerticalAlignment = properties.VerticalAlignment or Enum.VerticalAlignment.Center
    properties.HorizontalAlignment = properties.HorizontalAlignment or Enum.HorizontalAlignment.Right

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "VStack",
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.XY,
			Parent = parent,

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = true,
			}),
		})
	) :: Frame

	--// Initialize
	structures.Layout = structures.Body:FindFirstChild("UIListLayout") :: UIListLayout

	local object = binder.Wrap(properties, {
		Padding = function(value: UDim)
			structures.Layout.Padding = value
		end,
		HorizontalAlignment = function(value: Enum.HorizontalAlignment)
			structures.Layout.HorizontalAlignment = value
		end,
		VerticalAlignment = function(value: Enum.VerticalAlignment)
			structures.Layout.VerticalAlignment = value
		end,
	}, structures.Body)

	object.Type = "VStack"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.w():typeof(__modImpl())local v=__DIST.cache.w if not v then v={c=__modImpl()}__DIST.cache.w=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: TitleStackProperties__DARKLUA_TYPE_I): TitleStack__DARKLUA_TYPE_J	--// Imports
	
local binder = __DIST.c()

	local titleStack = __DIST.r()

	--// Variables
	local structures = titleStack(self)

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Title"

	structures.Body.Parent = self.__container or self.__instance or self

	--// Initialize
	local object = binder.Wrap(properties, {
		Title = function(value: string)
			structures.Title.Text = value
		end,
		Subtitle = function(value: string)
			structures.Subtitle.Visible = true
			structures.Subtitle.Text = value
		end,
	}, structures.Body)

	object.Type = "TitleStack"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.x():typeof(__modImpl())local v=__DIST.cache.x if not v then v={c=__modImpl()}__DIST.cache.x=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: LabelProperties__DARKLUA_TYPE_O): Label__DARKLUA_TYPE_P	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Text = properties.Text or "Label"

	structures.Body = create("TextLabel")({
		Name = "Label",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		FontFace = Font.new("rbxassetid://12187365364"),
		RichText = true,
		TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextWrapped = true,
		Parent = parent,

		__dynamicKeys = {
			TextColor3 = self.Theme.Text.Secondary[1],
			TextTransparency = self.Theme.Text.Secondary[2],
		},
	}) :: TextLabel

	--// Initialize
	local object = binder.Wrap(properties, {}, structures.Body)

	object.Type = "Label"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.y():typeof(__modImpl())local v=__DIST.cache.y if not v then v={c=__modImpl()}__DIST.cache.y=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: SymbolProperties__DARKLUA_TYPE_Q): Symbol__DARKLUA_TYPE_R	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Style = properties.Style or "Primary"
	properties.Size = properties.Size or UDim2.fromOffset(20, 20)

	structures.Body = create("ImageLabel")({
		Name = "Image",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Parent = parent,

		__dynamicKeys = {
			ImageColor3 = self.Theme.Text.Primary[1],
			ImageTransparency = self.Theme.Text.Primary[2],
		},

		__contextKeys = {
			ImageColor3 = function()
				return properties.Style == "Primary" and self.Theme.Text.Primary[1].Value or self.Theme.Text.Secondary[1].Value
			end,
			ImageTransparency = function()
				return properties.Style == "Primary" and self.Theme.Text.Primary[2].Value or self.Theme.Text.Secondary[2].Value
			end,
		},
	}) :: ImageLabel

	--// Initialize
	local object = binder.Wrap(properties, {
		Style = function(value: "Primary" | "Secondary")
			if value == "Primary" then
				structures.Body.ImageColor3 = self.Theme.Text.Primary[1].Value
				structures.Body.ImageTransparency = self.Theme.Text.Primary[2].Value
			else
				structures.Body.ImageColor3 = self.Theme.Text.Secondary[1].Value
				structures.Body.ImageTransparency = self.Theme.Text.Secondary[2].Value
			end
		end,
	}, structures.Body)

	object.Type = "Symbol"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.z():typeof(__modImpl())local v=__DIST.cache.z if not v then v={c=__modImpl()}__DIST.cache.z=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: ToggleProperties__DARKLUA_TYPE_S): Row__DARKLUA_TYPE_F	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()
	local services = __DIST.e()

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.Toggle
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Value = properties.Value == true

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "Toggle",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(28, 16),
			Parent = parent,

			create("ImageButton")({
				Name = "Switch",
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://104426531889908",
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = 0.91,
				Size = UDim2.fromOffset(28, 16),

				__dynamicKeys = {
					ImageColor3 = theme.SwitchOff[1],
					ImageTransparency = theme.SwitchOff[2],
				},
				__contextKeys = {
					ImageColor3 = function()
						return properties.Value and theme.SwitchOn[1].Value or theme.SwitchOff[1].Value
					end,
					ImageTransparency = function()
						return properties.Value and theme.SwitchOn[2].Value or theme.SwitchOff[2].Value
					end,
				},

				create("ImageLabel")({
					Name = "Knob",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://99107881432922",
					Position = UDim2.new(0, 1, 0.5, 0),
					Size = UDim2.fromOffset(14, 14),

					__dynamicKeys = {
						ImageColor3 = theme.Knob[1],
						ImageTransparency = theme.Knob[2],
					},

					create("ImageLabel")({
						Name = "Effects",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = "rbxassetid://138042641797315",
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(16, 16),

						__dynamicKeys = {
							ImageColor3 = theme.KnobEffects[1],
							ImageTransparency = theme.KnobEffects[2],
						},
					}),
				}),

				create("UIGradient")({
					Name = "UIGradient",
					Rotation = 90,

					__dynamicKeys = {
						Color = theme.DepthEffect[1],
					},
				}),
			}),
		})
	) :: Frame

	--// Initialize
	structures.Switch = structures.Body:FindFirstChild("Switch") :: ImageButton
	structures.Knob = structures.Switch:FindFirstChild("Knob") :: ImageLabel

	local object
	local bindings = {
		Value = function(value: boolean, instant: boolean?)
			instant = (instant == nil and true) or false

			local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			local knobGoal = { Position = value and UDim2.new(0, 13, 0.5, 0) or UDim2.new(0, 1, 0.5, 0) }
			local switchGoal = { 
				ImageColor3 = value and theme.SwitchOn[1].Value or theme.SwitchOff[1].Value,
				ImageTransparency = value and theme.SwitchOn[2].Value or theme.SwitchOff[2].Value,
			}

			if instant then
				tweenService:Create(structures.Knob, tweenInfo, knobGoal):Play()
				tweenService:Create(structures.Switch, tweenInfo, switchGoal):Play()
			else
				structures.Knob.Position = knobGoal.Position
				structures.Switch.ImageColor3 = switchGoal.ImageColor3
				structures.Switch.ImageTransparency = switchGoal.ImageTransparency
			end

			if properties.ValueChanged and instant then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Toggle"
	object.Theme = self.Theme
	object.Structures = structures

	do -- Input handler
		structures.Switch.MouseButton1Click:Connect(function()
			object.Value = not object.Value
		end)
	end

	bindings.Value(not not properties.Value, false)
	binder.Apply(properties, object)

	return object
end
end function __DIST.A():typeof(__modImpl())local v=__DIST.cache.A if not v then v={c=__modImpl()}__DIST.cache.A=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: TextFieldProperties__DARKLUA_TYPE_U): TextField__DARKLUA_TYPE_V	--// Imports
	
local binder = __DIST.c()

	--// Variables
	local structures = __DIST.j()(self)

	--// UI
	properties = properties or {}
	properties.Value = properties.Value ~= nil and properties.Value or ""
	properties.Placeholder = properties.Placeholder or "Placeholder"

	--// Initialize
	structures.Field.TextTruncate = Enum.TextTruncate.AtEnd
	structures.Field.TextXAlignment = Enum.TextXAlignment.Right
	structures.Body.Parent = self.__container or self.__instance or self

	local object
	object = binder.Wrap(properties, {
		Placeholder = function(value: string)
			structures.Field.PlaceholderText = value
		end,
		Value = function(value: string)
			structures.Field.Text = value

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}, structures.Body)

	structures.Field.Focused:Connect(function()
		structures.Body.AutomaticSize = Enum.AutomaticSize.XY
	end)

	structures.Field.FocusLost:Connect(function()
		structures.Body.AutomaticSize = Enum.AutomaticSize.None

		if object.Value ~= structures.Field.Text then
			object.Value = structures.Field.Text
		end
	end)

	object.Type = "TextField"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	structures.Field:GetPropertyChangedSignal("Text"):Connect(function()
		if properties.TextChanged then
			task.spawn(properties.TextChanged, object, structures.Field.Text or "")
		end
	end)

	return object
end
end function __DIST.B():typeof(__modImpl())local v=__DIST.cache.B if not v then v={c=__modImpl()}__DIST.cache.B=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: KeybindFieldProperties__DARKLUA_TYPE_W): KeybindFieldProperties__DARKLUA_TYPE_W	--// Imports
	
local binder = __DIST.c()
	local services = __DIST.e()

	--// References
	local userInputService = services.UserInputService

	--// Variables
	local structures = __DIST.j()(self)

	--// UI
	properties = properties or {}
	properties.Placeholder = properties.Placeholder or "Press a key"

	--// Initialize
	structures.Field.TextXAlignment = Enum.TextXAlignment.Right
	structures.Field.TextEditable = false
	structures.Body.Parent = self.__container or self.__instance or self
	structures.Body.AutomaticSize = Enum.AutomaticSize.XY
	structures.Body.Size = UDim2.fromOffset(0, 23)
	structures.Field.Size = UDim2.fromOffset(0, 23)
	structures.Corner.CornerRadius = UDim.new(0, 6)

	local object
	object = binder.Wrap(properties, {
		Placeholder = function(value: string)
			structures.Field.PlaceholderText = value
		end,
		Value = function(value: Enum.KeyCode)
			structures.Field.Text = value.Name

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}, structures.Body)

	userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == properties.Value and properties.BindPressed then
			properties.BindPressed(object, input.KeyCode, false, gameProcessedEvent)
		end
	end)

	userInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if structures.Field:IsFocused() then
			object.Value = input.KeyCode
			structures.Field:ReleaseFocus()
		elseif input.KeyCode == properties.Value and properties.BindPressed then
			properties.BindPressed(object, input.KeyCode, true, gameProcessedEvent)
		end
	end)

	object.Type = "KeybindField"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.C():typeof(__modImpl())local v=__DIST.cache.C if not v then v={c=__modImpl()}__DIST.cache.C=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: SliderProperties__DARKLUA_TYPE_Y): Slider__DARKLUA_TYPE_Z	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.Slider
	local dragStart = 0
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Value = properties.Value or 0
	properties.Maximum = properties.Maximum or 1
	properties.Minimum = properties.Minimum or 0

	structures.Body = binder.Apply(
		properties,
		create("ImageLabel")({
			Name = "Slider",
			Active = true,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://92966982499851",
			Position = UDim2.fromScale(0, 0.5),
			Selectable = true,
			Size = UDim2.fromOffset(150, 4),
			Parent = parent,

			__dynamicKeys = {
				ImageColor3 = theme.Track[1],
				ImageTransparency = theme.Track[2],
			},

			create("ImageLabel")({
				Name = "TrackClip",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://113661976068590",
				ImageColor3 = Color3.fromRGB(252, 252, 252),
				ResampleMode = Enum.ResamplerMode.Pixelated,
				Size = UDim2.new(0, 2, 1, 0),
				ZIndex = 3,

				__dynamicKeys = {
					ImageColor3 = self.Theme.Controls.View[1],
					ImageTransparency = self.Theme.Controls.View[2],
				},
			}),

			create("Frame")({
				Name = "Fill",
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, 1),

				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.Selection[1],
					BackgroundTransparency = self.Theme.Controls.Selection[2],
				},

				create("ImageLabel")({
					Name = "Effects",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://82410105327406",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					Size = UDim2.new(0, 150, 1, 0),
					ZIndex = 0,

					__dynamicKeys = {
						ImageColor3 = theme.TrackEffects[1],
						ImageTransparency = theme.TrackEffects[2],
					},
				}),

				create("Frame")({
					Name = "Thumb",
					Active = true,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(1, 0),
					Selectable = true,
					Size = UDim2.fromOffset(20, 20),
					ZIndex = 2,

					create("ImageLabel")({
						Name = "Background",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = "rbxassetid://125496304036680",
						Selectable = true,
						Size = UDim2.fromOffset(20, 20),

						__dynamicKeys = {
							ImageColor3 = theme.Thumb[1],
							ImageTransparency = theme.Thumb[2],
						},

						create("UIStroke")({
							Name = "UIStroke",
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

							__dynamicKeys = {
								Color = theme.ThumbStroke[1],
								Transparency = theme.ThumbStroke[2],
							},
						}),

						create("UICorner")({
							Name = "UICorner",
							CornerRadius = UDim.new(1, 0),
						}),
					}),

					create("ImageLabel")({
						Name = "ThumbEffects",
						AnchorPoint = Vector2.new(0.5, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = "rbxassetid://85926626300527",
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromOffset(22, 22),
						ZIndex = 0,

						__dynamicKeys = {
							ImageColor3 = theme.ThumbEffects[1],
							ImageTransparency = theme.ThumbEffects[2],
						},

						create("UICorner")({
							Name = "UICorner",
							CornerRadius = UDim.new(1, 0),
						}),
					}),
				}),
			}),
		})
	) :: ImageLabel

	--// Initialize
	structures.Fill = structures.Body:FindFirstChild("Fill") :: Frame
	structures.Thumb = structures.Fill:FindFirstChild("Thumb") :: Frame
	structures.Dragger = create("UIDragDetector")({
		Name = "UIDragDetector",
		ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomOffset,
		SelectionModeDragSpeed = UDim2.new(),
		SelectionModeRotateSpeed = 0,
		ActivatedCursorIcon = "rbxassetid://0",
		CursorIcon = "rbxassetid://0",
		Parent = structures.Thumb,
	}) :: UIDragDetector

	local object
	local bindings = {
		Value = function(value: number)
			local sliderWidth = structures.Body.AbsoluteSize.X
			local thumbWidth = structures.Thumb.AbsoluteSize.X
			local thumbHalfWidth = thumbWidth / 2

			local min = properties.Minimum
			local max = properties.Maximum
			local alpha = max ~= min and (value - min) / (max - min) or 0

			local availableWidth = sliderWidth - thumbWidth
			local fillWidth = thumbHalfWidth + (availableWidth * alpha)

			structures.Fill.Size = UDim2.new(0, fillWidth, 1, 0)

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Slider"
	object.Theme = self.Theme
	object.Structures = structures

	structures.Dragger.DragStart:Connect(function()
		dragStart = structures.Fill.AbsoluteSize.X
	end)

	structures.Dragger.DragContinue:Connect(function()
		local sliderWidth = structures.Body.AbsoluteSize.X
		local thumbWidth = structures.Thumb.AbsoluteSize.X
		local thumbHalfWidth = thumbWidth / 2

		local minX = thumbHalfWidth
		local maxX = sliderWidth - thumbHalfWidth

		local deltaPixels = structures.Dragger.DragUDim2.X.Offset
		local newCenterX = dragStart + deltaPixels
		local clampedCenterX = math.clamp(newCenterX, minX, maxX)

		local alpha = (clampedCenterX - minX) / (maxX - minX)
		
		object.Value = object.Minimum + (object.Maximum - object.Minimum) * alpha
	end)

	binder.Apply(properties, object)

	return object
end
end function __DIST.D():typeof(__modImpl())local v=__DIST.cache.D if not v then v={c=__modImpl()}__DIST.cache.D=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: ButtonProperties__DARKLUA_TYPE__): Button__DARKLUA_TYPE_0	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()
	local services = __DIST.e()

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.Button
	local structures = {}

	--// UI
	properties = properties or {}
	properties.State = properties.State or "Primary"
	properties.Label = properties.Label or "Label"

	structures.Body = binder.Apply(
		properties,
		create("TextButton")({
			Name = "Button",
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Text = "",
			Parent = parent,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 5),
			}),

			create("Folder")({
				Name = "ShadowLayers",

				create("Frame")({
					Name = "Layer1",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 0,

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 5),
					}),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Transparency = 0.95,

						__dynamicKeys = {
							Color = theme.Shadow,
						},
					}),
				}),

				create("Frame")({
					Name = "Layer2",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = -1,

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 5),
					}),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 2,
						Transparency = 0.98,

						__dynamicKeys = {
							Color = theme.Shadow,
						},
					}),
				}),
			}),

			create("Folder")({
				Name = "PressOverlay",

				create("Frame")({
					Name = "Overlay",
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 0,

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 5),
					}),
				}),
			}),
		})
	) :: TextButton

	--// Initialize
	structures.PressOverlay = structures.Body:FindFirstChild("PressOverlay"):FindFirstChild("Overlay")
	structures.Shadows = structures.Body:FindFirstChild("ShadowLayers")
	structures.Shadow1 = structures.Shadows:FindFirstChild("Layer1"):FindFirstChild("UIStroke")
	structures.Shadow2 = structures.Shadows:FindFirstChild("Layer2"):FindFirstChild("UIStroke")

	local labelContext = {
		TextColor3 = function()
			local state = properties.State

			return state == "Primary" and self.Theme.Text.SelectionPrimary[1].Value
				or state == "Secondary" and self.Theme.Text.Primary[1].Value
				or state == "Destructive" and self.Theme.Accents.Red[1].Value
		end,
		TextTransparency = function()
			local state = properties.State

			return state == "Primary" and self.Theme.Text.SelectionPrimary[2].Value
				or state == "Secondary" and self.Theme.Text.Primary[2].Value
				or state == "Destructive" and self.Theme.Accents.Red[2].Value
		end,
	}
	local fillContext = {
		Color = function()
			local state = properties.State

			return state == "Primary" and theme.FillPrimary.Value
				or (state == "Secondary" or state == "Destructive") and theme.FillSecondary.Value
		end,
	}

	structures.Label = create("TextLabel")({
		Size = UDim2.fromScale(1, 1),
		Name = "Label",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		FontFace = Font.new("rbxassetid://12187365364"),
		RichText = true,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = structures.Body.__instance,

		__dynamicKeys = {
			TextColor3 = self.Theme.Text.SelectionPrimary[1],
			TextTransparency = self.Theme.Text.SelectionPrimary[2],
		},
		__contextKeys = labelContext,

		create("UIPadding")({
			Name = "UIPadding",
			PaddingBottom = UDim.new(0, 3),
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
			PaddingTop = UDim.new(0, 3),
		}),
	}) :: TextLabel
	structures.Fill = create("UIGradient")({
		Name = "UIGradient",
		Rotation = 90,
		Parent = structures.Body.__instance,

		__dynamicKeys = {
			Color = theme.FillPrimary,
		},
		__contextKeys = fillContext,
	}) :: UIGradient

	local object
	local bindings = {
		State = function()
			task.defer(function()
				structures.Label.TextColor3 = labelContext.TextColor3()
				structures.Label.TextTransparency = labelContext.TextTransparency()
				structures.Fill.Color = fillContext.Color()
			end)
		end,
		Label = function(value: string)
			structures.Label.Text = value
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Button"
	object.Theme = self.Theme
	object.Structures = structures

	structures.Body.MouseButton1Click:Connect(function()
		if properties.Pushed then
			task.spawn(properties.Pushed, object)
		end
	end)

	local function animateRelease()
		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		tweenService
			:Create(structures.PressOverlay, tweenInfo, {
				BackgroundTransparency = 1,
			})
			:Play()
	end

	structures.Body.MouseButton1Down:Connect(function()
		local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		tweenService
			:Create(structures.PressOverlay, tweenInfo, {
				BackgroundTransparency = 0.8,
			})
			:Play()
	end)

	structures.Body.MouseButton1Up:Connect(animateRelease)
	structures.Body.MouseLeave:Connect(animateRelease)

	binder.Apply(properties, object)

	return object
end
end function __DIST.E():typeof(__modImpl())local v=__DIST.cache.E if not v then v={c=__modImpl()}__DIST.cache.E=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: StepperProperties__DARKLUA_TYPE_1): Stepper__DARKLUA_TYPE_2	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	local textField = __DIST.j()
	--// References
	
local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.Stepper
	local structures = {}

	local holding = false
	local stepConnections = {}
	local repeatDelay = 0.35
	local repeatInterval = 0.083

	--// Functions
	local function getPrecision(step)
		local stepStr = tostring(step)
		local dot = string.find(stepStr, "%.")
		local precision = 0

		if dot then
			precision = #stepStr - dot
		end

		return precision
	end

	local function stepFormat(value, step)
		local stepPrecision = getPrecision(step)
		local valuePrecision = getPrecision(value)

		local displayPrecision = math.max(stepPrecision, valuePrecision)

		local formatStr = "%." .. displayPrecision .. "f"
		return string.format(formatStr, value)
	end

	local function round(value, decimals)
		local mult = 10 ^ (decimals or 0)
		return math.floor(value * mult + 0.5) / mult
	end

	--// UI
	properties = properties or {}
	properties.Value = properties.Value or 0
	properties.Step = properties.Step or 0.1
	properties.Maximum = properties.Maximum or 1
	properties.Minimum = properties.Minimum or 0
	properties.Fielded = properties.Fielded or false

	structures.Body = binder.Apply(
		properties,
		create("ImageLabel")({
			Name = "Stepper",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://85888499115674",
			Size = UDim2.fromOffset(13, 20),
			Parent = parent,

			__dynamicKeys = {
				ImageColor3 = theme.Background[1],
				ImageTransparency = theme.Background[2],
			},

			create("ImageLabel")({
				Name = "Shadow",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://105571270097608",
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(19, 27),

				__dynamicKeys = {
					ImageColor3 = theme.Dropshadow[1],
					ImageTransparency = theme.Dropshadow[2],
				},
			}),

			create("ImageButton")({
				Name = "Up",
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://133515997946294",
				Size = UDim2.new(1, 0, 0, 9),
				Position = UDim2.fromOffset(0, 1),

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Primary[1],
					ImageTransparency = self.Theme.Text.Primary[2],
				},

				__contextKeys = {
					ImageColor3 = function()
						if properties.Value >= properties.Maximum then
							return self.Theme.Text.Tertiary[1].Value
						else
							return self.Theme.Text.Primary[1].Value
						end
					end,
					ImageTransparency = function()
						if properties.Value >= properties.Maximum then
							return self.Theme.Text.Tertiary[2].Value
						else
							return self.Theme.Text.Primary[2].Value
						end
					end,
				},
			}),

			create("ImageButton")({
				Name = "Down",
				AnchorPoint = Vector2.new(0, 1),
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://83836660987173",
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 9),

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Primary[1],
					ImageTransparency = self.Theme.Text.Primary[2],
				},

				__contextKeys = {
					ImageColor3 = function()
						if properties.Value <= properties.Minimum then
							return self.Theme.Text.Tertiary[1].Value
						else
							return self.Theme.Text.Primary[1].Value
						end
					end,
					ImageTransparency = function()
						if properties.Value <= properties.Minimum then
							return self.Theme.Text.Tertiary[2].Value
						else
							return self.Theme.Text.Primary[2].Value
						end
					end,
				},
			}),

			create("Frame")({
				Name = "Top",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 6),
				Size = UDim2.new(1, 0, 0, 4),
				ZIndex = 0,

				create("UIGradient")({
					Name = "UIGradient",
					Rotation = 90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.949),
						NumberSequenceKeypoint.new(1, 0.949),
					}),

					__dynamicKeys = {
						Color = theme.SegmentShadow,
					},
				}),
			}),

			create("Frame")({
				Name = "Separator",
				AnchorPoint = Vector2.new(0, 0.5),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 0,

				__dynamicKeys = {
					BackgroundColor3 = theme.Separator[1],
					BackgroundTransparency = theme.Separator[2],
				},
			}),

			create("Frame")({
				Name = "Bottom",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 10),
				Size = UDim2.new(1, 0, 0, 4),
				ZIndex = 0,

				create("UIGradient")({
					Name = "UIGradient",
					Rotation = -90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.949),
						NumberSequenceKeypoint.new(1, 0.949),
					}),

					__dynamicKeys = {
						Color = theme.SegmentShadow,
					},
				}),
			}),

			create("Frame")({
				Name = "Filler",
				AnchorPoint = Vector2.new(0, 0.5),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 0, 2),
				ZIndex = 0,

				__dynamicKeys = {
					BackgroundColor3 = theme.Filler[1],
					BackgroundTransparency = theme.Filler[2],
				},
			}),
		})
	) :: ImageLabel

	--// Initialize
	structures.IPlus = structures.Body:FindFirstChild("Up") :: ImageButton
	structures.IMinus = structures.Body:FindFirstChild("Down") :: ImageButton

	structures.Field = textField(self)
	structures.Field.Padding.PaddingBottom = UDim.new(0, 2)
	structures.Field.Padding.PaddingTop = UDim.new(0, 2)
	structures.Field.Padding.PaddingRight = UDim.new(0, 2)
	structures.Field.Body.Size = UDim2.fromOffset(0, 23)
	structures.Field.Field.Size = UDim2.fromOffset(0, 0)
	structures.Field.Corner.CornerRadius = UDim.new(0, 6)
	structures.Field.FieldPadding:Destroy()

	local object
	local bindings = {
		Fielded = function(value: boolean)
			if value then
				structures.Field.Body.Parent = parent
				structures.Body.Parent = structures.Field.Body.__instance
				structures.Body.LayoutOrder = 1
			else
				structures.Field.Body.Parent = nil
				structures.Body.Parent = parent
				structures.Body.LayoutOrder = 0
			end
		end,
		Value = function(value: number)
			if value <= properties.Minimum then
				structures.IMinus.ImageColor3 = self.Theme.Text.Tertiary[1].Value
				structures.IMinus.ImageTransparency = self.Theme.Text.Tertiary[2].Value
				structures.IMinus.Interactable = false
			else
				structures.IMinus.ImageColor3 = self.Theme.Text.Primary[1].Value
				structures.IMinus.ImageTransparency = self.Theme.Text.Primary[2].Value
				structures.IMinus.Interactable = true
			end

			if value >= properties.Maximum then
				structures.IPlus.ImageColor3 = self.Theme.Text.Tertiary[1].Value
				structures.IPlus.ImageTransparency = self.Theme.Text.Tertiary[2].Value
				structures.IPlus.Interactable = false
			else
				structures.IPlus.ImageColor3 = self.Theme.Text.Primary[1].Value
				structures.IPlus.ImageTransparency = self.Theme.Text.Primary[2].Value
				structures.IPlus.Interactable = true
			end

			if structures.Field then
				structures.Field.Field.Text = stepFormat(value, properties.Step)
			end

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Stepper"
	object.Theme = self.Theme
	object.Structures = structures
	object.Increment = function()
		assert(properties.Minimum)
		assert(properties.Maximum)

		local precision = math.max(getPrecision(object.Value), getPrecision(properties.Step))
		local rawValue = object.Value + properties.Step
		local newValue = round(rawValue, precision)

		object.Value = math.clamp(newValue, properties.Minimum, properties.Maximum)
	end

	object.Decrement = function()
		assert(properties.Minimum)
		assert(properties.Maximum)

		local precision = math.max(getPrecision(object.Value), getPrecision(properties.Step))
		local rawValue = object.Value - properties.Step
		local newValue = round(rawValue, precision)

		object.Value = math.clamp(newValue, properties.Minimum, properties.Maximum)
	end

	local function stepStart(direction: string)
		holding = true

		local action = (direction == "Up") and object.Increment or object.Decrement

		stepConnections[direction] = task.spawn(function()
			if  holding then
				task.wait(repeatDelay)
			end

			if not  holding then return end

			action()

			while  holding do
				task.wait(repeatInterval)
				if  holding then
					action()
				end
			end
		end)
	end

	local function stepStop(direction: string)
		 holding = false
		if stepConnections[direction] then
			task.cancel(stepConnections[direction])
			stepConnections[direction] = nil
		end
	end

	structures.IPlus.MouseButton1Down:Connect(function()
		object.Increment()
		stepStart("Up")
	end)
	structures.IPlus.MouseButton1Up:Connect(function()
		stepStop("Up")
	end)
	structures.IPlus.MouseLeave:Connect(function()
		stepStop("Up")
	end)

	structures.IMinus.MouseButton1Down:Connect(function()
		object.Decrement()
		stepStart("Down")
	end)
	structures.IMinus.MouseButton1Up:Connect(function()
		stepStop("Down")
	end)
	structures.IMinus.MouseLeave:Connect(function()
		stepStop("Down")
	end)

	structures.Body.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stepStop("Up")
			stepStop("Down")
			for _, conn in pairs(stepConnections) do
				if typeof(conn) == "RBXScriptConnection" then
					conn:Disconnect()
				end
			end
			stepConnections = {}
		end
	end)

	structures.Field.Field.FocusLost:Connect(function(fromEnter)
		if fromEnter then
			assert(properties.Minimum)
			assert(properties.Maximum)

			local text = structures.Field.Field.Text
			local number = tonumber(text)

			if number and properties.Fielded then
				properties.Value = math.clamp(number, properties.Minimum, properties.Maximum)

				if properties.Value then
					bindings.Value(properties.Value)
				end
			end
		else
			structures.Field.Field.Text = tostring(properties.Value)
		end
	end)

	binder.Apply(properties, object)

	return object
end
end function __DIST.F():typeof(__modImpl())local v=__DIST.cache.F if not v then v={c=__modImpl()}__DIST.cache.F=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: RadioButtonGroupProperties__DARKLUA_TYPE_3): RadioButtonGroup__DARKLUA_TYPE_4	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.RadioButtonGroup
	local structures = {
		RadioButtons = {},
	}

	--// Functions
	local function radioButton(object, name, index)
		structures.RadioButtons[index] = create("Frame")({
			Name = "RadioButton",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			LayoutOrder = index,
			Parent = structures.Body.__instance,

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("ImageButton")({
				Name = "Button",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://118333468121914",
				Size = UDim2.fromOffset(14, 14),

				__dynamicKeys = {
					ImageColor3 = theme.Background[1],
					ImageTransparency = theme.Background[2],
				},

				__contextKeys = {
					ImageColor3 = function()
						return properties.Value == index and self.Theme.Controls.Selection[1].Value
							or theme.Background[1].Value
					end,
					ImageTransparency = function()
						return properties.Value == index and self.Theme.Controls.Selection[2].Value
							or theme.Background[2].Value
					end,
				},

				create("ImageLabel")({
					Name = "Overlay",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://118333468121914",
					Size = UDim2.fromOffset(14, 14),

					__dynamicKeys = {
						ImageColor3 = theme.Overlay[1],
						ImageTransparency = theme.Overlay[2],
					},

					create("UIGradient")({
						Name = "UIGradient",
						Rotation = 90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),
				}),

				create("ImageLabel")({
					Name = "Dot",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://118333468121914",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(6, 6),
					SliceCenter = Rect.new(7, 7, 7, 7),

					__dynamicKeys = {
						ImageColor3 = theme.Dot[1],
						ImageTransparency = theme.Dot[2],
					},

					__contextKeys = {
						ImageTransparency = function()
							return properties.Value == index and theme.Dot[2].Value or 1
						end,
					},
				}),

				create("ImageLabel")({
					Name = "Stroke",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://132968326823931",
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					__dynamicKeys = {
						ImageColor3 = theme.Stroke[1],
						ImageTransparency = theme.Stroke[2],
					},

					__contextKeys = {
						ImageTransparency = function()
							return properties.Value == index and 1 or theme.Stroke[2].Value
						end,
					},
				}),

				create("ImageLabel")({
					Name = "InnerShadow",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://95115717327743",
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),

					__dynamicKeys = {
						ImageColor3 = theme.InnerShadow[1],
						ImageTransparency = theme.InnerShadow[2],
					},

					__contextKeys = {
						ImageTransparency = function()
							return properties.Value == index and 1 or theme.InnerShadow[2].Value
						end,
					},
				}),

				create("ImageLabel")({
					Name = "DropShadow",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://110994967430153",
					Position = UDim2.new(0.5, 0, 0.5, 1),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(20, 20),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Controls.Selection[1],
						ImageTransparency = self.Theme.Controls.Selection[2],
					},

					__contextKeys = {
						ImageTransparency = function()
							return properties.Value == index and 0.76 or 1
						end,
					},
				}),
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 1,
				RichText = true,
				Text = name,
				TextSize = 15,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Visible = not not name,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),
		}) :: Frame

		local button = structures.RadioButtons[index]:FindFirstChild("Button") :: ImageButton
		if button and button:IsA("ImageButton") then
			button.MouseButton1Click:Connect(function()
				if object then
					object.Value = index
				end
			end)
		end
	end

	--// UI
	properties = properties or {}
	properties.Options = properties.Options or {}

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "RadioButtons",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Parent = parent,

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				Padding = UDim.new(0, 16),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Wraps = true,
			}),
		})
	) :: Frame

	--// Initialize
	local object
	local bindings = {
		Options = function(value: { [number]: string })
			for index, option in ipairs(value) do
				if structures.RadioButtons[index] then
					structures.RadioButtons[index]:Destroy()
				end

				radioButton(object, option, index)
			end
		end,
		Value = function(value: number)
			for index, radioButton in ipairs(structures.RadioButtons) do
				local currentIndex = index == value

				if radioButton then
					local button = radioButton:FindFirstChild("Button")

					button.ImageColor3 = currentIndex and self.Theme.Controls.Selection[1].Value
						or theme.Background[1].Value
					button.ImageTransparency = currentIndex and self.Theme.Controls.Selection[2].Value
						or theme.Background[2].Value

					button:FindFirstChild("Dot").ImageTransparency = currentIndex and theme.Dot[2].Value or 1

					button:FindFirstChild("Stroke").ImageTransparency = currentIndex and 1 or theme.Stroke[2].Value
					button:FindFirstChild("InnerShadow").ImageTransparency = currentIndex and 1
						or theme.InnerShadow[2].Value
					button:FindFirstChild("DropShadow").ImageTransparency = currentIndex and 0.76 or 1
				end
			end

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "RadioButtonGroup"
	object.Theme = self.Theme
	object.Structures = structures
	object.Option = function(self, name: string?)
		local index = #structures.RadioButtons + 1

		radioButton(object, name, index)

		table.insert(properties.Options or {}, name)

		return structures.RadioButtons[index]
	end

	binder.Apply(properties, object)

	return object
end
end function __DIST.G():typeof(__modImpl())local v=__DIST.cache.G if not v then v={c=__modImpl()}__DIST.cache.G=v end return v.c end end do local function __modImpl()--// Imports

local creator = __DIST.d()






return function(self, config: DropdownMenuStructureConfig__DARKLUA_TYPE_ag?)
	--// Variables
	local create = creator.Create

	config = config or {}

	local theme = self.Theme.Controls.MenuButton
	local structures = {}

	structures.Container = create("ScreenGui")({
		Name = "Container",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ScreenInsets = Enum.ScreenInsets.None,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 201,
		OnTopOfCoreBlur = true,

		create("CanvasGroup")({
			Name = "MenuBody",
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			GroupTransparency = 1,
			Size = UDim2.fromScale(1, 1),

			create("ScrollingFrame")({
				Name = config.Name or "DropdownMenu",
				AutomaticSize = Enum.AutomaticSize.XY,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
				ScrollBarImageTransparency = 0.5,
				ScrollBarThickness = 3,

				__dynamicKeys = {
					BackgroundColor3 = theme.MenuBackground[1],
					BackgroundTransparency = theme.MenuBackground[2],
					ScrollBarImageColor3 = self.Theme.Controls.ScrollBar[1],
					ScrollBarImageTransparency = self.Theme.Controls.ScrollBar[2],
				},

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 6),
				}),

				create("UIStroke")({
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Transparency = 0.9,
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, 5),
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
				}),

				create("UIListLayout")({
					Name = "UIListLayout",
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 1),
				}),
			}),
		}),
	}) :: ScreenGui

	structures.Body = structures.Container:FindFirstChild("MenuBody") :: CanvasGroup
	structures.Menu = structures.Body:FindFirstChild(config.Name or "DropdownMenu") :: ScrollingFrame

	--// Public Methods
	function structures.Item(name: string?, index: number, showsCheckmark: boolean?): TextButton
		local item = nil
		item = create("TextButton")({
			Name = "Item",
			Size = UDim2.fromScale(1, 0),
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Selectable = false,
			Text = "",
			LayoutOrder = index,
			Parent = structures.Menu,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.SelectionFocused[1],
			},
			__contextKeys = {
				BackgroundTransparency = function()
					if not item then
						return
					end
					return item.GuiState == Enum.GuiState.Hover and self.Theme.Controls.SelectionFocused[2].Value or 1
				end,
			},

			create("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0, 3),
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 3),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 1,
				RichText = true,
				Text = name or "",
				TextColor3 = Color3.fromRGB(0, 0, 0),
				TextSize = 15,
				TextTransparency = 0.15,
				TextTruncate = Enum.TextTruncate.AtEnd,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 5),
			}),
		}) :: TextButton

		if showsCheckmark then
			create("ImageLabel")({
				Name = "Checkmark",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://127464789357538",
				ImageColor3 = Color3.fromRGB(0, 0, 0),
				ImageTransparency = 1,
				Size = UDim2.fromOffset(16, 16),
				Visible = false,
				Parent = item.__instance,

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Primary[1],
					ImageTransparency = self.Theme.Text.Primary[2],
				},
			})

			create("Frame")({
				Name = "CheckmarkRepl",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(16, 16),
				Visible = true,
				Parent = item.__instance,
			})
		end

		return item.__instance
	end

	--// Publish
	return structures
end
end function __DIST.H():typeof(__modImpl())local v=__DIST.cache.H if not v then v={c=__modImpl()}__DIST.cache.H=v end return v.c end end do local function __modImpl()--// Imports

local createStructure = __DIST.H()
local services = __DIST.e()
local utility = __DIST.a()

--// Constants












local EDGE_BUFFER = 6
local HORIZONTAL_OFFSET = -1
local PULLDOWN_GAP = 6

--// Variables
local DropdownMenu = {}
DropdownMenu.__index = DropdownMenu

local userInputService = services.UserInputService
local tweenService = services.TweenService
local workspace = services.Workspace
local guiService = services.GuiService

--// Private Methods
local function unwrap(object)
	if typeof(object) == "table" then
		local success, instance = pcall(function()
			return object.__instance
		end)

		if success and typeof(instance) == "Instance" then
			return instance
		end
	end

	return object
end

local function pointInside(guiObject: GuiObject?, x: number, y: number): boolean
	if not guiObject then
		return false
	end

	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize

	return x >= position.X
		and x <= position.X + size.X
		and y >= position.Y
		and y <= position.Y + size.Y
end

local function firstSelectedIndex(value): number?
	if typeof(value) == "table" then
		return value[1]
	end

	if typeof(value) == "number" then
		return value
	end

	return nil
end

local function readAnchorValue(anchor, key)
	if typeof(anchor) ~= "table" then
		return nil
	end

	return anchor[key]
end

local function mountMenuContainer(container): boolean
	local instance = unwrap(container)

	if typeof(instance) ~= "Instance" then
		return false
	end

	if instance.Parent then
		return true
	end

	return typeof(utility.ProtectUI(instance)) == "Instance"
end

--// Public Methods
function DropdownMenu.new(context, componentStructures, config: DropdownMenuConfig__DARKLUA_TYPE_ah?)
	config = config or {}

	local menuStructures = createStructure(context, {
		Name = config.Name,
	})

	componentStructures.MenuContainer = menuStructures.Container.__instance
	componentStructures.MenuBody = menuStructures.Body
	componentStructures.Menu = menuStructures.Menu
	componentStructures.Options = componentStructures.Options or {}

	local self = setmetatable({
		Context = context,
		Structures = componentStructures,
		MenuStructures = menuStructures,
		Object = nil,
		Anchor = config.Anchor,
		AnchorMode = config.AnchorMode or "BelowButton",
		Gap = config.Gap or PULLDOWN_GAP,
		MaxHeight = config.MaxHeight,
		ShowsCheckmarks = config.ShowsCheckmarks == true,
		AutoScroll = config.AutoScroll ~= false,
		OnSelected = config.OnSelected,
		SelectedValue = nil,
		Tween = nil,
		TweenToken = 0,
		Bound = false,
	}, DropdownMenu)

	return self
end

function DropdownMenu:SetObject(object)
	self.Object = object
	self:Bind()
end

function DropdownMenu:SetAnchor(anchor)
	self.Anchor = anchor
	self:AnchorMenu()
end

function DropdownMenu:SetAnchorMode(anchorMode: string)
	self.AnchorMode = anchorMode
	self:AnchorMenu()
end

function DropdownMenu:SetValue(value)
	self.SelectedValue = value
	self:AnchorMenu()
end

function DropdownMenu:GetAnchorElement(): GuiObject?
	local anchor = self.Anchor
	local anchorInstance = unwrap(anchor)

	if typeof(anchorInstance) == "Instance" then
		return anchorInstance
	end

	local anchorElement = readAnchorValue(anchor, "Object")
		or readAnchorValue(anchor, "Element")
		or readAnchorValue(anchor, "Label")
		or self.Structures.CurrentTab
		or self.Structures.Body

	return unwrap(anchorElement)
end

function DropdownMenu:GetAnchorOption(): number
	return readAnchorValue(self.Anchor, "Option") or firstSelectedIndex(self.SelectedValue) or 1
end

function DropdownMenu:GetAnchorOffsets(): (number, number)
	local anchor = self.Anchor
	local offset = readAnchorValue(anchor, "Offset")
	local xOffset = readAnchorValue(anchor, "XOffset") or 0
	local yOffset = readAnchorValue(anchor, "YOffset") or 0

	if typeof(offset) == "Vector2" then
		xOffset += offset.X
		yOffset += offset.Y
	end

	return xOffset, yOffset
end

function DropdownMenu:GetOptionLabel(index: number): TextLabel?
	local option = self.Structures.Options[index]

	if not option then
		return nil
	end

	return option:FindFirstChild("Label") :: TextLabel?
end

function DropdownMenu:ScrollToAnchorOption()
	local menu = self.Structures.Menu

	if not menu then
		return
	end

	local option = self.Structures.Options[self:GetAnchorOption()]
	local contentHeight = menu.AbsoluteCanvasSize.Y
	local viewportHeight = menu.AbsoluteSize.Y
	local maxCanvasY = math.max(0, contentHeight - viewportHeight)

	if not option or maxCanvasY <= 0 then
		menu.CanvasPosition = Vector2.new(menu.CanvasPosition.X, 0)
		return
	end

	local optionY = option.AbsolutePosition.Y - menu.AbsolutePosition.Y + menu.CanvasPosition.Y
	local optionHeight = option.AbsoluteSize.Y
	local desiredCanvasY = optionY - ((viewportHeight - optionHeight) / 2)

	menu.CanvasPosition = Vector2.new(menu.CanvasPosition.X, math.clamp(desiredCanvasY, 0, maxCanvasY))
end

function DropdownMenu:Resize()
	local menu = self.Structures.Menu

	if not menu then
		return
	end

	menu.AutomaticSize = Enum.AutomaticSize.XY

	if not self.MaxHeight then
		return
	end

	task.defer(function()
		if not menu then
			return
		end

		local menuHeight = menu.AbsoluteSize.Y

		if menuHeight >= self.MaxHeight then
			menu.AutomaticSize = Enum.AutomaticSize.X
			menu.Size = UDim2.fromOffset(0, self.MaxHeight)
		else
			menu.Size = UDim2.fromOffset(0, menuHeight)
			menu.AutomaticSize = Enum.AutomaticSize.X
		end

		self:AnchorMenu()
	end)
end

function DropdownMenu:AnchorMenu()
	local body = unwrap(self.Structures.Body)
	local menu = self.Structures.Menu
	local menuParent = menu and menu.Parent

	if not menu or not body or not menuParent then
		return
	end

	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	if self.AutoScroll then
		self:ScrollToAnchorOption()
	end

	local bodyPosition = body.AbsolutePosition
	local bodySize = body.AbsoluteSize
	local menuPosition = menu.AbsolutePosition
	local parentPosition = menuParent.AbsolutePosition
	local menuSize = menu.AbsoluteSize
	local viewportSize = camera.ViewportSize
	local desiredScreenX = bodyPosition.X + bodySize.X - menuSize.X + HORIZONTAL_OFFSET
	local desiredScreenY = bodyPosition.Y + bodySize.Y + self.Gap
	local xOffset, yOffset = self:GetAnchorOffsets()

	if self.AnchorMode == "SelectedLabel" then
		local anchorElement = self:GetAnchorElement()
		local optionLabel = self:GetOptionLabel(self:GetAnchorOption())

		if anchorElement and optionLabel then
			local labelOffset = optionLabel.AbsolutePosition - menuPosition

			desiredScreenX = anchorElement.AbsolutePosition.X - labelOffset.X
			desiredScreenY = anchorElement.AbsolutePosition.Y - labelOffset.Y
		elseif anchorElement then
			desiredScreenX = anchorElement.AbsolutePosition.X + HORIZONTAL_OFFSET
			desiredScreenY = anchorElement.AbsolutePosition.Y
		end
	end

	desiredScreenX += xOffset
	desiredScreenY += yOffset

	local maxX = math.max(EDGE_BUFFER, viewportSize.X - EDGE_BUFFER - menuSize.X)
	local maxY = math.max(EDGE_BUFFER, viewportSize.Y - EDGE_BUFFER - menuSize.Y)

	desiredScreenX = math.clamp(desiredScreenX, EDGE_BUFFER, maxX)
	desiredScreenY = math.clamp(desiredScreenY, EDGE_BUFFER, maxY)

	menu.Position = UDim2.fromOffset(desiredScreenX - parentPosition.X, desiredScreenY - parentPosition.Y)
end

function DropdownMenu:SetExpanded(value: boolean)
	local expand = value == true
	local body = unwrap(self.Structures.Body)
	local container = unwrap(self.Structures.MenuContainer)

	self.TweenToken += 1
	local tweenToken = self.TweenToken

	if self.Tween then
		self.Tween:Cancel()
		self.Tween = nil
	end

	if expand and body then
		self.Structures.MenuBody.GroupTransparency = 1

		if not mountMenuContainer(self.Structures.MenuContainer) then
			return
		end
	elseif not expand and container and not container.Parent then
		self.Structures.MenuBody.GroupTransparency = 1
		return
	end

	self:Resize()
	self:AnchorMenu()
	task.defer(function()
		self:AnchorMenu()
	end)

	local goal = { GroupTransparency = expand and 0 or 1 }
	local tweenInfo = TweenInfo.new(expand and 0 or 0.4, Enum.EasingStyle.Exponential)
	local tween = tweenService:Create(self.Structures.MenuBody, tweenInfo, goal)

	self.Tween = tween
	tween:Play()
	tween.Completed:Connect(function(playbackState)
		if tweenToken ~= self.TweenToken then
			return
		end

		if self.Tween == tween then
			self.Tween = nil
		end

		if playbackState ~= Enum.PlaybackState.Completed then
			return
		end

		if not expand and self.Object and self.Object.Expanded == false then
			self.Structures.MenuContainer.Parent = nil
		end
	end)
end

function DropdownMenu:SetSelectedMap(selected)
	if not self.ShowsCheckmarks then
		return
	end

	for index, option in ipairs(self.Structures.Options) do
		if not option then
			continue
		end

		local checkmark = option:FindFirstChild("Checkmark")
		local checkmarkReplacement = option:FindFirstChild("CheckmarkRepl")
		local isSelected = selected[index] == true

		if checkmark then
			checkmark.Visible = isSelected
		end

		if checkmarkReplacement then
			checkmarkReplacement.Visible = not isSelected
		end
	end
end

function DropdownMenu:ResetItemColors(option: TextButton)
	local label = option:FindFirstChild("Label")
	local checkmark = option:FindFirstChild("Checkmark")

	option.BackgroundTransparency = 1

	if label then
		label.TextColor3 = self.Context.Theme.Text.Primary[1].Value
		label.TextTransparency = self.Context.Theme.Text.Primary[2].Value
	end

	if checkmark then
		checkmark.ImageColor3 = self.Context.Theme.Text.Primary[1].Value
		checkmark.ImageTransparency = self.Context.Theme.Text.Primary[2].Value
	end
end

function DropdownMenu:HighlightItem(option: TextButton)
	local label = option:FindFirstChild("Label")
	local checkmark = option:FindFirstChild("Checkmark")

	option.BackgroundTransparency = self.Context.Theme.Controls.SelectionFocused[2].Value

	if label then
		label.TextColor3 = self.Context.Theme.Controls.SelectionFocusedAccent[1].Value
		label.TextTransparency = self.Context.Theme.Controls.SelectionFocusedAccent[2].Value
	end

	if checkmark then
		checkmark.ImageColor3 = self.Context.Theme.Controls.SelectionFocusedAccent[1].Value
		checkmark.ImageTransparency = self.Context.Theme.Controls.SelectionFocusedAccent[2].Value
	end
end

function DropdownMenu:AddOption(name: string?, index: number): TextButton
	local option = self.MenuStructures.Item(name, index, self.ShowsCheckmarks)

	self.Structures.Options[index] = option

	option:GetPropertyChangedSignal("GuiState"):Connect(function()
		if not self.Object or not self.Object.Expanded then
			return
		end

		if option.GuiState == Enum.GuiState.Hover then
			self:HighlightItem(option)
		else
			self:ResetItemColors(option)
		end
	end)

	option.MouseButton1Click:Connect(function()
		if self.OnSelected and self.Object then
			self.OnSelected(self.Object, index)
		end
	end)

	self:Resize()
	task.defer(function()
		self:AnchorMenu()
	end)

	return option
end

function DropdownMenu:ClearOptions()
	for _, option in ipairs(self.Structures.Options) do
		option:Destroy()
	end

	table.clear(self.Structures.Options)
	self:Resize()
end

function DropdownMenu:RemoveOption(index: number?)
	if index and self.Structures.Options[index] then
		self.Structures.Options[index]:Destroy()
		self.Structures.Options[index] = nil
	end

	self:Resize()
end

function DropdownMenu:Bind()
	if self.Bound then
		return
	end

	self.Bound = true

	self.Structures.Body:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:AnchorMenu()
	end)
	self.Structures.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:AnchorMenu()
	end)
	self.Structures.Menu:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:AnchorMenu()
	end)

	userInputService.InputBegan:Connect(function(input)
		if
			not self.Object
			or not self.Object.Expanded
			or (
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			)
		then
			return
		end

		local mouse = userInputService:GetMouseLocation()
		local inset = guiService:GetGuiInset()
		local adjustedY = mouse.Y - inset.Y
		local body = unwrap(self.Structures.Body)
		local insideBody = pointInside(body, mouse.X, adjustedY) or pointInside(body, mouse.X, mouse.Y)

		if
			not pointInside(self.Structures.Menu, mouse.X, adjustedY)
			and not insideBody
		then
			self.Object.Expanded = false
		end
	end)

	self.Structures.Body.MouseButton1Click:Connect(function()
		if self.Object then
			self.Object.Expanded = not self.Object.Expanded
		end
	end)
end

--// Publish
return DropdownMenu
end function __DIST.I():typeof(__modImpl())local v=__DIST.cache.I if not v then v={c=__modImpl()}__DIST.cache.I=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: PopUpButtonProperties__DARKLUA_TYPE_7): PopUpButton__DARKLUA_TYPE_8	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()
	local dropdownMenu = __DIST.I()

	--// References
	local create = creator.Create

	--// Constants
	local MAX_DISPLAY_LENGTH = 30

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.MenuButton
	local structures = {
		Options = {},
	}

	--// Private Methods
	local function truncate(text: string): string
		if #text > MAX_DISPLAY_LENGTH then
			return string.sub(text, 1, MAX_DISPLAY_LENGTH) .. "..."
		end

		return text
	end

	local function selectedMap(value)
		local map = {}

		if typeof(value) == "table" then
			for _, optionIndex in ipairs(value) do
				map[optionIndex] = true
			end
		elseif value then
			map[value] = true
		end

		return map
	end

	local function selectedLabels(value)
		local labels = {}
		local map = selectedMap(value)

		for index, option in ipairs(structures.Options) do
			local label = option and option:FindFirstChild("Label")
			if map[index] and label then
				table.insert(labels, label.Text)
			end
		end

		return labels
	end

	--// UI
	properties = properties or {}
	properties.Maximum = properties.Maximum or 1
	properties.Expanded = properties.Expanded or false
	properties.Options = properties.Options or {}

	structures.Body = binder.Apply(
		properties,
		create("TextButton")({
			Name = "PopUpButton",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Selectable = false,
			Text = "",
			Parent = parent,

			create("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0, 3),
				PaddingLeft = UDim.new(0, 3),
				PaddingRight = UDim.new(0, 3),
				PaddingTop = UDim.new(0, 3),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 7),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("Frame")({
				Name = "PopUpIndicator",
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Selectable = true,
				Size = UDim2.fromOffset(16, 16),

				__dynamicKeys = {
					BackgroundColor3 = theme.IndicatorBackground[1],
					BackgroundTransparency = theme.IndicatorBackground[2],
				},

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 4),
				}),

				create("ImageLabel")({
					Name = "Indicators",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://89151647333378",
					Size = UDim2.fromScale(1, 1),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Text.Primary[1],
						ImageTransparency = self.Theme.Text.Primary[2],
					},
				}),
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				RichText = true,
				Text = "None",
				TextSize = 15,
				TextTransparency = 0.15,
				TextTruncate = Enum.TextTruncate.AtEnd,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),
		})
	) :: TextButton

	--// Initialize
	structures.PopUpIndicator = structures.Body:FindFirstChild("PopUpIndicator") :: Frame
	structures.CurrentTab = structures.Body:FindFirstChild("Label") :: TextLabel

	local object
	local menu = dropdownMenu.new(self, structures, {
		Name = "PopUpMenu",
		Anchor = properties.Anchor,
		AnchorMode = "SelectedLabel",
		ShowsCheckmarks = true,
		MaxHeight = 239,
		OnSelected = function(target, index)
			if target.Maximum and target.Maximum > 1 then
				local current = target.Value or {}
				if typeof(current) ~= "table" then
					current = current and { current } or {}
				else
					current = table.clone(current)
				end

				local foundIndex = nil
				for currentIndex, value in ipairs(current) do
					if value == index then
						foundIndex = currentIndex
						break
					end
				end

				if foundIndex then
					table.remove(current, foundIndex)
				else
					if #current < target.Maximum then
						table.insert(current, index)
					else
						table.remove(current, 1)
						table.insert(current, index)
					end
				end

				target.Value = current
			else
				target.Expanded = false
				task.wait(0.2)
				target.Value = index
			end
		end,
	})

	local function updateValue(value, fireChanged: boolean)
		local isMulti = object and object.Maximum and object.Maximum > 1

		menu:SetAnchorMode(isMulti and "BelowButton" or "SelectedLabel")
		menu:SetValue(value)

		if isMulti then
			local labels = selectedLabels(value)

			if #labels == 0 then
				structures.CurrentTab.Text = "None"
			else
				structures.CurrentTab.Text = truncate(table.concat(labels, ", "))
			end

			menu:SetSelectedMap(selectedMap(value))
		else
			local optionLabel = value and structures.Options[value] and structures.Options[value]:FindFirstChild("Label")

			if not optionLabel then
				structures.CurrentTab.Text = "None"
			else
				structures.CurrentTab.Text = truncate(optionLabel.Text)
			end

			menu:SetSelectedMap(selectedMap(value))
		end

		if fireChanged and properties.ValueChanged then
			properties.Value = value
			task.spawn(properties.ValueChanged, object, value)
		end
	end

	local bindings = {
		Anchor = function(value)
			menu:SetAnchor(value)
		end,

		Options = function(value: { [number]: string })
			menu:ClearOptions()

			for index, optionName in ipairs(value) do
				menu:AddOption(optionName, index)
			end

			if object then
				updateValue(object.Value, false)
			end
		end,

		Expanded = function(value: boolean)
			menu:SetAnchorMode(object and object.Maximum and object.Maximum > 1 and "BelowButton" or "SelectedLabel")
			menu:SetExpanded(value)
		end,

		Value = function(value)
			updateValue(value, true)
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	menu:SetObject(object)

	object.Type = "PopUpButton"
	object.Theme = self.Theme
	object.Structures = structures
	object.Option = function(self, name: string?)
		local index = #structures.Options + 1
		local option = menu:AddOption(name, index)

		table.insert(object.Options, name)
		updateValue(object.Value, false)

		return option
	end
	object.Remove = function(self, index: number?)
		if index then
			menu:RemoveOption(index)
			object.Options[index] = nil
			updateValue(object.Value, false)
		end
	end

	binder.Apply(properties, object)
	updateValue(object.Value, false)

	return object
end
end function __DIST.J():typeof(__modImpl())local v=__DIST.cache.J if not v then v={c=__modImpl()}__DIST.cache.J=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: PullDownButtonProperties__DARKLUA_TYPE_9): PullDownButton__DARKLUA_TYPE_aa	--// Imports
	
local creator = __DIST.d()
	local binder = __DIST.c()
	local dropdownMenu = __DIST.I()

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.MenuButton
	local structures = {
		Options = {},
	}

	--// UI
	properties = properties or {}
	properties.Expanded = properties.Expanded or false
	properties.Options = properties.Options or {}

	structures.Body = binder.Apply(
		properties,
		create("TextButton")({
			Name = "PullDownButton",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Selectable = false,
			Text = "",
			Parent = parent,

			create("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0, 3),
				PaddingLeft = UDim.new(0, 7),
				PaddingRight = UDim.new(0, 3),
				PaddingTop = UDim.new(0, 3),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 7),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("Frame")({
				Name = "PullDownIndicator",
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Selectable = true,
				Size = UDim2.fromOffset(16, 16),

				__dynamicKeys = {
					BackgroundColor3 = theme.IndicatorBackground[1],
					BackgroundTransparency = theme.IndicatorBackground[2],
				},

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 4),
				}),

				create("ImageLabel")({
					Name = "Indicators",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://86693411280110",
					Size = UDim2.fromScale(1, 1),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Text.Primary[1],
						ImageTransparency = self.Theme.Text.Primary[2],
					},
				}),
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				RichText = true,
				TextSize = 15,
				TextTransparency = 0.15,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Visible = false,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),
		})
	) :: TextButton

	--// Initialize
	structures.PullDownIndicator = structures.Body:FindFirstChild("PullDownIndicator") :: Frame
	structures.CurrentTab = structures.Body:FindFirstChild("Label") :: TextLabel

	local object
	local menu = dropdownMenu.new(self, structures, {
		Name = "PullDownMenu",
		Anchor = properties.Anchor,
		AnchorMode = "BelowButton",
		Gap = 6,
		MaxHeight = 239,
		AutoScroll = false,
		OnSelected = function(target, index)
			target.Expanded = false
			target.Value = index
		end,
	})

	local bindings = {
		Anchor = function(value)
			menu:SetAnchor(value)
		end,

		Options = function(value: { [number]: string })
			menu:ClearOptions()

			for index, optionName in ipairs(value) do
				menu:AddOption(optionName, index)
			end
		end,

		Expanded = function(value: boolean)
			menu:SetExpanded(value)
		end,

		Label = function(value: string)
			if type(value) == "string" then
				structures.CurrentTab.Visible = true
				structures.CurrentTab.Text = value
			end
		end,

		Value = function(value: number)
			menu:SetValue(value)

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	menu:SetObject(object)

	object.Type = "PullDownButton"
	object.Theme = self.Theme
	object.Structures = structures
	object.Option = function(self, name: string?)
		local index = #structures.Options + 1
		local option = menu:AddOption(name, index)

		table.insert(object.Options, name)

		return option
	end
	object.Remove = function(self, index: number?)
		if index then
			menu:RemoveOption(index)
			object.Options[index] = nil
		end
	end

	binder.Apply(properties, object)
	menu:SetValue(object.Value)

	return object
end
end function __DIST.K():typeof(__modImpl())local v=__DIST.cache.K if not v then v={c=__modImpl()}__DIST.cache.K=v end return v.c end end do local function __modImpl()
local notificationList = {}

local services = __DIST.e()
local tweenService = services.TweenService

local activeNotifications = {}
local MAX_NOTIFICATIONS = 4
local STACK_OFFSET_Y = -12
local SCALE_DECREMENT = 0.05

function notificationList.AddNotification(notificationObj, frame)
	if #activeNotifications >= MAX_NOTIFICATIONS then
		local oldest = table.remove(activeNotifications, 1)
		if oldest and oldest.Object and oldest.Object.Close then
			oldest.Object:Close()
		end
	end

	table.insert(activeNotifications, {
		Object = notificationObj,
		Frame = frame,
	})

	notificationList.UpdateStack()
end

function notificationList.UpdateStack()
	local total = #activeNotifications

	for i = 1, total do
		local notif = activeNotifications[i]
		local frame = notif.Frame.__instance

		if not frame or not frame.Parent then
			continue
		end

		local age = total - i

		local targetScale = 1 - (age * SCALE_DECREMENT)
		local targetY = (age * STACK_OFFSET_Y)

		frame.ZIndex = 100 - age

		local baseOffsetX = -162.5
		local baseOffsetY = 0
		local endOffsetY = baseOffsetY + targetY

		local scaleObj = frame:FindFirstChild("UIScale")

		if age > 0 then
			if scaleObj then
				tweenService
					:Create(scaleObj, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						Scale = targetScale,
					})
					:Play()
			end

			tweenService
				:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, baseOffsetX, 1, endOffsetY),
				})
				:Play()

			if notif.Object.UpdateState then
				notif.Object:UpdateState(age)
			end
		else
			if scaleObj then
				tweenService
					:Create(scaleObj, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						Scale = 1,
					})
					:Play()
			end

			tweenService
				:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, baseOffsetX, 1, baseOffsetY),
				})
				:Play()

			if notif.Object.UpdateState then
				notif.Object:UpdateState(age)
			end
		end
	end
end

function notificationList.RemoveNotification(notificationObj)
	for i, notif in ipairs(activeNotifications) do
		if notif.Object == notificationObj then
			table.remove(activeNotifications, i)
			break
		end
	end

	notificationList.UpdateStack()
end

return notificationList
end function __DIST.L():typeof(__modImpl())local v=__DIST.cache.L if not v then v={c=__modImpl()}__DIST.cache.L=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self: any, properties: NotificationProperties__DARKLUA_TYPE_ab, state: { Age: number }, MAX_NOTIFICATIONS: number)
	local creator = __DIST.d()

	local create = creator.Create

	local notificationsContainer = self.__instance:FindFirstChild("Notifications")
	if not notificationsContainer then
		notificationsContainer = create("Frame")({
			Name = "Notifications",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 200,
			Parent = self.__instance,

			create("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),
		}).__instance
	end

	local body = create("Frame")({
		Name = "Notification",
		AnchorPoint = Vector2.new(0.5, 1),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Position = UDim2.new(1, -162.5, 1, 0),
		Size = UDim2.fromOffset(325, 0),
		Parent = notificationsContainer,

		create("Frame")({
			Name = "Canvas",
			AnchorPoint = Vector2.new(0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = self.Theme.Controls.Sidebar[1].Value,
			BackgroundTransparency = 0.1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, 0),
			Size = UDim2.fromScale(1, 0),

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Sidebar[1],
			},

			__contextKeys = {
				BackgroundTransparency = function()
					return state.Age >= (MAX_NOTIFICATIONS - 1) and 1 or 0.1
				end,
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 12),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 5),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("Frame")({
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 0, 68),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0),

				create("Frame")({
					Name = "TitleContainer",
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = 1,

					create("UIListLayout")({
						Name = "UIListLayout",
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, 5),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					create("ImageLabel")({
						Name = "Icon",
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						Size = UDim2.fromOffset(18, 18),
						Visible = false,

						__dynamicKeys = {
							ImageColor3 = self.Theme.Text.Primary[1],
						},
						__contextKeys = {
							ImageTransparency = function()
								return state.Age >= (MAX_NOTIFICATIONS - 1) and 1 or self.Theme.Text.Primary[2].Value
							end,
						},
					}),

					create("TextLabel")({
						Name = "Title",
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						LayoutOrder = 2,
						FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
						LineHeight = 0,
						Size = UDim2.new(1, 0, 0, 20),
						Text = properties.Title,
						TextColor3 = self.Theme.Text.Primary[1].Value,
						TextSize = 13,
						TextTransparency = self.Theme.Text.Primary[2].Value,
						TextWrapped = true,
						RichText = true,
						TextXAlignment = Enum.TextXAlignment.Left,

						__dynamicKeys = {
							TextColor3 = self.Theme.Text.Primary[1],
							TextTransparency = self.Theme.Text.Primary[2],
						},

						__contextKeys = {
							TextTransparency = function()
								return state.Age >= (MAX_NOTIFICATIONS - 1) and 1 or self.Theme.Text.Primary[2].Value
							end,
						},
					}),
				}),

				create("UIListLayout")({
					Name = "UIListLayout",
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				create("TextLabel")({
					Name = "Subtitle",
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					FontFace = Font.new("rbxassetid://12187365364"),
					LayoutOrder = 1,
					Position = UDim2.fromScale(0, 0.147),
					RichText = true,
					Size = UDim2.fromScale(1, 0),
					Text = properties.Subtitle,
					TextColor3 = self.Theme.Text.Secondary[1].Value,
					TextSize = 13,
					TextTransparency = self.Theme.Text.Secondary[2].Value,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					Visible = properties.Subtitle ~= "",

					__dynamicKeys = {
						TextColor3 = self.Theme.Text.Secondary[1],
						TextTransparency = self.Theme.Text.Secondary[2],
					},

					__contextKeys = {
						TextTransparency = function()
							return state.Age >= (MAX_NOTIFICATIONS - 1) and 1 or self.Theme.Text.Secondary[2].Value
						end,
					},
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, 12),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),
			}),

			create("Frame")({
				Name = "Topbar",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 0),
				Visible = (properties.App ~= nil) or (properties.AppIcon ~= nil),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				create("TextLabel")({
					Name = "App",
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
					LayoutOrder = 1,
					LineHeight = 0,
					Size = UDim2.fromOffset(0, 14),
					Text = properties.App or "",
					TextColor3 = self.Theme.Text.Primary[1].Value,
					TextSize = 13,
					TextTransparency = 0.5,
					TextXAlignment = Enum.TextXAlignment.Left,
					RichText = true,
					Visible = properties.App ~= nil,

					__dynamicKeys = {
						TextColor3 = self.Theme.Text.Primary[1],
					},
				}),

				create("ImageLabel")({
					Name = "Icon",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = properties.AppIcon or "",
					ImageColor3 = self.Theme.Text.Primary[1].Value,
					Size = UDim2.fromOffset(20, 20),
					Visible = properties.AppIcon ~= nil,

					__dynamicKeys = {
						ImageColor3 = self.Theme.Text.Primary[1],
					},
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					PaddingTop = UDim.new(0, 12),
				}),
			}),
		}),

		create("Folder")({
			Name = "LayoutIgnore",

			create("TextButton")({
				Name = "Exit",
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutoButtonColor = false,
				BackgroundColor3 = self.Theme.Controls.View[1].Value,
				BackgroundTransparency = 0.1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				Position = UDim2.fromOffset(3, 3),
				Size = UDim2.fromOffset(20, 20),
				Text = "",
				TextColor3 = self.Theme.Text.Primary[1].Value,
				TextSize = 14,
				TextTransparency = 0.5,

				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.View[1],
				},

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(1, 0),
				}),

				create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "rbxassetid://72660323302468",
					ImageColor3 = self.Theme.Text.Primary[1].Value,
					ImageTransparency = 0.5,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(20, 20),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Text.Primary[1],
					},
				}),

				create("Frame")({
					Name = "Shadow",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Transparency = 0.9,
					}),

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(1, 0),
					}),
				}),

				create("UIStroke")({
					Name = "UIStroke",
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = self.Theme.Text.Primary[1].Value,
					Thickness = 2,
					Transparency = 0.96,

					__dynamicKeys = {
						Color = self.Theme.Text.Primary[1],
					},
				}),
			}),
		}),

		create("UIScale")({
			Name = "UIScale",
			Scale = 0.85,
		}),
	}) :: Frame

	local exitBtn = body.LayoutIgnore.Exit
	local canvas = body.Canvas
	local content = canvas.Content
	local topbar = canvas.Topbar

	return body, exitBtn, canvas, content, topbar
end
end function __DIST.M():typeof(__modImpl())local v=__DIST.cache.M if not v then v={c=__modImpl()}__DIST.cache.M=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: NotificationProperties__DARKLUA_TYPE_ab): Notification__DARKLUA_TYPE_ac	
local services = __DIST.e()
	local binder = __DIST.c()
	local notificationList = __DIST.L()
	local ui = __DIST.M()

	local tweenService = services.TweenService

	properties = properties or {}
	properties.Title = properties.Title or "Notification"
	properties.Subtitle = properties.Subtitle or ""
	properties.Duration = properties.Duration or 6

	if properties.App then
		properties.App = string.upper(properties.App)
	end

	local closed = false
	local MAX_NOTIFICATIONS = 4
	local state = { Age = 0 }

	local body, exitBtn, canvas, content, topbar = ui(self, properties, state, MAX_NOTIFICATIONS)

	local bindings = {
		Title = function(value: string)
			content.TitleContainer.Title.Text = value
		end,
		Subtitle = function(value: string)
			content.Subtitle.Text = value
			content.Subtitle.Visible = value ~= ""
		end,
		App = function(value: string)
			local upperValue = string.upper(value or "")
			topbar.App.Text = upperValue
			topbar.App.Visible = value ~= nil
			topbar.Visible = (value ~= nil) or (properties.AppIcon ~= nil)

			if properties.App ~= upperValue then
				properties.App = upperValue
			end
		end,
		AppIcon = function(value: string)
			topbar.Icon.Image = value or ""
			topbar.Icon.Visible = value ~= nil
			topbar.Visible = (properties.App ~= nil) or (value ~= nil)
		end,
		Icon = function(value: string)
			if value then
				content.TitleContainer.Icon.Image = value
			end
			content.TitleContainer.Icon.Visible = value ~= nil
		end,
	}

	local object = binder.Wrap(properties, bindings, body, { "App", "Icon" })

	object.Type = "Notification"
	object.Theme = self.Theme

	binder.Apply(properties, object)

	local function closeNotification(fromUserInput: boolean?)
		if closed then
			return
		end
		closed = true

		if not body.Parent then
			return
		end

		if properties.Closed then
			task.spawn(properties.Closed, object, fromUserInput)
		end

		local fadeTween = tweenService:Create(
			object.__instance,
			TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				Position = object.__instance.Position + UDim2.fromOffset(350, 0),
			}
		)

		object:UpdateState(MAX_NOTIFICATIONS, false)

		local scale = object.__instance:FindFirstChild("UIScale")
		if scale then
			tweenService
				:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Scale = 0.85,
				})
				:Play()
		end

		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			if body.Parent then
				notificationList.RemoveNotification(object)
				body:Destroy()
			end
		end)
	end

	exitBtn.MouseButton1Click:Connect(function()
		closeNotification(true)
	end)

	function object:Close(fromUserInput: boolean?)
		closeNotification(fromUserInput)
	end

	function object:UpdateState(age: number, instant: boolean?)
		state.Age = age

		local isFaded = age >= (MAX_NOTIFICATIONS - 1)
		local isPrimary = age == 0

		local exitBgFade = isPrimary and 0.1 or 1
		local exitStrokeFade = isPrimary and 0.96 or 1
		local exitShadowFade = isPrimary and 0.9 or 1
		local exitIconFade = isPrimary and 0.5 or 1

		if isFaded then
			exitBgFade = 1
			exitStrokeFade = 1
			exitShadowFade = 1
			exitIconFade = 1
		end

		local targetBgTransparency = isFaded and 1 or 0.1

		local function apply(inst, props)
			if instant then
				for k, v in pairs(props) do
					inst[k] = v
				end
			else
				tweenService
					:Create(inst, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), props)
					:Play()
			end
		end

		apply(canvas, { BackgroundTransparency = targetBgTransparency })

		for _, descendant in ipairs(canvas:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				local targetTextTransparency = 1
				if not isFaded then
					if descendant.Name == "Title" then
						targetTextTransparency = self.Theme.Text.Primary[2].Value
					elseif descendant.Name == "Subtitle" then
						targetTextTransparency = self.Theme.Text.Secondary[2].Value
					elseif descendant.Name == "App" then
						targetTextTransparency = 0.5
					end
				end
				apply(descendant, { TextTransparency = targetTextTransparency })
			elseif descendant:IsA("ImageLabel") and descendant.Name ~= "Icon" then
				apply(descendant, { ImageTransparency = isFaded and 1 or 0 })
			end
		end

		if content:FindFirstChild("TitleContainer") and content.TitleContainer:FindFirstChild("Icon") then
			apply(content.TitleContainer.Icon, { ImageTransparency = isFaded and 1 or 0 })
		end
		if topbar:FindFirstChild("Icon") then
			apply(topbar.Icon, { ImageTransparency = isFaded and 1 or 0 })
		end

		apply(exitBtn, { BackgroundTransparency = exitBgFade })
		apply(exitBtn.Icon, { ImageTransparency = exitIconFade })
		apply(exitBtn.UIStroke, { Transparency = exitStrokeFade })

		local shadow = exitBtn:FindFirstChild("Shadow")
		if shadow and shadow:FindFirstChild("UIStroke") then
			apply(shadow.UIStroke, { Transparency = exitShadowFade })
		end
	end

	body.Position = UDim2.new(1, 187.5, 1, 0)

	object:UpdateState(0, true)

	notificationList.AddNotification(object, body)

	if body:FindFirstChild("UIScale") then
		body.UIScale.Scale = 0.85
		tweenService
			:Create(body.UIScale, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Scale = 1,
			})
			:Play()
	end

	tweenService
		:Create(body.__instance, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -162.5, 1, 0),
		})
		:Play()

	if properties.Duration > 0 then
		task.delay(properties.Duration, function()
			closeNotification()
		end)
	end

	return object
end
end function __DIST.N():typeof(__modImpl())local v=__DIST.cache.N if not v then v={c=__modImpl()}__DIST.cache.N=v end return v.c end end do local function __modImpl()
return function(self: any)
	--// Imports
	local creator = __DIST.d()

	--// Methods
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self

	--// Initialize
	local body = create("Frame")({
		Name = "ImageSurface",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(26, 26),
		Parent = parent,

		create("Frame")({
			Name = "Surface",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(200, 200, 200),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(24, 24),

			create("ImageLabel")({
				Name = "Image",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(20, 20),
			}),

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 5),
			}),

			create("UIGradient")({
				Name = "UIGradient",
				Rotation = 90,
                Enabled = true,

                __dynamicKeys = {
                    Color = self.Theme.Controls.ImageSurface.Gradient,
                },
			}),
		}),
	}) :: Frame

	local structures = {
		Body = body,
	}

    structures.Surface = body:FindFirstChild("Surface") :: Frame
    structures.Image = structures.Surface and structures.Surface:FindFirstChild("Image") :: ImageLabel
    structures.Gradient = structures.Surface and structures.Surface:FindFirstChild("UIGradient") :: UIGradient

	return structures
end
end function __DIST.O():typeof(__modImpl())local v=__DIST.cache.O if not v then v={c=__modImpl()}__DIST.cache.O=v end return v.c end end do local function __modImpl()
local types = __DIST.b()

return function(self, properties: ImageSurfaceProperties__DARKLUA_TYPE_ad): ImageSurface__DARKLUA_TYPE_ae	--// Imports
	
local binder = __DIST.c()

	local ui = __DIST.O()

	--// Variables
	local structures = ui(self)

	--// UI
	properties = properties or {}
	properties.SurfaceColor = properties.SurfaceColor or Color3.fromRGB(200, 200, 200)
	properties.ImageColor = properties.ImageColor or Color3.fromRGB(255, 255, 255)
	properties.Gradient = properties.Gradient ~= false

	--// Initialize
	local object
	local bindings = {
		Image = function(value: string)
			structures.Image.Image = value
		end,
		Gradient = function(value: boolean)
			structures.Gradient.Enabled = value
		end,
		SurfaceColor = function(value: Color3)
			structures.Surface.BackgroundColor3 = value
		end,
        ImageColor = function(value: Color3)
            structures.Image.ImageColor3 = value
        end
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "ImageSurface"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
end function __DIST.P():typeof(__modImpl())local v=__DIST.cache.P if not v then v={c=__modImpl()}__DIST.cache.P=v end return v.c end end do local function __modImpl()--// Imports

local binder = __DIST.c()
local appRecorder = __DIST.f()

--// Variables
local components = {
	Window = __DIST.n(),
	Section = __DIST.o(),
	Tab = __DIST.q(),
	PageSection = __DIST.s(),
	Form = __DIST.t(),
	Row = __DIST.u(),
	HStack = __DIST.v(),
	VStack = __DIST.w(),
	TitleStack = __DIST.x(),
	Label = __DIST.y(),
	Symbol = __DIST.z(),
	Toggle = __DIST.A(),
	TextField = __DIST.B(),
	KeybindField = __DIST.C(),
	Slider = __DIST.D(),
	Button = __DIST.E(),
	Stepper = __DIST.F(),
	RadioButtonGroup = __DIST.G(),
	PopUpButton = __DIST.J(),
	PullDownButton = __DIST.K(),
	Page = __DIST.p()
,
	Notification = __DIST.N(),
	ImageSurface = __DIST.P(),
}

--// Initialize
local function traceback(message)
	if debug and debug.traceback then
		return debug.traceback(message)
	end

	return tostring(message)
end

local function wrap(name, make)
	return function(self, ...)
		local args = table.pack(...)
		local recorder = appRecorder.FromContext(self)
		local recordNode = recorder and recorder:_Begin(self, name, args[1])
		local ok, result, raw = xpcall(function()
			return make(self, table.unpack(args, 1, args.n))
		end, traceback)

		if not ok then
			if recorder then
				recorder:_Cancel(recordNode)
			end

			error(result, 2)
		end

		if
			typeof(result) == "Instance"
			or (typeof(result) == "table" and getmetatable(result) and typeof(getmetatable(result)) == "Instance")
		then
			raw = result
			result = binder.Wrap({}, {}, result)
		end

		if typeof(result) == "table" then
			if result.Type == nil then
				result.Type = name
			end

			if result.Theme == nil and self and self.Theme then
				result.Theme = self.Theme
			end
		end

		binder.Apply(components, result)

		local final = raw
			or (
				typeof(result) == "table"
				and pcall(function()
					return result.__instance
				end)
				and result.__instance
			)

		if final ~= nil then
			table.insert(__SH.COMPINDEXES, final)

			if recorder then
				recorder:_Commit(recordNode, result, final)
			end

			return result, final
		end

		if recorder then
			recorder:_Commit(recordNode, result, nil)
		end

		return result
	end
end

for name, make in pairs(components) do
	components[name] = wrap(name, make)
end

function components.register(name: string, make: (any, any) -> any)
	components[name] = wrap(name, make)
end

return components
end function __DIST.Q():typeof(__modImpl())local v=__DIST.cache.Q if not v then v={c=__modImpl()}__DIST.cache.Q=v end return v.c end end do local function __modImpl()--// Imports
local creator = __DIST.d()

--// References
local value = creator.Value

--// Private Methods
local function color4(color: Color3 | string, alpha: number)
	local parsedColor = (typeof(color) == "Color3" and color) or (typeof(color) == "string" and Color3.fromHex(color))

	return {
		value(parsedColor),
		value(1 - (alpha / 100)),
	}
end

--// Publish
return {
	_id = "Dark",

	Text = {
		Primary = color4("FFFFFF", 85),
		Secondary = color4("FFFFFF", 55),
		Tertiary = color4("FFFFFF", 25),
		Quaternary = color4("FFFFFF", 10),
		Quinary = color4("FFFFFF", 5),

		SelectionPrimary = color4("FFFFFF", 100),
		PrimaryAccent = color4("FFFFFF", 38),
	},

	Accents = {
		Red = color4("FF453A", 100),
	},

	Controls = {
		Background = color4("1C1C1E", 100),

		View = color4("1F1F21", 100),
		ViewBorder = color4("FFFFFF", 5),

		WindowControlDisabled = color4("FFFFFF", 20),
		WindowControlIcon = color4("000000", 50),
		WindowControlStroke = color4("FFFFFF", 10),
		Exit = color4("FF5F57", 100),
		Minimize = color4("FEBC2E", 100),
		Zoom = color4("28C840", 100),

		SwitchAccent = color4("478CF6", 100),
		Selection = color4("007AFF", 100),
		SelectionStroke = color4("007AFF", 60),
		SelectionFocused = color4("0A82FF", 100),
		SelectionFocusedAccent = color4("FFFFFF", 85),

		Sidebar = color4("202023", 84),
		ScrollBar = color4("FFFFFF", 35),
		Separator = {
			Background = color4("000000", 50),
			Shadow = color4("FFFFFF", 0),
		},

		Titlebar = color4("363636", 100),
		TitlebarShadow = {
			Background = color4("000000", 0),
			Color = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})),
			Transparency = value(NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1),
			})),
		},

		Toggle = {
			Knob = color4("FFFFFF", 100),
			KnobEffects = color4("FFFFFF", 100),

			SwitchOff = color4("7a7a7a", 40),
			SwitchOn = color4("478cf6", 100),

			DepthEffect = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 225, 225)),
				ColorSequenceKeypoint.new(0.68, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})),
		},

		Slider = {
			Track = color4("2C2C2E", 100),
			TrackEffects = color4("000000", 10),

			Thumb = color4("FFFFFF", 100),
			ThumbStroke = color4("000000", 20),
			ThumbEffects = color4("FFFFFF", 80),
		},

		Button = {
			Shadow = value(Color3.fromRGB(0, 0, 0)),
			FillPrimary = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 148, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 110, 255)),
			})),
			FillSecondary = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 55, 55)),
			})),
		},

		Stepper = {
			Background = color4("373737", 100),
			Dropshadow = color4("000000", 100),
			Separator = color4("FFFFFF", 10),
			Filler = color4("FFFFFF", 4),
			SegmentShadow = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
			})),
		},

		RadioButtonGroup = {
			Background = color4("373737", 100),
			Dot = color4("FFFFFF", 100),
			Stroke = color4("000000", 20),
			Overlay = color4("FFFFFF", 8),
			InnerShadow = color4("FFFFFF", 10),
		},

		MenuButton = {
			IndicatorBackground = color4("FFFFFF", 10),
			MenuBackground = color4("2C2C2E", 95),
		},

		ImageSurface = {
			Gradient = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 190)),
			})),
		},
	},
}
end function __DIST.R():typeof(__modImpl())local v=__DIST.cache.R if not v then v={c=__modImpl()}__DIST.cache.R=v end return v.c end end do local function __modImpl()--// Imports

local creator = __DIST.d()

--// References
local value = creator.Value

--// Private Methods
local function color4(color: Color3 | string, alpha: number)
	local parsedColor = (typeof(color) == "Color3" and color) or (typeof(color) == "string" and Color3.fromHex(color))

	return {
		value(parsedColor),
		value(1 - (alpha / 100)),
	}
end

--// Publish
return {
	_id = "Light",

	Text = {
		Primary = color4("000000", 85),
		Secondary = color4("000000", 50),
		Tertiary = color4("000000", 25),
		Quaternary = color4("000000", 10),
		Quinary = color4("000000", 5),

		SelectionPrimary = color4("FFFFFF", 100),
		PrimaryAccent = color4("4D4D4D", 100),
	},

	Accents = {
		Red = color4("FF3B30", 100),
	},

	Controls = {
		Background = color4("FFFFFF", 100),

		View = color4("FCFCFC", 100),
		ViewBorder = color4("000000", 5),
		
		WindowControlDisabled = color4("000000", 20),
		WindowControlIcon = color4("000000", 50),
		WindowControlStroke = color4("000000", 20),
		Exit = color4("FF5F57", 100),
		Minimize = color4("FEBC2E", 100),
		Zoom = color4("28C840", 100),

		SwitchAccent = color4("478CF6", 100),
		Selection = color4("007AFF", 100),
		SelectionStroke = color4("007AFF", 50),
		SelectionFocused = color4("0A82FF", 100),
		SelectionFocusedAccent = color4("FFFFFF", 85),

		Sidebar = color4("EAEAEA", 84),
		ScrollBar = color4("000000", 40),
		Separator = {
			Background = color4("000000", 18),
			Shadow = color4("000000", 10),
		},

		Titlebar = color4("EEEEEE", 100),
		TitlebarShadow = {
			Background = color4("EAEAEA", 25),
			Color = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
			})),
			Transparency = value(NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.35),
				NumberSequenceKeypoint.new(1, 0.35),
			})),
		},

		Toggle = {
			Knob = color4("FFFFFF", 100),
			KnobEffects = color4("FFFFFF", 100),

			SwitchOff = color4("000000", 9),
			SwitchOn = color4("478CF6", 100),

			DepthEffect = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(225, 225, 225)),
				ColorSequenceKeypoint.new(0.68, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})),
		},

		Slider = {
			Track = color4("000000", 5),
			TrackEffects = color4("000000", 0),

			Thumb = color4("FFFFFF", 100),
			ThumbStroke = color4("000000", 2),
			ThumbEffects = color4("FFFFFF", 100),
		},

		Button = {
			Shadow = value(Color3.new(0, 0, 0)),
			FillPrimary = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 145, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 122, 255)),
			})),
			FillSecondary = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})),
		},

		Stepper = {
			Background = color4("FFFFFF", 100),
			Dropshadow = color4("000000", 100),
			Separator = color4("000000", 22),
			Filler = color4("000000", 5),
			SegmentShadow = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
			})),
		},

		RadioButtonGroup = {
			Background = color4("FFFFFF", 100),
			Dot = color4("FFFFFF", 100),
			Stroke = color4("000000", 8),
			Overlay = color4("FFFFFF", 17),
			InnerShadow = color4("000000", 10),
		},
		
		MenuButton = {
			IndicatorBackground = color4("000000", 5),
			MenuBackground = color4("F6F6F6", 95),
		},

		ImageSurface = {
			Gradient = value(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(190, 190, 190)),
			})),
		},
	},
}
end function __DIST.S():typeof(__modImpl())local v=__DIST.cache.S if not v then v={c=__modImpl()}__DIST.cache.S=v end return v.c end end do local function __modImpl()
return {
	Dark = __DIST.R(),
	Light = __DIST.S(),
}
end function __DIST.T():typeof(__modImpl())local v=__DIST.cache.T if not v then v={c=__modImpl()}__DIST.cache.T=v end return v.c end end do local function __modImpl()--// Private Methods

local function makeGradient(topHex, bottomHex)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex(topHex)),
		ColorSequenceKeypoint.new(1, Color3.fromHex(bottomHex)),
	})
end

--// Publish
return {
	Blue = {
		_id = "Blue",

		Dark = {
			SwitchAccent = Color3.fromHex("#0A84FF"),
			Selection = Color3.fromHex("#007AFF"),
			SelectionFocused = Color3.fromHex("#0A82FF"),
			Toggle = { SwitchOn = Color3.fromHex("#0A84FF") },
			Button = {
				FillPrimary = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(72, 148, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 110, 255)),
				}),
			},
		},
		Light = {
			SwitchAccent = Color3.fromHex("#0A84FF"),
			Selection = Color3.fromHex("#007AFF"),
			SelectionFocused = Color3.fromHex("#0A82FF"),
			Toggle = { SwitchOn = Color3.fromHex("#0A84FF") },
			Button = {
				FillPrimary = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 145, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 122, 255)),
				}),
			},
		},
	},

	Purple = {
		_id = "Purple",
		Dark = {
			SwitchAccent = Color3.fromHex("#BF5AF2"),
			Selection = Color3.fromHex("#9B35D4"),
			SelectionFocused = Color3.fromHex("#AE4FE0"),
			Toggle = { SwitchOn = Color3.fromHex("#BF5AF2") },
			Button = { FillPrimary = makeGradient("#AE4FE0", "#7A18B8") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#AF52DE"),
			Selection = Color3.fromHex("#8C2EC0"),
			SelectionFocused = Color3.fromHex("#9E42CA"),
			Toggle = { SwitchOn = Color3.fromHex("#AF52DE") },
			Button = { FillPrimary = makeGradient("#9E42CA", "#7010A8") },
		},
	},

	Pink = {
		_id = "Pink",
		Dark = {
			SwitchAccent = Color3.fromHex("#FF375F"),
			Selection = Color3.fromHex("#D4163E"),
			SelectionFocused = Color3.fromHex("#E83058"),
			Toggle = { SwitchOn = Color3.fromHex("#FF375F") },
			Button = { FillPrimary = makeGradient("#E83058", "#C00030") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#FF2D55"),
			Selection = Color3.fromHex("#C8103A"),
			SelectionFocused = Color3.fromHex("#DC2A50"),
			Toggle = { SwitchOn = Color3.fromHex("#FF2D55") },
			Button = { FillPrimary = makeGradient("#DC2A50", "#B4002C") },
		},
	},

	Red = {
		_id = "Red",
		Dark = {
			SwitchAccent = Color3.fromHex("#FF453A"),
			Selection = Color3.fromHex("#D4201A"),
			SelectionFocused = Color3.fromHex("#E83830"),
			Toggle = { SwitchOn = Color3.fromHex("#FF453A") },
			Button = { FillPrimary = makeGradient("#E83830", "#BC0E08") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#FF3B30"),
			Selection = Color3.fromHex("#C81A10"),
			SelectionFocused = Color3.fromHex("#DC2E24"),
			Toggle = { SwitchOn = Color3.fromHex("#FF3B30") },
			Button = { FillPrimary = makeGradient("#DC2E24", "#B00808") },
		},
	},

	Orange = {
		_id = "Orange",
		Dark = {
			SwitchAccent = Color3.fromHex("#FF9F0A"),
			Selection = Color3.fromHex("#C86800"),
			SelectionFocused = Color3.fromHex("#E07C00"),
			Toggle = { SwitchOn = Color3.fromHex("#FF9F0A") },
			Button = { FillPrimary = makeGradient("#E07C00", "#A85000") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#FF9500"),
			Selection = Color3.fromHex("#BC6000"), 
			SelectionFocused = Color3.fromHex("#D47000"),
			Toggle = { SwitchOn = Color3.fromHex("#FF9500") },
			Button = { FillPrimary = makeGradient("#D47000", "#A04800") },
		},
	},

	Yellow = {
		_id = "Yellow",
		Dark = {
			SwitchAccent = Color3.fromHex("#FFD60A"),
			Selection = Color3.fromHex("#A87800"),
			SelectionFocused = Color3.fromHex("#C49000"),
			Toggle = { SwitchOn = Color3.fromHex("#FFD60A") },
			Button = { FillPrimary = makeGradient("#C49000", "#8C6000") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#FFCC00"),
			Selection = Color3.fromHex("#9C7000"),
			SelectionFocused = Color3.fromHex("#B88400"),
			Toggle = { SwitchOn = Color3.fromHex("#FFCC00") },
			Button = { FillPrimary = makeGradient("#B88400", "#845800") },
		},
	},

	Green = {
		_id = "Green",
		Dark = {
			SwitchAccent = Color3.fromHex("#32D74B"),
			Selection = Color3.fromHex("#1A9030"),
			SelectionFocused = Color3.fromHex("#24A83C"),
			Toggle = { SwitchOn = Color3.fromHex("#32D74B") },
			Button = { FillPrimary = makeGradient("#24A83C", "#0E7020") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#28CD41"),
			Selection = Color3.fromHex("#148428"),
			SelectionFocused = Color3.fromHex("#1E9C34"),
			Toggle = { SwitchOn = Color3.fromHex("#28CD41") },
			Button = { FillPrimary = makeGradient("#1E9C34", "#0C6818") },
		},
	},

	Graphite = {
		_id = "Graphite",
		Dark = {
			SwitchAccent = Color3.fromHex("#98989D"),
			Selection = Color3.fromHex("#58585C"),
			SelectionFocused = Color3.fromHex("#6E6E72"),
			Toggle = { SwitchOn = Color3.fromHex("#98989D") },
			Button = { FillPrimary = makeGradient("#6E6E72", "#404044") },
		},
		Light = {
			SwitchAccent = Color3.fromHex("#8E8E93"),
			Selection = Color3.fromHex("#4E4E52"),
			SelectionFocused = Color3.fromHex("#626266"),
			Toggle = { SwitchOn = Color3.fromHex("#8E8E93") },
			Button = { FillPrimary = makeGradient("#626266", "#383838") },
		},
	},
}end function __DIST.U():typeof(__modImpl())local v=__DIST.cache.U if not v then v={c=__modImpl()}__DIST.cache.U=v end return v.c end end end--// Imports

local utility = __DIST.a()
local types = __DIST.b()
local creator = __DIST.d()
local binder = __DIST.c()
local services = __DIST.e()
local appRecorder = __DIST.f()

local symbols = __DIST.g()
local components = __DIST.Q()

local themes = __DIST.T()
local accents = __DIST.U()

--// References
local create = creator.Create

local tweenService = services.TweenService

--// Variables
local cascade = {
	Themes = themes,
	Accents = accents,
	Symbols = symbols,

	Creator = creator,
	Binder = binder,
	Components = components,
	AppRecorder = appRecorder,
}

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local currentTween: Tween? = nil

--// Functions
local function deepCopy(original, identifier: string?)
	local copy = {}
	for key, value in pairs(original) do
		local vType = typeof(value)
		if vType == "table" then
			if value.Value ~= nil and value.Connect and typeof(value.Connect) == "function" then
				copy[key] = creator.Value(value.Value)
			else
				copy[key] = deepCopy(value)
			end
		else
			copy[key] = value
		end
	end

	if identifier and not original._id then
		original._id = identifier
	end

	return copy
end

local function parseAccent(theme, overrides)
	for key, override in pairs(overrides) do
		local themeObj = theme[key]

		if not themeObj and type(theme) == "table" and type(theme.Controls) == "table" then
			themeObj = theme.Controls[key]
		end

		if not themeObj then
			continue
		end

		if type(themeObj) == "table" and themeObj.Connect then
			themeObj.Value = override
		elseif type(themeObj) == "table" and themeObj[1] and themeObj[1].Connect and typeof(override) == "Color3" then
			themeObj[1].Value = override
		elseif type(themeObj) == "table" and type(override) == "table" then
			parseAccent(themeObj, override)
		end
	end
end

local function updateThemes(target, theme, accent)
	local function deepUpdate(target, new)
		for key, value in pairs(new) do
			if type(value) == "table" and type(target[key]) == "table" and not value.Value then
				deepUpdate(target[key], value)
			elseif target[key] and value and value.Value ~= nil then
				target[key].Value = value.Value
			end
		end
	end
	deepUpdate(target, theme)

	if accent and accent[theme._id] then
		parseAccent(target, accent[theme._id])
	end
end

--// Initialize
cascade.New = function(properties: AppProperties__DARKLUA_TYPE_q): App__DARKLUA_TYPE_r	
if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	properties = properties or {}

	local initialTheme = properties.Theme or themes.Light
	local initialAccent = properties.Accent or accents.Blue

	local currentBaseTheme = initialTheme

	properties.Theme = deepCopy(initialTheme)
	properties.Accent = deepCopy(initialAccent)

	updateThemes(properties.Theme, initialTheme, initialAccent)

	local container = utility.ProtectUI(create("ScreenGui")({
		Name = "Cascade",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 200,

		OnTopOfCoreBlur = true,
	})) :: ScreenGui

	local pill = create("ImageButton")({
		Name = "WindowPill",
		AnchorPoint = Vector2.new(0.5, 0),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://93520763686656",
		ImageTransparency = 0.5,
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(180, 5),
		Parent = container.__instance,

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(1, 0),
		}),
	}) :: ImageButton

	pill.MouseEnter:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = tweenService:Create(pill.__instance, tweenInfo, {
			ImageTransparency = 0.15,
		})

		if currentTween then
			currentTween:Play()
		end
	end)

	pill.MouseLeave:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = tweenService:Create(pill.__instance, tweenInfo, {
			ImageTransparency = 0.5,
		})

		if currentTween then
			currentTween:Play()
		end
	end)

	local object = binder.Wrap(properties, {
		WindowPill = function(value: boolean)
			pill.Visible = value
		end,
		Theme = function(newTheme)
			currentBaseTheme = newTheme
			updateThemes(properties.Theme, newTheme, properties.Accent)
		end,
		Accent = function(newAccent)
			properties.Accent = deepCopy(newAccent, newAccent._id)
			updateThemes(properties.Theme, currentBaseTheme, newAccent)
		end,
	}, container, { "Theme", "Accent" })

	object.Structures = {
		WindowPill = pill,
	}

	setmetatable(properties, { __index = components })

	binder.Apply(properties, object)
	task.defer(binder.Apply, properties, object)

	return object
end

cascade.Component = function(properties: ComponentProperties__DARKLUA_TYPE_s?): ComponentContext__DARKLUA_TYPE_t	
properties = properties or {}

	local initialTheme = properties.Theme or themes.Light
	local initialAccent = properties.Accent or accents.Blue

	local currentBaseTheme = initialTheme

	properties.Theme = deepCopy(initialTheme)
	properties.Accent = deepCopy(initialAccent)

	updateThemes(properties.Theme, initialTheme, initialAccent)

	local object = binder.Wrap(properties, {
		Theme = function(newTheme)
			currentBaseTheme = newTheme
			updateThemes(properties.Theme, newTheme, properties.Accent)
		end,
		Accent = function(newAccent)
			properties.Accent = deepCopy(newAccent, newAccent._id)
			updateThemes(properties.Theme, currentBaseTheme, newAccent)
		end,
	}, nil, { "Theme", "Accent" })

	if properties.Parent then
		object.__container = properties.Parent
	end

	setmetatable(properties, { __index = components })

	binder.Apply(properties, object)
	task.defer(binder.Apply, properties, object)

	return object
end

cascade.RegisterComponent = function(name: string, make: (self: any, properties: any) -> any)
	components.register(name, make)
end

cascade.AppDump = function(app: App__DARKLUA_TYPE_r, options: { [string]: any }?)
	return appRecorder.DumpApp(app, options)
end


-- =========================================================================
-- Vynx UI Library - macOS Sequoia Customization & Compatibility Layer
-- =========================================================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local Vynx = {
    Cascade = cascade,
    Themes = cascade.Themes,
    Accents = cascade.Accents,
    Symbols = cascade.Symbols,
    Creator = cascade.Creator,
    Binder = cascade.Binder,
    Components = cascade.Components,

    New = cascade.New,
    Component = cascade.Component,
    RegisterComponent = cascade.RegisterComponent,

    Toggles = {},
    Options = {},

    ActiveApp = nil,
    ActiveWindow = nil,
    ActiveWatermark = nil,
    ActiveLauncher = nil,
    ScreenGui = nil,
    UnloadSignals = {},
}

-- -------------------------------------------------------------------------
-- SaveManager (LinoriaLib compatible)
-- -------------------------------------------------------------------------
local SaveManager = {
    Folder = "vynx",
    SubFolder = "configs",
    Library = Vynx,
    IgnoreIndexes = { ["ConfigName"] = true, ["ConfigSelect"] = true },
}

local function sanitizeFileName(name: string)
    local clean = string.gsub(name, "[^%w%-_]", "")
    return clean ~= "" and clean or "default"
end

local function getConfigPath(name: string)
    return string.format("%s/%s/%s.json", SaveManager.Folder, SaveManager.SubFolder, sanitizeFileName(name))
end

function SaveManager:SetLibrary(library)
    self.Library = library
end

function SaveManager:SetFolder(folder)
    self.Folder = folder
end

function SaveManager:SetSubFolder(sub)
    self.SubFolder = sub
end

function SaveManager:SetIgnoreIndexes(indexes)
    for _, idx in ipairs(indexes) do
        self.IgnoreIndexes[idx] = true
    end
end

function SaveManager:IgnoreThemeSettings()
    self.IgnoreIndexes["ThemeMode"] = true
    self.IgnoreIndexes["AccentColor"] = true
end

function SaveManager:InitFolders()
    if typeof(makefolder) == "function" and typeof(isfolder) == "function" then
        pcall(function()
            if not isfolder(self.Folder) then makefolder(self.Folder) end
            if not isfolder(self.Folder .. "/" .. self.SubFolder) then makefolder(self.Folder .. "/" .. self.SubFolder) end
        end)
    end
end

function SaveManager:Save(name: string): boolean
    if not self.Library then return false end
    self:InitFolders()

    local data = { Toggles = {}, Options = {} }
    for id, toggle in pairs(self.Library.Toggles) do
        if not self.IgnoreIndexes[id] then
            data.Toggles[id] = toggle.Value
        end
    end
    for id, option in pairs(self.Library.Options) do
        if not self.IgnoreIndexes[id] then
            local val = option.Value
            if typeof(val) == "Color3" then
                data.Options[id] = { Type = "Color3", R = val.R, G = val.G, B = val.B, Transparency = option.Transparency or 0 }
            elseif typeof(val) == "EnumItem" then
                data.Options[id] = { Type = "EnumItem", Name = val.Name, Mode = option.Mode or "Toggle" }
            else
                data.Options[id] = { Type = "Primitive", Value = val }
            end
        end
    end

    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok and typeof(writefile) == "function" then
        local writeOk = pcall(function() writefile(getConfigPath(name), encoded) end)
        return writeOk
    end
    return false
end

function SaveManager:Load(name: string): boolean
    if not self.Library then return false end
    local path = getConfigPath(name)
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return false end
    local existsOk, exists = pcall(function() return isfile(path) end)
    if not existsOk or not exists then return false end

    local readOk, content = pcall(function() return readfile(path) end)
    if not readOk or typeof(content) ~= "string" then return false end
    local decodeOk, data = pcall(function() return HttpService:JSONDecode(content) end)
    if not decodeOk or typeof(data) ~= "table" then return false end

    if data.Toggles then
        for id, val in pairs(data.Toggles) do
            if self.Library.Toggles[id] and not self.IgnoreIndexes[id] then
                pcall(function() self.Library.Toggles[id]:SetValue(val) end)
            end
        end
    end
    if data.Options then
        for id, item in pairs(data.Options) do
            if self.Library.Options[id] and not self.IgnoreIndexes[id] then
                pcall(function()
                    if item.Type == "Color3" then
                        self.Library.Options[id]:SetValue(Color3.new(item.R, item.G, item.B), item.Transparency or 0)
                    elseif item.Type == "EnumItem" then
                        local key = Enum.KeyCode[item.Name]
                        if key then
                            self.Library.Options[id]:SetValue(key)
                            if item.Mode and self.Library.Options[id].SetMode then
                                self.Library.Options[id]:SetMode(item.Mode)
                            end
                        end
                    else
                        self.Library.Options[id]:SetValue(item.Value)
                    end
                end)
            end
        end
    end
    return true
end

function SaveManager:DeleteConfig(name: string): boolean
    local path = getConfigPath(name)
    if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(path) then
        local ok = pcall(function() delfile(path) end)
        return ok
    end
    return false
end

function SaveManager:ListConfigs(): { [number]: string }
    local configs = {}
    if typeof(listfiles) == "function" and typeof(isfolder) == "function" then
        self:InitFolders()
        local folderPath = self.Folder .. "/" .. self.SubFolder
        local ok, files = pcall(function() return listfiles(folderPath) end)
        if ok and typeof(files) == "table" then
            for _, file in ipairs(files) do
                local match = string.match(file, "([^/\\]+)%.json$")
                if match then table.insert(configs, match) end
            end
        end
    end
    return configs
end

function SaveManager:SetAutoLoad(name: string)
    local autoPath = self.Folder .. "/autoload.txt"
    if typeof(writefile) == "function" then
        pcall(function() writefile(autoPath, sanitizeFileName(name)) end)
    end
end

function SaveManager:LoadAutoloadConfig()
    self:CheckAutoLoad()
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

function SaveManager:BuildConfigSection(tab)
    local section = tab:AddPageSection({ Title = "PROFILES & CONFIGURATION" })
    local form = section:AddForm()

    local configNameInput = form:AddInput("ConfigName", {
        Text = "Profile Name",
        Subtitle = "Enter a file name to save current settings",
        Placeholder = "default",
        Default = "default",
    })
    self.IgnoreIndexes["ConfigName"] = true

    local existingConfigs = self:ListConfigs()
    if #existingConfigs == 0 then table.insert(existingConfigs, "default") end

    local configDropdown = form:AddDropdown("ConfigSelect", {
        Text = "Saved Profiles",
        Subtitle = "Select an existing configuration profile",
        Values = existingConfigs,
        Default = existingConfigs[1] or "default",
        Callback = function(val)
            if configNameInput and configNameInput.SetValue then
                configNameInput:SetValue(val)
            end
        end,
    })
    self.IgnoreIndexes["ConfigSelect"] = true

    form:AddButton({
        Title = "Save Profile",
        Subtitle = "Write active settings to disk",
        Variant = "Prominent",
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                local ok = self:Save(name)
                Vynx:Notify({
                    Title = "Config Manager",
                    Content = ok and ("Saved config: " .. name) or "Failed to save config",
                    Type = ok and "Success" or "Error",
                    Duration = 3,
                })
                local updated = self:ListConfigs()
                if #updated > 0 and configDropdown.SetValues then
                    configDropdown:SetValues(updated)
                end
            end
        end,
    })

    form:AddButton({
        Title = "Load Profile",
        Subtitle = "Restore settings from selected file",
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                local ok = self:Load(name)
                Vynx:Notify({
                    Title = "Config Manager",
                    Content = ok and ("Loaded config: " .. name) or "Config file not found",
                    Type = ok and "Success" or "Error",
                    Duration = 3,
                })
            end
        end,
    })

    form:AddButton({
        Title = "Set As Autoload",
        Subtitle = "Automatically apply this profile on future starts",
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                self:SetAutoLoad(name)
                Vynx:Notify({
                    Title = "Autoload Config",
                    Content = "Set autoload profile to: " .. name,
                    Type = "Success",
                    Duration = 3,
                })
            end
        end,
    })

    form:AddButton({
        Title = "Delete Profile",
        Subtitle = "Permanently remove profile file from disk",
        DoubleClick = true,
        Func = function()
            local name = configNameInput.Value
            if name and #name > 0 then
                local ok = self:DeleteConfig(name)
                Vynx:Notify({
                    Title = "Config Manager",
                    Content = ok and ("Deleted profile: " .. name) or "Failed to delete profile",
                    Type = ok and "Warn" or "Error",
                    Duration = 3,
                })
                local updated = self:ListConfigs()
                if #updated > 0 and configDropdown.SetValues then
                    configDropdown:SetValues(updated)
                end
            end
        end,
    })
end

Vynx.SaveManager = SaveManager

-- -------------------------------------------------------------------------
-- ThemeManager (Theme & Accent Switching)
-- -------------------------------------------------------------------------
local ThemeManager = {
    Library = Vynx,
}

function ThemeManager:SetLibrary(library)
    self.Library = library
end

function ThemeManager:SetTheme(themeName: string)
    self.Library:SetTheme(themeName)
end

function ThemeManager:SetAccent(accentName: string)
    self.Library:SetAccent(accentName)
end

function ThemeManager:ApplyToTab(tab)
    local section = tab:AddPageSection({ Title = "APPEARANCE & THEME" })
    local form = section:AddForm()

    form:AddSegmented("ThemeMode", {
        Text = "Interface Theme",
        Subtitle = "Select dark or light appearance",
        Values = { "Dark", "Light" },
        Default = "Dark",
        Callback = function(val)
            self:SetTheme(val)
        end,
    })

    form:AddDropdown("AccentColor", {
        Text = "Accent Tint",
        Subtitle = "System-wide tint for controls and highlights",
        Values = { "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite" },
        Default = "Blue",
        Callback = function(val)
            self:SetAccent(val)
        end,
    })
end

Vynx.ThemeManager = ThemeManager

-- -------------------------------------------------------------------------
-- Notification System
-- -------------------------------------------------------------------------
function Vynx:Notify(options: { Title: string?, Content: string?, Subtitle: string?, Type: string?, Duration: number?, Icon: any? })
    if not self.ActiveApp then return end
    options = options or {}

    local typeIcons = {
        Success = self.Symbols.checkmarkCircleFill or self.Symbols.checkmark,
        Error = self.Symbols.xmarkCircleFill or self.Symbols.xmark,
        Warn = self.Symbols.exclamationmarkTriangleFill or self.Symbols.exclamationmarkTriangle,
        Info = self.Symbols.infoCircleFill or self.Symbols.infoCircle,
    }

    local chosenIcon = (options.Type and typeIcons[options.Type])
        or options.Icon
        or self.Symbols.bell

    pcall(function()
        self.ActiveApp:Notification({
            Title = options.Title or "Vynx",
            Subtitle = options.Content or options.Subtitle or "",
            App = "Vynx",
            AppIcon = chosenIcon,
            Duration = options.Duration or 4,
        })
    end)
end

-- -------------------------------------------------------------------------
-- Watermark System (Live FPS & Ping)
-- -------------------------------------------------------------------------
function Vynx:SetWatermark(text: string)
    if not self.ActiveWatermark and self.ScreenGui then
        local wmFrame = Instance.new("Frame")
        wmFrame.Name = "VynxWatermark"
        wmFrame.AnchorPoint = Vector2.new(0, 0)
        wmFrame.Position = UDim2.fromOffset(16, 16)
        wmFrame.AutomaticSize = Enum.AutomaticSize.XY
        wmFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
        wmFrame.BackgroundTransparency = 0.25
        wmFrame.BorderSizePixel = 0
        wmFrame.ZIndex = 500
        wmFrame.Parent = self.ScreenGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = wmFrame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = 0.88
        stroke.Thickness = 1
        stroke.Parent = wmFrame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = wmFrame

        local label = Instance.new("TextLabel")
        label.Name = "Text"
        label.AutomaticSize = Enum.AutomaticSize.XY
        label.BackgroundTransparency = 1
        label.FontFace = Font.new("rbxassetid://12187365364")
        label.Text = text or "vynx | macOS Sequoia"
        label.TextColor3 = Color3.fromRGB(240, 240, 245)
        label.TextSize = 12
        label.Parent = wmFrame

        self.ActiveWatermark = {
            Frame = wmFrame,
            Label = label,
            SetText = function(self, newText)
                label.Text = newText
            end,
            SetVisible = function(self, vis)
                wmFrame.Visible = vis
            end,
        }
    elseif self.ActiveWatermark then
        self.ActiveWatermark:SetText(text)
    end
    return self.ActiveWatermark
end

function Vynx:SetWatermarkVisibility(visible: boolean)
    if self.ActiveWatermark then
        self.ActiveWatermark:SetVisible(visible)
    end
end

-- -------------------------------------------------------------------------
-- Floating Draggable Launcher Pill
-- -------------------------------------------------------------------------
local function createFloatingLauncher(gui, windowObj, app)
    local btn = Instance.new("TextButton")
    btn.Name = "VynxFloatingLauncher"
    btn.Size = UDim2.fromOffset(42, 42)
    btn.Position = UDim2.new(0, 16, 0.5, -21)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
    btn.BackgroundTransparency = 0.15
    btn.Text = "V"
    btn.TextColor3 = Color3.fromRGB(10, 132, 255)
    btn.TextSize = 18
    btn.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold)
    btn.AutoButtonColor = false
    btn.ZIndex = 800
    btn.Visible = false
    btn.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(10, 132, 255)
    stroke.Transparency = 0.4
    stroke.Thickness = 1.5
    stroke.Parent = btn

    -- Dragging logic
    local dragging = false
    local dragStart = nil
    local startPos = nil

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if windowObj then
            windowObj.Minimized = not windowObj.Minimized
        end
    end)

    return btn
end

-- -------------------------------------------------------------------------
-- Popover Colorpicker Implementation
-- -------------------------------------------------------------------------
local function createColorpickerRow(form, id, opts, vynxLibrary)
    local row = form:Row({ SearchIndex = opts.Title or opts.Text or id })
    local currentColor = opts.Default or Color3.fromRGB(10, 132, 255)
    local currentAlpha = opts.Transparency or 0

    row:Left():TitleStack({
        Title = opts.Title or opts.Text or id,
        Subtitle = opts.Subtitle,
    })

    local previewBtn = Instance.new("TextButton")
    previewBtn.Name = "ColorSwatch"
    previewBtn.Size = UDim2.fromOffset(30, 20)
    previewBtn.BackgroundColor3 = currentColor
    previewBtn.Text = ""
    previewBtn.AutoButtonColor = false
    previewBtn.Parent = row.Structures.RightAccessories

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 5)
    corner.Parent = previewBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.8
    stroke.Thickness = 1
    stroke.Parent = previewBtn

    -- Popover Card
    local popover = Instance.new("Frame")
    popover.Name = id .. "_PopoverPalette"
    popover.Size = UDim2.fromOffset(210, 150)
    popover.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    popover.BorderSizePixel = 0
    popover.ZIndex = 900
    popover.Visible = false

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 10)
    pCorner.Parent = popover

    local pStroke = Instance.new("UIStroke")
    pStroke.Color = Color3.fromRGB(255, 255, 255)
    pStroke.Transparency = 0.88
    pStroke.Thickness = 1
    pStroke.Parent = popover

    local pPad = Instance.new("UIPadding")
    pPad.PaddingTop = UDim.new(0, 10)
    pPad.PaddingBottom = UDim.new(0, 10)
    pPad.PaddingLeft = UDim.new(0, 10)
    pPad.PaddingRight = UDim.new(0, 10)
    pPad.Parent = popover

    local pLayout = Instance.new("UIListLayout")
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 8)
    pLayout.Parent = popover

    -- Hex Input
    local hexBox = Instance.new("TextBox")
    hexBox.Name = "HexInput"
    hexBox.Size = UDim2.new(1, 0, 0, 26)
    hexBox.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
    hexBox.BorderSizePixel = 0
    hexBox.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
    hexBox.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
    hexBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    hexBox.TextSize = 12
    hexBox.ClearTextOnFocus = false
    hexBox.LayoutOrder = 1
    hexBox.Parent = popover

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 5)
    hCorner.Parent = hexBox

    -- Curated Swatches Grid
    local grid = Instance.new("Frame")
    grid.Name = "SwatchesGrid"
    grid.Size = UDim2.new(1, 0, 0, 56)
    grid.BackgroundTransparency = 1
    grid.LayoutOrder = 2
    grid.Parent = popover

    local gLayout = Instance.new("UIGridLayout")
    gLayout.CellSize = UDim2.fromOffset(32, 24)
    gLayout.CellPadding = UDim2.fromOffset(6, 6)
    gLayout.Parent = grid

    local appleSwatches = {
        Color3.fromRGB(10, 132, 255),
        Color3.fromRGB(191, 90, 242),
        Color3.fromRGB(255, 55, 95),
        Color3.fromRGB(255, 69, 58),
        Color3.fromRGB(255, 159, 10),
        Color3.fromRGB(255, 214, 10),
        Color3.fromRGB(48, 209, 88),
        Color3.fromRGB(152, 152, 159),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(28, 28, 30),
    }

    local colorObj = {
        Type = "Colorpicker",
        Value = currentColor,
        Transparency = currentAlpha,
        Callback = opts.Callback,
        ChangedCallbacks = {},
        Row = row,
    }

    function colorObj:SetValue(newCol: Color3, newAlpha: number?)
        self.Value = newCol
        if newAlpha ~= nil then self.Transparency = newAlpha end
        previewBtn.BackgroundColor3 = newCol
        hexBox.Text = string.format("#%02X%02X%02X", math.floor(newCol.R * 255), math.floor(newCol.G * 255), math.floor(newCol.B * 255))
        if self.Callback then task.spawn(self.Callback, newCol, self.Transparency) end
        for _, fn in ipairs(self.ChangedCallbacks) do task.spawn(fn, newCol, self.Transparency) end
    end

    function colorObj:OnChanged(fn)
        table.insert(self.ChangedCallbacks, fn)
        return self
    end

    for _, col in ipairs(appleSwatches) do
        local sb = Instance.new("TextButton")
        sb.BackgroundColor3 = col
        sb.Text = ""
        sb.AutoButtonColor = false
        sb.Parent = grid

        local sbc = Instance.new("UICorner")
        sbc.CornerRadius = UDim.new(0, 4)
        sbc.Parent = sb

        local sbs = Instance.new("UIStroke")
        sbs.Color = Color3.fromRGB(255, 255, 255)
        sbs.Transparency = 0.8
        sbs.Thickness = 1
        sbs.Parent = sb

        sb.MouseButton1Click:Connect(function()
            colorObj:SetValue(col)
        end)
    end

    hexBox.FocusLost:Connect(function()
        local clean = string.gsub(hexBox.Text, "[#%s]", "")
        if #clean == 6 then
            local r = tonumber(string.sub(clean, 1, 2), 16)
            local g = tonumber(string.sub(clean, 3, 4), 16)
            local b = tonumber(string.sub(clean, 5, 6), 16)
            if r and g and b then
                colorObj:SetValue(Color3.fromRGB(r, g, b))
                return
            end
        end
        hexBox.Text = string.format("#%02X%02X%02X", math.floor(colorObj.Value.R * 255), math.floor(colorObj.Value.G * 255), math.floor(colorObj.Value.B * 255))
    end)

    local isOpen = false
    previewBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            popover.Parent = vynxLibrary.ScreenGui
            popover.Visible = true
            local p = previewBtn.AbsolutePosition
            local s = previewBtn.AbsoluteSize
            popover.Position = UDim2.fromOffset(math.max(10, p.X - 180), p.Y + s.Y + 4)
        else
            popover.Visible = false
            popover.Parent = nil
        end
    end)

    vynxLibrary.Options[id] = colorObj
    return colorObj
end

-- -------------------------------------------------------------------------
-- Wrapper Helpers (Vynx & Linoria API)
-- -------------------------------------------------------------------------
local function wrapForm(form, vynxLibrary)
    local wrappedForm = {
        Form = form,
    }

    -- AddToggle
    function wrappedForm:AddToggle(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local toggle = row:Right():Toggle({
            Value = not not opts.Default,
            ValueChanged = function(_, val)
                if wrappedForm.Toggles and wrappedForm.Toggles[id] then
                    wrappedForm.Toggles[id].Value = val
                end
            end,
        })

        local toggleObj = {
            Type = "Toggle",
            Value = not not opts.Default,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Toggle = toggle,
        }

        function toggleObj:SetValue(val: boolean)
            self.Value = not not val
            toggle.Value = self.Value
        end

        function toggleObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        -- Support embedding Keybind inside Toggle row
        function toggleObj:AddKeybind(keyId: string, keyOpts)
            keyOpts = keyOpts or {}
            local keybindField = row:Right():KeybindField({
                Value = keyOpts.Default or Enum.KeyCode.Unknown,
                ValueChanged = function(_, key)
                    if vynxLibrary.Options[keyId] then
                        vynxLibrary.Options[keyId].Value = key
                    end
                end,
            })

            local keyObj = {
                Type = "Keybind",
                Value = keyOpts.Default or Enum.KeyCode.Unknown,
                Mode = keyOpts.Mode or "Toggle",
                Callback = keyOpts.Callback,
                ChangedCallbacks = {},
                Field = keybindField,
            }

            function keyObj:SetValue(k)
                self.Value = k
                keybindField.Value = k
            end

            function keyObj:OnChanged(fn)
                table.insert(self.ChangedCallbacks, fn)
                return self
            end

            if keyOpts.Callback then
                keybindField.ValueChanged = function(_, key)
                    keyObj.Value = key
                    task.spawn(keyOpts.Callback, key)
                    for _, fn in ipairs(keyObj.ChangedCallbacks) do task.spawn(fn, key) end
                end
            end

            vynxLibrary.Options[keyId] = keyObj
            return keyObj
        end

        -- Support embedding Colorpicker inside Toggle row
        function toggleObj:AddColorpicker(colorId: string, colorOpts)
            colorOpts = colorOpts or {}
            local colorObj = createColorpickerRow(form, colorId, colorOpts, vynxLibrary)
            return colorObj
        end

        if opts.Callback then
            toggle.ValueChanged = function(_, val)
                toggleObj.Value = val
                task.spawn(opts.Callback, val)
                for _, fn in ipairs(toggleObj.ChangedCallbacks) do task.spawn(fn, val) end
            end
        end

        vynxLibrary.Toggles[id] = toggleObj
        return toggleObj
    end

    -- AddSlider
    function wrappedForm:AddSlider(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local minVal = opts.Min or 0
        local maxVal = opts.Max or 100
        local defVal = opts.Default or minVal

        local slider = row:Right():Slider({
            Minimum = minVal,
            Maximum = maxVal,
            Value = defVal,
        })

        local valLabel = row:Right():Label({
            Text = tostring(defVal) .. (opts.Suffix or ""),
        })

        local sliderObj = {
            Type = "Slider",
            Value = defVal,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Slider = slider,
            Label = valLabel,
        }

        local function formatValue(val: number)
            local rounded = val
            if opts.Rounding then
                if opts.Rounding == 0 then
                    rounded = math.round(val)
                else
                    local p = 10 ^ opts.Rounding
                    rounded = math.round(val * p) / p
                end
            end
            return rounded
        end

        slider.ValueChanged = function(_, val)
            local rounded = formatValue(val)
            valLabel.Text = tostring(rounded) .. (opts.Suffix or "")
            sliderObj.Value = rounded
            if opts.Callback then task.spawn(opts.Callback, rounded) end
            for _, fn in ipairs(sliderObj.ChangedCallbacks) do task.spawn(fn, rounded) end
        end

        function sliderObj:SetValue(val: number)
            local rounded = formatValue(val)
            self.Value = rounded
            slider.Value = rounded
            valLabel.Text = tostring(rounded) .. (opts.Suffix or "")
        end

        function sliderObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = sliderObj
        return sliderObj
    end

    -- AddDropdown
    function wrappedForm:AddDropdown(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local valuesList = opts.Values or {}
        local defIdx = 1
        if typeof(opts.Default) == "string" then
            defIdx = table.find(valuesList, opts.Default) or 1
        elseif typeof(opts.Default) == "number" then
            defIdx = opts.Default
        end

        local popup = row:Right():PopUpButton({
            Options = valuesList,
            Value = defIdx,
            Maximum = opts.Multi and 999 or 1,
        })

        local dropdownObj = {
            Type = "Dropdown",
            Value = opts.Default or valuesList[1],
            Values = valuesList,
            Multi = opts.Multi == true,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Popup = popup,
        }

        popup.ValueChanged = function(_, rawVal)
            local resolved
            if dropdownObj.Multi and typeof(rawVal) == "table" then
                resolved = {}
                for _, idx in ipairs(rawVal) do
                    if valuesList[idx] then table.insert(resolved, valuesList[idx]) end
                end
            else
                local idx = typeof(rawVal) == "table" and rawVal[1] or rawVal
                resolved = valuesList[idx] or rawVal
            end

            dropdownObj.Value = resolved
            if opts.Callback then task.spawn(opts.Callback, resolved) end
            for _, fn in ipairs(dropdownObj.ChangedCallbacks) do task.spawn(fn, resolved) end
        end

        function dropdownObj:SetValue(val)
            if self.Multi and typeof(val) == "table" then
                local indices = {}
                for _, item in ipairs(val) do
                    local idx = table.find(valuesList, item)
                    if idx then table.insert(indices, idx) end
                end
                popup.Value = indices
            else
                local idx = table.find(valuesList, val)
                if idx then popup.Value = idx end
            end
        end

        function dropdownObj:SetValues(newValues)
            valuesList = newValues
            self.Values = newValues
            popup.Options = newValues
        end

        function dropdownObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = dropdownObj
        return dropdownObj
    end

    -- AddColorpicker
    function wrappedForm:AddColorpicker(id: string, opts)
        return createColorpickerRow(form, id, opts, vynxLibrary)
    end

    -- AddKeybind
    function wrappedForm:AddKeybind(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local keybindField = row:Right():KeybindField({
            Value = opts.Default or Enum.KeyCode.Unknown,
        })

        local keyObj = {
            Type = "Keybind",
            Value = opts.Default or Enum.KeyCode.Unknown,
            Mode = opts.Mode or "Toggle",
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Field = keybindField,
        }

        keybindField.ValueChanged = function(_, key)
            keyObj.Value = key
            if opts.Callback then task.spawn(opts.Callback, key) end
            for _, fn in ipairs(keyObj.ChangedCallbacks) do task.spawn(fn, key) end
        end

        function keyObj:SetValue(k)
            self.Value = k
            keybindField.Value = k
        end

        function keyObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = keyObj
        return keyObj
    end

    -- AddButton
    function wrappedForm:AddButton(opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Title or opts.Text or "Button" })
        if opts.Subtitle or opts.Text then
            row:Left():TitleStack({
                Title = opts.Title or opts.Text or "",
                Subtitle = opts.Subtitle,
            })
        end

        local clicks = 0
        local lastClick = 0

        local btn = row:Right():Button({
            Label = opts.Title or opts.Text or "Button",
            Variant = opts.Variant or "Default",
            Pushed = function()
                if opts.DoubleClick then
                    local now = os.clock()
                    if now - lastClick < 0.35 then
                        if opts.Func then opts.Func() end
                    end
                    lastClick = now
                else
                    if opts.Func then opts.Func() end
                end
            end,
        })

        return btn
    end

    -- AddInput
    function wrappedForm:AddInput(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local tf = row:Right():TextField({
            Value = opts.Default or "",
            Placeholder = opts.Placeholder or "",
            ValueChanged = function(_, text)
                if vynxLibrary.Options[id] then
                    vynxLibrary.Options[id].Value = text
                end
            end,
        })

        local inputObj = {
            Type = "Input",
            Value = opts.Default or "",
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            TextField = tf,
        }

        tf.ValueChanged = function(_, text)
            inputObj.Value = text
            if opts.Callback then task.spawn(opts.Callback, text) end
            for _, fn in ipairs(inputObj.ChangedCallbacks) do task.spawn(fn, text) end
        end

        function inputObj:SetValue(val: string)
            self.Value = val
            tf.Value = val
        end

        function inputObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = inputObj
        return inputObj
    end

    -- AddStepper
    function wrappedForm:AddStepper(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local minVal = opts.Min or 0
        local maxVal = opts.Max or 100
        local stepVal = opts.Step or 1
        local defVal = opts.Default or minVal

        local stepper = row:Right():Stepper({
            Minimum = minVal,
            Maximum = maxVal,
            Step = stepVal,
            Value = defVal,
        })

        local stepperObj = {
            Type = "Stepper",
            Value = defVal,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            Stepper = stepper,
        }

        stepper.ValueChanged = function(_, val)
            stepperObj.Value = val
            if opts.Callback then task.spawn(opts.Callback, val) end
            for _, fn in ipairs(stepperObj.ChangedCallbacks) do task.spawn(fn, val) end
        end

        function stepperObj:SetValue(val: number)
            self.Value = val
            stepper.Value = val
        end

        function stepperObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = stepperObj
        return stepperObj
    end

    -- AddSegmented
    function wrappedForm:AddSegmented(id: string, opts)
        opts = opts or {}
        local row = form:Row({ SearchIndex = opts.Text or id })
        row:Left():TitleStack({
            Title = opts.Text or id,
            Subtitle = opts.Subtitle,
        })

        local valuesList = opts.Values or {}
        local defIdx = 1
        if typeof(opts.Default) == "string" then
            defIdx = table.find(valuesList, opts.Default) or 1
        elseif typeof(opts.Default) == "number" then
            defIdx = opts.Default
        end

        local radioGroup = row:Right():RadioButtonGroup({
            Options = valuesList,
            Value = defIdx,
        })

        local segmentedObj = {
            Type = "Segmented",
            Value = opts.Default or valuesList[1],
            Values = valuesList,
            Callback = opts.Callback,
            ChangedCallbacks = {},
            Row = row,
            RadioGroup = radioGroup,
        }

        radioGroup.ValueChanged = function(_, idx)
            local resolved = valuesList[idx] or idx
            segmentedObj.Value = resolved
            if opts.Callback then task.spawn(opts.Callback, resolved) end
            for _, fn in ipairs(segmentedObj.ChangedCallbacks) do task.spawn(fn, resolved) end
        end

        function segmentedObj:SetValue(val)
            local idx = table.find(valuesList, val)
            if idx then radioGroup.Value = idx end
        end

        function segmentedObj:OnChanged(fn)
            table.insert(self.ChangedCallbacks, fn)
            return self
        end

        vynxLibrary.Options[id] = segmentedObj
        return segmentedObj
    end

    -- AddLabel
    function wrappedForm:AddLabel(text: string)
        local row = form:Row()
        row:Left():Label({ Text = text })
        return row
    end

    -- AddDivider
    function wrappedForm:AddDivider()
        -- Row divider is automatic between rows in Form
    end

    -- AddDependencyBox
    function wrappedForm:AddDependencyBox(toggleObj)
        local subForm = form -- rows in this sub-form track toggleObj.Value
        local depForm = wrapForm(subForm, vynxLibrary)
        local originalAddToggle = depForm.AddToggle
        local originalAddSlider = depForm.AddSlider
        local originalAddDropdown = depForm.AddDropdown

        local managedRows = {}

        local function updateVisibility(active: boolean)
            for _, r in ipairs(managedRows) do
                if r.Structures and r.Structures.Body then
                    r.Structures.Body.Visible = active
                end
            end
        end

        if toggleObj and toggleObj.OnChanged then
            toggleObj:OnChanged(function(val)
                updateVisibility(val == true)
            end)
        end

        local depWrapper = setmetatable({}, {
            __index = function(_, k)
                local origMethod = depForm[k]
                if typeof(origMethod) == "function" then
                    return function(self, ...)
                        local res = origMethod(depForm, ...)
                        if res and res.Row then
                            table.insert(managedRows, res.Row)
                            if toggleObj and toggleObj.Value ~= nil then
                                if res.Row.Structures and res.Row.Structures.Body then
                                    res.Row.Structures.Body.Visible = (toggleObj.Value == true)
                                end
                            end
                        end
                        return res
                    end
                end
                return origMethod
            end
        })

        return depWrapper
    end

    return wrappedForm
end

local function wrapPageSection(pageSection, vynxLibrary)
    local wrappedPS = {
        PageSection = pageSection,
    }

    function wrappedPS:AddForm()
        local form = pageSection:Form()
        return wrapForm(form, vynxLibrary)
    end

    return wrappedPS
end

local function wrapTab(tab, vynxLibrary)
    local wrappedTab = {
        Tab = tab,
    }

    function wrappedTab:AddPageSection(opts)
        opts = opts or {}
        local ps = tab:PageSection({
            Title = opts.Title,
            Subtitle = opts.Subtitle,
        })
        return wrapPageSection(ps, vynxLibrary)
    end

    function wrappedTab:AddForm()
        local form = tab:Form()
        return wrapForm(form, vynxLibrary)
    end

    -- Classic Linoria compatibility: AddLeftGroupbox / AddRightGroupbox / AddGroupbox
    function wrappedTab:AddLeftGroupbox(title: string)
        local ps = tab:PageSection({ Title = string.upper(title) })
        local form = ps:Form()
        return wrapForm(form, vynxLibrary)
    end

    function wrappedTab:AddRightGroupbox(title: string)
        local ps = tab:PageSection({ Title = string.upper(title) })
        local form = ps:Form()
        return wrapForm(form, vynxLibrary)
    end

    function wrappedTab:AddGroupbox(title: string)
        local ps = tab:PageSection({ Title = string.upper(title) })
        local form = ps:Form()
        return wrapForm(form, vynxLibrary)
    end

    return wrappedTab
end

local function wrapSection(section, vynxLibrary)
    local wrappedSec = {
        Section = section,
    }

    function wrappedSec:AddTab(opts)
        if typeof(opts) == "string" then opts = { Title = opts } end
        opts = opts or {}

        local icon = opts.Icon
        if typeof(icon) == "string" and vynxLibrary.Symbols[icon] then
            icon = vynxLibrary.Symbols[icon]
        end

        local tab = section:Tab({
            Title = opts.Title or opts.Text or "Tab",
            Icon = icon,
            Selected = opts.Selected,
        })
        return wrapTab(tab, vynxLibrary)
    end

    function wrappedSec:CreateTab(opts)
        return self:AddTab(opts)
    end

    return wrappedSec
end

-- -------------------------------------------------------------------------
-- CreateWindow (Main entrypoint)
-- -------------------------------------------------------------------------
function Vynx:CreateWindow(options)
    options = options or {}

    -- Resolve Theme
    local themeObj = self.Themes.Dark
    if options.Theme == "Light" or options.Theme == self.Themes.Light then
        themeObj = self.Themes.Light
    end

    -- Resolve Accent
    local accentObj = self.Accents.Blue
    if typeof(options.Accent) == "string" and self.Accents[options.Accent] then
        accentObj = self.Accents[options.Accent]
    elseif typeof(options.Accent) == "table" then
        accentObj = options.Accent
    end

    -- Create App
    local app = self.New({
        WindowPill = options.WindowPill ~= false,
        Theme = themeObj,
        Accent = accentObj,
    })
    self.ActiveApp = app

    -- Container ScreenGui
    local screenGui = app.__container or (app.Structures and app.Structures.WindowPill and app.Structures.WindowPill.Parent)
    self.ScreenGui = screenGui

    -- Create Window
    local window = app:Window({
        Title = options.Title or "Vynx",
        Subtitle = options.Subtitle or options.SubTitle,
        Size = options.Size or UDim2.fromOffset(720, 480),
        Dropshadow = options.Dropshadow ~= false,
        Resizable = options.Resizable ~= false,
        Searching = options.Searchable ~= false,
    })
    self.ActiveWindow = window

    -- Responsive Mobile Auto-Scale (UIScale)
    local bodyFrame = window.Structures and window.Structures.Body
    if bodyFrame then
        local uiScale = Instance.new("UIScale")
        uiScale.Name = "VynxResponsiveScale"
        uiScale.Parent = bodyFrame

        local function updateScale()
            local cam = workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
            local targetW = (options.Size and options.Size.X.Offset > 0) and options.Size.X.Offset or 720
            local targetH = (options.Size and options.Size.Y.Offset > 0) and options.Size.Y.Offset or 480

            local scaleX = (vp.X - 24) / targetW
            local scaleY = (vp.Y - 24) / targetH
            local minScale = math.min(scaleX, scaleY)
            if minScale < 1 then
                uiScale.Scale = math.clamp(minScale, 0.55, 1)
            else
                uiScale.Scale = 1
            end
        end
        updateScale()
        local scaleConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
        table.insert(self.UnloadSignals, function() scaleConn:Disconnect() end)
    end

    -- Keybind toggle listener
    local toggleKey = options.Keybind or Enum.KeyCode.RightControl
    local uisConn = UserInputService.InputEnded:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            window.Minimized = not window.Minimized
        end
    end)
    table.insert(self.UnloadSignals, function() uisConn:Disconnect() end)

    -- Floating Launcher Button
    if screenGui then
        local launcher = createFloatingLauncher(screenGui, window, app)
        self.ActiveLauncher = launcher
        window:GetPropertyChangedSignal("Minimized"):Connect(function()
            launcher.Visible = window.Minimized
        end)
    end

    -- Wrapped Window
    local defaultSection = nil
    local wrappedWin = {
        Window = window,
        App = app,
    }

    function wrappedWin:AddSection(title: string)
        local sec = window:Section({
            Title = title,
            Disclosure = false,
        })
        return wrapSection(sec, Vynx)
    end

    function wrappedWin:AddTab(opts)
        if not defaultSection then
            defaultSection = self:AddSection("Navigation")
        end
        return defaultSection:AddTab(opts)
    end

    function wrappedWin:CreateTab(opts)
        return self:AddTab(opts)
    end

    return wrappedWin
end

-- -------------------------------------------------------------------------
-- Theme Switching API
-- -------------------------------------------------------------------------
function Vynx:SetTheme(themeName: string)
    if not self.ActiveApp then return end
    if themeName == "Light" or themeName == self.Themes.Light then
        self.ActiveApp.Theme = self.Themes.Light
    else
        self.ActiveApp.Theme = self.Themes.Dark
    end
end

function Vynx:SetAccent(accentName: string)
    if not self.ActiveApp then return end
    if typeof(accentName) == "string" and self.Accents[accentName] then
        self.ActiveApp.Accent = self.Accents[accentName]
    elseif typeof(accentName) == "table" then
        self.ActiveApp.Accent = accentName
    end
end

-- -------------------------------------------------------------------------
-- Teardown / Unload
-- -------------------------------------------------------------------------
function Vynx:OnUnload(cb)
    table.insert(self.UnloadSignals, cb)
end

function Vynx:Unload()
    for _, fn in ipairs(self.UnloadSignals) do
        pcall(fn)
    end
    table.clear(self.UnloadSignals)

    if self.ActiveWindow and self.ActiveWindow.Destroy then
        pcall(function() self.ActiveWindow:Destroy() end)
    end
    if self.ScreenGui then
        pcall(function() self.ScreenGui:Destroy() end)
        self.ScreenGui = nil
    end

    table.clear(self.Toggles)
    table.clear(self.Options)
    self.ActiveWindow = nil
    self.ActiveApp = nil
    self.ActiveWatermark = nil
    self.ActiveLauncher = nil
end

return Vynx
