local addonName, addonData = ...


local CommandAPI = addonData.CollectionsAPI:GetCollection('command'):GetMixin('api')


local IconFrame = CreateFrame('Frame')
IconFrame:SetPoint('Top', 0, -50)
IconFrame:SetSize(50, 50)
IconFrame:SetMovable(true)

IconFrame.Texture = IconFrame:CreateTexture()
IconFrame.Texture:SetAllPoints()

IconFrame:SetScript('OnMouseDown', function(self)
	self:StartMoving()
end)

IconFrame:SetScript('OnMouseUp', function(self)
	local itemID = select(2, GetCursorInfo())

	if itemID then
		local itemIcon = GetItemIcon(itemID)

		self.Texture:SetTexture(itemIcon)

		ClearCursor()
	end

	self:StopMovingOrSizing()
end)

IconFrame:SetScript('OnMouseWheel', function(self, delta)
	local sizeOffset = 5

	if IsShiftKeyDown() then
		sizeOffset = sizeOffset * 10
	end

	local newSize = self:GetWidth() + (sizeOffset * delta)

	newSize = math.max(10, newSize)

	self:SetSize(newSize, newSize)
end)



CommandAPI:AddCommand('VIEW_ICON', function(iconIDOrName)
	if not iconIDOrName then
		IconFrame:Hide()
	end

	local iconID = tonumber(iconIDOrName)

	local texture

	if iconID then
		texture = iconID
	else
		texture = 'Interface/Icons/' .. iconIDOrName
	end

	IconFrame.Texture:SetTexture(texture)

	IconFrame:Show()
end)
