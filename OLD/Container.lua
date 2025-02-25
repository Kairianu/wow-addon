local addonName, addonTable = ...

local Container = CreateFrame("Frame")
addonTable.Container = Container

function Container:IsItemOnPlayer(itemID)
	for containerIndex = Enum.BagIndex.Backpack, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		local slotCount = C_Container.GetContainerNumSlots(containerIndex)

		for slotIndex = 1, slotCount do
			local slotInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex)

			if slotInfo then
				if type(itemID) == "number" then
					if slotInfo.itemID == itemID then
						return true
					end
				elseif type(itemID) == "string" then
					if itemID:find(":$") then
						local itemHyperlink = slotInfo.hyperlink
						itemHyperlink = itemHyperlink:gsub("^\124c.*\124H", "")
						itemHyperlink = itemHyperlink:gsub("\124h.*$", "")

						if itemHyperlink:find(itemID) then
							return true
						end
					end
				end
			end
		end
	end

	return false
end
