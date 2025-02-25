-- /dump GetBuildInfo()


local addonName, addonTable = ...


local TABLE_CONTAINER_TITLE_ENUM = {
	Functions = "Functions",
	Tables = "Tables",
	UserData = "User Data",
	Variables = "Variables",
}

local TABLE_CONTAINER_TITLE_ORDER = {
	TABLE_CONTAINER_TITLE_ENUM.UserData,
	TABLE_CONTAINER_TITLE_ENUM.Tables,
	TABLE_CONTAINER_TITLE_ENUM.Functions,
	TABLE_CONTAINER_TITLE_ENUM.Variables,
}



local DisplayFrame = CreateFrame("ScrollFrame", nil, UIParent)

DisplayFrame.containerFrameIndex = 1
DisplayFrame.containerFrames = {}
DisplayFrame.lineButtonIndex = 1
DisplayFrame.lineButtons = {}
DisplayFrame.maxHeight = 600
DisplayFrame.minHeight = 100
DisplayFrame.padding = 3
DisplayFrame.tableObjects = {}

DisplayFrame:SetClampedToScreen(true)
DisplayFrame:SetMovable(true)

DisplayFrame:SetScript("OnMouseDown", function(self)
	self:StartMoving()
end)

DisplayFrame:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
end)

DisplayFrame:Hide()
DisplayFrame:SetPoint("Center")
DisplayFrame:SetSize(500, 500)

DisplayFrame:SetScript("OnKeyDown", function(self, key)
	local propagateKeyboardInput = true

	if key == "ESCAPE" then
		propagateKeyboardInput = false

		self:Hide()
	end

	self:SetPropagateKeyboardInput(propagateKeyboardInput)
end)

DisplayFrame:SetScript("OnMouseWheel", function(self, delta)
	local verticalScroll = self:GetVerticalScroll() + 20 * -delta

	local minScroll = 0
	local maxScroll = self:GetVerticalScrollRange()

	if self:GetHeight() == self.maxHeight then
		maxScroll = maxScroll + self.padding
	end

	if verticalScroll < minScroll then
		verticalScroll = minScroll
	elseif verticalScroll > maxScroll then
		verticalScroll = maxScroll
	end

	self:SetVerticalScroll(verticalScroll)
end)

local ScrollChild = CreateFrame("Frame", nil, DisplayFrame)
DisplayFrame.ScrollChild = ScrollChild
DisplayFrame:SetScrollChild(ScrollChild)
ScrollChild:SetSize(DisplayFrame:GetSize())

hooksecurefunc(DisplayFrame, "SetHeight", function(self, ...)
	self:GetScrollChild():SetHeight(...)
end)

hooksecurefunc(DisplayFrame, "SetWidth", function(self, ...)
	self:GetScrollChild():SetWidth(...)
end)

hooksecurefunc(DisplayFrame, "SetSize", function(self, ...)
	self:GetScrollChild():SetSize(...)
end)

local Background = DisplayFrame:CreateTexture()
DisplayFrame.Background = Background
Background:SetAllPoints()
Background:SetColorTexture(0, 0, 0, 0.8)

local TitleButton = CreateFrame("Button", nil, DisplayFrame:GetScrollChild())
DisplayFrame.TitleButton = TitleButton

TitleButton.defaultText = "Debug Frame"

TitleButton:SetPoint("Right", -DisplayFrame.padding, 0)
TitleButton:SetPoint("TopLeft", DisplayFrame.padding, -DisplayFrame.padding)
TitleButton:SetText(TitleButton.defaultText)

local TitleButtonFontString = TitleButton:GetFontString()
TitleButtonFontString:SetFont(addonTable.Font:GetDefaultFontFamily(), 20)
TitleButtonFontString:SetJustifyH("Center")
TitleButtonFontString:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

hooksecurefunc(TitleButton, "SetText", function(self)
	self:SetSize(self:GetFontString():GetSize())
end)

TitleButton:SetText(TitleButton.defaultText)

local SecondaryTitleButton = CreateFrame("Button", nil, DisplayFrame:GetScrollChild())
DisplayFrame.SecondaryTitleButton = SecondaryTitleButton
SecondaryTitleButton:Hide()
SecondaryTitleButton:SetPoint("TopLeft", TitleButton, "BottomLeft")
SecondaryTitleButton:SetPoint("TopRight", TitleButton, "BottomRight")

