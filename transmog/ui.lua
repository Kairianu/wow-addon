local addonName, addonData = ...


-- TODO: Make a window to scroll through all appearance ids

-- This function takes the current collections appearances set and uses the
-- Dressing Room to try on other appearances that are next to it by appearance ID.
-- A lot of similar sets with different colors are next to each other by appearance ID.
-- Try negative and positive values starting from 1 for appearanceIDModifier.
function TryOnOffsetWardrobeSet(appearanceIDModifier)
	if not WardrobeCollectionFrame then
		return
	end

	local playerActor = DressUpFrame.ModelScene:GetPlayerActor()

	if not playerActor then
		return
	end

	appearanceIDModifier = tonumber(appearanceIDModifier) or 0

	local transmogInfoList = WardrobeCollectionFrame.SetsCollectionFrame.Model:GetItemTransmogInfoList()

	playerActor:Undress()

	for i, transmogInfo in ipairs(transmogInfoList) do
		local appearanceID = transmogInfo.appearanceID

		if appearanceID ~= 0 then
			playerActor:TryOn(appearanceID + appearanceIDModifier)
		end
	end
end





-- Outputs the visualID of the transmog appearance in the right side list at given index.
-- /dump TransmogFrame.WardrobeCollection.TabContent.ItemsFrame.PagedContent:GetElementDataByIndex(1).appearanceInfo.visualID


local transmogEquipmentSlots = {
	head = {
		index = 1,
		parentKey = 'LeftSlots',
		hiddenVisualID = 29124,
	},
	shoulderRight = {
		index = 2,
		parentKey = 'LeftSlots',
		hiddenVisualID = 24531,
	},
	shoulderLeft = {
		index = 3,
		parentKey = 'LeftSlots',
		hiddenVisualID = 24531,
	},
	back = {
		index = 4,
		parentKey = 'LeftSlots',
		hiddenVisualID = 2352,
	},
	chest = {
		index = 5,
		parentKey = 'LeftSlots',
		hiddenVisualID = 40282,
	},
	tabard = {
		index = 6,
		parentKey = 'LeftSlots',
		hiddenVisualID = 33156,
	},
	shirt = {
		index = 7,
		parentKey = 'LeftSlots',
		hiddenVisualID = 33155,
	},
	wrist = {
		index = 8,
		parentKey = 'LeftSlots',
		hiddenVisualID = 40284,
	},

	hands = {
		index = 1,
		parentKey = 'RightSlots',
		hiddenVisualID = 37207,
	},
	waist = {
		index = 2,
		parentKey = 'RightSlots',
		hiddenVisualID = 33252,
	},
	legs = {
		index = 3,
		parentKey = 'RightSlots',
		hiddenVisualID = 42568,
	},
	feet = {
		index = 4,
		parentKey = 'RightSlots',
		hiddenVisualID = 40283,
	},
}


local function GetTransmogEquipmentSlot(transmogEquipmentSlotInfo)
	local parentKey = transmogEquipmentSlotInfo.parentKey
	local slotIndex = transmogEquipmentSlotInfo.index

	return TransmogFrame.CharacterPreview[parentKey]:GetLayoutChildren()[slotIndex]
end

local function HideAllTransmogEquipmentSlots()
	local TransmogEquipmentSlot = GetTransmogEquipmentSlot(transmogEquipmentSlots.shoulderRight)

	TransmogEquipmentSlot:Click()

	local SeparateShoulderTransmogCheckbox = TransmogFrame.WardrobeCollection.TabContent.ItemsFrame.SecondaryAppearanceToggle.Checkbox

	if not SeparateShoulderTransmogCheckbox:GetChecked() then
		SeparateShoulderTransmogCheckbox:Click()
	end

	for _, transmogEquipmentSlotInfo in pairs(transmogEquipmentSlots) do
		local hiddenVisualID = transmogEquipmentSlotInfo.hiddenVisualID

		local TransmogEquipmentSlot = GetTransmogEquipmentSlot(transmogEquipmentSlotInfo)

		TransmogEquipmentSlot:Click()

		TransmogFrame.WardrobeCollection.TabContent.ItemsFrame:SelectVisual(hiddenVisualID)
	end
end


local TransmogEventFrame = CreateFrame('Frame')
TransmogEventFrame:RegisterEvent('ADDON_LOADED')
TransmogEventFrame:SetScript('OnEvent', function(self, event, loadedAddonName)
	if loadedAddonName == 'Blizzard_Transmog' then
		local HideAllTransmogSlotsButton = CreateFrame('Button', nil, TransmogFrame.CharacterPreview.Gradients, 'UIPanelButtonTemplate')
		HideAllTransmogSlotsButton:SetPoint('Right', -25, 0)
		HideAllTransmogSlotsButton:SetPoint('Center', TransmogFrame.CharacterPreview.ToggleOptions.HideIgnoredToggle.Text)
		HideAllTransmogSlotsButton:SetText('Hide All Slots')
		HideAllTransmogSlotsButton:FitToText()
		HideAllTransmogSlotsButton:SetScript('OnClick', function()
			HideAllTransmogEquipmentSlots()
		end)
	end
end)
