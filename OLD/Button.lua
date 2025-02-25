local addonName, addonTable = ...


local ButtonFrameMetatable = {}

function ButtonFrameMetatable:ResizeToText()
	local defaults = self:GetDefaults()
	local textFontStringWidth, textFontStringHeight = self:GetTextFontStringSize()

	local resizedHeight = addonTable.Math:LimitRange(textFontStringHeight, defaults.minHeight, defaults.maxHeight)
	local resizedWidth = addonTable.Math:LimitRange(textFontStringWidth, defaults.minWidth, defaults.maxWidth)

	self:SetSize(resizedWidth, resizedHeight)
end

function ButtonFrameMetatable:GetTextFontStringSize()
	local textFontString = self:GetTextFontString()

	textFontString:ClearAllPoints()

	local width, height = textFontString:GetSize()

	width = width * 1.04 -- TODO: Certain fonts like blei00d return wrong actual size

	textFontString:SetAllPoints()

	return width, height
end

function ButtonFrameMetatable:GetTextFontStringKey()
	return "Text"
end

function ButtonFrameMetatable:GetTextFontString()
	local textFontStringKey = self:GetTextFontStringKey()

	local textFontString = self[textFontStringKey]

	if not textFontString then
		textFontString = self:CreateFontString()

		textFontString:SetFont(self:GetDefaultFont())
		textFontString:SetTextColor(self:GetDefaultTextColor())

		self[textFontStringKey] = textFontString
	end

	return textFontString
end

function ButtonFrameMetatable:GetText()
	return self:GetTextFontString():GetText()
end

function ButtonFrameMetatable:SetText(text, resizeToText)
	if text == nil then
		text = self:GetDefaults().text
	end

	self:GetTextFontString():SetText(text)

	if resizeToText then
		self:ResizeToText()
	end
end

function ButtonFrameMetatable:GetDefaultFont()
	local defaultFont = self:GetDefaults().font

	if defaultFont then
		return unpack(defaultFont)
	end

	return addonTable.Font:GetDefaultFontFamily(), 12
end

function ButtonFrameMetatable:GetDefaultTextColor()
	local defaultTextColor = self:GetDefaults().textColor

	if type(defaultTextColor) == "table" then
		if type(defaultTextColor.GetRGB) == "function" then
			return defaultTextColor:GetRGB()
		end

		return unpack(defaultTextColor)
	end

	return addonTable.Color:GetColor("yellow"):GetRGB()
end

function ButtonFrameMetatable:GetDefaultsKey()
	return "defaults"
end

function ButtonFrameMetatable:GetDefaults()
	local defaultsKey = self:GetDefaultsKey()

	if type(self[defaultsKey]) ~= "table" then
		self:SetDefaults({})
	end

	return self[defaultsKey]
end

function ButtonFrameMetatable:SetDefaults(defaults)
	if type(defaults) ~= "table" then
		return
	end

	self[self:GetDefaultsKey()] = defaults

	local textFontString = self:GetTextFontString()

	if not textFontString:GetText() then
		textFontString:SetText(defaults.text)
	end
end



local Button = {}
addonTable.Button = Button

function Button:CreateButton(options)
	if not options then
		options = {}
	end

	local name = options.name
	local parent = options.parent
	local template = options.template

	local ButtonFrame = CreateFrame("button", name, parent, template)

	addonTable.Metatable:AddObjectMetatable(ButtonFrame, ButtonFrameMetatable)

	ButtonFrame:SetDefaults({
		font = options.font,
		fontLayer = options.fontLayer,
		maxWidth = options.maxWidth,
		minWidth = options.minWidth,
		text = options.text,
		textColor = options.textColor,
	})

	return ButtonFrame
end