SecondaryTitleButton:SetText("<TEMP_TEXT>")

local SecondaryTitleButtonFontString = SecondaryTitleButton:GetFontString()
SecondaryTitleButtonFontString:SetFont(addonTable.Font:GetDefaultFontFamily(), 14)
SecondaryTitleButtonFontString:SetJustifyH("Center")
SecondaryTitleButtonFontString:SetTextColor(addonTable.Color:GetColor("gray"):GetRGB())

SecondaryTitleButton:SetText()

function SecondaryTitleButton:SetTableStringText(tableObject)
	self:SetText("(" .. tostring(tableObject) .. ")")

	self:SetSize(self:GetFontString():GetSize())

	self:Show()

	local FirstContainerFrame = DisplayFrame.containerFrames[1]

	if FirstContainerFrame then
		FirstContainerFrame:SetPoint("Top", self, "Bottom", 0, -10)
	end
end

SecondaryTitleButton:SetScript("OnHide", function(self)
	local FirstContainerFrame = DisplayFrame.containerFrames[1]

	if FirstContainerFrame then
		FirstContainerFrame:SetPoint("Top", TitleButton, "Bottom", 0, -10)
	end
end)




function DisplayFrame:AddContainerFrame(title)
	local ContainerFrame = self:GetNewContainerFrame()

	ContainerFrame.Title:SetText(title)

	return ContainerFrame
end

