local addonName, addonTable = ...


local function getPayloadRange(payloadArgs, startIndex, dataConvertMethod)
	startIndex = addonTable.Number:Convert(startIndex)

	local rangeData
	local rangeLength = addonTable.Number:Convert(payloadArgs[startIndex]) or 0

	if rangeLength > 0 then
		rangeData = {}

		for rangeIndex = startIndex + 1, startIndex + rangeLength do
			local rangeItem = payloadArgs[rangeIndex]

			if type(dataConvertMethod) == "function" then
				rangeItem = dataConvertMethod(rangeItem)
			end

			table.insert(rangeData, rangeItem)
		end
	end

	return rangeData, startIndex + rangeLength + 1
end

local function payloadConvert(value)
	if value == "" then
		return
	end

	return addonTable.Number:Convert(value, true)
end


local payloadMethods = {
	item = function(payloadArgs)
		local itemPayload = {}

		itemPayload.type = payloadArgs[1]
		itemPayload.itemID = payloadConvert(payloadArgs[2])
		itemPayload.enchantID = payloadConvert(payloadArgs[3])

		for gemIDIndex = 4, 7 do
			local gemID = payloadConvert(payloadArgs[gemIDIndex])

			if gemID then
				if not itemPayload.gemIDs then
					itemPayload.gemIDs = {}
				end

				table.insert(itemPayload.gemIDs, gemID)
			end
		end

		itemPayload.suffixID = payloadConvert(payloadArgs[8])
		itemPayload.uniqueID = payloadConvert(payloadArgs[9])
		itemPayload.linkLevel = payloadConvert(payloadArgs[10])
		itemPayload.specializationID = payloadConvert(payloadArgs[11])
		itemPayload.modifiersMask = payloadConvert(payloadArgs[12])
		itemPayload.itemContext = payloadConvert(payloadArgs[13])

		local rangeIndex = 14

		itemPayload.bonusIDs, rangeIndex = getPayloadRange(payloadArgs, rangeIndex, payloadConvert)
		itemPayload.modifiers, rangeIndex = getPayloadRange(payloadArgs, rangeIndex, payloadConvert)
		itemPayload.relic1BonusIDs, rangeIndex = getPayloadRange(payloadArgs, rangeIndex, payloadConvert)
		itemPayload.relic2BonusIDs, rangeIndex = getPayloadRange(payloadArgs, rangeIndex, payloadConvert)
		itemPayload.relic3BonusIDs, rangeIndex = getPayloadRange(payloadArgs, rangeIndex, payloadConvert)

		return itemPayload
	end,
}


local Hyperlink = {
	regex = "|c(........)|H(.-)|h(.-)|h|r",
}
addonTable.Hyperlink = Hyperlink

function Hyperlink:GetPayload(payloadString)
	local payloadArgs = { string.split(":", payloadString) }

	local payloadMethod = payloadMethods[payloadArgs[1]]

	if type(payloadMethod) == "function" then
		return payloadMethod(payloadArgs)
	end
end

function Hyperlink:Parse(value)
	local hexColor, payloadString, text = string.match(value, self.regex)

	local payload = self:GetPayload(payloadString)

	return {
		color = addonTable.Color:CreateColor(nil, hexColor),
		payload = payload,
		text = text,
	}
end

-- /script DEFAULT_CHAT_FRAME:AddMessage("\124cffa335ee\124Hitem:207133::::::::70::::1:9552:\124h[Silent Tormentor's Hood]\124h\124r");

