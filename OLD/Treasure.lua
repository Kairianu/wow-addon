local addonName, addonTable = ...


local TreasureFrame = CreateFrame("Frame", nil, UIParent)
TreasureFrame.infoTextButtonCount = 0
TreasureFrame.infoTextButtonParentKeyPrefix = "InfoTextButton"
TreasureFrame.infoTextColorDefault = addonTable.Color:GetColor("gray")
TreasureFrame.infoTextColorSelected = addonTable.Color:GetColor("white")

TreasureFrame.nearbyItemButtons = {
	available = {},
	used = {},
}

TreasureFrame.nearbyItemInfo = {
	categories = {},
}

TreasureFrame:Hide()
TreasureFrame:SetPoint("Top", UIWidgetTopCenterContainerFrame, "Bottom")

TreasureFrame.NearbyText = TreasureFrame:CreateFontString()
TreasureFrame.NearbyText:SetPoint("Center")
TreasureFrame.NearbyText:SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(2), "Outline")
TreasureFrame.NearbyText:SetText("Treasure Nearby!")
TreasureFrame.NearbyText:SetTextColor(addonTable.Color:GetColor("green"):GetRGB())

TreasureFrame:SetSize(TreasureFrame.NearbyText:GetSize())



local function NearbyItemButton_OnClick(self, button)
	local position = self.nearbyItemInfo.position

	if not position then
		return
	end

	if button == "LeftButton" then
		if C_Map.CanSetUserWaypointOnMap(position.uiMapID) then
			C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(position.uiMapID, position.x, position.y))
			C_SuperTrack.SetSuperTrackedUserWaypoint(true)
		end
	elseif button == "RightButton" then
		-- if TreasureFrame.selectedVignetteGUID == self.vignetteGUID then
		-- 	TreasureFrame.selectedVignetteGUID = nil

		-- 	self.Text:SetTextColor(TreasureFrame.infoTextColorDefault:GetRGB())

		-- 	local waypoint = C_Map.GetUserWaypoint()

		-- 	if
		-- 		waypoint.uiMapID == self.uiMapID
		-- 		and waypoint.position.x == self.position.x
		-- 		and waypoint.position.y == self.position.y
		-- 	then
		-- 		C_Map.ClearUserWaypoint()
		-- 	end
		-- end
	end
end


function TreasureFrame:CreateNearbyItemButton()
	local NearbyItemButton = CreateFrame("Button", nil, self)

	NearbyItemButton:SetSize(1, 1)

	NearbyItemButton:RegisterForClicks("AnyUp")
	NearbyItemButton:SetScript("OnClick", NearbyItemButton_OnClick)

	NearbyItemButton:SetText("-")
	NearbyItemButton:GetFontString():SetFont(addonTable.Font:GetDefaultFontFamily(), addonTable.Font:GetFontSize(0.8), "Outline")
	NearbyItemButton:GetFontString():SetTextColor(self.infoTextColorDefault:GetRGB())
	NearbyItemButton:SetText("")

	hooksecurefunc(NearbyItemButton, "SetText", function(self)
		self:SetSize(self:GetFontString():GetSize())
	end)

	return NearbyItemButton
end

