local addonName, addonData = ...


local IMPORTS = {
	character = {
		persistentData = true,
	},
}

addonData.CollectionsAPI:GetCollection("character"):AddMixin("ui", IMPORTS, function()
	local CharacterUI = CreateFrame("frame")
	CharacterUI:RegisterEvent("PLAYER_ENTERING_WORLD")
	CharacterUI:SetScript("OnEvent", function()
		IMPORTS.character.persistentData:UpdatePlayerData()
	end)


	return CharacterUI
end)













-- local slotFrames = {
-- 	CharacterHeadSlot,
-- 	CharacterNeckSlot,
-- 	CharacterShoulderSlot,
-- 	CharacterBackSlot,
-- 	CharacterChestSlot,
-- 	CharacterWristSlot,

-- 	CharacterHandsSlot,
-- 	CharacterWaistSlot,
-- 	CharacterLegsSlot,
-- 	CharacterFeetSlot,
-- 	CharacterFinger0Slot,
-- 	CharacterFinger1Slot,
-- 	CharacterTrinket0Slot,
-- 	CharacterTrinket1Slot,

-- 	CharacterMainHandSlot,
-- 	CharacterSecondaryHandSlot,
-- }

-- for _, slotFrame in ipairs(slotFrames) do
-- 	local itemLevelButton = CreateFrame("Button", nil, slotFrame)
-- 	itemLevelButton:EnableMouse(false)
-- 	itemLevelButton:SetHeight(1)
-- 	itemLevelButton:SetPoint("Bottom")
-- 	itemLevelButton:SetPoint("Left")
-- 	itemLevelButton:SetPoint("Right")

-- 	itemLevelButton:SetText("-")
-- 	itemLevelButton:GetFontString():SetFont(FontAPI:GetDefaultFontFamily(), FontAPI:GetFontSize(), "OUTLINE")
-- 	itemLevelButton:SetText("")

-- 	hooksecurefunc(itemLevelButton, "SetText", function(self)
-- 		self:SetHeight(self:GetFontString():GetHeight())
-- 	end)

-- 	C_Timer.After(2, function()
-- 		if slotFrame:GetItemLocation():IsValid() then
-- 			-- print(slotFrame:GetItemInfo())
-- 		end

-- 		local slotID = GetInventorySlotInfo(slotFrame:GetName():gsub("Character", ""))

-- 		local itemLink = GetInventoryItemLink("player", slotID)

-- 		if itemLink then
-- 			-- print(select(2, GetItemInfo(itemLink)):gsub("|", "||"))
-- 			-- print(itemLink, GetDetailedItemLevelInfo(itemLink))
-- 		end
-- 	end)
-- end



-- /run print(C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(INVSLOT_HEAD)))
-- /run STE(C_TooltipInfo.GetInventoryItem("player", INVSLOT_HEAD))