function DisplayFrame:AddLineButton(ContainerFrame, key, value)
	local LineButton = self:GetNewLineButton()

	table.insert(ContainerFrame.lineButtons, LineButton)

	LineButton.key = key
	LineButton.value = value

	LineButton:SetParent(ContainerFrame)

	if #ContainerFrame.lineButtons == 1 then
		LineButton:SetPoint("Left")
		LineButton:SetPoint("Top", ContainerFrame.Title, "Bottom", 0, -3)
	else
		LineButton:SetPoint("TopLeft", ContainerFrame.lineButtons[#ContainerFrame.lineButtons - 1], "BottomLeft", 0, -2)
	end

	LineButton:SetKeyValueText()
	LineButton:Show()

	local ContainerFrameBottom, _, ContainerFrameHeight = select(2, ContainerFrame:GetRect())
	local LineButtonBottom, LineButtonWidth = select(2, LineButton:GetRect())

	local ContainerFrameTop = ContainerFrameBottom + ContainerFrameHeight

	ContainerFrame:SetHeight(ContainerFrameTop - LineButtonBottom)

	ContainerFrame:Show()

	local LineButtonTotalWidth = LineButtonWidth + (self.padding * 2)

	if LineButtonTotalWidth > self:GetWidth() then
		self:SetWidth(LineButtonTotalWidth)
	end
end

function DisplayFrame:ClearContent()
	self.tableObjects = {}

	self:ClearVisualContent()
end

function DisplayFrame:ClearVisualContent()
	for i, LineButton in ipairs(self.lineButtons) do
		LineButton:Hide()
		LineButton:ClearAllPoints()
		LineButton:SetText()
	end

	for i, ContainerFrame in ipairs(self.containerFrames) do
		ContainerFrame:Hide()
		ContainerFrame.lineButtons = {}
		ContainerFrame.Title:SetText()
	end

	self.containerFrameIndex = 1
	self.lineButtonIndex = 1

	self:SetTitle()
end

function DisplayFrame:GetNewContainerFrame()
	local ContainerFrame = self.containerFrames[self.containerFrameIndex]

	if not ContainerFrame then
		ContainerFrame = CreateFrame("Frame", nil, self:GetScrollChild())

		table.insert(self.containerFrames, ContainerFrame)

		ContainerFrame.lineButtons = {}

		ContainerFrame:Hide()
		ContainerFrame:SetHeight(0.00001)
		ContainerFrame:SetPoint("Left", self.padding, 0)
		ContainerFrame:SetPoint("Right", -self.padding, 0)

		if #self.containerFrames == 1 then
			local AnchorFrame

			if self.SecondaryTitleButton:IsShown() then
				AnchorFrame = self.SecondaryTitleButton
			else
				AnchorFrame = self.TitleButton
			end

			ContainerFrame:SetPoint("Top", AnchorFrame, "Bottom", 0, -10)
		else
			ContainerFrame:SetPoint("Top", self.containerFrames[#self.containerFrames - 1], "Bottom", 0, -10)
		end

		ContainerFrame:SetScript("OnHide", function(self)
			self:SetHeight(0.00001)
		end)

		local ContainerTitle = ContainerFrame:CreateFontString()
		ContainerFrame.Title = ContainerTitle
		ContainerTitle:SetFont(addonTable.Font:GetDefaultFontFamily(), 17)
		ContainerTitle:SetPoint("Left")
		ContainerTitle:SetPoint("Right")
		ContainerTitle:SetPoint("Top")
		ContainerTitle:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())
	end

	self.containerFrameIndex = self.containerFrameIndex + 1

	return ContainerFrame
end

function DisplayFrame:GetNewLineButton()
	local LineButton = self.lineButtons[self.lineButtonIndex]

	if not LineButton then
		LineButton = CreateFrame("Button", nil, self:GetScrollChild())

		table.insert(self.lineButtons, LineButton)

		LineButton.DisplayFrame = DisplayFrame
		LineButton.onUpdateElapsed = 0
		LineButton.onUpdateInterval = 0.5

		LineButton:SetText("<Temp Text>")
		LineButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 15)
		LineButton:SetText()

		hooksecurefunc(LineButton, "SetText", function(self)
			self:SetSize(self:GetFontString():GetSize())
		end)

		function LineButton:SetKeyValueText()
			local keyColor = "|cffffcc00"

			local valueColor = ""
			local valueType = type(self.value)

			if valueType == "function" then
				valueColor = "|cffc586c0"
			elseif valueType == "number" then
				valueColor = "|cff5ba5e3"
			elseif valueType == "string" then
				valueColor = "|cffeb7c21"
			elseif valueType == "table" then
				valueColor = "|cff4ec9b0" -- 2ea043
			end

			local text = string.format(
				"%s%s|r %s%s|r",
				keyColor,
				self.key,
				valueColor,
				tostring(self.value)
			)

			self:SetText(text)
		end

		LineButton:SetScript("OnClick", function(self)
			local valueType = type(self.value)

			if valueType == "table" then
				self.DisplayFrame:SetChildTableObject(self.value, self.key)
			end
		end)

		LineButton:SetScript("OnHide", function(self)
			self:SetHeight(0.00001)
		end)

		LineButton:SetScript("OnUpdate", function(self, elapsed)
			self.onUpdateElapsed = self.onUpdateElapsed + elapsed

			if self.onUpdateElapsed < self.onUpdateInterval then
				return
			else
				self.onUpdateElapsed = 0
			end

			local newValue = self.DisplayFrame:GetParentTable()[self.key]

			if newValue ~= self.value then
				self.value = newValue

				self:SetKeyValueText()
			end
		end)
	end

	self.lineButtonIndex = self.lineButtonIndex + 1

	return LineButton
end

function DisplayFrame:ResizeToChildren()
	local BottomContainerFrame = self.containerFrames[#self.containerFrames]

	local BottomContainerFrameBottom = select(2, BottomContainerFrame:GetRect())
	local selfBottom, _, selfHeight = select(2, self:GetRect())

	local selfTop = selfBottom + selfHeight

	local contentHeight = selfTop - BottomContainerFrameBottom + self.padding

	local height = self.minHeight

	if contentHeight > self.minHeight and contentHeight < self.maxHeight then
		height = contentHeight
	elseif contentHeight > self.maxHeight then
		height = self.maxHeight
	end

	-- self:SetHeight(height)
end

function DisplayFrame:GetParentTable()
	return self.tableObjects[#self.tableObjects]
end

function DisplayFrame:GetTableName(tableObject)
	local tableName

	if tableObject == _G then
		tableName = "_G"
	else
		local getNameSuccess, getNameArg1 = pcall(tableObject.GetName, tableObject)

		if getNameSuccess then
			tableName = getNameArg1
		end

		if not tableName then
			tableName = tostring(tableObject)
		end
	end

	return tostring(tableName)
end

function DisplayFrame:SetChildTableObject(tableObject, tableKey)
	local tableName

	for i, parentTableObject in ipairs(self.tableObjects) do
		local parentTableName = self:GetTableName(parentTableObject)

		if tableName then
			tableName = tableName .. "." .. parentTableName
		else
			tableName = parentTableName
		end
	end

	if tableName then
		tableName = tableName .. "." .. tableKey
	else
		tableName = self:GetTableName(tableObject)
	end

	self:SetTableObject(tableObject, {
		clearVisualContentOnly = true,
		tableName = tableName,
	})
end

function DisplayFrame:SetTableObject(tableObject, options)
	if type(tableObject) ~= "table" then
		return
	end

	local clearVisualContentOnly
	local filterOptions
	local tableName

	if type(options) == "table" then
		clearVisualContentOnly = options.clearVisualContentOnly
		filterOptions = options.filterOptions
		tableName = options.tableName
	end

	if clearVisualContentOnly then
		self:ClearVisualContent()
	else
		self:ClearContent()
	end

	table.insert(self.tableObjects, tableObject)

	if not tableName then
		tableName = self:GetTableName(tableObject)
	end

	self:SetTitle(tableName)

	if tableName == tostring(tableObject) then
		self.SecondaryTitleButton:Hide()
	else
		self.SecondaryTitleButton:SetTableStringText(tableObject)
	end

	local tableContainerFrames = {}

	for i, tableContainerTitle in ipairs(TABLE_CONTAINER_TITLE_ORDER) do
		tableContainerFrames[tableContainerTitle] = self:AddContainerFrame(tableContainerTitle)
	end

	local entryData = {}

	for key, value in pairs(tableObject) do
		local insertKey = true

		if filterOptions then
			if filterOptions.key then
				if not tostring(key):find(filterOptions.key) then
					insertKey = false
				end
			end

			if filterOptions.valueType then
				if type(value) ~= filterOptions.valueType then
					insertKey = false
				end
			end
		end

		if insertKey then
			table.insert(entryData, {
				key = key,
				value = value,
			})
		end
	end

	table.sort(entryData, function(left, right)
		if type(left.key) == "number" and type(right.key) == "number" then
			return left.key < right.key
		end

		return tostring(left.key) < tostring(right.key)
	end)

	for i, keyData in ipairs(entryData) do
		local ContainerFrame
		local valueType = type(keyData.value)

		if valueType == "function" then
			ContainerFrame = tableContainerFrames[TABLE_CONTAINER_TITLE_ENUM.Functions]
		elseif valueType == "table" then
			ContainerFrame = tableContainerFrames[TABLE_CONTAINER_TITLE_ENUM.Tables]
		elseif valueType == "userdata" then
			ContainerFrame = tableContainerFrames[TABLE_CONTAINER_TITLE_ENUM.UserData]
		else
			ContainerFrame = tableContainerFrames[TABLE_CONTAINER_TITLE_ENUM.Variables]
		end

		self:AddLineButton(ContainerFrame, keyData.key, keyData.value)
	end

	self:ResizeToChildren()

	self:SetVerticalScroll(0)

	self:Show()
end

function DisplayFrame:SetInheritedMethodsObject(tableObject, tableTitle)
end

function DisplayFrame:SetTitle(title)
	self.TitleButton:SetText(title or self.TitleButton.defaultText)
end










local CopyTextEditBox = CreateFrame("EditBox", nil, UIParent)
CopyTextEditBox:Hide()
CopyTextEditBox:SetFont(addonTable.Font:GetDefaultFontFamily(), 12, "")
CopyTextEditBox:SetMultiLine(true)
CopyTextEditBox:SetPoint("Center", 0, 250)
CopyTextEditBox:SetTextColor(addonTable.Color:GetColor("white"):GetRGB())
CopyTextEditBox:SetTextInsets(5, 5, 5, 5)
CopyTextEditBox:SetWidth(250)

CopyTextEditBox.Background = CopyTextEditBox:CreateTexture()
CopyTextEditBox.Background:SetAllPoints()
CopyTextEditBox.Background:SetColorTexture(0, 0, 0)

hooksecurefunc(CopyTextEditBox, "SetText", function(self, text)
	self.originalText = text

	self:Show()
	self:HighlightText()
end)

-- CopyTextEditBox:SetScript("OnShow", function(self)
-- 	self:Disable()

-- 	C_Timer.After(0.1, function()
-- 		self:Enable()
-- 	end)
-- end)

CopyTextEditBox:SetScript("OnTextChanged", function(self)
	if self:GetText() ~= self.originalText then
		self:SetText(self.originalText)
	end
end)

CopyTextEditBox:SetScript("OnEscapePressed", function(self)
	self:Hide()
end)















local C_Debug = {}
addonTable.C_Debug = C_Debug

function C_Debug:ShowTableEntries(...)
	DisplayFrame:SetTableObject(...)
end

function ShowTableEntries(...)
	C_Debug:ShowTableEntries(...)
end

function C_Debug:SetCopyText(...)
	CopyTextEditBox:SetText(...)
end

function SetCopyText(...)
	C_Debug:SetCopyText(...)
end



STE = ShowTableEntries
SCT = SetCopyText




SLASH_DEBUG_TABLE_CONTENTS1 = "/tablecontent"
SLASH_DEBUG_TABLE_CONTENTS2 = "/tc"
SlashCmdList["DEBUG_TABLE_CONTENTS"] = function(argString)
	local args = {}

	for arg in string.gmatch(argString, "[^%s]+") do
		table.insert(args, arg)
	end

	local objectString = args[1]

	if not objectString then
		DisplayFrame:Hide()

		return
	end

	local keyFilter = args[2]
	local object
	local valueTypeFilter = args[3]

	if objectString == "_G" then
		if keyFilter then
			object = _G
		end
	else
		object = _G[objectString]
	end

	ShowTableEntries(object, {
		filterOptions = {
			key = keyFilter,
			valueType = valueTypeFilter,
		},
	})
end


local FRAME_METHODS_FRAMES = {}

SLASH_FRAME_METHODS1 = "/framemethods"
SLASH_FRAME_METHODS2 = "/fm"
SlashCmdList["FRAME_METHODS"] = function(argString)
	if argString == "" then
		return
	end

	local frame = FRAME_METHODS_FRAMES[argString]

	if not frame then
		frame = CreateFrame(argString)

		FRAME_METHODS_FRAMES[argString] = frame
	end

	DisplayFrame:SetTableObject(frame, {
		tableName = argString,
	})
end



SLASH_FRAMESTACK_FS1 = "/fs"
SlashCmdList["FRAMESTACK_FS"] = SlashCmdList["FRAMESTACK"]



ScriptErrorsFrame:SetScale(UIParent:GetScale() + 0.1)





























local arrowUpTextureInfo = {
	bottom = 12,
	fileID = 4331838,
	filePath = "Interface/Buttons/MinimalScrollbarProportional.BLP",
	imageHeight = 64,
	imageWidth = 128,
	left = 89,
	right = 105,
	top = 1,
}

local function GetTextureSizeFromWidth(width, textureInfo)
	local textureWidth = textureInfo.right - textureInfo.left
	local textureHeight = textureInfo.bottom - textureInfo.top

	local textureHeightRatio = textureHeight / textureWidth

	return width, width * textureHeightRatio
end

local function SetTextureAndCoords(Texture, textureInfo, mirror)
	Texture:SetTexture(textureInfo.filePath)

	local coordBottom
	local coordLeft
	local coordRight
	local coordTop

	if mirror then
		coordBottom = textureInfo.top / textureInfo.imageHeight
		coordLeft = textureInfo.right / textureInfo.imageWidth
		coordRight = textureInfo.left / textureInfo.imageWidth
		coordTop = textureInfo.bottom / textureInfo.imageHeight
	else
		coordBottom = textureInfo.bottom / textureInfo.imageHeight
		coordLeft = textureInfo.left / textureInfo.imageWidth
		coordRight = textureInfo.right / textureInfo.imageWidth
		coordTop = textureInfo.top / textureInfo.imageHeight
	end

	Texture:SetTexCoord(coordLeft, coordRight, coordTop, coordBottom)
end






local DebugFrame = CreateFrame("ScrollFrame", nil, UIParent)
DebugFrame:SetClampedToScreen(true)
DebugFrame:SetMovable(true)
DebugFrame:SetPoint("TopLeft", 250, 0)
DebugFrame:SetSize(200, 200)

DebugFrame:Hide()

DebugFrame:SetScript("OnSizeChanged", function(self, width, height)
	width = width - self.ScrollBarContainer:GetWidth()

	self:GetScrollChild():SetSize(width, height)
end)

DebugFrame:SetScrollChild(CreateFrame("Frame", nil, DebugFrame))

DebugFrame.Background = DebugFrame:CreateTexture("Background")
DebugFrame.Background:SetAllPoints()
DebugFrame.Background:SetColorTexture(0, 0, 0, 0.4)

DebugFrame.ScrollBarContainer = CreateFrame("Frame", nil, DebugFrame)
DebugFrame.ScrollBarContainer:SetPoint("BottomRight")
DebugFrame.ScrollBarContainer:SetPoint("Top")
DebugFrame.ScrollBarContainer:SetWidth(10)

DebugFrame.ScrollBarContainer.ScrollUpButton = CreateFrame("Button", nil, DebugFrame.ScrollBarContainer)
DebugFrame.ScrollBarContainer.ScrollUpButton:SetPoint("TopRight")
DebugFrame.ScrollBarContainer.ScrollUpButton:SetPoint("Left")
DebugFrame.ScrollBarContainer.ScrollUpButton:SetSize(GetTextureSizeFromWidth(DebugFrame.ScrollBarContainer.ScrollUpButton:GetWidth(), arrowUpTextureInfo))

DebugFrame.ScrollBarContainer.ScrollUpButton.ArrowTexture = DebugFrame.ScrollBarContainer.ScrollUpButton:CreateTexture()
DebugFrame.ScrollBarContainer.ScrollUpButton.ArrowTexture:SetAllPoints()
SetTextureAndCoords(DebugFrame.ScrollBarContainer.ScrollUpButton.ArrowTexture, arrowUpTextureInfo)

DebugFrame.ScrollBarContainer.ScrollBar = CreateFrame("Button", nil, DebugFrame.ScrollBarContainer)
DebugFrame.ScrollBarContainer.ScrollBar:SetPoint("Left")
DebugFrame.ScrollBarContainer.ScrollBar:SetPoint("Right")
DebugFrame.ScrollBarContainer.ScrollBar:SetHeight(100)

DebugFrame.ScrollBarContainer.ScrollBar.BarTexture = DebugFrame.ScrollBarContainer.ScrollBar:CreateTexture()
DebugFrame.ScrollBarContainer.ScrollBar.BarTexture:SetAllPoints()
DebugFrame.ScrollBarContainer.ScrollBar.BarTexture:SetColorTexture(0, 0, 0)

DebugFrame.ScrollBarContainer.ScrollDownButton = CreateFrame("Button", nil, DebugFrame.ScrollBarContainer)
DebugFrame.ScrollBarContainer.ScrollDownButton:SetPoint("BottomRight")
DebugFrame.ScrollBarContainer.ScrollDownButton:SetPoint("Left")
DebugFrame.ScrollBarContainer.ScrollDownButton:SetSize(GetTextureSizeFromWidth(DebugFrame.ScrollBarContainer.ScrollDownButton:GetWidth(), arrowUpTextureInfo))

DebugFrame.ScrollBarContainer.ScrollDownButton.ArrowTexture = DebugFrame.ScrollBarContainer.ScrollDownButton:CreateTexture()
DebugFrame.ScrollBarContainer.ScrollDownButton.ArrowTexture:SetAllPoints()
SetTextureAndCoords(DebugFrame.ScrollBarContainer.ScrollDownButton.ArrowTexture, arrowUpTextureInfo, true)

function DebugFrame:SetObject(object)
	self.object = object
end



-- C_Timer.After(1, function()
-- 	ShowTableEntries(getmetatable(DebugFrame.ScrollBarContainer.ScrollUpButton.ArrowTexture).__index)
-- end)