function Hyperlink:GenerateItemHyperlink(itemID, options)
	if not options then
		options = {}
	end

	local itemName, originalItemHyperlink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, itemTypeID, itemSubTypeID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemID)

	if not originalItemHyperlink then
		return
	end

	local hyperlinkColorString = originalItemHyperlink:match("(\124c.+)\124H")

	local innerHyperlink = originalItemHyperlink:match("\124H(.+)\124h")

	local hyperlinkDataString = innerHyperlink:match(".+\124h")
	local hyperlinkText = innerHyperlink:match("\124h(.+)")

	local hyperlinkData = {}
	local partString = ""

	for part in hyperlinkDataString:gmatch(".") do
		if part == ":" then
			table.insert(hyperlinkData, partString)

			partString = ""
		else
			partString = partString .. part
		end
	end

	-- local hyperlinkType = options.linkType or hyperlinkData[1]
	local hyperlinkItemID = hyperlinkData[2]
	-- local hyperlinkEnchantID = options.enchantID or hyperlinkData[3]
	-- local hyperlinkGemID1 = options.gemID1 or hyperlinkData[4]
	-- local hyperlinkGemID2 = options.gemID2 or hyperlinkData[5]
	-- local hyperlinkGemID3 = options.gemID3 or hyperlinkData[6]
	-- local hyperlinkGemID4 = options.gemID4 or hyperlinkData[7]
	-- local hyperlinkSuffixID = options.suffixID or hyperlinkData[8]
	-- local hyperlinkUniqueID = options.uniqueID or hyperlinkData[9]
	local hyperlinkLinkLevel = options.linkLevel or hyperlinkData[10]
	-- local hyperlinkSpecializationID = options.specializationID or hyperlinkData[11]
	-- local hyperlinkModifiersMask = options.modifiersMask or hyperlinkData[12]
	-- local hyperlinkItemContext = options.itemContext or hyperlinkData[13]
	-- local hyperlinkNumBonusIDs = hyperlinkData[14]
	-- local hyperlinkBonusIDs = {}

	-- if options.bonusIDs then
	-- 	for _, bonusID in ipairs(options.bonusIDs) do
	-- 		table.insert(hyperlinkBonusIDs, bonusID)
	-- 	end
	-- elseif hyperlinkNumBonusIDs then
	-- 	for i = 15, tonumber(hyperlinkNumBonusIDs) + 15 do
	-- 		table.insert(hyperlinkBonusIDs, hyperlinkData[i])
	-- 	end
	-- end

	local hyperlink = string.format("item:%s::::::::%s::::", hyperlinkItemID, hyperlinkLinkLevel)

	if options.bonusIDs and #options.bonusIDs > 0 then
		hyperlink = hyperlink .. #options.bonusIDs .. ":"

		for _, bonusID in ipairs(options.bonusIDs) do
			hyperlink = hyperlink .. bonusID .. ":"
		end
	end

	return string.format(
		"%s\124H%s\124h%s\124h\124r",
		hyperlinkColorString,
		hyperlink,
		hyperlinkText
	)
end





-- C_Timer.NewTicker(3, function()
-- 	Hyperlink:Parse("|cffa335ee|Hitem:itemID:enchantID:24:71:98:49:suffixID:uniqueID:linkLevel:specializationID:modifiersMask:itemContext:3:2323:12:23233233424:3:7689:123:234:2:769867:23231121:1:12312:1:435345:crafterGUID:extraEnchantID:|h[Silent Tormentor's Hood]|h|r")
-- end)







-- appearanceID == visualID
-- modifiedAppearanceID == sourceID
-- itemInfo == itemID or itemLink or itemName

-- C_TransmogCollection.GetAllAppearanceSources(appearanceID)
-- C_TransmogCollection.GetAppearanceInfoBySource(sourceID)
-- C_TransmogCollection.GetAppearanceSourceDrops(sourceID)
-- C_TransmogCollection.GetAppearanceSourceInfo(sourceID)
-- C_TransmogCollection.GetAppearanceSources(appearanceID [, categoryType, transmogLocation])
-- C_TransmogCollection.GetItemInfo(itemInfo)
-- C_TransmogCollection.GetSourceInfo(sourceID)
-- C_TransmogCollection.GetSourceItemID(sourceID)






-- local bonusIDs = {
-- 	9552,
-- 	nil,
-- 	9568,
-- 	9581,
-- }

-- local itemIDs = {
-- 	207281,
-- 	207279,
-- 	207284,
-- 	207280,
-- 	207282,
-- 	207278,
-- 	207283,
-- 	207277,
-- 	207276,
-- }

-- local bonusIDIndex = 1

-- C_Timer.NewTicker(1, function()
-- 	DressUpFrame_Show(DressUpFrame)
-- 	DressUpFrame.ModelScene:GetPlayerActor():Undress()

-- 	local bonusID = bonusIDs[bonusIDIndex]

-- 	for _, itemID in ipairs(itemIDs) do
-- 		local hl = Hyperlink:GenerateItemHyperlink(itemID, {
-- 			bonusIDs = {bonusID},
-- 		})

-- 		local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(hl)

-- 		DressUpFrame.ModelScene:GetPlayerActor():TryOn(sourceID)
-- 	end


-- 	bonusIDIndex = bonusIDIndex + 1

-- 	if bonusIDIndex > #bonusIDs then
-- 		bonusIDIndex = 1
-- 	end
-- end)
