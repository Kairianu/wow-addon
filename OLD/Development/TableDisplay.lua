local addonName, addonTable = ...


local TableDisplayFrame = CreateFrame("Frame", nil, UIParent)

TableDisplayFrame:SetClampedToScreen(true)
TableDisplayFrame:SetMovable(true)

TableDisplayFrame:Hide()
TableDisplayFrame:SetPoint("Center")
TableDisplayFrame:SetSize(500, 700)



TableDisplayFrame.Background = TableDisplayFrame:CreateTexture("Background")
TableDisplayFrame.Background:SetAllPoints()
TableDisplayFrame.Background:SetColorTexture(0, 0, 0, 0.8)



TableDisplayFrame.TopBar = CreateFrame("Frame", nil, TableDisplayFrame)
TableDisplayFrame.TopBar.MovingFrame = TableDisplayFrame
TableDisplayFrame.TopBar:SetHeight(18)
TableDisplayFrame.TopBar:SetPoint("TopLeft")
TableDisplayFrame.TopBar:SetPoint("Right")

TableDisplayFrame.TopBar:SetScript("OnMouseDown", function(self)
	self.MovingFrame:StartMoving()
end)

TableDisplayFrame.TopBar:SetScript("OnMouseUp", function(self)
	self.MovingFrame:StopMovingOrSizing()
end)

TableDisplayFrame.TopBar.Background = TableDisplayFrame.TopBar:CreateTexture("Background")
TableDisplayFrame.TopBar.Background:SetAllPoints()
TableDisplayFrame.TopBar.Background:SetColorTexture(0, 0, 0, 0.8)

TableDisplayFrame.TopBar.TitleText = TableDisplayFrame.TopBar:CreateFontString()
TableDisplayFrame.TopBar.TitleText:SetFont(addonTable.Font:GetDefaultFontFamily(), 15)
TableDisplayFrame.TopBar.TitleText:SetPoint("Left", 5, 2)
TableDisplayFrame.TopBar.TitleText:SetText("Table Display")
TableDisplayFrame.TopBar.TitleText:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

TableDisplayFrame.TopBar.CloseButton = CreateFrame("Button", nil, TableDisplayFrame.TopBar)
TableDisplayFrame.TopBar.CloseButton.HidingFrame = TableDisplayFrame
TableDisplayFrame.TopBar.CloseButton:SetPoint("TopRight")
TableDisplayFrame.TopBar.CloseButton:SetSize(15, 15)
TableDisplayFrame.TopBar.CloseButton:SetText("X")

TableDisplayFrame.TopBar.CloseButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 15)
TableDisplayFrame.TopBar.CloseButton:GetFontString():SetTextColor(addonTable.Color:GetColor("red"):GetRGB())

TableDisplayFrame.TopBar.CloseButton:SetScript("OnClick", function(self)
	self.HidingFrame:Hide()
end)




TableDisplayFrame.ContentFrame = CreateFrame("Frame", nil, TableDisplayFrame)
TableDisplayFrame.ContentFrame:SetPoint("TopLeft", TableDisplayFrame.TopBar, "BottomLeft")
TableDisplayFrame.ContentFrame:SetPoint("BottomRight")



TableDisplayFrame.TableName = CreateFrame("Button", nil, TableDisplayFrame.ContentFrame)
TableDisplayFrame.TableName:SetPoint("Top")
TableDisplayFrame.TableName:SetSize(1, 1)
TableDisplayFrame.TableName:SetText("Table Name")

TableDisplayFrame.TableName:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 18)
TableDisplayFrame.TableName:GetFontString():SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

TableDisplayFrame.TableName:SetSize(TableDisplayFrame.TableName:GetFontString():GetSize())


TableDisplayFrame.TableID = CreateFrame("Button", nil, TableDisplayFrame.ContentFrame)
TableDisplayFrame.TableID:SetPoint("Top", TableDisplayFrame.TableName, "Bottom")
TableDisplayFrame.TableID:SetSize(1, 1)
TableDisplayFrame.TableID:SetText("Table ID")

