local addonName, addonTable = ...


local MenuButtonMetatable = {
	buttonMargin = 2,
}

function MenuButtonMetatable:AddChildButton(text)
	local MenuFrame = self.MenuFrame

	local SelectionButton = addonTable.Button:CreateButton({
		font = self:GetDefaults().font,
		parent = MenuFrame,
		text = text,
	})

	SelectionButton:ResizeToText()
	SelectionButton:SetPoint("Left")
	SelectionButton:SetPoint("Right")

	local previousChild = MenuFrame.children[#MenuFrame.children]

	if previousChild then
		SelectionButton:SetPoint("Top", previousChild, "Bottom", 0, -self.buttonMargin)
	else
		SelectionButton:SetPoint("Top")
	end

	table.insert(MenuFrame.children, SelectionButton)

	MenuFrame:ResizeToChildren()

	return SelectionButton
end

function MenuButtonMetatable:AddSelection(text, value)
	if value == nil then
		value = text
	end

	local SelectionButton = self:AddChildButton(text)

	SelectionButton.value = value

	local textFontString = SelectionButton:GetTextFontString()

	textFontString:SetJustifyH("Right")
	textFontString:SetTextColor(addonTable.Color:GetColor("white"):GetRGB())

	function SelectionButton:Select()
		self:GetTextFontString():SetTextColor(addonTable.Color:GetColor("blue"):GetRGB())
	end

	function SelectionButton:Unselect()
		self:GetTextFontString():SetTextColor(addonTable.Color:GetColor("white"):GetRGB())
	end

	SelectionButton:SetScript("OnClick", function(self)
		local selectedChild = self:GetParent():GetParent().selectedChild

		if selectedChild then
			selectedChild:Unselect()
		end

		self:Select()

		self:GetParent():GetParent():SetSelectedChild(self)
	end)

	return SelectionButton
end

function MenuButtonMetatable:AddSection(...)
	local SectionButton = self:AddChildButton(...)

	SectionButton:GetTextFontString():SetJustifyH("Left")

	return SectionButton
end

function MenuButtonMetatable:SetSelectedChild(child)
	self.selectedChild = child

	self:SetText(child:GetText())

	self:ResizeToText()

	if self.OnSelectionChange then
		self.OnSelectionChange(child.value)
	end
end


local MenuFrameMetatable = {}

function MenuFrameMetatable:ResizeToChildren()
	local resizedWidth = 0

	local childTopMax
	local childBottomMax

	for _, child in ipairs(self.children) do
		local childTextWidth, childTextHeight = child:GetTextFontStringSize()

		local _, childBottom, _, childHeight = child:GetRect()

		local childTop = childBottom + childHeight

		if not childBottomMax or childBottom < childBottomMax then
			childBottomMax = childBottom
		end

		if not childTopMax or childTop > childTopMax then
			childTopMax = childTop
		end

		if childTextWidth > resizedWidth then
			resizedWidth = childTextWidth
		end
	end

	local resizedHeight = childTopMax - childBottomMax

	self:SetSize(resizedWidth + 5, resizedHeight)
end


local DropdownMenu = {}
addonTable.DropdownMenu = DropdownMenu

function DropdownMenu:CreateDropdownMenu(options)
	if not options then
		options = {}
	end

	local font = options.font
	local name = options.name
	local OnSelectionChange = options.OnSelectionChange
	local parent = options.parent
	local text = options.text

	local DropdownMenuButton = addonTable.Button:CreateButton({
		font = font,
		name = name,
		parent = parent,
		text = text,
	})

	addonTable.Metatable:AddObjectMetatable(DropdownMenuButton, MenuButtonMetatable)

	DropdownMenuButton.OnSelectionChange = OnSelectionChange

	DropdownMenuButton:SetScript("OnClick", function(self)
		local MenuFrame = self.MenuFrame

		if MenuFrame:IsShown() then
			MenuFrame:Hide()
		else
			MenuFrame:Show()
		end
	end)

	DropdownMenuButton.MenuFrame = CreateFrame("Frame", nil, DropdownMenuButton)

	addonTable.Metatable:AddObjectMetatable(DropdownMenuButton.MenuFrame, MenuFrameMetatable)

	DropdownMenuButton.MenuFrame.children = {}

	DropdownMenuButton.MenuFrame:Hide()
	DropdownMenuButton.MenuFrame:SetPoint("TopRight", DropdownMenuButton, "BottomRight")
	DropdownMenuButton.MenuFrame:SetSize(20, 20)

	DropdownMenuButton.MenuFrame.Background = DropdownMenuButton.MenuFrame:CreateTexture("Background")
	DropdownMenuButton.MenuFrame.Background:SetAllPoints()
	DropdownMenuButton.MenuFrame.Background:SetColorTexture(0, 0, 0, 0.8)

	return DropdownMenuButton
end
