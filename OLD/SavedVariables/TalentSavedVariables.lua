local addonName, addonTable = ...

local PersistentData = addonTable.PersistentData


local persistentDataAccessKey

local function GetPersistentData()
	if not persistentDataAccessKey then
		persistentDataAccessKey = PersistentData:CreateAccessKey("talent")
	end

	return PersistentData:GetAccessKeyData(persistentDataAccessKey)
end



local TalentSavedVariables = CreateFrame("Frame")
addonTable.TalentSavedVariables = TalentSavedVariables

function TalentSavedVariables:GetSpellDescription(spellID)
	local persistentData = GetPersistentData()

	local spellData = persistentData[spellID]

	if spellData then
		return spellData.normal.description, spellData.pvp.description
	end
end

function TalentSavedVariables:IsPvPItemLevelActive()
	for inventorySlotID = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local inventorySlotInfo = C_TooltipInfo.GetInventoryItem("player", inventorySlotID)

		if inventorySlotInfo then
			for _, tooltipLine in ipairs(inventorySlotInfo.lines) do
				if tooltipLine.leftText:find("^Item Level %d+") then
					if tooltipLine.leftText:find("Item Level %d+ %(%d+%)") then
						return true
					end

					break
				end
			end
		end
	end
end

function TalentSavedVariables:UpdateSpellData(spellID)
	local persistentData = GetPersistentData()

	local spellData = persistentData[spellID]

	if not spellData then
		spellData = {
			normal = {},
			pvp = {},
		}

		persistentData[spellID] = spellData
	end

	local spellDescription = GetSpellDescription(spellID)

	if spellDescription then
		if self:IsPvPItemLevelActive() then
			spellData.pvp.description = spellDescription
		else
			spellData.normal.description = spellDescription
		end
	end
end



-- local spellName, spellRank, spellIcon, spellCastTime, spellMinRange, spellMaxRange, spellID, spellOriginalIcon = GetSpellInfo(spellID)