TableDisplayFrame.TableID:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), 14)
TableDisplayFrame.TableID:GetFontString():SetTextColor(addonTable.Color:GetColor("gray"):GetRGB())

TableDisplayFrame.TableID:SetSize(TableDisplayFrame.TableID:GetFontString():GetSize())



TableDisplayFrame.TableContentListContainer = CreateFrame("Frame", nil, TableDisplayFrame.ContentFrame)
TableDisplayFrame.TableContentListContainer:SetPoint("Left", 5, 0)
TableDisplayFrame.TableContentListContainer:SetPoint("BottomRight", -5, 5)
TableDisplayFrame.TableContentListContainer:SetPoint("Top", TableDisplayFrame.TableID, "Bottom", 0, -10)

TableDisplayFrame.TableContentListContainer.dataTypeOrder = {
	"userdata",
	"tables",
	"functions",
	"variables",
}

TableDisplayFrame.TableContentListContainer.dataTypeNames = {
	functions = "Functions",
	tables = "Tables",
	userdata = "User Data",
	variables = "Variables",
}

TableDisplayFrame.TableContentListContainer.listItems = {
	available = {},
	claimed = {},
}

function TableDisplayFrame.TableContentListContainer:GetListItem()
	local ListItem = table.remove(self.listItems.available)

	if not ListItem then
		ListItem = self:CreateListItem()
	end

	local PreviousListItem = self.listItems.claimed[#self.listItems.claimed]

	if PreviousListItem then
		ListItem:SetPoint("Top", PreviousListItem, "Bottom")
	else
		ListItem:SetPoint("Top")
	end

	table.insert(self.listItems.claimed, ListItem)

	ListItem:Show()

	return ListItem
end

function TableDisplayFrame.TableContentListContainer:CreateListItem()
	local ListItem = CreateFrame("Button", nil, self)
	ListItem:SetPoint("Left")
	ListItem:SetPoint("Right")
	ListItem:SetSize(1, 1)

	ListItem.fontStrings = {
		available = {},
		claimed = {},
	}

	function ListItem:GetFontString()
		local FontString = table.remove(self.fontStrings.available)

		if not FontString then
			FontString = self:CreateFontString()
		end

		table.insert(self.fontStrings.claimed, FontString)

		return FontString
	end

	function ListItem:CleanFontString(FontString)
		FontString:ClearAllPoints()
		FontString:Hide()
		FontString:SetSize(1, 1)
		FontString:SetText("")
	end

	function ListItem:ReleaseFontString(FontString)
		for i = 0, #self.fontStrings.claimed do
			if FontString == self.fontStrings.claimed[i] then
				local FontString = table.remove(self.fontStrings.claimed, i)

				self:CleanFontString(FontString)

				table.insert(self.fontStrings.available, FontString)

				return
			end
		end
	end

	function ListItem:ReleaseAllFontStrings()
		while #self.fontStrings.claimed > 0 do
			local FontString = table.remove(self.fontStrings.claimed)

			self:CleanFontString(FontString)

			table.insert(self.fontStrings.available, FontString)
		end
	end

	function ListItem:SetAsHeader(text)
		self:ReleaseAllFontStrings()

		local FontString = self:GetFontString()
		FontString:SetFont(addonTable.Font:GetDefaultFontFamily(), 16)
		FontString:SetPoint("Center")
		FontString:SetText(text)
		FontString:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

		FontString:Show()

		self:SetHeight(FontString:GetHeight())
	end

	function ListItem:SetAsKeyValue(key, value)
		self:ReleaseAllFontStrings()

		local KeyFontString = self:GetFontString()
		KeyFontString:SetFont(addonTable.Font:GetDefaultFontFamily(), 14)
		KeyFontString:SetPoint("Left")
		KeyFontString:SetText(tostring(key))
		KeyFontString:SetTextColor(addonTable.Color:GetColor("yellow"):GetRGB())

		local ValueFontString = self:GetFontString()
		ValueFontString:SetFont(KeyFontString:GetFont())
		ValueFontString:SetPoint("Left", KeyFontString, "Right", 5, 0)
		ValueFontString:SetText(tostring(value))
		ValueFontString:SetTextColor(addonTable.Color:GetColor("white"):GetRGB())

		KeyFontString:Show()
		ValueFontString:Show()

		self.keyValueElapsed = 0
		self.keyValueInterval = 3
		self:SetHeight(math.max(KeyFontString:GetHeight(), ValueFontString:GetHeight()))

		self:SetScript("OnUpdate", function(self, elapsed)
			self.keyValueElapsed = self.keyValueElapsed + elapsed

			if self.keyValueElapsed < self.keyValueInterval then
				return
			end

			self.keyValueElapsed = 0
		end)
	end

	return ListItem
end




function TableDisplayFrame.TableContentListContainer:ClearData()
	self.data = {
		functions = {},
		tables = {},
		userdata = {},
		variables = {},
	}
end

function TableDisplayFrame.TableContentListContainer:SetData(data, name)
	self:ClearData()

	if not name then
		if type(data.GetName) == "function" then
			name = data:GetName()
		else
			name = "<Anonymous>"
		end
	end

	TableDisplayFrame.TableID:SetText(tostring(data))
	TableDisplayFrame.TableName:SetText(name)

	for key, value in pairs(data) do
		local typeTableKey
		local valueType = type(value)

		if valueType == "function" then
			typeTableKey = "functions"
		elseif valueType == "table" then
			typeTableKey = "tables"
		elseif valueType == "userdata" then
			typeTableKey = "userdata"
		else
			typeTableKey = "variables"
		end

		table.insert(self.data[typeTableKey], {
			key = key,
			value = value,
		})
	end

	for _, typeData in pairs(self.data) do
		table.sort(typeData, function(left, right)
			local leftKey = left.key
			local rightKey = right.key

			if type(leftKey) ~= "number" or type(rightKey) ~= "number" then
				leftKey = tostring(leftKey)
				rightKey = tostring(rightKey)
			end

			return leftKey < rightKey
		end)
	end

	self:DisplayData()
end

function TableDisplayFrame.TableContentListContainer:GetMaxScrollValue()
	local maxScrollValue = 0

	if self.data then
		for _, typeData in pairs(self.data) do
			local typeDataSize = #typeData

			if typeDataSize > 0 then
				maxScrollValue = maxScrollValue + typeDataSize + 1
			end
		end
	end

	return maxScrollValue
end

function TableDisplayFrame.TableContentListContainer:GetScrollValue()
	local scrollValue = self.scrollValue

	if not scrollValue then
		return self:SetScrollValue(0)
	end

	return scrollValue
end

function TableDisplayFrame.TableContentListContainer:SetScrollValue(value)
	if type(value) ~= "number" then
		return
	end

	local maxScrollValue = self:GetMaxScrollValue()

	if value < 0 then
		value = 0
	elseif value > maxScrollValue then
		value = maxScrollValue
	end

	self.scrollValue = value

	return value
end

function TableDisplayFrame.TableContentListContainer:DisplayData()
	if not self.data then
		return
	end

	for _, dataTypeKey in ipairs(self.dataTypeOrder) do
		local typeData = self.data[dataTypeKey]

		if #typeData > 0 then
			self:GetListItem():SetAsHeader(self.dataTypeNames[dataTypeKey])

			for _, typeItemData in ipairs(typeData) do
				self:GetListItem():SetAsKeyValue(typeItemData.key, typeItemData.value)
			end
		end
	end
end



-- C_Timer.After(2, function()
-- 	TableDisplayFrame.TableContentListContainer:SetData(PlayerFrame)
-- end)