function TreasureFrame:AddNearbyItemButton(nearbyItemInfo)
	local NearbyItemButton = table.remove(self.nearbyItemButtons.available)

	if not NearbyItemButton then
		NearbyItemButton = self:CreateNearbyItemButton()
	end

	local usedNearbyItemButtons = self.nearbyItemButtons.used

	local anchorFrame

	if #usedNearbyItemButtons > 0 then
		anchorFrame = usedNearbyItemButtons[#usedNearbyItemButtons]
	else
		anchorFrame = self.NearbyText
	end

	table.insert(usedNearbyItemButtons, NearbyItemButton)

	NearbyItemButton.nearbyItemInfo = nearbyItemInfo

	local text = tostring(nearbyItemInfo.text) or ""

	if nearbyItemInfo.position then
		text = string.format(
			"%s (%s, %s)",
			text,
			math.floor(nearbyItemInfo.position.x * 1000) / 10,
			math.floor(nearbyItemInfo.position.y * 1000) / 10
		)
	end

	NearbyItemButton:SetPoint("Top", anchorFrame, "Bottom")
	NearbyItemButton:SetText(text)

	if nearbyItemInfo.disabled then
		NearbyItemButton:Disable()
	end

	NearbyItemButton:Show()

	nearbyItemInfo.NearbyItemButton = NearbyItemButton
end

function TreasureFrame:ReleaseNearbyItemButton(NearbyItemButton)
	NearbyItemButton:Hide()
	NearbyItemButton:SetText("")

	NearbyItemButton.nearbyItemInfo = nil

	local usedNearbyItemButtons = self.nearbyItemButtons.used

	for i, IteratedNearbyItemButton in ipairs(usedNearbyItemButtons) do
		if IteratedNearbyItemButton == NearbyItemButton then
			table.insert(
				self.nearbyItemButtons.available,
				table.remove(usedNearbyItemButtons, i)
			)

			break
		end
	end
end

function TreasureFrame:ReleaseAllNearbyItemButtons()
	local usedNearbyItemButtons = self.nearbyItemButtons.used

	while #usedNearbyItemButtons > 0 do
		self:ReleaseNearbyItemButton(usedNearbyItemButtons[1])
	end
end

function TreasureFrame:GetNearbyItemID()
	return math.floor(math.random() * 1000000)
end

function TreasureFrame:AddNearbyItem(nearbyItemInfo)
	nearbyItemInfo.id = self:GetNearbyItemID()

	local category = nearbyItemInfo.category or "Uncategorized"

	local categories = self.nearbyItemInfo.categories

	if not addonTable.C_Table:Includes(categories, category) then
		table.insert(categories, category)

		table.sort(categories)
	end

	local categoryData = self.nearbyItemInfo[category]

	if not categoryData then
		categoryData = {}

		self.nearbyItemInfo[category] = categoryData
	end

	table.insert(categoryData, nearbyItemInfo)

	table.sort(categoryData, function(left, right)
		return left.text > right.text
	end)

	self:SortNearbyItems()

	return nearbyItemInfo.id
end

function TreasureFrame:RemoveNearbyItem(nearbyItemID)
	for _, category in ipairs(self.nearbyItemInfo.categories) do
		local categoryData = self.nearbyItemInfo[category]

		for nearbyItemInfoIndex, nearbyItemInfo in ipairs(categoryData) do
			if nearbyItemInfo.id == nearbyItemID then
				table.remove(categoryData, nearbyItemInfoIndex)

				if #categoryData == 0 then
					self.nearbyItemInfo[category] = nil

					addonTable.C_Table:RemoveValue(self.nearbyItemInfo.categories, category)
				end

				self:SortNearbyItems()

				return true
			end
		end
	end

	return false
end

function TreasureFrame:SortNearbyItems()
	self:ReleaseAllNearbyItemButtons()

	if #self.nearbyItemInfo.categories == 0 then
		self:Hide()
	else
		self:Show()
	end

	for categoryIndex, category in ipairs(self.nearbyItemInfo.categories) do
		for _, nearbyItemInfo in ipairs(self.nearbyItemInfo[category]) do
			self:AddNearbyItemButton(nearbyItemInfo)
		end
	end
end


function TreasureFrame:AddVignetteItem(vignetteGUID, vignetteName)
	local uiMapID = C_Map.GetBestMapForUnit("player")

	if not uiMapID then
		return
	end

	local mapPosition
	local vignettePosition = C_VignetteInfo.GetVignettePosition(vignetteGUID, uiMapID)

	if vignettePosition then
		mapPosition = {
			uiMapID = uiMapID,
			x = vignettePosition.x,
			y = vignettePosition.y,
		}
	end

	self:AddNearbyItem({
		category = "vignette",
		position = mapPosition,
		text = vignetteName,
		vignetteGUID = vignetteGUID,
	})
end

function TreasureFrame:RemoveVignetteItem(vignetteGUID)
	local vignetteNearbyItemInfo = self.nearbyItemInfo.vignette

	if not vignetteNearbyItemInfo then
		return
	end

	for _, vignetteInfo in ipairs(vignetteNearbyItemInfo) do
		if vignetteInfo.vignetteGUID == vignetteGUID then
			self:RemoveNearbyItem(vignetteInfo.id)

			break
		end
	end
end

function TreasureFrame:RemoveAllVignetteItems()
	self.nearbyItemInfo.vignette = nil

	addonTable.C_Table:RemoveValue(self.nearbyItemInfo.categories, "vignette")

	self:SortNearbyItems()
end







function TreasureFrame:OnUnitAura(event, unitName, unitAuraData)
	if unitName ~= "player" then
		return
	end

	local addedAuras = unitAuraData.addedAuras
	local removedAuraIDs = unitAuraData.removedAuraInstanceIDs

	if addedAuras then
		for _, auraData in ipairs(addedAuras) do
			if auraData.name == "Skyriding Glyph Resonance" then
				self.skyridingGlyphAuraID = auraData.auraInstanceID

				self.skyridingGlyphNearbyItemID = self:AddNearbyItem({
					category = "skyriding-glyph",
					text = "Nearby Skyriding Glyph",
				})
			end
		end
	elseif removedAuraIDs then
		for _, auraInstanceID in ipairs(removedAuraIDs) do
			if auraInstanceID == self.skyridingGlyphAuraID then
				self:RemoveNearbyItem(self.skyridingGlyphNearbyItemID)
			end
		end
	end
end

function TreasureFrame:OnVignette()
	self:RemoveAllVignetteItems()

	local vignetteGUIDs = C_VignetteInfo.GetVignettes()

	for i, vignetteGUID in ipairs(vignetteGUIDs) do
		local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)

		if vignetteInfo then
			if vignetteInfo.atlasName == "VignetteLoot" or vignetteInfo.atlasName == "VignetteLootElite" then
				self:AddVignetteItem(vignetteGUID, vignetteInfo.name)
			end
		end
	end
end

TreasureFrame:RegisterEvent("UNIT_AURA")
TreasureFrame:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
TreasureFrame:RegisterEvent("VIGNETTES_UPDATED")
TreasureFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "UNIT_AURA" then
		self:OnUnitAura(event, ...)
	elseif event == "VIGNETTE_MINIMAP_UPDATED" or event == "VIGNETTES_UPDATED" then
		self:OnVignette(event, ...)
	end
end)

-- C_Timer.NewTicker(2, function()
-- 	STE(TreasureFrame.nearbyItemInfo)
-- end)
